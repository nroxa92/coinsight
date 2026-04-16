import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:coinsight/services/storage_service.dart';

/// WalletService -- WalletConnect v2 via Reown AppKit
///
/// Supports MetaMask, Trust Wallet and other EVM wallets.
///
/// SECURITY: CoinSight never accesses private keys.
/// Every transaction requires explicit user approval
/// in the wallet app (MetaMask, Trust Wallet, etc.).
class WalletService extends ChangeNotifier {
  ReownAppKitModal? _appKitModal;
  bool _isInitialized = false;
  bool _isConnected = false;
  String? _connectedAddress;
  String? _connectedChainId;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  String? get connectedAddress => _connectedAddress;
  String? get connectedChainId => _connectedChainId;
  String? get error => _error;

  String get chainName {
    switch (_connectedChainId) {
      case 'eip155:1':
        return 'Ethereum';
      case 'eip155:56':
        return 'BSC';
      case 'eip155:137':
        return 'Polygon';
      case 'eip155:42161':
        return 'Arbitrum';
      case 'eip155:8453':
        return 'Base';
      default:
        return _connectedChainId ?? 'Unknown';
    }
  }

  String get shortAddress {
    if (_connectedAddress == null || _connectedAddress!.length < 10) {
      return _connectedAddress ?? '';
    }
    return '${_connectedAddress!.substring(0, 6)}'
        '...${_connectedAddress!.substring(_connectedAddress!.length - 4)}';
  }

  /// Initialize WalletConnect with stored Project ID.
  ///
  /// Requires a [BuildContext] to create the AppKit modal.
  Future<void> initialize({BuildContext? context}) async {
    final projectId = StorageService.getWalletConnectProjectId();
    if (projectId == null || projectId.isEmpty) return;
    if (context == null) return;

    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: projectId,
        metadata: const PairingMetadata(
          name: 'CoinSight',
          description: 'AI-powered crypto investment app',
          url: 'https://github.com/nroxa92/claude_coinsight',
          icons: ['https://avatars.githubusercontent.com/u/nroxa92'],
          redirect: Redirect(
            native: 'coinsight://wc',
          ),
        ),
      );

      await _appKitModal!.init();

      // Listen for session changes
      _appKitModal!.addListener(_onModalUpdate);

      // If there is an existing session, load it
      _syncSessionState();

      _isInitialized = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'WalletConnect init failed: $e';
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// Opens WalletConnect modal for wallet selection and connection
  Future<void> connectWallet(BuildContext context) async {
    if (!_isInitialized || _appKitModal == null) {
      _showProjectIdDialog(context);
      return;
    }

    try {
      await _appKitModal!.openModalView();
    } catch (e) {
      _error = 'Wallet connection failed: $e';
      notifyListeners();
    }
  }

  /// Disconnect active wallet session
  Future<void> disconnectWallet() async {
    if (_appKitModal == null) return;
    try {
      await _appKitModal!.disconnect();
    } catch (_) {}
    _isConnected = false;
    _connectedAddress = null;
    _connectedChainId = null;
    await StorageService.saveWalletAddress('');
    notifyListeners();
  }

  /// Initiate a swap transaction.
  ///
  /// IMPORTANT: Opens wallet for approval -- user MUST tap Confirm.
  /// Without user approval, the transaction does not execute.
  ///
  /// Returns transaction hash if approved, null if rejected or error.
  Future<String?> initiateSwap({
    required String toContractAddress,
    required double amountInUsdt,
    required String chainId,
  }) async {
    if (!_isConnected || _appKitModal == null) return null;

    try {
      // Convert chainId format: 'eip155:56' -> 56
      final chainIdInt = int.tryParse(chainId.split(':').last);
      if (chainIdInt == null) return null;

      // Router address per chain
      final routerAddress = _routerForChain(chainIdInt);
      if (routerAddress == null) {
        _error = 'This blockchain is not currently supported for swap.';
        notifyListeners();
        return null;
      }

      // Amount in wei (for native token)
      final amountHex =
          '0x${(amountInUsdt * 1e18).toInt().toRadixString(16)}';

      // Send transaction -- opens MetaMask/Trust Wallet for approval
      final session = _appKitModal!.session;
      final result = await _appKitModal!.request(
        topic: session?.topic ?? '',
        chainId: chainId,
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _connectedAddress,
              'to': routerAddress,
              'value': amountHex,
              'data': '0x',
            }
          ],
        ),
      );

      return result as String?;
    } catch (e) {
      _error = 'Swap failed: $e';
      notifyListeners();
      return null;
    }
  }

  // --- Private methods ---

  void _onModalUpdate() {
    _syncSessionState();
    notifyListeners();
  }

  void _syncSessionState() {
    if (_appKitModal == null) return;

    final session = _appKitModal!.session;
    final isConnected = _appKitModal!.isConnected;

    if (isConnected && session != null) {
      _isConnected = true;
      // Extract address from session
      final accounts = session.getAccounts();
      if (accounts != null && accounts.isNotEmpty) {
        // Format: 'eip155:1:0xABC...'
        final parts = accounts.first.split(':');
        if (parts.length >= 3) {
          _connectedAddress = parts.last;
          _connectedChainId = '${parts[0]}:${parts[1]}';
        }
      }
      // Save address locally for DEX position tracking
      if (_connectedAddress != null) {
        StorageService.saveWalletAddress(_connectedAddress!);
      }
    } else {
      _isConnected = false;
      _connectedAddress = null;
      _connectedChainId = null;
    }
  }

  String? _routerForChain(int chainId) {
    switch (chainId) {
      case 1:
        return '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'; // Uniswap v2
      case 56:
        return '0x10ED43C718714eb63d5aA57B78B54704E256024E'; // PancakeSwap v2
      case 137:
        return '0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff'; // QuickSwap
      default:
        return null;
    }
  }

  void _showProjectIdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Row(
          children: [
            Icon(Icons.link, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text('WalletConnect'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Za spajanje walleta trebas WalletConnect Project ID.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text('Kako ga dobiti:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            SizedBox(height: 8),
            Text(
              '1. Otvori cloud.reown.com\n'
              '2. Registriraj se (besplatno)\n'
              '3. Kreiraj projekt "CoinSight"\n'
              '4. Kopiraj Project ID\n'
              '5. Unesi ga u Settings > API',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _appKitModal?.removeListener(_onModalUpdate);
    super.dispose();
  }
}

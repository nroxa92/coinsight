import 'package:flutter/material.dart';
import 'package:coinsight/services/storage_service.dart';

/// WalletService — WalletConnect v2 integration (STUB)
///
/// This is a stub implementation that provides the same public interface
/// as the full WalletConnect integration. The actual reown_appkit package
/// requires native platform support that may not be available in all
/// environments.
///
/// To enable full WalletConnect:
/// 1. Add reown_appkit: ^1.4.5 to pubspec.yaml
/// 2. Get a Project ID from cloud.reown.com
/// 3. Replace this stub with the full implementation
///
/// SECURITY: Every transaction MUST be approved by the user in their
/// wallet app. CoinSight never signs transactions without explicit
/// user confirmation.
class WalletService extends ChangeNotifier {
  bool _isConnected = false;
  String? _connectedAddress;
  String? _connectedChainId;
  String? _error;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  String? get connectedAddress => _connectedAddress;
  String? get connectedChainId => _connectedChainId;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  /// Human-readable chain name
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

  /// Initialize WalletConnect with stored Project ID
  Future<void> initialize() async {
    final projectId = StorageService.getWalletConnectProjectId();
    if (projectId == null || projectId.isEmpty) return;

    try {
      // STUB: In full implementation, this would create a ReownAppKit instance
      // with the project ID and register event handlers.
      _isInitialized = true;

      // Check for previously saved wallet address (session persistence)
      final savedAddress = StorageService.getWalletAddress();
      if (savedAddress != null && savedAddress.isNotEmpty) {
        _isConnected = true;
        _connectedAddress = savedAddress;
        _connectedChainId = 'eip155:1'; // Default to Ethereum
      }

      notifyListeners();
    } catch (e) {
      _error = 'WalletConnect init failed: $e';
      notifyListeners();
    }
  }

  /// Opens WalletConnect modal for wallet connection
  ///
  /// STUB: Shows a dialog explaining that WalletConnect requires
  /// the reown_appkit package for full functionality.
  Future<void> connectWallet(BuildContext context) async {
    if (!_isInitialized) {
      _error =
          'WalletConnect nije inicijaliziran. Dodaj Project ID u Settings.';
      notifyListeners();
      return;
    }

    // STUB: Show info dialog instead of actual WalletConnect modal
    final result = await showDialog<bool>(
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
              'WalletConnect integracija zahtijeva reown_appkit paket '
              'koji trenutno nije aktivan.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              'Za potpunu funkcionalnost:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              '1. Registriraj se na cloud.reown.com\n'
              '2. Kreiraj projekt i kopiraj Project ID\n'
              '3. Unesi Project ID u Settings > API tab',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 12),
            Text(
              'U medjuvremenu, mozemo simulirati konekciju za testiranje UI-ja.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Zatvori'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Simuliraj konekciju'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Simulate a connection for UI testing
      _isConnected = true;
      _connectedAddress = '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18';
      _connectedChainId = 'eip155:1';
      await StorageService.saveWalletAddress(_connectedAddress!);
      notifyListeners();
    }
  }

  /// Disconnect active wallet session
  void disconnectWallet() {
    _isConnected = false;
    _connectedAddress = null;
    _connectedChainId = null;
    notifyListeners();
  }

  /// Get ETH balance via eth_getBalance
  ///
  /// STUB: Returns null (not implemented without reown_appkit)
  Future<String?> getBalance() async {
    if (!_isConnected) return null;
    // STUB: Would call eth_getBalance via appKit
    return null;
  }

  /// Initiate a swap transaction
  ///
  /// IMPORTANT: This only initiates the transaction - the user must
  /// approve it in their wallet app (MetaMask, Trust Wallet, etc.)
  ///
  /// STUB: Returns null (not implemented without reown_appkit)
  Future<String?> sendSwapTransaction({
    required String to,
    required String data,
    required String value,
  }) async {
    if (!_isConnected) return null;

    _error = 'Swap transakcije zahtijevaju reown_appkit paket. '
        'Pogledaj SESSION_11 za potpunu implementaciju.';
    notifyListeners();
    return null;
  }

  /// Initiate a DEX swap
  ///
  /// STUB: Returns null with informative error
  Future<String?> initiateSwap({
    required String fromToken,
    required String toToken,
    required double amountIn,
    required String chainId,
    required double slippagePercent,
  }) async {
    if (!_isConnected) return null;

    _error = 'DEX swap zahtijeva reown_appkit i web3dart pakete.';
    notifyListeners();
    return null;
  }

  @override
  void dispose() {
    // STUB: In full implementation, would unsubscribe from events
    // and properly clean up the appKit instance.
    super.dispose();
  }
}

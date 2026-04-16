import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/services/wallet_service.dart';

/// Compact button showing wallet connection status.
///
/// - Not connected: "Spoji Wallet" button
/// - Connected: truncated address (0xAB...CD) + green dot + chain name
///   with tap-to-disconnect option
class WalletConnectButton extends StatelessWidget {
  const WalletConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        if (!wallet.isInitialized) {
          return const SizedBox.shrink();
        }

        if (wallet.isConnected) {
          // Show truncated address
          final addr = wallet.connectedAddress ?? '';
          final shortAddr = addr.length > 10
              ? '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}'
              : addr;

          return GestureDetector(
            onTap: () => _showDisconnectDialog(context, wallet),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.green.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet,
                      size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(shortAddr,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Text('\u00b7 ${wallet.chainName}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey[500])),
                ],
              ),
            ),
          );
        }

        // Not connected
        return TextButton.icon(
          icon: const Icon(Icons.link, size: 14),
          label:
              const Text('Spoji Wallet', style: TextStyle(fontSize: 11)),
          onPressed: () => wallet.connectWallet(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.purple,
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      },
    );
  }

  void _showDisconnectDialog(
      BuildContext context, WalletService wallet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Wallet spojen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adresa: ${wallet.connectedAddress ?? ""}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Chain: ${wallet.chainName}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Zatvori'),
          ),
          TextButton(
            onPressed: () {
              wallet.disconnectWallet();
              Navigator.of(ctx).pop();
            },
            child: const Text('Disconnect',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:coinsight/models/dexscreener_signal.dart';

/// Card za prikaz DEX signala u Watchlist screenu
class DexSignalCard extends StatelessWidget {
  final DexscreenerSignal signal;
  final VoidCallback? onAnalyze;

  const DexSignalCard({
    super.key,
    required this.signal,
    this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive1h = signal.priceChange1h >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    signal.dexId.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    signal.chainId.toUpperCase(),
                    style:
                        const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
                const Spacer(),
                Text(
                  '${signal.ageHours}h ago',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Token info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${signal.baseTokenSymbol}/${signal.quoteTokenSymbol}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        signal.baseTokenName,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${signal.priceUsd.toStringAsFixed(8)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${isPositive1h ? "+" : ""}${signal.priceChange1h.toStringAsFixed(2)}% 1h',
                      style: TextStyle(
                        fontSize: 12,
                        color: isPositive1h ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stats row
            Row(
              children: [
                _stat('Vol', '\$${_formatNumber(signal.volumeUsd24h)}'),
                const SizedBox(width: 16),
                _stat('Liq', '\$${_formatNumber(signal.liquidityUsd)}'),
                const SizedBox(width: 16),
                _stat('V/L',
                    '${signal.volumeLiquidityRatio.toStringAsFixed(1)}x'),
                const Spacer(),
                TextButton.icon(
                  onPressed: onAnalyze,
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('Analiziraj',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}

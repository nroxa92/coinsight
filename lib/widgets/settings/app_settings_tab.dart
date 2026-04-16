import 'package:flutter/material.dart';

class AppSettingsTab extends StatelessWidget {
  final VoidCallback onExportLogs;
  final VoidCallback onClearLogs;
  final VoidCallback onResetAll;

  const AppSettingsTab({
    super.key,
    required this.onExportLogs,
    required this.onClearLogs,
    required this.onResetAll,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAppControlsSection(context),
        const SizedBox(height: 16),
        _buildAboutSection(context),
      ],
    );
  }

  Widget _buildAppControlsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.tune, 'App Controls'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline, size: 20),
              title: const Text('Clear analysis history'),
              subtitle: Text(
                'Remove all saved AI analysis conversations',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: onClearLogs,
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.copy_outlined, size: 20),
              title: const Text('Export logs to clipboard'),
              subtitle: Text(
                'Copy app logs for debugging',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: onExportLogs,
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.warning_amber_outlined,
                  size: 20, color: Theme.of(context).colorScheme.error),
              title: Text('Reset all settings',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
              subtitle: Text(
                'Remove all API keys, preferences and data',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              trailing: Icon(Icons.chevron_right,
                  size: 20, color: Theme.of(context).colorScheme.error),
              onTap: onResetAll,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.info_outline, 'About CoinSight'),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '2.1.0'),
            _buildInfoRow('Market Data', 'CoinGecko API'),
            _buildInfoRow('AI Analysis', 'Claude by Anthropic'),
            _buildInfoRow('Trading', 'Binance Spot'),
            _buildInfoRow('Intelligence', 'Telegram Monitor'),
            const Divider(height: 24),
            Text(
              'CoinSight provides cryptocurrency market data and AI-powered analysis. '
              'This is not financial advice. Always do your own research.',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title,
      {String? statusLabel, bool statusActive = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        if (statusLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusActive
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                color: statusActive ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

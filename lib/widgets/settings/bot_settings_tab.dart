import 'package:flutter/material.dart';
import 'package:coinsight/services/telegram_monitor.dart';
import 'package:coinsight/models/risk_parameters.dart';

class BotSettingsTab extends StatelessWidget {
  final TextEditingController monitorTokenController;
  final TextEditingController addChannelController;
  final bool monitorConfigured;
  final bool testingMonitor;
  final List<String> customChannels;
  final RiskParameters risk;
  final VoidCallback onSaveToken;
  final VoidCallback onTestMonitor;
  final VoidCallback onRemoveToken;
  final VoidCallback onAddChannel;
  final ValueChanged<String> onRemoveChannel;
  final ValueChanged<bool> onToggleMonitor;
  final VoidCallback onOpenBotManager;

  const BotSettingsTab({
    super.key,
    required this.monitorTokenController,
    required this.addChannelController,
    required this.monitorConfigured,
    required this.testingMonitor,
    required this.customChannels,
    required this.risk,
    required this.onSaveToken,
    required this.onTestMonitor,
    required this.onRemoveToken,
    required this.onAddChannel,
    required this.onRemoveChannel,
    required this.onToggleMonitor,
    required this.onOpenBotManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTelegramMonitorSection(context),
      ],
    );
  }

  Widget _buildTelegramMonitorSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
                context, Icons.satellite_alt, 'Intelligence — Telegram Monitor',
                statusLabel: monitorConfigured ? 'Configured' : 'Not set',
                statusActive: monitorConfigured),
            const SizedBox(height: 8),
            Text(
              'Kreiraj bota kod @BotFather, dodaj ga u željene javne kanale kao administratora.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: monitorTokenController,
              obscureText: true,
              onTap: () {
                if (monitorTokenController.text.startsWith('••')) {
                  monitorTokenController.clear();
                }
              },
              decoration: const InputDecoration(labelText: 'Bot Token'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSaveToken,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: testingMonitor ? null : onTestMonitor,
                    child: testingMonitor
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Test'),
                  ),
                ),
                if (monitorConfigured) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onRemoveToken,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Default kanali:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: TelegramMonitor.defaultChannels
                  .map((ch) => Chip(
                        label: Text(ch, style: const TextStyle(fontSize: 12)),
                        avatar: const Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                        backgroundColor: const Color(0xFF252525),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Dodatni kanali:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400])),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addChannelController,
                    decoration: const InputDecoration(
                      hintText: '@channel_username',
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAddChannel,
                  child: const Text('Dodaj'),
                ),
              ],
            ),
            if (customChannels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: customChannels
                    .map((ch) => Chip(
                          label:
                              Text(ch, style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFF252525),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => onRemoveChannel(ch),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.manage_accounts, size: 18),
                label: const Text('Otvori Bot Manager'),
                onPressed: onOpenBotManager,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aktiviraj monitoring'),
              subtitle: Text(
                monitorConfigured
                    ? 'Bot čita poruke iz praćenih kanala'
                    : 'Konfiguriraj bot token za aktiviranje',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              value: risk.telegramMonitorEnabled,
              onChanged: monitorConfigured ? onToggleMonitor : null,
            ),
          ],
        ),
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

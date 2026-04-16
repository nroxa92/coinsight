import 'package:flutter/material.dart';
import 'package:coinsight/models/risk_parameters.dart';

class TradeSettingsTab extends StatelessWidget {
  final RiskParameters risk;
  final TextEditingController maxTradeController;
  final bool binanceConfigured;
  final ValueChanged<RiskParameters> onRiskChanged;
  final VoidCallback onSaveRisk;
  final ValueChanged<bool> onPickHour;

  const TradeSettingsTab({
    super.key,
    required this.risk,
    required this.maxTradeController,
    required this.binanceConfigured,
    required this.onRiskChanged,
    required this.onSaveRisk,
    required this.onPickHour,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(context),
        const SizedBox(height: 16),
        _buildRiskSection(context),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.dashboard_outlined, 'Current Settings'),
            const SizedBox(height: 12),
            _infoRow('Max trade', '\$${risk.maxTradeAmountUsdt.toStringAsFixed(2)} USDT'),
            _infoRow('Open positions', '${risk.maxOpenPositions}'),
            _infoRow('Stop-loss', '${risk.stopLossPercent.toStringAsFixed(0)}%'),
            _infoRow('Take-profit', '${risk.takeProfitPercent.toStringAsFixed(0)}%'),
            _infoRow('Auto-trade', risk.autoTradeEnabled ? 'ON' : 'OFF'),
            _infoRow('Quiet hours', '${risk.quietHoursStart}:00 — ${risk.quietHoursEnd}:00'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRiskSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, Icons.shield_outlined, 'Risk Parameters'),
            const SizedBox(height: 12),
            TextField(
              controller: maxTradeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Max trade amount (USDT)',
                hintText: '10.00',
              ),
              onSubmitted: (_) => onSaveRisk(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Max open positions:'),
                const Spacer(),
                DropdownButton<int>(
                  value: risk.maxOpenPositions,
                  items: List.generate(
                      10,
                      (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          )),
                  onChanged: (v) {
                    if (v == null) return;
                    onRiskChanged(risk.copyWith(maxOpenPositions: v));
                    onSaveRisk();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Stop-loss: ${risk.stopLossPercent.toStringAsFixed(0)}%'),
            Slider(
              value: risk.stopLossPercent,
              min: 5,
              max: 30,
              divisions: 25,
              label: '${risk.stopLossPercent.toStringAsFixed(0)}%',
              onChanged: (v) =>
                  onRiskChanged(risk.copyWith(stopLossPercent: v)),
              onChangeEnd: (_) => onSaveRisk(),
            ),
            Text('Take-profit: ${risk.takeProfitPercent.toStringAsFixed(0)}%'),
            Slider(
              value: risk.takeProfitPercent,
              min: 10,
              max: 100,
              divisions: 90,
              label: '${risk.takeProfitPercent.toStringAsFixed(0)}%',
              onChanged: (v) =>
                  onRiskChanged(risk.copyWith(takeProfitPercent: v)),
              onChangeEnd: (_) => onSaveRisk(),
            ),
            const Divider(height: 24),
            if (binanceConfigured)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-trade (Faza 3)'),
                subtitle: Text(
                  'Bot će automatski kupovati bez tvoje potvrde unutar gore definiranih parametara.',
                  style: TextStyle(fontSize: 11, color: Colors.orange[300]),
                ),
                value: risk.autoTradeEnabled,
                onChanged: (v) {
                  onRiskChanged(risk.copyWith(autoTradeEnabled: v));
                  onSaveRisk();
                },
              ),
            const Divider(height: 24),
            Text(
                'Quiet hours: ${risk.quietHoursStart}:00 — ${risk.quietHoursEnd}:00',
                style: const TextStyle(fontSize: 13)),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => onPickHour(true),
                    child: Text(
                        'Start: ${risk.quietHoursStart.toString().padLeft(2, '0')}:00'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => onPickHour(false),
                    child: Text(
                        'End: ${risk.quietHoursEnd.toString().padLeft(2, '0')}:00'),
                  ),
                ),
              ],
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

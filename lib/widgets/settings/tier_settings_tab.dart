import 'package:flutter/material.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/services/storage_service.dart';

class TierSettingsTab extends StatefulWidget {
  const TierSettingsTab({super.key});

  @override
  State<TierSettingsTab> createState() => _TierSettingsTabState();
}

class _TierSettingsTabState extends State<TierSettingsTab> {
  // SHORT params (read-only here, managed by Trade tab)
  late double _shortMaxTrade;
  late double _shortStopLoss;
  late double _shortTakeProfit;

  // MID params
  double _midMaxPositionUsdt = 500;
  int _midMaxProjects = 10;
  double _midStopLossPercent = 15;
  double _midTargetReturnPercent = 50;

  // LONG params
  double _longMaxHoldingPercent = 20;
  int _longMaxHoldings = 5;
  double _longDcaTriggerPercent = 10;

  bool _shortExpanded = true;
  bool _midExpanded = false;
  bool _longExpanded = false;

  @override
  void initState() {
    super.initState();
    final risk = StorageService.getRiskParameters();
    _shortMaxTrade = risk.maxTradeAmountUsdt;
    _shortStopLoss = risk.stopLossPercent;
    _shortTakeProfit = risk.takeProfitPercent;

    _loadTierParams();
  }

  void _loadTierParams() {
    final box = StorageService.getTierRiskParameters();
    _midMaxPositionUsdt = (box['mid_max_position_usdt'] as num?)?.toDouble() ?? 500;
    _midMaxProjects = (box['mid_max_projects'] as num?)?.toInt() ?? 10;
    _midStopLossPercent = (box['mid_stop_loss_percent'] as num?)?.toDouble() ?? 15;
    _midTargetReturnPercent = (box['mid_target_return_percent'] as num?)?.toDouble() ?? 50;
    _longMaxHoldingPercent = (box['long_max_holding_percent'] as num?)?.toDouble() ?? 20;
    _longMaxHoldings = (box['long_max_holdings'] as num?)?.toInt() ?? 5;
    _longDcaTriggerPercent = (box['long_dca_trigger_percent'] as num?)?.toDouble() ?? 10;
  }

  Future<void> _saveTierParams() async {
    final params = {
      'mid_max_position_usdt': _midMaxPositionUsdt,
      'mid_max_projects': _midMaxProjects,
      'mid_stop_loss_percent': _midStopLossPercent,
      'mid_target_return_percent': _midTargetReturnPercent,
      'long_max_holding_percent': _longMaxHoldingPercent,
      'long_max_holdings': _longMaxHoldings,
      'long_dca_trigger_percent': _longDcaTriggerPercent,
    };
    await StorageService.saveTierRiskParameters(params);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tier postavke spremljene')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShortSection(),
        const SizedBox(height: 8),
        _buildMidSection(),
        const SizedBox(height: 8),
        _buildLongSection(),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _saveTierParams,
          icon: const Icon(Icons.save, size: 18),
          label: const Text('Spremi tier postavke'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildShortSection() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: _shortExpanded,
        onExpansionChanged: (v) => setState(() => _shortExpanded = v),
        leading: Text(InvestmentTier.short.emoji,
            style: const TextStyle(fontSize: 18)),
        title: Text('SHORT',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: InvestmentTier.short.color)),
        subtitle: Text(InvestmentTier.short.description,
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _paramRow('Max Trade (USDT)',
                    '\$${_shortMaxTrade.toStringAsFixed(0)}'),
                _paramRow('Stop Loss',
                    '${_shortStopLoss.toStringAsFixed(0)}%'),
                _paramRow('Take Profit',
                    '${_shortTakeProfit.toStringAsFixed(0)}%'),
                const SizedBox(height: 8),
                Text(
                  'SHORT parametre mijenjaj u Trade tabu.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMidSection() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: _midExpanded,
        onExpansionChanged: (v) => setState(() => _midExpanded = v),
        leading: Text(InvestmentTier.mid.emoji,
            style: const TextStyle(fontSize: 18)),
        title: Text('MID',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: InvestmentTier.mid.color)),
        subtitle: Text(InvestmentTier.mid.description,
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _sliderParam(
                  'Max Position (USDT)',
                  _midMaxPositionUsdt,
                  100, 5000,
                  '\$${_midMaxPositionUsdt.toStringAsFixed(0)}',
                  (v) => setState(() => _midMaxPositionUsdt = v),
                  color: InvestmentTier.mid.color,
                ),
                _sliderParam(
                  'Max projekata',
                  _midMaxProjects.toDouble(),
                  1, 30,
                  '$_midMaxProjects',
                  (v) => setState(() => _midMaxProjects = v.round()),
                  color: InvestmentTier.mid.color,
                  divisions: 29,
                ),
                _sliderParam(
                  'Stop-Loss %',
                  _midStopLossPercent,
                  5, 50,
                  '${_midStopLossPercent.toStringAsFixed(0)}%',
                  (v) => setState(() => _midStopLossPercent = v),
                  color: InvestmentTier.mid.color,
                ),
                _sliderParam(
                  'Target Return %',
                  _midTargetReturnPercent,
                  10, 200,
                  '${_midTargetReturnPercent.toStringAsFixed(0)}%',
                  (v) => setState(() => _midTargetReturnPercent = v),
                  color: InvestmentTier.mid.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongSection() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: _longExpanded,
        onExpansionChanged: (v) => setState(() => _longExpanded = v),
        leading: Text(InvestmentTier.long.emoji,
            style: const TextStyle(fontSize: 18)),
        title: Text('LONG',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: InvestmentTier.long.color)),
        subtitle: Text(InvestmentTier.long.description,
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _sliderParam(
                  'Max Holding % portfolia',
                  _longMaxHoldingPercent,
                  5, 50,
                  '${_longMaxHoldingPercent.toStringAsFixed(0)}%',
                  (v) => setState(() => _longMaxHoldingPercent = v),
                  color: InvestmentTier.long.color,
                ),
                _sliderParam(
                  'Max holdinga',
                  _longMaxHoldings.toDouble(),
                  1, 20,
                  '$_longMaxHoldings',
                  (v) => setState(() => _longMaxHoldings = v.round()),
                  color: InvestmentTier.long.color,
                  divisions: 19,
                ),
                _sliderParam(
                  'DCA Trigger %',
                  _longDcaTriggerPercent,
                  5, 30,
                  '${_longDcaTriggerPercent.toStringAsFixed(0)}%',
                  (v) => setState(() => _longDcaTriggerPercent = v),
                  color: InvestmentTier.long.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paramRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sliderParam(
    String label,
    double value,
    double min,
    double max,
    String displayValue,
    ValueChanged<double> onChanged, {
    Color color = Colors.blue,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            Text(displayValue,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            inactiveTrackColor: Colors.grey[800],
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

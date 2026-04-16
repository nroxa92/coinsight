import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/portfolio_provider.dart';
import 'package:coinsight/models/risk_parameters.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/telegram_monitor.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;

  final _binanceKeyController = TextEditingController();
  final _binanceSecretController = TextEditingController();
  bool _obscureBinanceKey = true;
  bool _obscureBinanceSecret = true;
  bool _binanceTestnet = true;
  bool _binanceConfigured = false;
  bool _testingBinance = false;

  late RiskParameters _risk;
  final _maxTradeController = TextEditingController();

  final _monitorTokenController = TextEditingController();
  final _addChannelController = TextEditingController();
  bool _monitorConfigured = false;
  bool _testingMonitor = false;
  List<String> _customChannels = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<AnalysisProvider>();
    if (provider.hasApiKey) {
      _apiKeyController.text = '••••••••••••••••••••';
    }

    _binanceConfigured = StorageService.getBinanceApiKey()?.isNotEmpty ?? false;
    _binanceTestnet = StorageService.getBinanceTestnet();
    if (_binanceConfigured) {
      _binanceKeyController.text = '••••••••••••••••';
      _binanceSecretController.text = '••••••••••••••••';
    }

    _risk = StorageService.getRiskParameters();
    _maxTradeController.text = _risk.maxTradeAmountUsdt.toStringAsFixed(2);

    _monitorConfigured =
        StorageService.getTelegramMonitorToken()?.isNotEmpty ?? false;
    if (_monitorConfigured) {
      _monitorTokenController.text = '••••••••••••••••';
    }
    _customChannels = StorageService.getMonitoredChannels();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _binanceKeyController.dispose();
    _binanceSecretController.dispose();
    _maxTradeController.dispose();
    _monitorTokenController.dispose();
    _addChannelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildApiKeySection(provider),
            const SizedBox(height: 16),
            _buildBinanceSection(),
            const SizedBox(height: 16),
            _buildRiskSection(),
            const SizedBox(height: 16),
            _buildTelegramMonitorSection(),
            const SizedBox(height: 16),
            _buildAboutSection(),
          ],
        );
      },
    );
  }

  // ───────── Anthropic API Key ─────────
  Widget _buildApiKeySection(AnalysisProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.key, 'Anthropic API Key',
                statusLabel: provider.hasApiKey ? 'Active' : 'Not set',
                statusActive: provider.hasApiKey),
            const SizedBox(height: 12),
            Text(
              'Required for AI analysis. Get your key from console.anthropic.com',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              onTap: () {
                if (_apiKeyController.text.startsWith('••')) {
                  _apiKeyController.clear();
                }
              },
              decoration: InputDecoration(
                hintText: 'sk-ant-...',
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureKey ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: Colors.grey[600]),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final key = _apiKeyController.text.trim();
                      if (key.isEmpty || key.startsWith('••')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Enter a valid API key')),
                        );
                        return;
                      }
                      provider.setApiKey(key);
                      setState(() {
                        _apiKeyController.text = '••••••••••••••••••••';
                        _obscureKey = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('API key saved')),
                      );
                    },
                    child: const Text('Save Key'),
                  ),
                ),
                if (provider.hasApiKey) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _confirmRemoveKey(provider),
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
          ],
        ),
      ),
    );
  }

  // ───────── Binance ─────────
  Widget _buildBinanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.currency_bitcoin, 'Binance API',
                statusLabel: _binanceConfigured ? 'Active' : 'Not set',
                statusActive: _binanceConfigured),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️  Osiguraj da API ključ NEMA dozvolu za Withdrawal.',
                style: TextStyle(color: Colors.orange[300], fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _binanceKeyController,
              obscureText: _obscureBinanceKey,
              onTap: () {
                if (_binanceKeyController.text.startsWith('••')) {
                  _binanceKeyController.clear();
                }
              },
              decoration: InputDecoration(
                labelText: 'API Key',
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureBinanceKey
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: Colors.grey[600]),
                  onPressed: () => setState(
                      () => _obscureBinanceKey = !_obscureBinanceKey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _binanceSecretController,
              obscureText: _obscureBinanceSecret,
              onTap: () {
                if (_binanceSecretController.text.startsWith('••')) {
                  _binanceSecretController.clear();
                }
              },
              decoration: InputDecoration(
                labelText: 'API Secret',
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureBinanceSecret
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: Colors.grey[600]),
                  onPressed: () => setState(
                      () => _obscureBinanceSecret = !_obscureBinanceSecret),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Testnet mode'),
              subtitle: Text(
                _binanceTestnet
                    ? 'Paper trading — nema pravog novca'
                    : '⚠️  LIVE — pravi novac na kocki',
                style: TextStyle(
                    fontSize: 12,
                    color: _binanceTestnet
                        ? Colors.grey[500]
                        : Colors.orange),
              ),
              value: _binanceTestnet,
              onChanged: (v) async {
                if (!v) {
                  final ok = await _confirmLiveMode();
                  if (!ok) return;
                }
                await StorageService.setBinanceTestnet(v);
                if (!mounted) return;
                setState(() => _binanceTestnet = v);
                context.read<PortfolioProvider>().reloadCredentials();
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveBinance,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testingBinance ? null : _testBinance,
                    child: _testingBinance
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Test'),
                  ),
                ),
                if (_binanceConfigured) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _removeBinance,
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
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmLiveMode() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Prebaci na LIVE?'),
        content: const Text(
          'Napuštaš testnet. Sve transakcije koristit će PRAVI novac na Binance računu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm LIVE',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveBinance() async {
    final key = _binanceKeyController.text.trim();
    final secret = _binanceSecretController.text.trim();
    if (key.isEmpty || secret.isEmpty || key.startsWith('••')) {
      if (!key.startsWith('••')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unesi API key i secret')),
        );
        return;
      }
    }
    final finalKey =
        key.startsWith('••') ? StorageService.getBinanceApiKey() ?? '' : key;
    final finalSecret = secret.startsWith('••')
        ? StorageService.getBinanceSecret() ?? ''
        : secret;
    await StorageService.saveBinanceCredentials(finalKey, finalSecret);
    if (!mounted) return;
    setState(() {
      _binanceConfigured = true;
      _binanceKeyController.text = '••••••••••••••••';
      _binanceSecretController.text = '••••••••••••••••';
      _obscureBinanceKey = true;
      _obscureBinanceSecret = true;
    });
    context.read<PortfolioProvider>().reloadCredentials();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Binance credentials saved')),
    );
  }

  Future<void> _testBinance() async {
    setState(() => _testingBinance = true);
    final b = BinanceService();
    final pingOk = await b.ping();
    if (!pingOk) {
      if (!mounted) return;
      setState(() => _testingBinance = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ping failed — no connection')),
      );
      return;
    }
    try {
      final balance = await b.getUsdtBalance();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'OK — USDT balance: \$${balance.toStringAsFixed(2)} (${b.isTestnet ? 'testnet' : 'live'})')),
      );
    } on BinanceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _testingBinance = false);
    }
  }

  Future<void> _removeBinance() async {
    await StorageService.deleteBinanceCredentials();
    if (!mounted) return;
    setState(() {
      _binanceConfigured = false;
      _binanceKeyController.clear();
      _binanceSecretController.clear();
    });
    context.read<PortfolioProvider>().reloadCredentials();
  }

  // ───────── Risk Parameters ─────────
  Widget _buildRiskSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.shield_outlined, 'Risk Parameters'),
            const SizedBox(height: 12),
            TextField(
              controller: _maxTradeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Max trade amount (USDT)',
                hintText: '10.00',
              ),
              onSubmitted: (_) => _saveRisk(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Max open positions:'),
                const Spacer(),
                DropdownButton<int>(
                  value: _risk.maxOpenPositions,
                  items: List.generate(
                      10,
                      (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          )),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() =>
                        _risk = _risk.copyWith(maxOpenPositions: v));
                    _saveRisk();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Stop-loss: ${_risk.stopLossPercent.toStringAsFixed(0)}%'),
            Slider(
              value: _risk.stopLossPercent,
              min: 5,
              max: 30,
              divisions: 25,
              label: '${_risk.stopLossPercent.toStringAsFixed(0)}%',
              onChanged: (v) =>
                  setState(() => _risk = _risk.copyWith(stopLossPercent: v)),
              onChangeEnd: (_) => _saveRisk(),
            ),
            Text('Take-profit: ${_risk.takeProfitPercent.toStringAsFixed(0)}%'),
            Slider(
              value: _risk.takeProfitPercent,
              min: 10,
              max: 100,
              divisions: 90,
              label: '${_risk.takeProfitPercent.toStringAsFixed(0)}%',
              onChanged: (v) => setState(
                  () => _risk = _risk.copyWith(takeProfitPercent: v)),
              onChangeEnd: (_) => _saveRisk(),
            ),
            const Divider(height: 24),
            if (_binanceConfigured)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-trade (Faza 3)'),
                subtitle: Text(
                  'Bot će automatski kupovati bez tvoje potvrde unutar gore definiranih parametara.',
                  style: TextStyle(
                      fontSize: 11, color: Colors.orange[300]),
                ),
                value: _risk.autoTradeEnabled,
                onChanged: (v) {
                  setState(
                      () => _risk = _risk.copyWith(autoTradeEnabled: v));
                  _saveRisk();
                },
              ),
            const Divider(height: 24),
            Text('Quiet hours: ${_risk.quietHoursStart}:00 — ${_risk.quietHoursEnd}:00',
                style: const TextStyle(fontSize: 13)),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _pickHour(true),
                    child: Text(
                        'Start: ${_risk.quietHoursStart.toString().padLeft(2, '0')}:00'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _pickHour(false),
                    child: Text(
                        'End: ${_risk.quietHoursEnd.toString().padLeft(2, '0')}:00'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickHour(bool isStart) async {
    final current =
        isStart ? _risk.quietHoursStart : _risk.quietHoursEnd;
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
    );
    if (result == null) return;
    setState(() {
      _risk = isStart
          ? _risk.copyWith(quietHoursStart: result.hour)
          : _risk.copyWith(quietHoursEnd: result.hour);
    });
    _saveRisk();
  }

  Future<void> _saveRisk() async {
    final parsed = double.tryParse(_maxTradeController.text);
    if (parsed != null && parsed > 0) {
      _risk = _risk.copyWith(maxTradeAmountUsdt: parsed);
    }
    await StorageService.saveRiskParameters(_risk);
  }

  // ───────── Intelligence — Telegram Monitor ─────────
  Widget _buildTelegramMonitorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.satellite_alt, 'Intelligence — Telegram Monitor',
                statusLabel:
                    _monitorConfigured ? 'Configured' : 'Not set',
                statusActive: _monitorConfigured),
            const SizedBox(height: 8),
            Text(
              'Kreiraj bota kod @BotFather, dodaj ga u željene javne kanale kao administratora.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monitorTokenController,
              obscureText: true,
              onTap: () {
                if (_monitorTokenController.text.startsWith('••')) {
                  _monitorTokenController.clear();
                }
              },
              decoration:
                  const InputDecoration(labelText: 'Bot Token'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveMonitorToken,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testingMonitor ? null : _testMonitor,
                    child: _testingMonitor
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Test'),
                  ),
                ),
                if (_monitorConfigured) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _removeMonitorToken,
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
                    controller: _addChannelController,
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
                  onPressed: _addChannel,
                  child: const Text('Dodaj'),
                ),
              ],
            ),
            if (_customChannels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _customChannels
                    .map((ch) => Chip(
                          label:
                              Text(ch, style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFF252525),
                          deleteIcon:
                              const Icon(Icons.close, size: 14),
                          onDeleted: () => _removeChannel(ch),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aktiviraj monitoring'),
              subtitle: Text(
                _monitorConfigured
                    ? 'Bot čita poruke iz praćenih kanala'
                    : 'Konfiguriraj bot token za aktiviranje',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              value: _risk.telegramMonitorEnabled,
              onChanged: _monitorConfigured
                  ? (v) {
                      setState(() => _risk =
                          _risk.copyWith(telegramMonitorEnabled: v));
                      _saveRisk();
                      final provider = context.read<AnalysisProvider>();
                      if (v) {
                        provider.startTelegramMonitor();
                      } else {
                        provider.stopTelegramMonitor();
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMonitorToken() async {
    final tokenInput = _monitorTokenController.text.trim();
    if (tokenInput.isEmpty || tokenInput.startsWith('••')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi Bot Token')),
      );
      return;
    }
    await StorageService.saveTelegramMonitorToken(tokenInput);
    if (!mounted) return;
    setState(() {
      _monitorConfigured = true;
      _monitorTokenController.text = '••••••••••••••••';
    });
    context.read<AnalysisProvider>().startTelegramMonitor();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Telegram Monitor token saved')),
    );
  }

  Future<void> _testMonitor() async {
    setState(() => _testingMonitor = true);
    try {
      final provider = context.read<AnalysisProvider>();
      final username = await provider.testTelegramMonitor();
      if (!mounted) return;
      if (username != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OK — bot: @$username')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed — invalid token')),
        );
      }
    } finally {
      if (mounted) setState(() => _testingMonitor = false);
    }
  }

  Future<void> _removeMonitorToken() async {
    await StorageService.deleteTelegramMonitorToken();
    if (!mounted) return;
    setState(() {
      _monitorConfigured = false;
      _monitorTokenController.clear();
    });
    context.read<AnalysisProvider>().stopTelegramMonitor();
  }

  void _addChannel() {
    var channel = _addChannelController.text.trim();
    if (channel.isEmpty) return;
    if (!channel.startsWith('@')) channel = '@$channel';
    if (_customChannels.contains(channel) ||
        TelegramMonitor.defaultChannels.contains(channel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kanal već postoji')),
      );
      return;
    }
    setState(() => _customChannels.add(channel));
    _addChannelController.clear();
    StorageService.saveMonitoredChannels(_customChannels);
  }

  void _removeChannel(String channel) {
    setState(() => _customChannels.remove(channel));
    StorageService.saveMonitoredChannels(_customChannels);
  }

  // ───────── Shared widgets ─────────
  Widget _sectionHeader(IconData icon, String title,
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

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.info_outline, 'About CoinSight'),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '1.0.0'),
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

  void _confirmRemoveKey(AnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Remove API key?'),
        content: const Text(
          'You will need to re-enter your key to use AI analysis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeApiKey();
              _apiKeyController.clear();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API key removed')),
              );
            },
            child: Text(
              'Remove',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
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
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/portfolio_provider.dart';
import 'package:coinsight/models/risk_parameters.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/telegram_monitor.dart';
import 'package:coinsight/screens/bot_manager_screen.dart';
import 'package:coinsight/widgets/settings/api_settings_tab.dart';
import 'package:coinsight/widgets/settings/bot_settings_tab.dart';
import 'package:coinsight/widgets/settings/trade_settings_tab.dart';
import 'package:coinsight/widgets/settings/app_settings_tab.dart';
import 'package:coinsight/widgets/settings/tier_settings_tab.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // API tab state
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  final _binanceKeyController = TextEditingController();
  final _binanceSecretController = TextEditingController();
  bool _obscureBinanceKey = true;
  bool _obscureBinanceSecret = true;
  bool _binanceTestnet = true;
  bool _binanceConfigured = false;
  bool _testingBinance = false;
  final _githubTokenController = TextEditingController();
  bool _obscureGithubToken = true;
  bool _githubConfigured = false;
  final _walletController = TextEditingController();
  bool _walletConfigured = false;

  // Trade tab state
  late RiskParameters _risk;
  final _maxTradeController = TextEditingController();

  // Bot tab state
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

    _githubConfigured = StorageService.getGitHubToken()?.isNotEmpty ?? false;
    if (_githubConfigured) {
      _githubTokenController.text = '••••••••••••••••';
    }

    _walletConfigured = StorageService.getWalletAddress()?.isNotEmpty ?? false;
    if (_walletConfigured) {
      _walletController.text = StorageService.getWalletAddress() ?? '';
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
    _githubTokenController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'API'),
              Tab(text: 'Tiers'),
              Tab(text: 'Bot'),
              Tab(text: 'Trade'),
              Tab(text: 'App'),
            ],
          ),
          Expanded(
            child: Consumer<AnalysisProvider>(
              builder: (context, provider, _) {
                return TabBarView(
                  children: [
                    ApiSettingsTab(
                      apiKeyController: _apiKeyController,
                      obscureKey: _obscureKey,
                      onToggleObscureKey: () =>
                          setState(() => _obscureKey = !_obscureKey),
                      onSaveApiKey: () => _saveApiKey(provider),
                      onRemoveApiKey: () => _confirmRemoveKey(provider),
                      hasApiKey: provider.hasApiKey,
                      binanceKeyController: _binanceKeyController,
                      binanceSecretController: _binanceSecretController,
                      obscureBinanceKey: _obscureBinanceKey,
                      obscureBinanceSecret: _obscureBinanceSecret,
                      onToggleBinanceKey: () => setState(
                          () => _obscureBinanceKey = !_obscureBinanceKey),
                      onToggleBinanceSecret: () => setState(
                          () => _obscureBinanceSecret = !_obscureBinanceSecret),
                      binanceTestnet: _binanceTestnet,
                      binanceConfigured: _binanceConfigured,
                      testingBinance: _testingBinance,
                      onSaveBinance: _saveBinance,
                      onTestBinance: _testBinance,
                      onRemoveBinance: _removeBinance,
                      onToggleTestnet: _toggleTestnet,
                      githubTokenController: _githubTokenController,
                      obscureGithubToken: _obscureGithubToken,
                      onToggleGithubToken: () => setState(
                          () => _obscureGithubToken = !_obscureGithubToken),
                      githubConfigured: _githubConfigured,
                      onSaveGithubToken: _saveGithubToken,
                      onRemoveGithubToken: _removeGithubToken,
                      walletController: _walletController,
                      walletConfigured: _walletConfigured,
                      onSaveWallet: _saveWallet,
                      onRemoveWallet: _removeWallet,
                    ),
                    const TierSettingsTab(),
                    BotSettingsTab(
                      monitorTokenController: _monitorTokenController,
                      addChannelController: _addChannelController,
                      monitorConfigured: _monitorConfigured,
                      testingMonitor: _testingMonitor,
                      customChannels: _customChannels,
                      risk: _risk,
                      onSaveToken: _saveMonitorToken,
                      onTestMonitor: _testMonitor,
                      onRemoveToken: _removeMonitorToken,
                      onAddChannel: _addChannel,
                      onRemoveChannel: _removeChannel,
                      onToggleMonitor: _toggleMonitor,
                      onOpenBotManager: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const BotManagerScreen()),
                      ),
                    ),
                    TradeSettingsTab(
                      risk: _risk,
                      maxTradeController: _maxTradeController,
                      binanceConfigured: _binanceConfigured,
                      onRiskChanged: (r) => setState(() => _risk = r),
                      onSaveRisk: _saveRisk,
                      onPickHour: _pickHour,
                    ),
                    AppSettingsTab(
                      onExportLogs: _exportLogs,
                      onClearLogs: _confirmClearLogs,
                      onResetAll: _confirmFullReset,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────── API Key actions ─────────
  void _saveApiKey(AnalysisProvider provider) {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty || key.startsWith('••')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid API key')),
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
  }

  void _confirmRemoveKey(AnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Remove API key?'),
        content: const Text(
            'You will need to re-enter your key to use AI analysis.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.removeApiKey();
              _apiKeyController.clear();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API key removed')),
              );
            },
            child: Text('Remove',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  // ───────── Binance actions ─────────
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
                'OK — USDT: \$${balance.toStringAsFixed(2)} | ${b.isTestnet ? 'testnet' : 'live'} | Offset: ${b.serverTimeOffsetMs}ms')),
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

  Future<void> _toggleTestnet(bool v) async {
    if (!v) {
      final ok = await _confirmLiveMode();
      if (!ok) return;
    }
    await StorageService.setBinanceTestnet(v);
    if (!mounted) return;
    setState(() => _binanceTestnet = v);
    context.read<PortfolioProvider>().reloadCredentials();
  }

  Future<bool> _confirmLiveMode() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Prebaci na LIVE?'),
        content: const Text(
            'Napuštaš testnet. Sve transakcije koristit će PRAVI novac na Binance računu.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm LIVE',
                  style: TextStyle(color: Color(0xFFEF5350)))),
        ],
      ),
    );
    return result ?? false;
  }

  // ───────── GitHub Token actions ─────────
  Future<void> _saveGithubToken() async {
    final token = _githubTokenController.text.trim();
    if (token.isEmpty || token.startsWith('••')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi GitHub token')),
      );
      return;
    }
    await StorageService.saveGitHubToken(token);
    if (!mounted) return;
    setState(() {
      _githubConfigured = true;
      _githubTokenController.text = '••••••••••••••••';
      _obscureGithubToken = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GitHub token saved')),
    );
  }

  Future<void> _removeGithubToken() async {
    await StorageService.deleteGitHubToken();
    if (!mounted) return;
    setState(() {
      _githubConfigured = false;
      _githubTokenController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GitHub token removed')),
    );
  }

  // ───────── Wallet actions ─────────
  Future<void> _saveWallet() async {
    final address = _walletController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi wallet adresu')),
      );
      return;
    }
    await StorageService.saveWalletAddress(address);
    if (!mounted) return;
    setState(() => _walletConfigured = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet adresa spremljena')),
    );
  }

  Future<void> _removeWallet() async {
    await StorageService.deleteWalletAddress();
    if (!mounted) return;
    setState(() {
      _walletConfigured = false;
      _walletController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet adresa uklonjena')),
    );
  }

  // ───────── Risk actions ─────────
  Future<void> _saveRisk() async {
    final parsed = double.tryParse(_maxTradeController.text);
    if (parsed != null && parsed > 0) {
      _risk = _risk.copyWith(maxTradeAmountUsdt: parsed);
    }
    await StorageService.saveRiskParameters(_risk);
  }

  Future<void> _pickHour(bool isStart) async {
    final current = isStart ? _risk.quietHoursStart : _risk.quietHoursEnd;
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

  // ───────── Telegram Monitor actions ─────────
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                username != null ? 'OK — bot: @$username' : 'Failed — invalid token')),
      );
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

  void _toggleMonitor(bool v) {
    setState(() => _risk = _risk.copyWith(telegramMonitorEnabled: v));
    _saveRisk();
    final provider = context.read<AnalysisProvider>();
    if (v) {
      provider.startTelegramMonitor();
    } else {
      provider.stopTelegramMonitor();
    }
  }

  // ───────── App actions ─────────
  Future<void> _exportLogs() async {
    final logs = StorageService.getAnalysisLogs();
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nema logova za izvoz')),
      );
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln(
        'CoinSight Analysis Export — ${DateTime.now().toIso8601String()}');
    buffer.writeln('─' * 50);
    for (final log in logs) {
      buffer.writeln('${log.timestamp.toIso8601String()} | '
          '${log.recommendationType} | '
          '${log.coinSymbol} | '
          '\$${log.priceAtAnalysis.toStringAsFixed(6)}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${logs.length} logova kopirano u clipboard')),
    );
  }

  void _confirmClearLogs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Obriši Analysis History?'),
        content: const Text('Svi WATCH/SKIP/INTERESTING zapisi će biti obrisani.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              StorageService.clearAnalysisLogs();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analysis history obrisana')),
              );
            },
            child: Text('Obriši',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _confirmFullReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Reset svih postavki?'),
        content: const Text(
            'Ovo briše SVE: API ključeve, postavke, logove i pozicije. Ova akcija se ne može poništiti.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await StorageService.resetAll();
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sve postavke resetirane')),
              );
            },
            child: const Text('RESET',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }
}

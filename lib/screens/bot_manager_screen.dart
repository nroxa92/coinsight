import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/monitored_channel.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/telegram_monitor.dart';

class BotManagerScreen extends StatefulWidget {
  const BotManagerScreen({super.key});

  @override
  State<BotManagerScreen> createState() => _BotManagerScreenState();
}

class _BotManagerScreenState extends State<BotManagerScreen> {
  final _addChannelController = TextEditingController();
  List<MonitoredChannel> _channels = [];

  static const _recommendedChannels = [
    {'username': '@gate_io', 'name': 'Gate.io', 'desc': 'Exchange listinzi'},
    {
      'username': '@mexc_global',
      'name': 'MEXC Global',
      'desc': 'Exchange listinzi'
    },
    {'username': '@bybit_official', 'name': 'Bybit', 'desc': 'Exchange'},
    {
      'username': '@cointelegraph',
      'name': 'CoinTelegraph',
      'desc': 'Crypto vijesti'
    },
    {
      'username': '@cryptonews_official',
      'name': 'CryptoNews',
      'desc': 'Vijesti'
    },
    {'username': '@defipulse', 'name': 'DeFi Pulse', 'desc': 'DeFi signali'},
    {
      'username': '@onchaindata',
      'name': 'On-Chain Data',
      'desc': 'Whale tracking'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _addChannelController.dispose();
    super.dispose();
  }

  void _loadChannels() {
    final stored = StorageService.getMonitoredChannelsDetail();
    final customList = StorageService.getMonitoredChannels();

    // Ensure default channels exist in detail storage
    final allUsernames = stored.map((c) => c.username).toSet();
    final defaults = <MonitoredChannel>[];
    for (final ch in TelegramMonitor.defaultChannels) {
      if (!allUsernames.contains(ch)) {
        final channel = MonitoredChannel(
          username: ch,
          displayName: _displayNameFor(ch),
          isDefault: true,
        );
        StorageService.saveMonitoredChannel(channel);
        defaults.add(channel);
      }
    }

    // Ensure custom channels exist in detail storage
    for (final ch in customList) {
      if (!allUsernames.contains(ch)) {
        final channel = MonitoredChannel(
          username: ch,
          displayName: ch,
        );
        StorageService.saveMonitoredChannel(channel);
        defaults.add(channel);
      }
    }

    setState(() {
      _channels = [...stored, ...defaults];
      // Mark defaults
      _channels = _channels.map((c) {
        if (TelegramMonitor.defaultChannels.contains(c.username)) {
          return c.copyWith(isDefault: true);
        }
        return c;
      }).toList();
    });
  }

  String _displayNameFor(String username) {
    const names = {
      '@binance': 'Binance Official',
      '@kucoincom': 'KuCoin',
      '@whale_alert': 'Whale Alert',
      '@coingecko': 'CoinGecko',
      '@coinmarketcap': 'CoinMarketCap',
    };
    return names[username] ?? username;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AnalysisProvider>();
    final monitorConfigured =
        StorageService.getTelegramMonitorToken()?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Bot Manager')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusHeader(monitorConfigured, provider),
          const SizedBox(height: 16),
          _buildChannelsList(),
          const SizedBox(height: 16),
          _buildAddChannel(),
          const SizedBox(height: 16),
          _buildRecommended(),
        ],
      ),
    );
  }

  // ───────── Sekcija 1: Status Header ─────────
  Widget _buildStatusHeader(bool configured, AnalysisProvider provider) {
    final risk = StorageService.getRiskParameters();
    final active = configured && risk.telegramMonitorEnabled;
    final todaySignals = _channels.fold<int>(
        0, (sum, c) => sum + c.signalsRelevant);
    final botToken = StorageService.getTelegramMonitorToken();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Telegram Monitor',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle,
                          size: 8,
                          color: active ? Colors.green : Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        active ? 'AKTIVAN' : 'NEAKTIVAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statChip('Kanala', '${_channels.length}'),
                const SizedBox(width: 12),
                _statChip('Signala', '$todaySignals'),
              ],
            ),
            if (botToken != null && botToken.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Token: ${botToken.substring(0, 8)}...',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ───────── Sekcija 2: Aktivni kanali ─────────
  Widget _buildChannelsList() {
    if (_channels.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text('Nema praćenih kanala',
                style: TextStyle(color: Colors.grey[500])),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Praćeni kanali',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400])),
        const SizedBox(height: 8),
        ..._channels.map(_buildChannelCard),
      ],
    );
  }

  Widget _buildChannelCard(MonitoredChannel channel) {
    final lastStr = channel.lastSignal != null
        ? _timeAgo(channel.lastSignal!)
        : 'nikad';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(channel.username,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      if (channel.displayName != channel.username)
                        Text(channel.displayName,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: channel.reliabilityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    channel.reliabilityLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: channel.reliabilityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Primljeno: ${channel.signalsReceived} | Relevantno: ${channel.signalsRelevant} | Zadnji: $lastStr',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    StorageService.toggleChannelActive(
                        channel.username, !channel.isActive);
                    _loadChannels();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    channel.isActive ? 'Pauziraj' : 'Aktiviraj',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                if (!channel.isDefault) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _confirmDelete(channel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child:
                        const Text('Obriši', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Sekcija 3: Dodaj kanal ─────────
  Widget _buildAddChannel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dodaj kanal',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400])),
            const SizedBox(height: 4),
            Text('Bot mora biti administrator tog kanala',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }

  // ───────── Sekcija 4: Preporučeni kanali ─────────
  Widget _buildRecommended() {
    final trackedUsernames =
        _channels.map((c) => c.username).toSet();
    final untracked = _recommendedChannels
        .where((r) => !trackedUsernames.contains(r['username']))
        .toList();

    if (untracked.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preporučeni kanali',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400])),
        const SizedBox(height: 8),
        ...untracked.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                title: Text('${r['username']} — ${r['name']}',
                    style: const TextStyle(fontSize: 13)),
                subtitle: Text(r['desc']!,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500])),
                trailing: OutlinedButton(
                  onPressed: () => _addRecommended(
                      r['username']!, r['name']!),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Dodaj', style: TextStyle(fontSize: 11)),
                ),
              ),
            )),
      ],
    );
  }

  // ───────── Actions ─────────
  void _addChannel() {
    var channel = _addChannelController.text.trim();
    if (channel.isEmpty) return;
    if (!channel.startsWith('@')) channel = '@$channel';
    if (channel.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimalno 3 znaka')),
      );
      return;
    }
    final existing = _channels.map((c) => c.username).toSet();
    if (existing.contains(channel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kanal već postoji')),
      );
      return;
    }

    final customChannels = StorageService.getMonitoredChannels();
    customChannels.add(channel);
    StorageService.saveMonitoredChannels(customChannels);
    StorageService.saveMonitoredChannel(MonitoredChannel(
      username: channel,
      displayName: channel,
    ));
    _addChannelController.clear();
    _loadChannels();
  }

  void _addRecommended(String username, String name) {
    final customChannels = StorageService.getMonitoredChannels();
    customChannels.add(username);
    StorageService.saveMonitoredChannels(customChannels);
    StorageService.saveMonitoredChannel(MonitoredChannel(
      username: username,
      displayName: name,
    ));
    _loadChannels();
  }

  void _confirmDelete(MonitoredChannel channel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: Text('Obriši ${channel.username}?'),
        content:
            const Text('Statistike kanala će biti izgubljene.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              StorageService.removeMonitoredChannel(channel.username);
              Navigator.of(ctx).pop();
              _loadChannels();
            },
            child: Text('Obriši',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'upravo';
    if (diff.inMinutes < 60) return 'prije ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'prije ${diff.inHours}h';
    return 'prije ${diff.inDays}d';
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/theme/app_theme.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/trade_service.dart';
import 'package:coinsight/services/telegram_service.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/portfolio_provider.dart';
import 'package:coinsight/screens/watchlist_screen.dart';
import 'package:coinsight/screens/analysis_screen.dart';
import 'package:coinsight/screens/settings_screen.dart';
import 'package:coinsight/screens/portfolio_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('Storage init failed: $e');
  }
  runApp(const CoinSightApp());
}

class CoinSightApp extends StatelessWidget {
  const CoinSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: MaterialApp(
        title: 'CoinSight',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _titles = const ['Watchlist', 'Analysis', 'Portfolio', 'Settings'];

  final TradeService _tradeService = TradeService();
  final TelegramService _telegramService = TelegramService();
  Timer? _stopLossTimer;

  @override
  void initState() {
    super.initState();
    _startBackgroundServices();
  }

  void _startBackgroundServices() {
    if (_telegramService.isConfigured) {
      _telegramService.setCommandHandler(_handleTelegramCommand);
      _telegramService.startPolling();
    }
    _stopLossTimer?.cancel();
    if (BinanceService().hasCredentials) {
      _stopLossTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _tradeService.checkStopLosses(),
      );
    }
  }

  Future<void> _handleTelegramCommand(String command, String argument) async {
    // Minimal handler — proširi u budućim sesijama za /buy_/skip_/status/balance
    switch (command) {
      case 'status':
        final positions = StorageService.getPositions();
        final totalInv =
            positions.fold<double>(0, (s, p) => s + p.entryTotal);
        await _telegramService.sendMessage(
          '📊 Open positions: ${positions.length}\nInvested: \$${totalInv.toStringAsFixed(2)}',
        );
        break;
      case 'stop':
        final rp = StorageService.getRiskParameters();
        await StorageService.saveRiskParameters(
            rp.copyWith(autoTradeEnabled: false));
        await _telegramService.sendMessage('⏸  Auto-trade paused');
        break;
      case 'start':
        final rp = StorageService.getRiskParameters();
        await StorageService.saveRiskParameters(
            rp.copyWith(autoTradeEnabled: true));
        await _telegramService.sendMessage('▶  Auto-trade enabled');
        break;
      default:
        await _telegramService.sendMessage(
            'ℹ  Commands: /status /stop /start');
    }
  }

  @override
  void dispose() {
    _stopLossTimer?.cancel();
    _telegramService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          WatchlistScreen(),
          AnalysisScreen(),
          PortfolioScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

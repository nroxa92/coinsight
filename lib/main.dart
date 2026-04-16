import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/theme/app_theme.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/trade_service.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/portfolio_provider.dart';
import 'package:coinsight/models/tier_provider.dart';
import 'package:coinsight/widgets/tier_mode_selector.dart';
import 'package:coinsight/screens/watchlist_screen.dart';
import 'package:coinsight/screens/analysis_screen.dart';
import 'package:coinsight/screens/settings_screen.dart';
import 'package:coinsight/screens/portfolio_screen.dart';
import 'package:coinsight/services/dexscreener_service.dart';
import 'package:coinsight/models/dex_position.dart';
import 'package:coinsight/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('Storage init failed: $e');
  }
  await NotificationService.init();
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
        ChangeNotifierProvider(create: (_) => TierProvider()),
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
  final _titles = const ['Watchlist', 'Analysis', 'Portfolio', 'Manage'];

  final TradeService _tradeService = TradeService();
  Timer? _stopLossTimer;
  Timer? _dexPriceTimer;
  final DexscreenerService _dexService = DexscreenerService();

  @override
  void initState() {
    super.initState();
    _startBackgroundServices();
  }

  void _startBackgroundServices() {
    // Start Intelligence Monitoring (Telegram + DEX + GitHub + Reddit)
    context.read<AnalysisProvider>().startIntelligenceMonitoring();

    // Start stop-loss checker if Binance is configured
    _stopLossTimer?.cancel();
    if (BinanceService().hasCredentials) {
      _stopLossTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _tradeService.checkStopLosses(),
      );
    }

    // Start DEX position price refresh (only if positions exist)
    _dexPriceTimer?.cancel();
    if (StorageService.getDexPositions().isNotEmpty) {
      _dexPriceTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _refreshDexPrices(),
      );
    }
  }

  Future<void> _refreshDexPrices() async {
    final positions = StorageService.getDexPositions()
        .where((p) => p.status == DexPositionStatus.open)
        .toList();
    if (positions.isEmpty) return;

    for (final pos in positions) {
      try {
        final price = await _dexService.getPriceByContract(
            pos.contractAddress, pos.chainId);
        if (price == null) continue;

        final updated = pos.copyWith(currentPrice: price);
        await StorageService.saveDexPosition(updated);

        // SL alert
        if (updated.isStopLossHit) {
          await NotificationService.showStopLossAlert(
            symbol: pos.tokenSymbol,
            price: price,
            pnlPercent: updated.pnlPercent,
          );
        }
        // TP alert
        if (updated.isTakeProfitHit) {
          await NotificationService.showTakeProfitAlert(
            symbol: pos.tokenSymbol,
            price: price,
            pnlPercent: updated.pnlPercent,
          );
        }
      } catch (_) {
        continue;
      }

      // Rate limit courtesy
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _stopLossTimer?.cancel();
    _dexPriceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: Column(
        children: [
          const TierModeSelector(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                WatchlistScreen(),
                AnalysisScreen(),
                PortfolioScreen(),
                SettingsScreen(),
              ],
            ),
          ),
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
            icon: Icon(Icons.tune_outlined),
            activeIcon: Icon(Icons.tune),
            label: 'Manage',
          ),
        ],
      ),
    );
  }
}

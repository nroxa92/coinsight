import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:coinsight/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = Directory.systemTemp.createTempSync('app_nav_test');
    Hive.init(dir.path);
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
    if (!Hive.isBoxOpen('watchlist')) await Hive.openBox('watchlist');
    if (!Hive.isBoxOpen('analysis_logs')) await Hive.openBox('analysis_logs');
    if (!Hive.isBoxOpen('positions')) await Hive.openBox('positions');
    if (!Hive.isBoxOpen('monitored_channels_detail')) await Hive.openBox('monitored_channels_detail');
    if (!Hive.isBoxOpen('mid_term_projects')) await Hive.openBox('mid_term_projects');
    if (!Hive.isBoxOpen('long_term_holdings')) await Hive.openBox('long_term_holdings');
    if (!Hive.isBoxOpen('dex_positions')) await Hive.openBox('dex_positions');
    if (!Hive.isBoxOpen('closed_trades')) await Hive.openBox('closed_trades');
  });

  group('App Navigation', () {
    testWidgets('app renders with 4 bottom nav tabs', (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      expect(find.text('Watchlist'), findsWidgets);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
    });

    testWidgets('tapping Analysis tab shows API key required',
        (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Analysis'));
      await tester.pumpAndSettle();

      expect(find.text('API Key Required'), findsOneWidget);
    });

    testWidgets('tapping Manage tab shows tabbed settings',
        (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      // Tabbed layout with 5 tabs
      expect(find.text('API'), findsWidgets);
      expect(find.text('Tiers'), findsOneWidget);
      expect(find.text('Bot'), findsOneWidget);
      expect(find.text('Trade'), findsOneWidget);
      expect(find.text('App'), findsOneWidget);
    });

    testWidgets('TierModeSelector renders with 3 tier buttons',
        (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      expect(find.text('SHORT'), findsOneWidget);
      expect(find.text('MID'), findsOneWidget);
      expect(find.text('LONG'), findsOneWidget);
    });

    testWidgets('Manage tab now has 5 tabs including Tiers',
        (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(find.text('Tiers'), findsOneWidget);
    });

    testWidgets('tapping Portfolio tab shows portfolio screen',
        (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Portfolio'));
      await tester.pumpAndSettle();

      // Portfolio shows no-credentials state when Binance not configured
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsWidgets);
    });
  });
}

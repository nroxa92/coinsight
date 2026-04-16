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
  });

  group('App Navigation', () {
    testWidgets('app renders with 4 bottom nav tabs', (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      expect(find.text('Watchlist'), findsWidgets);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping Analysis tab shows API key required',
        (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Analysis'));
      await tester.pumpAndSettle();

      expect(find.text('API Key Required'), findsOneWidget);
    });

    testWidgets('tapping Settings tab shows settings sections',
        (tester) async {
      await tester.pumpWidget(const CoinSightApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Anthropic API Key'), findsOneWidget);
      expect(find.text('Binance API'), findsOneWidget);
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

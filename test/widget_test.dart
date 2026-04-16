import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:coinsight/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync('coinsight_test');
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
    if (!Hive.isBoxOpen('watchlist')) await Hive.openBox('watchlist');
    if (!Hive.isBoxOpen('analysis_logs')) await Hive.openBox('analysis_logs');
    if (!Hive.isBoxOpen('positions')) await Hive.openBox('positions');
  });

  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const CoinSightApp());
    await tester.pumpAndSettle();

    expect(find.text('Watchlist'), findsWidgets);
    expect(find.text('Analysis'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const CoinSightApp());
    await tester.pumpAndSettle();

    // Tap Analysis tab
    await tester.tap(find.text('Analysis'));
    await tester.pumpAndSettle();
    expect(find.text('API Key Required'), findsOneWidget);

    // Tap Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Anthropic API Key'), findsOneWidget);
    expect(find.text('Binance API'), findsOneWidget);
  });
}

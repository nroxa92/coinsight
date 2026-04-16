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
    if (!Hive.isBoxOpen('monitored_channels_detail')) await Hive.openBox('monitored_channels_detail');
    if (!Hive.isBoxOpen('mid_term_projects')) await Hive.openBox('mid_term_projects');
    if (!Hive.isBoxOpen('long_term_holdings')) await Hive.openBox('long_term_holdings');
    if (!Hive.isBoxOpen('dex_positions')) await Hive.openBox('dex_positions');
    if (!Hive.isBoxOpen('closed_trades')) await Hive.openBox('closed_trades');
  });

  testWidgets('App renders with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const CoinSightApp());
    await tester.pumpAndSettle();

    expect(find.text('Watchlist'), findsWidgets);
    expect(find.text('Analysis'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const CoinSightApp());
    await tester.pumpAndSettle();

    // Tap Analysis tab
    await tester.tap(find.text('Analysis'));
    await tester.pumpAndSettle();
    expect(find.text('API Key Required'), findsOneWidget);

    // Tap Manage tab
    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();
    // Settings now uses tabs - check that API tab content is visible
    expect(find.text('API'), findsWidgets);
  });
}

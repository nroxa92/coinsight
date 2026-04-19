import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/tier_provider.dart';
import 'package:coinsight/widgets/tier_mode_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/hive_test_setup.dart';

void main() {
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  testWidgets('renders all three tier labels via TierProvider', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: ChangeNotifierProvider<TierProvider>(
          create: (_) => TierProvider(),
          child: const TierModeSelector(),
        ),
      ),
    ));

    expect(find.text('SHORT'), findsOneWidget);
    expect(find.text('MID'), findsOneWidget);
    expect(find.text('LONG'), findsOneWidget);
    expect(find.byType(TierModeSelector), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

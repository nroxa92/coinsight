import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/widgets/coin_card.dart';
import '../helpers/test_fixtures.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('CoinCard', () {
    testWidgets('displays coin name and symbol', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CoinCard(
          coin: TestFixtures.btcCoin(),
          isWatchlisted: false,
          onToggleWatchlist: () {},
        ),
      ));

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
    });

    testWidgets('star icon is filled when isWatchlisted is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CoinCard(
          coin: TestFixtures.btcCoin(),
          isWatchlisted: true,
          onToggleWatchlist: () {},
        ),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('star icon is unfilled when isWatchlisted is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CoinCard(
          coin: TestFixtures.btcCoin(),
          isWatchlisted: false,
          onToggleWatchlist: () {},
        ),
      ));

      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('onToggleWatchlist callback fires on star tap',
        (tester) async {
      var toggled = false;
      await tester.pumpWidget(buildTestWidget(
        CoinCard(
          coin: TestFixtures.btcCoin(),
          isWatchlisted: false,
          onToggleWatchlist: () => toggled = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.star_border));
      expect(toggled, true);
    });

    testWidgets('CoinCardSkeleton renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CoinCardSkeleton(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CoinCardSkeleton), findsOneWidget);
    });
  });
}

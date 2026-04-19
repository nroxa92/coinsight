import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/price_chart_data.dart';
import 'package:coinsight/widgets/price_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: SizedBox(width: 400, child: child)),
      );

  PriceChartData buildData({
    InvestmentTier tier = InvestmentTier.short,
    List<PricePoint>? historical,
    List<PricePoint>? prediction,
  }) {
    final now = DateTime(2026, 4, 15);
    return PriceChartData(
      symbol: 'PEPE',
      tier: tier,
      historical: historical ??
          List.generate(
            5,
            (i) => PricePoint(
              timestamp: now.subtract(Duration(days: 4 - i)),
              price: 1.0 + i * 0.1,
            ),
          ),
      prediction: prediction ??
          List.generate(
            3,
            (i) => PricePoint(
              timestamp: now.add(Duration(days: i + 1)),
              price: 1.5 + i * 0.1,
              priceMin: 1.3 + i * 0.1,
              priceMax: 1.7 + i * 0.1,
            ),
          ),
      tradeEvents: const [],
      generatedAt: now,
    );
  }

  testWidgets('renders symbol and legend for SHORT tier', (tester) async {
    await tester.pumpWidget(wrap(PriceChartWidget(
      data: buildData(),
      tier: InvestmentTier.short,
    )));
    expect(find.text('Historija'), findsOneWidget);
    expect(find.text('Predikcija'), findsOneWidget);
    expect(find.textContaining('PEPE'), findsOneWidget);
    expect(find.text('24h pred.'), findsOneWidget);
  });

  testWidgets('MID tier shows 30d prediction label', (tester) async {
    await tester.pumpWidget(wrap(PriceChartWidget(
      data: buildData(tier: InvestmentTier.mid),
      tier: InvestmentTier.mid,
    )));
    expect(find.text('30d pred.'), findsOneWidget);
  });

  testWidgets('LONG tier shows 6mj prediction label', (tester) async {
    await tester.pumpWidget(wrap(PriceChartWidget(
      data: buildData(tier: InvestmentTier.long),
      tier: InvestmentTier.long,
    )));
    expect(find.text('6mj pred.'), findsOneWidget);
  });

  testWidgets('empty historical renders fallback message', (tester) async {
    await tester.pumpWidget(wrap(PriceChartWidget(
      data: buildData(historical: const [], prediction: const []),
      tier: InvestmentTier.short,
    )));
    expect(find.text('Nema podataka'), findsOneWidget);
  });
}

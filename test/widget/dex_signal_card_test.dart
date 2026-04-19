import 'package:coinsight/models/dexscreener_signal.dart';
import 'package:coinsight/widgets/dex_signal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  DexscreenerSignal buildSignal({
    double priceChange1h = 5.0,
    double volumeUsd24h = 1_500_000,
    double liquidityUsd = 750_000,
  }) =>
      DexscreenerSignal(
        pairAddress: '0xABC',
        baseTokenSymbol: 'PEPE',
        baseTokenName: 'PepeCoin',
        baseTokenAddress: '0x123',
        quoteTokenSymbol: 'WETH',
        dexId: 'uniswap',
        chainId: 'ethereum',
        priceUsd: 0.00000123,
        volumeUsd24h: volumeUsd24h,
        liquidityUsd: liquidityUsd,
        priceChange1h: priceChange1h,
        priceChange24h: 22.5,
        pairCreatedAt: DateTime.now()
                .subtract(const Duration(hours: 4))
                .millisecondsSinceEpoch ~/
            1000,
        detectedAt: DateTime.now(),
      );

  testWidgets('renders dex + chain badges, pair, and token name',
      (tester) async {
    await tester
        .pumpWidget(wrap(DexSignalCard(signal: buildSignal())));
    expect(find.text('UNISWAP'), findsOneWidget);
    expect(find.text('ETHEREUM'), findsOneWidget);
    expect(find.text('PEPE/WETH'), findsOneWidget);
    expect(find.text('PepeCoin'), findsOneWidget);
  });

  testWidgets('positive 1h change renders with + prefix', (tester) async {
    await tester.pumpWidget(
      wrap(DexSignalCard(signal: buildSignal(priceChange1h: 12.5))),
    );
    expect(find.text('+12.50% 1h'), findsOneWidget);
  });

  testWidgets('negative 1h change renders without + prefix', (tester) async {
    await tester.pumpWidget(
      wrap(DexSignalCard(signal: buildSignal(priceChange1h: -3.2))),
    );
    expect(find.text('-3.20% 1h'), findsOneWidget);
  });

  testWidgets('volume/liquidity formatted as M/K', (tester) async {
    await tester.pumpWidget(
      wrap(DexSignalCard(
        signal: buildSignal(
          volumeUsd24h: 2_500_000,
          liquidityUsd: 300_000,
        ),
      )),
    );
    expect(find.text('\$2.5M'), findsOneWidget);
    expect(find.text('\$300K'), findsOneWidget);
  });

  testWidgets('onAnalyze and onTrack callbacks fire on tap', (tester) async {
    var analyzed = 0;
    var tracked = 0;
    await tester.pumpWidget(
      wrap(DexSignalCard(
        signal: buildSignal(),
        onAnalyze: () => analyzed++,
        onTrack: () => tracked++,
      )),
    );
    await tester.tap(find.text('Analiziraj'));
    await tester.tap(find.text('Prati +'));
    expect(analyzed, 1);
    expect(tracked, 1);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/long_term_holding.dart';

void main() {
  LongTermHolding makeHolding({
    List<LongTermPurchase>? purchases,
    double targetPriceMin = 10,
    double targetPriceMax = 20,
    LongTermFundamentals? fundamentals,
    List<LongTermNote>? notes,
  }) {
    return LongTermHolding(
      id: 'h1',
      symbol: 'BTC',
      name: 'Bitcoin',
      coinGeckoId: 'bitcoin',
      firstResearchDate: DateTime(2026, 1, 1),
      status: LongTermStatus.accumulating,
      purchases: purchases ?? [],
      targetPriceMin: targetPriceMin,
      targetPriceMax: targetPriceMax,
      investmentThesis: 'Digital gold',
      fundamentals: fundamentals,
      notes: notes ?? [],
      claudeConfidenceScore: 85,
    );
  }

  LongTermPurchase makePurchase({
    String id = 'p1',
    double price = 50000,
    double quantity = 0.1,
    double amountUsdt = 5000,
  }) {
    return LongTermPurchase(
      id: id,
      date: DateTime(2026, 2, 1),
      price: price,
      quantity: quantity,
      amountUsdt: amountUsdt,
      note: 'DCA buy',
    );
  }

  group('LongTermHolding', () {
    group('averageEntryPrice', () {
      test('weighted average of multiple purchases', () {
        final purchases = [
          makePurchase(id: 'p1', price: 40000, quantity: 0.5, amountUsdt: 20000),
          makePurchase(id: 'p2', price: 60000, quantity: 0.5, amountUsdt: 30000),
        ];
        final h = makeHolding(purchases: purchases);
        // weighted: (40000*0.5 + 60000*0.5) / (0.5+0.5) = 50000
        expect(h.averageEntryPrice, 50000.0);
      });

      test('returns 0 with no purchases', () {
        final h = makeHolding(purchases: []);
        expect(h.averageEntryPrice, 0);
      });
    });

    group('totalInvested', () {
      test('sums amountUsdt of all purchases', () {
        final purchases = [
          makePurchase(id: 'p1', amountUsdt: 1000),
          makePurchase(id: 'p2', amountUsdt: 2000),
        ];
        final h = makeHolding(purchases: purchases);
        expect(h.totalInvested, 3000.0);
      });
    });

    group('totalQuantity', () {
      test('sums quantity of all purchases', () {
        final purchases = [
          makePurchase(id: 'p1', quantity: 0.3),
          makePurchase(id: 'p2', quantity: 0.7),
        ];
        final h = makeHolding(purchases: purchases);
        expect(h.totalQuantity, closeTo(1.0, 0.0001));
      });
    });

    group('potentialReturnMinPercent', () {
      test('calculates correctly', () {
        final purchases = [
          makePurchase(id: 'p1', price: 100, quantity: 1),
        ];
        final h = makeHolding(
          purchases: purchases,
          targetPriceMin: 200,
          targetPriceMax: 400,
        );
        expect(h.potentialReturnMinPercent, 100.0);
      });

      test('returns 0 with no purchases', () {
        final h = makeHolding(
          purchases: [],
          targetPriceMin: 200,
        );
        expect(h.potentialReturnMinPercent, 0);
      });
    });

    group('potentialReturnMaxPercent', () {
      test('calculates correctly', () {
        final purchases = [
          makePurchase(id: 'p1', price: 100, quantity: 1),
        ];
        final h = makeHolding(
          purchases: purchases,
          targetPriceMin: 200,
          targetPriceMax: 400,
        );
        expect(h.potentialReturnMaxPercent, 300.0);
      });

      test('returns 0 with no purchases', () {
        final h = makeHolding(
          purchases: [],
          targetPriceMax: 400,
        );
        expect(h.potentialReturnMaxPercent, 0);
      });
    });

    group('toMap / fromMap roundtrip', () {
      test('preserves all fields', () {
        final fundamentals = LongTermFundamentals(
          teamBackground: 'Strong team',
          investors: 'a16z',
          partnerships: 'Major exchanges',
          realWorldUseCase: 'Payments',
          tokenomics: 'Fixed supply',
          competitorAnalysis: 'Market leader',
          roadmapAssessment: 'On track',
          lastUpdated: DateTime(2026, 4, 1),
        );
        final note = LongTermNote(
          id: 'ln1',
          timestamp: DateTime(2026, 4, 5),
          content: 'Looking good',
          noteType: 'research',
        );
        final purchase = makePurchase();
        final original = makeHolding(
          purchases: [purchase],
          targetPriceMin: 80000,
          targetPriceMax: 150000,
          fundamentals: fundamentals,
          notes: [note],
        );

        final map = original.toMap();
        final restored = LongTermHolding.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.symbol, original.symbol);
        expect(restored.name, original.name);
        expect(restored.coinGeckoId, original.coinGeckoId);
        expect(restored.firstResearchDate, original.firstResearchDate);
        expect(restored.status, original.status);
        expect(restored.purchases.length, 1);
        expect(restored.targetPriceMin, original.targetPriceMin);
        expect(restored.targetPriceMax, original.targetPriceMax);
        expect(restored.investmentThesis, original.investmentThesis);
        expect(restored.fundamentals, isNotNull);
        expect(restored.notes.length, 1);
        expect(restored.claudeConfidenceScore, original.claudeConfidenceScore);
      });
    });
  });

  group('LongTermPurchase', () {
    test('toMap / fromMap roundtrip', () {
      final original = makePurchase();
      final map = original.toMap();
      final restored = LongTermPurchase.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.date, original.date);
      expect(restored.price, original.price);
      expect(restored.quantity, original.quantity);
      expect(restored.amountUsdt, original.amountUsdt);
      expect(restored.note, original.note);
    });
  });

  group('LongTermFundamentals', () {
    test('toMap / fromMap roundtrip', () {
      final original = LongTermFundamentals(
        teamBackground: 'Ex-Google',
        investors: 'Sequoia',
        partnerships: 'Visa',
        realWorldUseCase: 'Cross-border payments',
        tokenomics: 'Deflationary',
        competitorAnalysis: 'Better than XRP',
        roadmapAssessment: 'Ambitious but feasible',
        lastUpdated: DateTime(2026, 3, 15),
      );
      final map = original.toMap();
      final restored = LongTermFundamentals.fromMap(map);

      expect(restored.teamBackground, original.teamBackground);
      expect(restored.investors, original.investors);
      expect(restored.partnerships, original.partnerships);
      expect(restored.realWorldUseCase, original.realWorldUseCase);
      expect(restored.tokenomics, original.tokenomics);
      expect(restored.competitorAnalysis, original.competitorAnalysis);
      expect(restored.roadmapAssessment, original.roadmapAssessment);
      expect(restored.lastUpdated, original.lastUpdated);
    });
  });
}

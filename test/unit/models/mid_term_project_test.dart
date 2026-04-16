import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/mid_term_project.dart';

void main() {
  final now = DateTime(2026, 4, 10);

  MidTermProject makeProject({
    double? entryPriceTarget,
    double? takeProfitPrice,
    double? actualEntryPrice,
    double? actualEntryAmount,
    DateTime? entryDate,
    DateTime? discoveredAt,
    List<MidTermNote>? notes,
  }) {
    return MidTermProject(
      id: 'test-1',
      symbol: 'SOL',
      name: 'Solana',
      coinGeckoId: 'solana',
      githubRepo: 'solana-labs/solana',
      discoveredAt: discoveredAt ?? now,
      status: MidTermStatus.researching,
      entryPriceTarget: entryPriceTarget,
      takeProfitPrice: takeProfitPrice,
      actualEntryPrice: actualEntryPrice,
      actualEntryAmount: actualEntryAmount,
      entryDate: entryDate,
      thesis: 'Great project',
      notes: notes ?? [],
    );
  }

  group('MidTermProject', () {
    group('potentialReturnPercent', () {
      test('calculates from actualEntryPrice when entered', () {
        final p = makeProject(
          actualEntryPrice: 100,
          takeProfitPrice: 200,
          entryPriceTarget: 80,
        );
        expect(p.potentialReturnPercent, 100.0);
      });

      test('falls back to entryPriceTarget when not entered', () {
        final p = makeProject(
          entryPriceTarget: 80,
          takeProfitPrice: 200,
        );
        expect(p.potentialReturnPercent, 150.0);
      });

      test('returns 0 when no entry and no target', () {
        final p = makeProject(takeProfitPrice: 200);
        expect(p.potentialReturnPercent, 0);
      });

      test('returns 0 when no take profit price', () {
        final p = makeProject(actualEntryPrice: 100);
        expect(p.potentialReturnPercent, 0);
      });
    });

    group('daysWatching', () {
      test('calculates days since discovery', () {
        final past = DateTime.now().subtract(const Duration(days: 5));
        final p = makeProject(discoveredAt: past);
        expect(p.daysWatching, greaterThanOrEqualTo(5));
      });
    });

    group('isEntered', () {
      test('true when actualEntryPrice and entryDate are set', () {
        final p = makeProject(
          actualEntryPrice: 100,
          entryDate: DateTime.now(),
        );
        expect(p.isEntered, isTrue);
      });

      test('false when actualEntryPrice is null', () {
        final p = makeProject(entryDate: DateTime.now());
        expect(p.isEntered, isFalse);
      });

      test('false when entryDate is null', () {
        final p = makeProject(actualEntryPrice: 100);
        expect(p.isEntered, isFalse);
      });
    });

    group('toMap / fromMap roundtrip', () {
      test('preserves all fields', () {
        final note = MidTermNote(
          id: 'n1',
          timestamp: DateTime(2026, 4, 10, 12, 0),
          content: 'Looking good',
          claudeSnippet: 'Claude says buy',
        );
        final original = MidTermProject(
          id: 'p1',
          symbol: 'ETH',
          name: 'Ethereum',
          coinGeckoId: 'ethereum',
          githubRepo: 'ethereum/go-ethereum',
          discoveredAt: DateTime(2026, 3, 1),
          status: MidTermStatus.watching,
          entryPriceTarget: 3000,
          entryAmountUsdt: 500,
          stopLossPrice: 2800,
          takeProfitPrice: 5000,
          actualEntryPrice: 3100,
          actualEntryAmount: 490,
          entryDate: DateTime(2026, 3, 15),
          exitPrice: 4500,
          exitDate: DateTime(2026, 4, 1),
          thesis: 'ETH 2.0',
          notes: [note],
          lastClaudeAnalysis: 'Bullish',
          lastAnalysisDate: DateTime(2026, 4, 5),
        );

        final map = original.toMap();
        final restored = MidTermProject.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.symbol, original.symbol);
        expect(restored.name, original.name);
        expect(restored.coinGeckoId, original.coinGeckoId);
        expect(restored.githubRepo, original.githubRepo);
        expect(restored.discoveredAt, original.discoveredAt);
        expect(restored.status, original.status);
        expect(restored.entryPriceTarget, original.entryPriceTarget);
        expect(restored.entryAmountUsdt, original.entryAmountUsdt);
        expect(restored.stopLossPrice, original.stopLossPrice);
        expect(restored.takeProfitPrice, original.takeProfitPrice);
        expect(restored.actualEntryPrice, original.actualEntryPrice);
        expect(restored.actualEntryAmount, original.actualEntryAmount);
        expect(restored.entryDate, original.entryDate);
        expect(restored.exitPrice, original.exitPrice);
        expect(restored.exitDate, original.exitDate);
        expect(restored.thesis, original.thesis);
        expect(restored.notes.length, 1);
        expect(restored.lastClaudeAnalysis, original.lastClaudeAnalysis);
        expect(restored.lastAnalysisDate, original.lastAnalysisDate);
      });
    });

    group('copyWith', () {
      test('overrides specified fields only', () {
        final p = makeProject(
          actualEntryPrice: 100,
          entryDate: DateTime(2026, 3, 1),
        );
        final updated = p.copyWith(
          status: MidTermStatus.entered,
          thesis: 'Updated thesis',
        );
        expect(updated.status, MidTermStatus.entered);
        expect(updated.thesis, 'Updated thesis');
        expect(updated.symbol, p.symbol);
        expect(updated.actualEntryPrice, p.actualEntryPrice);
      });
    });
  });

  group('MidTermNote', () {
    test('toMap / fromMap roundtrip', () {
      final note = MidTermNote(
        id: 'n1',
        timestamp: DateTime(2026, 4, 10, 12, 0),
        content: 'Research note',
        claudeSnippet: 'AI insight',
      );
      final map = note.toMap();
      final restored = MidTermNote.fromMap(map);

      expect(restored.id, note.id);
      expect(restored.timestamp, note.timestamp);
      expect(restored.content, note.content);
      expect(restored.claudeSnippet, note.claudeSnippet);
    });

    test('fromMap handles null claudeSnippet', () {
      final note = MidTermNote(
        id: 'n2',
        timestamp: DateTime(2026, 4, 10),
        content: 'No AI',
      );
      final map = note.toMap();
      final restored = MidTermNote.fromMap(map);
      expect(restored.claudeSnippet, isNull);
    });
  });
}

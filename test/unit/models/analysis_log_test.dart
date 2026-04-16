import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/analysis_log.dart';

void main() {
  group('AnalysisLog', () {
    test('parseRecommendationType detects INTERESTING', () {
      expect(
        AnalysisLog.parseRecommendationType(
            'This is an **INTERESTING** coin to watch.'),
        'INTERESTING',
      );
    });

    test('parseRecommendationType detects WATCH', () {
      expect(
        AnalysisLog.parseRecommendationType(
            'I would say **WATCH** this coin closely.'),
        'WATCH',
      );
    });

    test('parseRecommendationType detects SKIP', () {
      expect(
        AnalysisLog.parseRecommendationType(
            'Definitely a **SKIP** for now.'),
        'SKIP',
      );
    });

    test('parseRecommendationType returns NONE for no markers', () {
      expect(
        AnalysisLog.parseRecommendationType(
            'This is a general analysis without markers.'),
        'NONE',
      );
    });

    test('parseRecommendationType prioritizes INTERESTING over others', () {
      expect(
        AnalysisLog.parseRecommendationType(
            'Both **WATCH** and **INTERESTING** are here.'),
        'INTERESTING',
      );
    });

    test('parseRecommendationType prioritizes WATCH over SKIP', () {
      expect(
        AnalysisLog.parseRecommendationType(
            'This is **SKIP** but also **WATCH**.'),
        'WATCH',
      );
    });

    test('toMap and fromMap roundtrip', () {
      final original = AnalysisLog(
        timestamp: DateTime(2026, 4, 15, 12, 30),
        coinId: 'bitcoin',
        coinSymbol: 'BTC',
        priceAtAnalysis: 71867.10,
        claudeRecommendation: 'Test recommendation **WATCH**',
        recommendationType: 'WATCH',
      );
      final map = original.toMap();
      final restored = AnalysisLog.fromMap(map);

      expect(restored.timestamp, original.timestamp);
      expect(restored.coinId, original.coinId);
      expect(restored.coinSymbol, original.coinSymbol);
      expect(restored.priceAtAnalysis, original.priceAtAnalysis);
      expect(restored.claudeRecommendation, original.claudeRecommendation);
      expect(restored.recommendationType, original.recommendationType);
    });
  });
}

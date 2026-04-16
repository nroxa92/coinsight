import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/trade_proposal.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('TradeProposal', () {
    test('isExpired returns false immediately after creation', () {
      final proposal = TradeProposal(
        coin: TestFixtures.btcCoin(),
        amountUsdt: 10.0,
        estimatedQty: 0.000139,
        currentPrice: 71867.10,
        stopLossPrice: 61087.035,
        takeProfitPrice: 93427.23,
        claudeRecommendation: 'test',
        createdAt: DateTime.now(),
      );
      expect(proposal.isExpired, false);
    });

    test('isExpired returns true after 61 seconds', () {
      final proposal = TradeProposal(
        coin: TestFixtures.btcCoin(),
        amountUsdt: 10.0,
        estimatedQty: 0.000139,
        currentPrice: 71867.10,
        stopLossPrice: 61087.035,
        takeProfitPrice: 93427.23,
        claudeRecommendation: 'test',
        createdAt: DateTime.now().subtract(const Duration(seconds: 61)),
      );
      expect(proposal.isExpired, true);
    });

    test('isExpired returns false at exactly 60 seconds', () {
      final proposal = TradeProposal(
        coin: TestFixtures.btcCoin(),
        amountUsdt: 10.0,
        estimatedQty: 0.000139,
        currentPrice: 71867.10,
        stopLossPrice: 61087.035,
        takeProfitPrice: 93427.23,
        claudeRecommendation: 'test',
        createdAt: DateTime.now().subtract(const Duration(seconds: 59)),
      );
      expect(proposal.isExpired, false);
    });
  });
}

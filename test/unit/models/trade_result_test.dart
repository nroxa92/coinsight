import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/trade_result.dart';

void main() {
  group('TradeResult', () {
    test('failure factory creates failed result with message', () {
      final result = TradeResult.failure('Insufficient balance');
      expect(result.success, false);
      expect(result.errorMessage, 'Insufficient balance');
      expect(result.orderId, isNull);
      expect(result.executedPrice, isNull);
    });

    test('success result has all fields', () {
      const result = TradeResult(
        success: true,
        orderId: '12345',
        executedPrice: 0.00234,
        executedQty: 4273.504,
        totalUsdt: 10.0,
      );
      expect(result.success, true);
      expect(result.orderId, '12345');
      expect(result.executedPrice, 0.00234);
      expect(result.executedQty, 4273.504);
      expect(result.totalUsdt, 10.0);
      expect(result.errorMessage, isNull);
    });
  });
}

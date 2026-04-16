import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/investment_tier.dart';

void main() {
  group('InvestmentTier', () {
    group('displayName', () {
      test('short tier displays SHORT', () {
        expect(InvestmentTier.short.displayName, 'SHORT');
      });

      test('mid tier displays MID', () {
        expect(InvestmentTier.mid.displayName, 'MID');
      });

      test('long tier displays LONG', () {
        expect(InvestmentTier.long.displayName, 'LONG');
      });
    });

    group('emoji', () {
      test('short tier has lightning emoji', () {
        expect(InvestmentTier.short.emoji, '\u26A1');
      });

      test('mid tier has chart emoji', () {
        expect(InvestmentTier.mid.emoji, '\uD83D\uDCC8');
      });

      test('long tier has building emoji', () {
        expect(InvestmentTier.long.emoji, '\uD83C\uDFDB\uFE0F');
      });
    });

    group('supportsAutoTrade', () {
      test('short tier supports auto trade', () {
        expect(InvestmentTier.short.supportsAutoTrade, isTrue);
      });

      test('mid tier does not support auto trade', () {
        expect(InvestmentTier.mid.supportsAutoTrade, isFalse);
      });

      test('long tier does not support auto trade', () {
        expect(InvestmentTier.long.supportsAutoTrade, isFalse);
      });
    });

    group('color', () {
      test('short tier color is non-null', () {
        expect(InvestmentTier.short.color, isA<Color>());
      });

      test('mid tier color is non-null', () {
        expect(InvestmentTier.mid.color, isA<Color>());
      });

      test('long tier color is non-null', () {
        expect(InvestmentTier.long.color, isA<Color>());
      });
    });

    group('description', () {
      test('short tier description is non-empty', () {
        expect(InvestmentTier.short.description, isNotEmpty);
      });

      test('mid tier description is non-empty', () {
        expect(InvestmentTier.mid.description, isNotEmpty);
      });

      test('long tier description is non-empty', () {
        expect(InvestmentTier.long.description, isNotEmpty);
      });
    });
  });
}

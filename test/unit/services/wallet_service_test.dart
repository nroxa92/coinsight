import 'package:coinsight/services/wallet_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_setup.dart';

void main() {
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  group('WalletService', () {
    test('initial state is disconnected and uninitialized', () {
      final w = WalletService();
      expect(w.isInitialized, false);
      expect(w.isConnected, false);
      expect(w.connectedAddress, isNull);
      expect(w.connectedChainId, isNull);
      expect(w.error, isNull);
    });

    test('chainName returns Unknown for null chain', () {
      final w = WalletService();
      expect(w.chainName, 'Unknown');
    });

    test('shortAddress returns empty when no address', () {
      final w = WalletService();
      expect(w.shortAddress, '');
    });

    test('initialize without projectId is a no-op', () async {
      final w = WalletService();
      await w.initialize();
      expect(w.isInitialized, false);
      expect(w.error, isNull);
    });

    test('disconnectWallet without modal is safe and idempotent', () async {
      final w = WalletService();
      await w.disconnectWallet();
      expect(w.isConnected, false);
      expect(w.connectedAddress, isNull);
    });

    test('initiateSwap returns null when not connected', () async {
      final w = WalletService();
      final tx = await w.initiateSwap(
        toContractAddress: '0xABC',
        amountInUsdt: 10,
        chainId: 'eip155:1',
      );
      expect(tx, isNull);
    });
  });
}

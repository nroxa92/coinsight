import 'package:coinsight/services/wallet_service.dart';
import 'package:coinsight/widgets/wallet_connect_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/hive_test_setup.dart';

void main() {
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  Widget wrap(WalletService service) => MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: ChangeNotifierProvider<WalletService>.value(
            value: service,
            child: const WalletConnectButton(),
          ),
        ),
      );

  testWidgets('renders nothing when service not initialized', (tester) async {
    final svc = WalletService();
    await tester.pumpWidget(wrap(svc));
    expect(find.text('Spoji Wallet'), findsNothing);
    expect(find.byIcon(Icons.account_balance_wallet), findsNothing);
  });
}

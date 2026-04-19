# CoinSight Test Suite

## Struktura

- `widget_test.dart` — top-level smoke test (Hive init + CoinSightApp navigation)
- `helpers/` — shared test utilities
  - `hive_test_setup.dart` — `setUpHive()` / `tearDownHive()` — otvara sve Hive boxeve iz StorageService-a u temp direktoriju i stubira `flutter_local_notifications` platform channel
  - `mock_http_client.dart` — `HttpClientFactory.returning(...)`, `throwingTimeout()`, `returningSequence(...)` za izolirano testiranje HTTP slojeva
  - `test_fixtures.dart` — fixture podaci (btcCoin, newListingCoin, openPosition, RiskParameters, CoinGecko / Binance / Telegram JSON)
- `unit/` — izolirani testovi za modele, servise i providere
- `widget/` — testovi individualnih widgeta
- `integration/` — end-to-end flows

## Trenutno stanje (v8.0.0)

**352 testa, 0 fail.** `flutter analyze` — 0 issues.

```bash
flutter test
# 352/352 passed
```

### Pokrivenost po modulu

| Sloj | Fajlovi | Primjer |
|------|---------|---------|
| Models | 19 | `coin_test`, `pnl_analytics_test`, `intelligence_report_test`, `investment_tier_test`, `risk_parameters_test` |
| Services | 13 | `coingecko_service_test`, `binance_service_test`, `claude_service_test`, `trade_service_test`, `storage_service_test`, `intelligence_aggregator_test`, `wallet_service_test` |
| Providers | 4 | `tier_provider_test`, `watchlist_provider_test`, `analysis_provider_test`, `portfolio_provider_test` |
| Widgets | 7 | `coin_card_test`, `chat_bubble_test`, `sparkline_chart_test`, `dex_signal_card_test`, `price_chart_widget_test`, `tier_mode_selector_test`, `wallet_connect_button_test` |
| Integration | 1 | `app_navigation_test` |

## Uzorci

**Hive boxevi:** pozovi `setUpHive()` u `setUp` i `tearDownHive()` u `tearDown` — svaki test dobiva svježi Hive u temp direktoriju.

**HTTP mockovi:** `HttpClientFactory.returning(jsonBody)` vraća `http.Client` koji na bilo koji `.get/.post` odgovara s danim body-jem; `throwingTimeout()` baca `TimeoutException`; `returningSequence([r1, r2])` za više uzastopnih poziva.

**Widget testovi:** koriste `ChangeNotifierProvider<T>(create: ...)` kad widget sluša provider. Za widgete koji pokreću asinkrone Hive zapise (npr. tap koji mijenja tier) preferiraj `pump(Duration)` umjesto `pumpAndSettle()` i eksplicitno `pumpWidget(SizedBox.shrink())` na kraju testa kako bi se ticker i provider uredno disponirali.

**Notification service:** `flutter_local_notifications` ovisi o Android platform kanalima i nije pokriven host unit testovima — `hive_test_setup.dart` ipak stubira kanal kako logika koja ga poziva usput (npr. `AnalysisProvider` visoki-score callback) ne puca u host okruženju.

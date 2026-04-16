# CoinSight — Sveobuhvatni Projektni Dokument

**Verzija:** 7.0.0
**Datum generiranja:** 2026-04-16
**Status projekta:** v7.0.0 release — 280 testova, 10 sesija, Three-Tier Investment Framework (SHORT/MID/LONG) + Intelligence Layer + Detail Screens + DEX Position Tracking + Charts & Visualization + Push Notifications + P&L Dashboard + WalletConnect v2
**Autor:** Neven (developer) + Claude Code (implementacija)
**Licenca:** MIT (Copyright (c) 2026 Neven Roksandic)

---

## 0. Svrha ovog dokumenta

Ovaj dokument daje potpunu sliku projekta CoinSight od prvog Flutter `create` poziva do trenutnog stanja — kroz **devet implementacijskih sesija**, s preko **7000+ linija Dart koda** rasporedenih u **50 lib/ fajl**, na **5 platformi** (Android/iOS/Windows/Linux/macOS/Web target, stvarno buildano: Android APK + Windows EXE).

Namijenjen je:
- **Developeru (Neven)** — da ima referencu za ono sto je napravljeno, zasto, i sto slijedi
- **Budućim Claude Code sesijama** — kao onboarding dokument koji pokriva kontekst bez potrebe citanja cijelog `WORKLOG.md`-a i svih izvornih `.md` spec fajlova
- **Code review / audit** — pregled arhitekture, ovisnosti, sigurnosnih odluka
- **Open source kontributorima** — razumijevanje dizajn odluka i tehnickog duga

Postoji paralelni `WORKLOG.md` koji ima vise granularne zapise po fajlu i liniji; ovaj dokument je **narativan** i **arhitekturalan**, `WORKLOG.md` je **forenzicki**.

---

## 1. Sto je CoinSight

### 1.1 Kratki opis

CoinSight je **open source** (MIT licenca) **Flutter aplikacija** za **rano otkrivanje momentum prilike na cryptocurrency trzistu** sa **AI-podrzanom analizom** kroz Claude API i **Telegram channel intelligence**. Aplikacija je primarno Android-namijenjena (glavni use case: mobilno pracenje trzista u realnom vremenu) s Windows desktop targetom za development/debug.

### 1.2 Core value proposition

Postoje tisuce crypto dashboardova. Ono sto CoinSight razlikuje:

1. **Filter za early-stage listinge** — ne pokazuje Bitcoin i Ethereum (to je sum za korisnika), nego coinove s market cap rankom >500, volume-om izmedu $50k–$50M (filter ghost coinova i whale manipulacija), sortirane po 1h price change — dakle **kontekstualno pripremljen pipeline za trenutne momentum prilike**.

2. **Claude AI analiza kroz tri objektiva** — umjesto generickog chat-a, AI sistem prompt je **precizno kalibriran** za profil momentum coinova: analizira (a) profil listinga (volume organicnost, exchange tier, mcap rank), (b) risk profil (pump-and-dump znakovi, 1h/24h konzistentnost), i (c) daje **strukturiranu preporuku** s jednom od tri oznake: `**WATCH**`, `**SKIP**`, `**INTERESTING**`.

3. **Multi-source intelligence agregacija** — pet izvora podataka (Dexscreener DEX listinzi, GitHub repo aktivnost, Reddit community sentiment, Telegram channel signali, CoinGecko market data) agregirani kroz IntelligenceAggregator s cross-channel confluence scoring sustavom (0–6.0). Svaki izvor ima vlastiti scoring (DEX 0–2, GitHub 0–1, Reddit 0–1, Telegram 0–1, Market 0–1) i kategorizaciju (STRONG_INTERESTING / POSSIBLE_WATCH / WEAK_SIGNAL / LIKELY_SKIP / INSUFFICIENT_DATA).

4. **Direktna veza analiza -> trade** — kada Claude vrati **INTERESTING**, pojavi se *Trade Action Bar* u Analysis ekranu s **BUY NOW** buttonom. Jedan tap -> confirmation dialog -> market buy kroz Binance Spot. Nema prebacivanja u drugu app, nema copy-paste simbola.

5. **Automatizirano izvrsavanje (Faza 3)** — uz eksplicitni opt-in, bot moze autonomno izvrsavati INTERESTING signale unutar strogih risk parametara (max iznos, max pozicija, SL/TP, quiet hours).

6. **Bot Manager** — full-screen upravljanje Telegram kanalima s reliability scoring-om (Novo/Niska/Srednja/Visoka), preporucenim kanalima, i statistikama.

### 1.3 Sto CoinSight NIJE i nece biti

- **Nije edukacijska app.** Claude sistem prompt eksplicitno pretpostavlja iskusnog korisnika i **ne objasnjava osnovne pojmove** (volume, market cap, blockchain). Razgovara kao kolega analiticar.
- **Nije financijski savjet.** System prompt zavrsava disclaimerom. UI ima disclaimer u Manage -> App.
- **Nema futures/margin/options.** Samo Binance Spot.
- **Nema WebSocket real-time streaming.** REST polling je svjesna odluka (jednostavnija implementacija, manje drift state, primjereno za momentum na min-scale, ne second-scale).
- **Nema withdrawal kroz app.** Binance API kljuc se eksplicitno kreira **bez** withdrawal permission. Isplate na Revolut rade se **rucno** kroz Binance web: Spot -> Convert USDT u EUR -> Withdraw SEPA na Revolut IBAN.

---

## 2. Stack, arhitektura, ovisnosti

### 2.1 Tech stack

| Sloj | Tehnologija | Razlog izbora |
|------|-------------|---------------|
| Framework | Flutter 3.41.6 stable, Dart 3.11.4 | Jedan codebase, Android + Windows za dev, native performance |
| State management | `provider ^6.1.0` (ChangeNotifier) | Minimalno, idiomatski Flutter, bez heavy boilerplate-a (BLoC/Riverpod overkill za scope) |
| Local storage | `hive ^2.2.3` + `hive_flutter ^1.1.0` | Brz key-value store, nema SQL setup, ideal za API kljuceve + watchlist + pozicije + logs |
| HTTP klijent | `http ^1.4.0` | Standard, injectable za testing |
| Kripto potpisi | `crypto ^3.0.3` + `convert ^3.1.1` | HMAC-SHA256 za Binance signed requestove |
| Notifikacije | `flutter_local_notifications ^18.0.0` | Push notifikacije za SL/TP/INTERESTING alerte [v6.0.0] |
| Formatting | `intl ^0.20.0` | NumberFormat.currency, DateFormat za timestamps |
| Ikone | `cupertino_icons ^1.0.8` | iOS-style fallback |
| Linting | `flutter_lints ^6.0.0` | Standardni Flutter recommended set |
| Testing | `mocktail ^1.0.4` | Mock-based testiranje, mocktail pattern |
| HTML parsing | `html ^0.15.4` | Reddit HTML entity decoding u RedditMonitor |
| Hive codegen | `hive_generator ^2.0.1` + `build_runner ^2.4.0` | Za buduce typed TypeAdapters (trenutno koristimo Map<String, dynamic> pristup) |

### 2.2 Struktura fajlova (lib/)

```
lib/
├── main.dart                                  # Entry point, MultiProvider, 4-tab navigation, background timers + intelligence
├── theme/
│   └── app_theme.dart                         # Dark tema (primary #6C63FF, secondary #03DAC6, surface #1E1E1E)
├── models/ (17 fajlova)
│   ├── coin.dart                              # Coin data model (12 polja + sparkline + 1h change)
│   ├── analysis_log.dart                      # AnalysisLog + parseRecommendationType()
│   ├── coin_position.dart                     # Binance spot pozicija + P&L getteri
│   ├── closed_trade.dart                      # Zatvoreni trade model (entry/exit price, P&L, tier, razlog) [v7.0.0]
│   ├── pnl_analytics.dart                     # P&L analitika (win rate, R/R ratio, equity curve, tier breakdown) [v7.0.0]
│   ├── dex_position.dart                      # DEX pozicija model (token, entry, qty, DEX, chain, SL/TP) [v5.0.0]
│   ├── risk_parameters.dart                   # Risk config (max trade, SL/TP, quiet hours, auto-trade)
│   ├── trade_proposal.dart                    # Pending trade prije korisnikove potvrde (60s expiry)
│   ├── trade_result.dart                      # Ishod executeTrade() poziva
│   ├── telegram_signal.dart                   # Signal primljen iz Telegram kanala (text, channel, preview)
│   ├── monitored_channel.dart                 # Kanal s reliability scoring-om (signalsReceived/Relevant)
│   ├── dexscreener_signal.dart                # DEX listing signal (pair, liquidity, volume, age) [v3.0.0]
│   ├── github_signal.dart                     # GitHub repo signal (stars, forks, activity, topics) [v3.0.0]
│   ├── reddit_signal.dart                     # Reddit post signal (upvotes, comments, momentum) [v3.0.0]
│   ├── intelligence_report.dart               # Agregirani multi-source report + scoring engine [v3.0.0]
│   ├── investment_tier.dart                   # InvestmentTier enum (SHORT/MID/LONG) + tier config [v4.0.0]
│   ├── mid_term_project.dart                  # MidTermProject model (coin, catalyst, target, deadline) [v4.0.0]
│   ├── long_term_holding.dart                 # LongTermHolding model (coin, DCA purchases, thesis) [v4.0.0]
│   ├── price_chart_data.dart                  # Chart data model: OHLC + predikcija + tier ranges [v6.0.0]
│   ├── tier_provider.dart                     # ChangeNotifier: aktivni tier + MID projects + LONG holdings [v4.0.0]
│   ├── watchlist_provider.dart                # ChangeNotifier: topCoins + watchlist + newListings + dexListings + timer
│   ├── analysis_provider.dart                 # ChangeNotifier: Claude chat + system prompt + intelligence + auto-log
│   └── portfolio_provider.dart                # ChangeNotifier: USDT balance + positions + 30s price refresh
├── services/ (11 fajlova)
│   ├── coingecko_service.dart                 # CoinGecko REST (getMarketData, searchAndFetch, getNewListings, searchBySymbol)
│   ├── claude_service.dart                    # Anthropic Messages API klijent
│   ├── storage_service.dart                   # Hive wrapper za 5 box-ova
│   ├── binance_service.dart                   # Binance Spot REST (HMAC-SHA256 signed) + LOT_SIZE cache + time sync
│   ├── trade_service.dart                     # Trade orchestration (prepare/execute/auto/SL/close)
│   ├── telegram_monitor.dart                  # Pasivni citac javnih Telegram kanala + recentSignals cache
│   ├── dexscreener_service.dart               # Dexscreener API — 6 chainova, new pair discovery [v3.0.0]
│   ├── github_intelligence.dart               # GitHub Search API — crypto repo monitoring [v3.0.0]
│   ├── reddit_monitor.dart                    # Reddit JSON API — 5 subreddita, sentiment [v3.0.0]
│   ├── intelligence_aggregator.dart           # Multi-source koordinator + confluence scoring [v3.0.0]
│   ├── chart_data_service.dart                # CoinGecko historical data fetch + predikcija [v6.0.0]
│   ├── notification_service.dart              # Push notifikacije: SL/TP/INTERESTING alerte [v6.0.0]
│   └── wallet_service.dart                    # WalletConnect v2 integracija (connect, address, swap) [v7.0.0]
├── screens/ (10 fajlova)
│   ├── watchlist_screen.dart                  # Tab 0: DEX Early / New Listings / My Watchlist / MID Discovery / LONG Research / Projekti / Top Coins
│   ├── analysis_screen.dart                   # Tab 1: Claude chat + tier-specific Action Bar (SHORT/MID/LONG)
│   ├── portfolio_screen.dart                  # Tab 2: USDT balance + positions + DEX positions + MID projects + LONG holdings + Intelligence Dashboard
│   ├── settings_screen.dart                   # Tab 3: App Management (5 tabova: API/Bot/Trade/Tiers/App)
│   ├── bot_manager_screen.dart                # Full-screen route: channel management, stats, recommended
│   ├── mid_project_detail_screen.dart         # MID projekt detail: thesis, GitHub, entry plan, status, biljeske [v5.0.0]
│   ├── long_holding_detail_screen.dart        # LONG holding detail: 4 taba (Osnove/Fundamentali/DCA/Biljeske) [v5.0.0]
│   ├── dex_position_screen.dart               # DEX pozicije: rucni unos, auto price refresh, SL/TP monitoring [v5.0.0]
│   ├── chart_screen.dart                      # Full-screen tier-aware price chart s predikcijom [v6.0.0]
│   └── pnl_dashboard_screen.dart              # P&L dashboard: equity curve, win rate, R/R, tier breakdown [v7.0.0]
└── widgets/ (13 fajlova)
    ├── coin_card.dart                         # CoinCard (s 1h badge) + CoinCardSkeleton (shimmer)
    ├── chat_bubble.dart                       # Selectable user/assistant chat mjehur
    ├── sparkline_chart.dart                   # 7-day price sparkline, CustomPainter
    ├── dex_signal_card.dart                   # DexSignalCard — DEX pair kartica s chain/dex badge [v3.0.0]
    ├── tier_mode_selector.dart                # TierModeSelector — banner s SHORT/MID/LONG buttonima [v4.0.0]
    ├── price_chart_widget.dart                # Interaktivni price chart (CustomPainter, touch crosshair) [v6.0.0]
    ├── wallet_connect_button.dart              # WalletConnect spajanje UI widget [v7.0.0]
    └── settings/
        ├── api_settings_tab.dart              # Anthropic + Binance API kljucevi
        ├── bot_settings_tab.dart              # Telegram Monitor konfiguracija
        ├── trade_settings_tab.dart            # Risk Parameters (SL/TP, auto-trade, quiet hours)
        ├── tier_settings_tab.dart             # Tier konfiguracija (MID/LONG postavke, statistike) [v4.0.0]
        └── app_settings_tab.dart              # About + App Controls (clear/export/reset)
```

**Ukupno:** 55 Dart fajl u lib/ (+5 fajlova od v6.0.0: closed_trade, pnl_analytics, pnl_dashboard_screen, wallet_service, wallet_connect_button).

### 2.3 Dependency graph

```
main.dart
├── theme/app_theme.dart
├── services/storage_service.dart ──→ hive_flutter
│   ├── models/analysis_log.dart
│   ├── models/coin_position.dart
│   ├── models/risk_parameters.dart
│   └── models/monitored_channel.dart
├── services/trade_service.dart
│   ├── services/binance_service.dart ──→ crypto, convert, http
│   ├── services/storage_service.dart
│   └── models/{coin, coin_position, risk_parameters, trade_proposal, trade_result, analysis_log}
├── services/binance_service.dart (via trade & portfolio)
│   └── _lotSizeCache (in-memory), _serverTimeOffsetMs (sync via /api/v3/time)
├── models/watchlist_provider.dart
│   ├── dart:async (Timer)
│   ├── models/coin.dart
│   └── services/coingecko_service.dart ──→ http, dart:async, dart:convert
├── models/analysis_provider.dart
│   ├── services/claude_service.dart ──→ http, dart:async, dart:convert
│   ├── services/storage_service.dart
│   ├── services/telegram_monitor.dart ──→ http, models/telegram_signal.dart
│   ├── models/coin.dart
│   └── models/analysis_log.dart
├── models/portfolio_provider.dart
│   ├── services/binance_service.dart
│   ├── services/storage_service.dart
│   └── services/trade_service.dart
├── screens/watchlist_screen.dart ──→ provider
│   └── widgets/coin_card.dart (+ sparkline_chart, intl)
├── screens/analysis_screen.dart ──→ provider
│   ├── services/{binance, trade, storage}
│   └── widgets/chat_bubble.dart
├── screens/portfolio_screen.dart ──→ provider, intl
│   └── services/storage_service.dart
├── screens/settings_screen.dart ──→ provider
│   ├── services/{binance, telegram_monitor, storage}
│   ├── screens/bot_manager_screen.dart
│   └── widgets/settings/{api, bot, trade, app}_settings_tab.dart
├── screens/bot_manager_screen.dart ──→ provider
│   ├── services/{storage, telegram_monitor}
│   └── models/{analysis_provider, monitored_channel}
├── models/tier_provider.dart [v4.0.0]
│   ├── models/investment_tier.dart (InvestmentTier enum)
│   ├── models/mid_term_project.dart (MidTermProject CRUD)
│   ├── models/long_term_holding.dart (LongTermHolding + DCA)
│   ├── services/storage_service.dart (Hive persistence)
│   └── ──→ screens/{watchlist, analysis, portfolio}_screen.dart (tier-aware UI)
├── widgets/tier_mode_selector.dart [v4.0.0]
│   └── models/tier_provider.dart (currentTier, switchTier)
└── services/intelligence_aggregator.dart [v3.0.0]
    ├── services/dexscreener_service.dart ──→ http (6 chainova, rate limit 200ms)
    ├── services/github_intelligence.dart ──→ http (GitHub Search API, 500ms delay)
    ├── services/reddit_monitor.dart ──→ http, html (5 subreddita, 300ms delay)
    ├── services/telegram_monitor.dart (recentSignals cache)
    └── services/coingecko_service.dart (searchBySymbol)
```

### 2.4 Providers (state management)

Cetiri `ChangeNotifier` providera registrirana u `main.dart` `MultiProvider`:

1. **`WatchlistProvider`** — drzi `topCoins`, `watchlistCoins`, `newListings`, `watchlistIds`. Dispozicijski Timer za new-listings auto-refresh (3 min). Persistira watchlistIds u Hive.

2. **`AnalysisProvider`** — drzi `messages` (List<ChatMessage>), loading state, error, `_pendingSignals` (List<TelegramSignal>). Konstruktor automatski ucita spremljeni Anthropic API kljuc iz Hive. Sadrzi ugradeni **HR sistem prompt** (30 linija) i `_tryLogAnalysis()` koji parsira Claudeov odgovor za WATCH/SKIP/INTERESTING marker i auto-sprema u Hive. Integrira TelegramMonitor: `startTelegramMonitor()` pokrece polling, primljeni signali se automatski dodaju kao `[TELEGRAM INTELLIGENCE]` kontekst u sljedecu korisnikovu poruku.

3. **`PortfolioProvider`** — drzi `usdtBalance`, `positions` (List<CoinPosition>), loading state. Computed getteri za total P&L. Dispozicijski Timer za 30s refresh pozicijskih cijena. Reload pattern za Binance credentials (kada korisnik promijeni u Manage).

4. **`TierProvider`** [v4.0.0] — drzi `currentTier` (InvestmentTier enum: SHORT/MID/LONG), `midTermProjects` (List<MidTermProject>), `longTermHoldings` (List<LongTermHolding>). CRUD metode za MID projekte i LONG holdinge. DCA purchase tracking za LONG tier. Persistira u Hive (`mid_term_projects` i `long_term_holdings` box-ovi).

### 2.5 Hive box-ovi

9 box-ova otvorenih u `StorageService.init()`:

| Box | Sadrzaj | Keyevi |
|-----|---------|--------|
| `settings` | Anthropic API key, Binance key/secret/testnet, Telegram monitor token, Risk Parameters | Fiksni stringovi |
| `watchlist` | Lista pracenih coin IDs (default: bitcoin/ethereum/solana) | Fiksni string |
| `analysis_logs` | AnalysisLog zapisi (Claude preporuke + entered + exited + skipped) | Auto-increment (box.add) |
| `positions` | Otvorene Binance spot pozicije | coinId (CoinGecko ID) |
| `monitored_channels_detail` | MonitoredChannel zapisi s reliability scoring-om | channel username |
| `mid_term_projects` | MidTermProject zapisi (coin, catalyst, target, deadline, status) [v4.0.0] | projectId (UUID) |
| `long_term_holdings` | LongTermHolding zapisi (coin, DCA purchases, thesis, fundamentals) [v4.0.0] | holdingId (UUID) |
| `dex_positions` | DexPosition zapisi (token, entry, qty, DEX, chain, SL/TP) [v5.0.0] | positionId (UUID) |
| `closed_trades` | ClosedTrade zapisi (entry/exit price, P&L, tier, razlog zatvaranja) [v7.0.0] | tradeId (UUID) |

**Napomena (v3.0.0):** Intelligence podaci (DexscreenerSignal, GitHubSignal, RedditSignal, IntelligenceReport) su **in-memory only** — nema novih Hive box-ova. Svjestan izbor: intelligence podaci su kratkotrajni i brzo zastarjevaju, persistencija bi stvorila stale data problem.

**Napomena (v4.0.0):** MidTermProject i LongTermHolding **jesu** persistirani u Hive jer su dugorocni zapisi (tjedni do mjeseci) — za razliku od intelligence podataka koji zastarjevaju u minutama.

### 2.6 Eksterni API-ji

| API | Svrha | Auth | Rate limit | Key mgmt |
|-----|-------|------|------------|----------|
| **CoinGecko v3** | Market data, new listings, search | Free tier (no key) | 10–30 req/min | — |
| **Anthropic Claude Messages** | AI chat analiza | `x-api-key` header | Pay per token (~$3/M input, $15/M output Sonnet 4) | Korisnik upisuje u Manage -> API |
| **Binance Spot REST** | Balance, price, buy, sell, order history | `X-MBX-APIKEY` + HMAC-SHA256 signature | 1200 weight/min (signed) | Korisnik upisuje u Manage -> API |
| **Telegram Bot API** | Pasivno citanje kanala (getUpdates) | Token u URL-u | ~30 msg/s globalno | Korisnik upisuje u Manage -> Bot |
| **Dexscreener API** | DEX pair discovery (6 chainova) | Free tier (no key) | Nespecificiran (~300/min) | — |
| **GitHub Search API** | Crypto repo monitoring | Free tier (no key) | 60 req/h (unauth) | — (optional token future) |
| **Reddit JSON API** | Community sentiment (5 subreddita) | Free tier (no key) | ~60 req/h | — (optional OAuth2 future) |

**Sigurnosno nacelo:** nijedan kljuc nikada ne ide u source code, log, ili error poruku. Svi se cuvaju lokalno u Hive, `.gitignore` blokira `.env*` i `.hive/`.

---

## 3. Session 1 (2026-04-12) — Faze 1–5: Temelji

Pocetak projekta. Developer dao instrukcije u `CLAUDE.md` o faznom pristupu (5 faza, svaka mora biti funkcionalna prije sljedece) i eksplicitnoj potvrdi kraja faze prije nastavka. Cilj: imati radni Flutter app od scratch-a do funkcionalne mini verzije s mock-free live podacima.

### 3.1 Faza 1 — Scaffold

**Opseg:** Kreiranje Flutter projekta, konfiguracija dependencies, osnovna 3-tab navigacija, tamna tema.

**Kljucni elementi:**
- `flutter create --org com.coinsight --project-name coinsight .` -> 131 fajl
- `pubspec.yaml` postavljen s pocetnim dependency setom (http, provider, hive, intl)
- `lib/main.dart` — `CoinSightApp` (StatelessWidget, MaterialApp s `darkTheme`), `MainNavigation` (StatefulWidget s `BottomNavigationBar`, 3 taba: Watchlist/Analysis/Settings)
- `lib/theme/app_theme.dart` — sve definicije boja centralizirane u jednoj klasi: primary `#6C63FF`, secondary `#03DAC6`, background `#121212`, surface `#1E1E1E`, card `#252525`, error `#CF6679`, green `#4CAF50`, red `#EF5350`. AppBarTheme (elevation 0, centerTitle), CardThemeData (borderRadius 12), InputDecorationTheme (filled, borderRadius 12)
- Stub screenovi: `watchlist_screen.dart`, `analysis_screen.dart`, `settings_screen.dart` — samo `Center(Text)` placeholderi
- Direktoriji kreirani: `lib/{screens,widgets,services,models,theme}/`
- `test/widget_test.dart` — osnovni navigation render test (Watchlist/Analysis/Settings findable)

**Verifikacija:** `flutter analyze` 0 issues, `flutter build windows` uspjelo — `coinsight.exe` generiran.

### 3.2 Faza 2 — CoinGecko + Watchlist

**Opseg:** Prvi eksterni API (CoinGecko), Coin data model, state provider, funkcionalan Watchlist ekran s dvije podtabe (My Watchlist / Top Coins), skeleton loading, pull-to-refresh, error handling.

**Kljucni elementi:**

`lib/models/coin.dart` — 12 polja (`id`, `symbol`, `name`, `image`, `currentPrice`, `marketCap`, `marketCapRank`, `priceChangePercentage24h`, `high24h`, `low24h`, `totalVolume`, `sparklineIn7d`). Null-safe `fromJson` s `?? 0` fallbackom za sve `num` polja. Sparkline se parsira iz nested `json['sparkline_in_7d']?['price']`.

`lib/services/coingecko_service.dart` — `CoinGeckoService` klasa s `http.Client` dependency injection (omogucava mock testiranje). Base URL `https://api.coingecko.com/api/v3`. Dvije metode:
- `getMarketData()` — parametri `vs_currency`, `order`, `per_page`, `page`, `sparkline`, optional `ids` (za fetch specificnih coinova). Vraca `List<Coin>`.
- `searchAndFetch(String query)` — `/search` endpoint pa `getMarketData` s top 10 rezultata.

Status code handling: 200 parse, 429 rate limit exception, ostalo generic exception. Custom `CoinGeckoException` klasa.

`lib/models/watchlist_provider.dart` — `ChangeNotifier` s 5 state polja (`_topCoins`, `_watchlistCoins`, `_watchlistIds` kao Set, `_isLoading`, `_error`). Default watchlist: bitcoin/ethereum/solana. Metode `fetchTopCoins()`, `refreshWatchlist()`, `toggleWatchlist(coinId)`, `_updateWatchlistCoins()` (filter topCoins po watchlistIds).

`lib/widgets/sparkline_chart.dart` — `SparklineChart` StatelessWidget s `CustomPainter`. Racuna min/max/range podataka, crta `Path` s `strokeWidth 1.5`, `StrokeCap.round`. `shouldRepaint` provjerava data i color.

`lib/widgets/coin_card.dart` — `CoinCard` StatelessWidget. Layout: Row s rankom (SizedBox 28w), ikonicom (Image.network 36x36, s errorBuilderom), name/symbol stupac (Expanded flex:3), sparkline-om (conditional), price/change stupcem (Expanded flex:3), zvjezdicom (GestureDetector). Formatiranje cijene: `NumberFormat.currency` za >=1, `toStringAsFixed(6)` za <1. Boja change postotka: zelena za >=0, crvena za <0, s `arrow_drop_up/down` ikonom.

`lib/screens/watchlist_screen.dart` — `StatefulWidget` s `SingleTickerProviderStateMixin`, `TabController(length: 2)`. `Consumer<WatchlistProvider>` za reaktivnost. `RefreshIndicator` pull-to-refresh. Empty state (star_border + tekst), error state (cloud_off + Retry button). `ListView.builder` za kartice.

**Verifikacija:** 0 analyze issues, Windows build OK.

### 3.3 Faza 3 — Anthropic Claude integracija

**Opseg:** Drugi eksterni API (Anthropic), ClaudeService, AnalysisProvider, chat UI.

**Kljucni elementi:**

`lib/services/claude_service.dart` — `ClaudeService` klasa s `http.Client` injection. Konstante: `_baseUrl = https://api.anthropic.com/v1/messages`, `_model = claude-sonnet-4-20250514`, `_apiVersion = 2023-06-01`. `hasApiKey` getter, `setApiKey(String)`. Glavna metoda `sendMessage()`:
- Prima `userMessage`, `history` (List<ChatMessage>), optional `systemPrompt`
- POST s headers: `Content-Type`, `x-api-key`, `anthropic-version`
- Body: `model`, `max_tokens: 1024`, `messages`, `system`
- Parsira response `content` blokove filtrirane po `type == 'text'`
- Error handling: 401 (invalid key), 429 (rate limit), ostalo parsira `error.message` iz response body-ja

`ChatMessage` klasa (role, content, timestamp, toJson) unutar istog fajla. `ClaudeException` custom.

`lib/models/analysis_provider.dart` — `ChangeNotifier`. `_systemPrompt` inicijalno 5-line generic "crypto assistant" tekst (kasnije zamijenjeno u Session 2). Konstruktor prima optional `ClaudeService`. State: `_messages` (List<ChatMessage>), `_isLoading`, `_error`. Metode:
- `sendMessage(text, {watchlistCoins})` — dodaje user poruku odmah, salje s history-jem (sve osim zadnje poruke), dodaje assistant response. Na gresku: uklanja user poruku, seta error
- `_buildUserMessage()` — ako postoje coins, dodaje formatiranu listu (name, symbol, price, 24h change, mcap rank) ispred pitanja
- `setApiKey()`, `clearChat()`

`lib/widgets/chat_bubble.dart` — `ChatBubble` StatelessWidget. `Align: centerRight` za user, `centerLeft` za assistant. Container: maxWidth 80% screena, asymmetric margin. User bubble: `primary.withAlpha(0.2)`, assistant: `#252525`. `BorderRadius` asymmetric (user: bottomRight 4, assistant: bottomLeft 4). **`SelectableText`** za copy podrsku.

`lib/screens/analysis_screen.dart` — kompletno prepisano iz stuba (274 linije). `StatefulWidget` s `TextEditingController` + `ScrollController`. Pet state widgeta:
- `_buildNoApiKeyState` — key icon + poruka "Add your Anthropic API key in Settings"
- `_buildEmptyState` — auto_awesome icon + 3 `ActionChip` suggestion chipa
- `_buildMessageList` — `ListView.builder` + typing indicator na kraju ako loading
- `_buildTypingIndicator` — spinner + "Thinking..." tekst
- `_buildInputBar` — delete button + TextField (maxLines 4) + send `IconButton`

`_scrollToBottom()` koristi `Future.delayed(100ms)` za pravi moment nakon build-a.

**Verifikacija:** 0 issues.

### 3.4 Faza 4 — Hive Storage + Settings

**Opseg:** Lokalna persistencija za API key i watchlist, funkcionalni Settings ekran.

**Kljucni elementi:**

`lib/services/storage_service.dart` — sve metode static. Dvije box konstante (`settings`, `watchlist`), dva field-a (`anthropic_api_key`, `watchlist_ids`). `init()` poziva `Hive.initFlutter()` + `Hive.openBox()` za oba. API Key metode (`getApiKey`, `saveApiKey`, `deleteApiKey`), Watchlist metode (`getWatchlistIds` s default fallbackom, `saveWatchlistIds`).

`lib/models/watchlist_provider.dart` — konstruktor sad cita: `_watchlistIds = Set<String>.from(StorageService.getWatchlistIds())`. `toggleWatchlist()` nakon svake promjene poziva `StorageService.saveWatchlistIds()` — persist svaki klik.

`lib/models/analysis_provider.dart` — konstruktor cita `StorageService.getApiKey()`, ako postoji poziva `_claudeService.setApiKey()`. `setApiKey()` sada i sprema (`StorageService.saveApiKey()`). Nova `removeApiKey()`: clear client + `deleteApiKey()`.

`lib/screens/settings_screen.dart` — kompletno prepisano (220 linija). `StatefulWidget` s TextEditingController + `_obscureKey` bool. Dvije sekcije:
- `_buildApiKeySection()` — Row s key icon + "Anthropic API Key" + status badge (Active zeleni / Not set narancasti). TextField s obscureText i visibility toggle suffix. Save/Remove buttons s validacijom.
- `_buildAboutSection()` — Version 1.0.0, Market Data CoinGecko, AI Analysis Claude, Divider, disclaimer tekst

`lib/main.dart` — `main()` sada `async`, `WidgetsFlutterBinding.ensureInitialized()` + `await StorageService.init()` prije `runApp`.

**Verifikacija:** 0 issues, Windows build OK.

### 3.5 Faza 5 — Polish

**Opseg:** Error handling na oba HTTP servisa, skeleton loading, UX poboljsanja.

**Kljucni elementi:**

`lib/services/coingecko_service.dart` — `import 'dart:async'` za TimeoutException. Konstanta `_timeout = Duration(seconds: 15)`. Svi HTTP pozivi: `try { ... .timeout(_timeout) } on TimeoutException`. JSON decode: `try { json.decode } on FormatException`.

`lib/services/claude_service.dart` — isti timeout pattern (ali s 30s, Claude pozivi dulji), `FormatException` catch za response i error body. Response validation: `data['content'] as List<dynamic>?` + null/empty check.

`lib/widgets/coin_card.dart`:
- `Image.network`: dodan `loadingBuilder` koji prikazuje `_buildFallbackIcon()` dok se slika ucitava
- Star toggle: wrappano u `AnimatedSwitcher(duration: 250ms, transitionBuilder: ScaleTransition)` s `ValueKey(isWatchlisted)`
- **Novi widget `CoinCardSkeleton`** (StatefulWidget): AnimationController(1200ms repeat reverse), shimmer Row imitirajuci layout CoinCarda. Boja: `Colors.grey[800]!.withValues(alpha: _animation.value)`.

`lib/screens/watchlist_screen.dart` — Nova metoda `_buildSkeletonList()`: ListView.builder s 8 CoinCardSkeleton widgeta. Loading state zamijenjen iz `CircularProgressIndicator` u skeleton list.

`lib/screens/analysis_screen.dart`:
- `bool _disposed = false` field, double guard u `_scrollToBottom()` (prevent use-after-dispose race)
- TextField: `enabled: !provider.isLoading`, hint mijenja u "Waiting for response..." tijekom loading-a
- Error bar: wrappan u `Dismissible` + X button
- Confirm dialog za clear chat
- `clearError()` metoda na AnalysisProvider

`lib/main.dart`:
- `StorageService.init()` wrappan u `try/catch` — app se pokrece i ako init failira
- `Scaffold.body`: **`_screens[_currentIndex]` zamijenjeno s `IndexedStack`** — cuva stanje svih tabova (ne rebuilda Watchlist kad prelazis na Analysis)

**Verifikacija:** 0 issues, test 2/2, Windows build OK.

### 3.6 Post-Session 1 — Audit, Documentation, Git Setup

Nakon Faze 5, izvrsen je **dvostruki audit** (dva paralelna Claude Code agenta):

**Agent 1 (code audit):** procitao svih 14 Dart fajlova. Rezultati: 0 kriticnih bugova, 0 nedostajucih imports, svi provideri pravilno wired, svi dispose() na mjestu, null safety strict compliant, nema hardkodiranih secretsa. Pronasao: 2 nekoristene dependencies (`flutter_dotenv`, `url_launcher`), 1 nekoristena metoda (`searchAndFetch`).

**Agent 2 (project checks):** `flutter analyze` 0 issues, `flutter test` **FAIL** (Hive not initialized u testu), git not initialized, no .env files, Windows Runner.rc ima generic metadata.

**Cleanup izvrsen:**
- `pubspec.yaml`: uklonjeno `url_launcher` i `flutter_dotenv` — ukupno 10 paketa obrisano
- `.gitignore`: dodano `.env`, `.env.*`, `*.env`, `.hive/`, `chat_log.md`, `work_log.md`
- `windows/runner/Runner.rc`: metadata apdejtan (CompanyName, FileDescription, ProductName)
- `test/widget_test.dart`: `setUpAll` koristi `Directory.systemTemp.createTempSync()` za Hive init
- `LICENSE` kreiran: Proprietary Software License (Session 4 ce ga zamijeniti MIT)
- `README.md`, `WORKLOG.md` kreirani
- `git init`, initial commit `5691f2e`

**Session 1 rezultat:** funkcionalan MVP s CoinGecko live podacima, Claude chat-om, Hive persistencijom, dark temom, polish elementima (skeletons, timeouts, error handling, IndexedStack).

---

## 4. Session 2 (2026-04-12) — Nove funkcionalnosti

Kontekst: izmedu sesija developer je pushao projekt na GitHub (remote origin postavljen, branch renamed master->main). Dodani su novi spec fajlovi: `CLAUDE_CODE_PROMPT.md` i `SESSION_2.md` (5 zadataka). Cilj sesije: implementirati **core feature** (New Listings tab), redesignati Claude prompt, auto-logirati analize, verificirati Android build.

### 4.1 Zadatak 1 — New Listings Tab (core feature)

**Opseg:** Novi tab kao default pri otvaranju app-a, prikazuje coinove s early momentum profilom filtrirane po volume i market cap ranku, sortirane po 1h price change.

**Kljucni elementi:**

`lib/models/coin.dart` — dodano polje `final double? priceChangePercentage1h` (nullable — CoinGecko ne vraca uvijek). Dodano u `fromJson()`: `priceChangePercentage1h: (json['price_change_percentage_1h_in_currency'] as num?)?.toDouble()`

`lib/services/coingecko_service.dart` — Nova metoda `getNewListings({vsCurrency, perPage})`:
- Endpoint `/api/v3/coins/markets` s `order=volume_desc`, `per_page=100`, `price_change_percentage=1h,24h`
- **Frontend filter:**
  - `marketCapRank == 0 || marketCapRank > 500` — eliminira established coinove
  - `totalVolume >= 50000 && totalVolume <= 50000000` — eliminira ghost coinove i whale manipulacije
  - `priceChangePercentage24h != 0` — eliminira stale coinove
- **Sort:** po `priceChangePercentage1h` descending (null -> 0)

`lib/models/watchlist_provider.dart` — Nova polja: `_newListings`, `_newListingsTimer`. Metode `fetchNewListings()`, `startNewListingsAutoRefresh()` (Timer 3 min), `stopNewListingsAutoRefresh()`. `dispose()` cancel timer.

`lib/screens/watchlist_screen.dart` — TabController 2->3. Tab order: **New Listings (index 0, default)**, My Watchlist, Top Coins. Timer management: index 0 -> startAutoRefresh, ostalo -> stopAutoRefresh.

`lib/widgets/coin_card.dart` — Novi prop `show1hChange` (default false). Nova metoda `_buildChangeBadge(double change, String label)` — Container s padding, color.withAlpha(0.15), borderRadius 4. Prikazuje "1H" label + "+X.X%" value.

### 4.2 Zadatak 2 — Claude sistemski prompt redesign

**Opseg:** Zamjena generickog engleskog prompta precizno kalibriranim HR promptom za momentum coin analizu.

Stari prompt (5 linija): "You are CoinSight, an AI assistant specialized in cryptocurrency analysis..."

Novi prompt (30 linija HR teksta):
1. **Uloga:** "CoinSight — specijalizirani AI analiticar za rano otkrivanje momentum prilike na cryptocurrency trzistu"
2. **Korisnikov profil:** "iskusan tehnicar i analiticar" — ne objasnjava osnove
3. **Objektiv 1 — Profil listinga:** Volume organicnost, volume/mcap odnos, exchange tier, market cap rank
4. **Objektiv 2 — Rizik profil:** Pump-and-dump znakovi, 1h/24h konzistentnost, volume/price bearish divergence
5. **Objektiv 3 — Preporuka:** jedna od tri oznake na **zasebnoj liniji u Markdown bold-u**: `**WATCH**`, `**SKIP**`, `**INTERESTING**` + razlog + konkretan sljedeci korak
6. **Pravila:** ne garantira profit, analiza obrazaca ne financijski savjet
7. **Jezik:** HR ako korisnik pise HR, EN ako EN

Ovo je **bitna arhitekturalna odluka** jer `**WATCH**`/`**SKIP**`/`**INTERESTING**` postaju **machine-parsable markeri** koje ostatak app-a koristi za auto-logging (Zadatak 3) i Trade Action Bar (Session 3 Faza F).

### 4.3 Zadatak 3 — Analysis Logging

**Opseg:** Automatsko logiranje Claude AI analiza u Hive storage, parsiranje preporuka iz odgovora.

`lib/models/analysis_log.dart` (novi fajl) — 6 polja: `timestamp`, `coinId`, `coinSymbol`, `priceAtAnalysis`, `claudeRecommendation`, `recommendationType`. `toMap/fromMap` za Hive.

**Kljucna metoda `static String parseRecommendationType(String claudeResponse)`:**
```dart
if (claudeResponse.contains('**INTERESTING**')) return 'INTERESTING';
if (claudeResponse.contains('**WATCH**')) return 'WATCH';
if (claudeResponse.contains('**SKIP**')) return 'SKIP';
return 'NONE';
```

Redoslijed je kritican: `INTERESTING` ide prvo (najspecificnije), ako bi `WATCH` isao prvi a odgovor sadrzi oboje, zamijenili bismo specifican marker za manje specifican.

`lib/services/storage_service.dart` — Nova konstanta `_analysisLogBox = 'analysis_logs'`, dodano u `init()`. Metode `saveAnalysisLog()` (auto-increment key) i `getAnalysisLogs()` (sort po timestamp desc).

`lib/models/analysis_provider.dart` — Nova metoda `_tryLogAnalysis(String response, List<Coin>? coins)`: parsira tip, ako nije 'NONE' logira s coin podacima (ili fallback), response trunciran na 500 chars.

### 4.4 Zadatak 4 — CHATLOG.md

Kreiran `CHATLOG.md` template za **rucno** biljezenje ishoda Claude analiza 24–48h nakon preporuke. Svrha: **long-term kalibracija Claude prompta**.

### 4.5 Zadatak 5 — Android Build Verifikacija

`flutter build apk --debug` — uspjesan (203s). Output: `build/app/outputs/flutter-apk/app-debug.apk`.

**Session 2 rezultat:** app vise nije samo "browse + chat" tool — postao je **signal-driven tool** s jasnom taksonomijom (WATCH/SKIP/INTERESTING) koja je podloga za buducu automatizaciju, i **audit trail-om** (AnalysisLog).

---

## 5. Session 3 (2026-04-15) — Binance + Telegram + Portfolio

Kontekst: Session 2 zavrsio s funkcionalnom analizom ali bez trading izvrsavanja. Session 3 dodaje **direktno povezivanje signal -> trade** kroz Binance Spot API (Faza 2 — manualna potvrda, Faza 3 — auto-execute), Telegram Bot za remote signalizaciju i komande, te **Portfolio screen** kao 4. tab.

SESSION_3.md spec dao je 8 zadataka u 7 faza (A–G). Implementirano: Faze A–F (kod). Faza G (end-to-end live test) **blokirana** zbog Binance 2FA problema.

### 5.1 Arhitekturalne odluke donesene prije koda

**1. Izbor exchange-a.** Developer pitao za alternative Binanceu (Revolut isplata kao zahtjev). Razmotreni: Kraken (dobar API, premalo new listingsa), Bitpanda, Coinbase, Revolut Crypto (nema API). **Odluka:** Binance — jedini ima small-cap momentum listinge koji su core funkcija appa. Isplate: Binance -> SEPA EUR -> Revolut IBAN.

**2. Testnet vs live.** Developer odbio testnet, ide odmah live. Preporuka: za prvi trade `maxTradeAmountUsdt=5`, `maxOpenPositions=1`, `stopLoss=10%`, `autoTradeEnabled=false`.

**3. API kljucevi.** Developer pitao mogu li se hardkodirati. **Kategoricki odbijeno:** repo je javan na GitHubu, Binance ima leak-detection koji auto-disable-a kljuceve.

### 5.2 Faza A — pubspec + StorageService credential extension

**`pubspec.yaml`:** +3 dependencies: `flutter_local_notifications: ^18.0.0`, `crypto: ^3.0.3`, `convert: ^3.1.1`.

**`lib/services/storage_service.dart`** (60->147 linija): Novi 4. box `positions`. Nove field konstante i metode za Binance credentials (apiKey, secret, testnet) i Telegram credentials (token, chatId).

### 5.3 Faza B — Modeli

Cetiri nova modela:

**`lib/models/coin_position.dart`** — 9 polja: `coinId`, `symbol`, `binanceSymbol`, `quantity`, `entryPrice`, `entryTotal`, `entryTime`, `currentPrice?` (mutable), `stopLossOrderId?`. Computed getteri: `currentValue`, `pnlAbsolute`, `pnlPercent`, `isProfit`. `toMap/fromMap` za Hive.

**`lib/models/risk_parameters.dart`** — 8 polja s razumnim defaultima: `maxTradeAmountUsdt: 10.0`, `maxOpenPositions: 3`, `stopLossPercent: 15.0`, `takeProfitPercent: 30.0`, `autoTradeEnabled: false`, `telegramNotifications: false`, `quietHoursStart: 23`, `quietHoursEnd: 7`. **Kljucni getter `isQuietHours`** s wraparound logikom za prijelaz preko ponoci. `copyWith()` za immutable update pattern.

**`lib/models/trade_proposal.dart`** — 8 polja (coin, amountUsdt, estimatedQty, currentPrice, stopLossPrice, takeProfitPrice, claudeRecommendation, createdAt). **`isExpired`:** >60s od kreiranja (cijena se moze znacajno promijeniti za small-cap coinove).

**`lib/models/trade_result.dart`** — 6 polja (success, orderId?, executedPrice?, executedQty?, totalUsdt?, errorMessage?). `.failure(String)` factory.

### 5.4 Faza C — BinanceService

**Najkompleksniji dio Session 3.** Binance REST zahtijeva HMAC-SHA256 potpis za authenticated endpointe.

**`lib/services/binance_service.dart`** (~270 linija, Session 3 verzija; kasnije prosireno u Session 5):

**`BinanceException`** custom exception s optional `int? code`. **`BinanceOrder`** klasa s computed `avgPrice = cummulativeQuoteQty / executedQty`.

**BinanceService:**
- URL switching: `_prodUrl` (api.binance.com) / `_testnetUrl` (testnet.binance.vision)
- HMAC-SHA256 potpis: `_sign(queryString)` koristi `Hmac(sha256, key)` iz `crypto` paketa
- Signed query: dodaje `timestamp` (Unix ms) + `recvWindow=5000` + `signature`
- Error mapping: -1021 (timestamp sync), -2010 (insufficient balance), -1100/-1121 (bad symbol)
- 6 public metoda: `ping()`, `getUsdtBalance()`, `getCurrentPrice(symbol)`, `placeBuyOrder(symbol, quoteAmount)`, `placeSellOrder(symbol, quantity)`, `getOrderHistory(symbol)`
- Timeout 15s svuda

### 5.5 Faza D — TradeService + TelegramService

**`lib/services/trade_service.dart`** (~160 linija) — centralna trade orkestracija:

**`prepareTradeProposal()`**: fetch price, racuna estimatedQty/SL/TP, vraca TradeProposal s 60s expiry.

**`executeTrade(proposal)`** — redoslijed validacija:
1. Check `proposal.isExpired`
2. Check maxOpenPositions
3. Check duplicate position
4. Check USDT balance
5. `binance.placeBuyOrder()` — **jedina ireverzibilna akcija**
6. Kreira CoinPosition s actual executed podacima
7. Logira AnalysisLog s `recommendationType = 'ENTERED'`

**`autoExecuteIfEligible()`**: gate na autoTradeEnabled + !isQuietHours + hasCredentials + limits.

**`checkStopLosses()`**: iterira pozicije, fetcha cijenu, ako price <= SL ili >= TP -> closePosition.

**`closePosition()`**: market sell, brise iz Hive, logira EXITED s P&L.

**`lib/services/telegram_service.dart`** (~185 linija, Session 3 verzija — **zamijenjeno TelegramMonitor-om u Session 4**):
- Notification bot: sendMessage, sendInterestingSignal, sendTradeExecuted, sendStopLossTriggered
- Polling (5s) + command handler (/status, /stop, /start)

### 5.6 Faza E — Portfolio Screen + Settings Update

**`lib/models/portfolio_provider.dart`** — 4. ChangeNotifier provider. State: `_usdtBalance`, `_positions`, `_priceTimer`. Computed getteri: `totalInvested`, `totalValue`, `totalPnl`, `totalPnlPercent`. `_refreshPrices()` iterira pozicije, za svaku fetch current price. `startAutoRefresh()` Timer 30s.

**`lib/screens/portfolio_screen.dart`** — `AutomaticKeepAliveClientMixin`. **Kljucna optimizacija:** `_providerRef` cuva provider za safe dispose (izbjegava `context.read` u dispose). Tri sekcije: Header Card (balance, P&L), Open Positions lista s CLOSE button, Analysis History (zadnjih 20 logova s obojenim chipovima).

**`lib/screens/settings_screen.dart`** — prosireno na ~700 linija. Tri nove sekcije: Binance API (key/secret/testnet/test/remove), Risk Parameters (sliders, dropdowns, quiet hours), Telegram Bot (token, chatId, test).

### 5.7 Faza F — Analysis Trade Action Bar + main.dart 4 taba

**Trade Action Bar eligibility logika u `analysis_screen.dart`:**
- Last msg je INTERESTING assistant
- Binance spojen
- Nije auto-trade mode
- Watchlist nije prazan

**UI:** Zeleni okvir s header "INTERESTING signal — SYMBOL/USDT", editable amount TextField, 3 buttona: **BUY NOW** (zeleni), **SKIP** (outlined), **TELEGRAM** (outlined).

**`_buyNow()`:** prepare proposal -> confirm dialog -> execute trade -> SnackBar -> dismiss bar.
**`_skip()`:** logira AnalysisLog tipa SKIP za dataset kalibracije.

**`lib/main.dart`** (90->125 linija): MultiProvider +PortfolioProvider, 4 taba, background services (Telegram polling gated, stop-loss Timer 5min gated na credentials), `_handleTelegramCommand` minimalni handler.

### 5.8 Faza G — End-to-end live test (BLOCKED)

**Status: BLOCKED — Binance 2FA problem kod developera.** SMS kod ne stize, API Management samo na desktop webu. Kod 100% spreman.

**Session 3 rezultat:** end-to-end signal-driven trading pipeline od CoinGecko browsinga -> Claude analize -> Binance Spot izvrsavanja -> Portfolio pracenja -> Telegram notifikacija. Ceka live verifikaciju.

---

## 6. Session 4 (2026-04-16) — v2.0.0 Final Release

Kontekst: Session 3 zavrsila s kompletnim kodom ali bez testova i s TelegramService koji je bio notification bot (salje poruke korisniku). Session 4 cilj: dovesti projekt do production-ready stanja za javni open source release. Nema novih featurea — samo refactoring, testovi, cleanup, dokumentacija.

### 6.1 Faza 1 — Telegram Refactoring: Service -> Monitor

**Najbitnija arhitekturalna promjena u Session 4.** TelegramService je bio **notification bot** (salje poruke korisniku, prima komande). Zamijenjen je s **TelegramMonitor** — pasivni citac javnih kanala koji primljene signale koristi kao **kontekst za Claude analizu**.

**Obrisano:** `lib/services/telegram_service.dart` (185 linija)

**Kreirano:**

`lib/services/telegram_monitor.dart` (~135 linija):
- Pasivni citac: koristi `getUpdates` polling (10s interval) za primanje poruka iz javnih kanala
- Bot mora biti dodan kao admin/member u svaki kanal (korisnik to radi rucno)
- Keyword filter: listing, whale, alert, i slicno
- `onSignalReceived` callback za dostavu signala AnalysisProvider-u
- `testConnection()` za getMe provjeru
- Default kanali: @binance, @kucoincom, @whale_alert, @coingecko, @coinmarketcap
- **Ne salje poruke korisniku** — samo prima i filtrira

`lib/models/telegram_signal.dart` (24 linije):
- Model za primljeni signal: text, channelTitle, channelUsername, timestamp, messageId
- `preview` getter (truncate 150 chars)
- `toClaudeContext()` formatter za ubacivanje u Claude prompt

**Integracijske promjene:**

`lib/models/analysis_provider.dart` — dodan TelegramMonitor + `_pendingSignals` lista (max 10). `onSignalReceived` callback dodaje signale. `_buildUserMessage()` ukljucuje pending signale kao `[TELEGRAM INTELLIGENCE]` kontekst blok ispred korisnikove poruke. Nove metode: `startTelegramMonitor()`, `stopTelegramMonitor()`, `testTelegramMonitor()`, getter `pendingSignalsCount`.

`lib/main.dart` — uklonjen TelegramService, dodan `context.read<AnalysisProvider>().startTelegramMonitor()` u initState.

`lib/screens/analysis_screen.dart` — uklonjen TELEGRAM button iz Trade Action Bar, dodan signal badge widget iznad chat liste.

`lib/screens/settings_screen.dart` — uklonjena Telegram Bot sekcija, dodana "Intelligence — Telegram Monitor" sekcija (token, default kanali chips, custom kanali, monitoring toggle).

### 6.2 Faza 3 — Kompletni Test Suite

**Od 2 testa do 97 testova.** Dodana dependency `mocktail: ^1.0.4`.

**Test infrastruktura:**
- `test/helpers/test_fixtures.dart` — centralizirani test podaci: btcCoin(), newListingCoin(), openPosition(), defaultRisk(), aggressiveRisk(), coinJson() factory, mock responses za Binance/Telegram
- `test/helpers/mock_http_client.dart` — MockHttpClient (mocktail), HttpClientFactory s helper metodama

**17 test fajlova:**

| Kategorija | Fajl | Testova | Pokriva |
|-----------|------|---------|---------|
| Unit/Models | coin_test.dart | 6 | fromJson kompletni/nullable, 1h change, sparkline |
| Unit/Models | coin_position_test.dart | 7 | pnl profit/loss/breakeven, null fallback, roundtrip |
| Unit/Models | risk_parameters_test.dart | 4 | defaults, copyWith, roundtrip, missing fields |
| Unit/Models | analysis_log_test.dart | 7 | parseRecommendationType prioritet, roundtrip |
| Unit/Models | trade_proposal_test.dart | 3 | isExpired false/true/boundary |
| Unit/Models | trade_result_test.dart | 2 | failure factory, success fields |
| Unit/Models | telegram_signal_test.dart | 3 | preview truncate/short, toClaudeContext |
| Unit/Services | coingecko_service_test.dart | 7 | getMarketData 200/429/timeout, getNewListings filter/sort |
| Unit/Services | claude_service_test.dart | 11 | sendMessage success/no-key/401/429/timeout, hasApiKey |
| Unit/Services | binance_service_test.dart | 12 | ping, hasCredentials, balance, buy/sell, errors |
| Unit/Services | trade_service_test.dart | 8 | prepare, execute expired/max/duplicate, auto disabled |
| Unit/Services | telegram_monitor_test.dart | 6 | isConfigured, testConnection |
| Widget | coin_card_test.dart | 5 | name/symbol, star, toggle, skeleton |
| Widget | chat_bubble_test.dart | 3 | user/assistant align, selectable text |
| Widget | sparkline_chart_test.dart | 3 | valid/empty/single data |
| Integration | app_navigation_test.dart | 4 | 4 nav tabs, API key required, sections |
| Legacy | widget_test.dart | 6 | navigation render, tab switching |

**Ukupno Session 4: 97 testova.**

### 6.3 Faza 4 — Projekt Cleanup i Arhiviranje

- Kreiran `archive/` folder s `README.md`
- Premjesteni stari spec fajlovi u archive/: SESSION_2.md, SESSION_3.md, SESSION_4.md, CLAUDE_CODE_PROMPT.md, PROJECT_OVERVIEW.md, USER_MANUAL.md, chat_log.md, work_log.md
- `.gitignore` dodan: `*.hive`, `*.lock.hive`, `/archive/*.md`, `*.secret`
- `pubspec.yaml` version: `1.0.0+1` -> `2.0.0+2`

### 6.4 Faza 5 — MIT Licenca

**`LICENSE`** — Proprietary Software License zamijenjen s **MIT**. Provjera: 0 proprietary/confidential referenci u lib/, 0 hardkodiranih API kljuceva.

### 6.5 Faza 6 — Dokumentacija

- `MANUAL.md` (~120 linija) — korisnicki prirucnik: setup, koristenje, risk management
- `OVERVIEW.md` (~80 linija) — tehnicki pregled: arhitekturalni principi, podatkovni tok dijagram, sigurnosni model
- `README.md` kompletno prepisan za public audience
- `CLAUDE.md` kompletno prepisan: identitet, pravila rada, arhitektura, API integracije, Hive boxovi

### 6.6 Faza 7 — Android Build Fix

`flutter build apk --debug` inicijalno pukao. **Fix:** dodano `isCoreLibraryDesugaringEnabled = true` i `coreLibraryDesugaring` dependency u `android/app/build.gradle.kts` — `flutter_local_notifications` zahtijeva core library desugaring za API level kompatibilnost.

**Session 4 verifikacija:**
- `flutter analyze` — **0 issues**
- `flutter test` — **97/97 passed**
- `flutter build apk --debug` — **uspjesan**
- Stari TelegramService reference — **0**
- Hardkodirani secreti — **0**

**Session 4 rezultat:** projekt transformiran iz proprietary closed-source s 2 testa u **open source MIT-licenciran** s **97 testova**, cistaim archiveom, i kompletnom dokumentacijom. TelegramService notification bot zamijenjen pasivnim TelegramMonitor intelligence reader-om — fundamentalno bolji pattern za kontekstualizaciju Claude analize.

---

## 7. Session 5 (2026-04-16) — v2.1.0 Bugfixes + Bot Manager + App Management

Kontekst: Session 4 zavrsila s v2.0.0. Session 5 popravlja dva Identified Issues buga (LOT_SIZE precision, timestamp drift), dodaje Bot Manager screen za upravljanje Telegram kanalima s reliability scoring-om, i refaktorira Settings u tabbed App Management screen s 4 taba.

### 7.1 Faza 1 — Bugfix: LOT_SIZE Dynamic Precision

**Problem:** `placeSellOrder` koristio hardkodirani `toStringAsFixed(6)` za quantity. Binance za svaki trading par definira `LOT_SIZE` filter s razlicitim `stepSize` (npr. BTC moze imati 8 decimala, SHIB 0). Hardkodiranih 6 decimala znaci rizik greske `-1013 Filter failure: LOT_SIZE` za coinove koji zahtijevaju drukciju preciznost.

**Rjesenje u `lib/services/binance_service.dart`:**

Dodan `_lotSizeCache` (`Map<String, int>`) za in-memory cache — izbjegava ponovljene API pozive za isti simbol.

Nova metoda `_getLotSizeDecimals(String symbol)`:
1. Check cache — ako postoji, vrati odmah
2. Fetch `/api/v3/exchangeInfo?symbol=X`
3. Parse `filters` array, trazi `filterType == 'LOT_SIZE'`
4. Izvuci `stepSize` string (npr. `'0.00100000'`)
5. Konvertiraj u broj decimala: `_stepSizeToDecimals('0.00100000')` -> 3
6. Cache rezultat i vrati
7. Fallback na 6 ako fetch pukne

`_stepSizeToDecimals(String stepSize)`:
```dart
final normalized = stepSize.replaceAll(RegExp(r'0+$'), '');
final dotIndex = normalized.indexOf('.');
if (dotIndex == -1) return 0;
return normalized.length - dotIndex - 1;
```

`placeSellOrder` sada koristi `await _getLotSizeDecimals(symbol)` umjesto hardkodiranog 6.

### 7.2 Faza 2 — Bugfix: Timestamp Drift Korekcija

**Problem:** `_signedQuery` koristio `DateTime.now().millisecondsSinceEpoch` koji ovisi o sistemskom satu. Ako sat drifta vise od `recvWindow` (5000ms), Binance odbija s error -1021 (TIMESTAMP_OUT_OF_SYNC). Posebno relevantan na Android uredajima koji ponekad kasne s NTP sinkronizacijom.

**Rjesenje u `lib/services/binance_service.dart`:**

Dodan `_serverTimeOffsetMs` field (int, default 0) i `serverTimeOffsetMs` getter.

Nova javna metoda `syncServerTime()`:
1. Fetch `GET /api/v3/time` (public, no auth)
2. Parsira `serverTime` (Unix ms)
3. Racuna offset: `_serverTimeOffsetMs = serverTime - localTime`
4. Na gresku: reset na 0

Dodan `_correctedTimestamp` getter: `DateTime.now().millisecondsSinceEpoch + _serverTimeOffsetMs`

`_signedQuery` sada koristi `_correctedTimestamp` umjesto `DateTime.now()`.

**Auto-sync tocke:**
- `ping()` poziva `syncServerTime()` nakon uspjesnog pinga (Settings "Test Connection" automatski sinkronizira)
- `_throwForResponse` pri -1021 poziva `syncServerTime()` fire-and-forget — sljedeci retry ce imati korigirani offset

**UI:** Test Binance gumb u Manage -> API prikazuje offset u SnackBar poruci (npr. "OK — USDT: $50.00 (offset: +230ms)").

### 7.3 Faza 3 — Telegram Bot Manager Screen

**Opseg:** Full-screen route za upravljanje Telegram kanalima — pregled statistika, dodavanje/uklanjanje kanala, preporuceni kanali.

**`lib/models/monitored_channel.dart`** (~85 linija):
- Polja: `username`, `displayName`, `isDefault`, `signalsReceived`, `signalsRelevant`, `lastSignal`, `isActive`
- **Reliability scoring:**
  - `reliabilityScore` — ako <10 signala vraca -1 (premalo podataka), inace `signalsRelevant / signalsReceived`
  - `reliabilityLabel` — mapira score na: **Novo** (-1), **Niska** (<0.1), **Srednja** (0.1–0.3), **Visoka** (>0.3)
  - `reliabilityColor` — grey/red/orange/green
- `copyWith()`, `toMap/fromMap` za Hive

**`lib/screens/bot_manager_screen.dart`** (~370 linija):
- `StatefulWidget`, `Navigator.push` full-screen route (ne tab)
- 4 sekcije:
  1. **Status Header** — aktivan/neaktivan badge, ukupno kanala, ukupno signala
  2. **Aktivni kanali** — ListView s reliability chip-ovima za svaki kanal, pauziraj/obrisi opcije
  3. **Dodaj kanal** — TextField + validacija usernamea (mora poceti s @)
  4. **Preporuceni kanali** — 7 staticnih predloga: gate_io, mexc, bybit, cointelegraph, cryptonews, defipulse, onchaindata

**StorageService prosirenje:**
- Novi box `monitored_channels_detail` (5. Hive box)
- CRUD metode: `getMonitoredChannelsDetail`, `saveMonitoredChannel`, `updateChannelStats`, `removeMonitoredChannel`, `toggleChannelActive`
- Utility metode: `clearAnalysisLogs`, `resetAll`

**TelegramMonitor prosirenje:**
- `_processUpdate()` sada poziva `StorageService.updateChannelStats()` za sve poruke iz pracenih kanala, s `wasRelevant: true/false` flagom ovisno o keyword filter rezultatu

### 7.4 Faza 4 — App Management Screen Refactoring

**Problem:** settings_screen.dart narastao na ~900 linija — tezak za navigaciju i odrzavanje.

**Rjesenje:** Razdijeljen u 4 tab widgeta unutar `DefaultTabController(length: 4)`. Sva logika (callbacks, state, controllers) ostaje u parent `SettingsScreen`, tab widgeti su `StatelessWidget`-i koji primaju callbacks kao props.

**4 nova widget fajla u `lib/widgets/settings/`:**

1. **`api_settings_tab.dart`** — Anthropic API key sekcija (save/remove/obscure) + Binance API sekcija (key/secret/testnet toggle/test/remove) sa summary cardom
2. **`bot_settings_tab.dart`** — Telegram Monitor token (save/test/remove), default kanali chips, custom kanali (add/remove), monitoring toggle, "Otvori Bot Manager" gumb za navigaciju na BotManagerScreen
3. **`trade_settings_tab.dart`** — Risk Parameters sa summary cardom: maxTradeAmountUsdt TextField, maxOpenPositions Dropdown (1-10), stopLossPercent Slider (5-30%), takeProfitPercent Slider (10-100%), autoTradeEnabled SwitchListTile (gated na Binance konfiguriran), quiet hours TimePicker
4. **`app_settings_tab.dart`** — App Controls sekcija (3 akcije) + About sekcija:
   - **Clear Analysis History** — `_confirmClearLogs()` s confirm dialogom, brise analysis_logs box
   - **Export Logs** — `_exportLogs()` kopira sve logove na clipboard u citljivom formatu
   - **Full Reset** — `_confirmFullReset()` s double-confirm dialogom, brise SVE Hive box-ove

**Main navigation update:**
- Bottom nav label: `Settings` -> `Manage`
- Bottom nav ikona: `Icons.settings` -> `Icons.tune_outlined` / `Icons.tune`
- AppBar title: `Settings` -> `Manage`

**Razlog rename-a:** "Settings" implicira samo konfiguraciju. "Manage" bolje opisuje 4-tab layout koji ukljucuje i operativne akcije (export, reset, bot management).

### 7.5 Faza 5 — Test Azuriranja

**Novi test fajl:**
- `test/unit/models/monitored_channel_test.dart` (8 testova) — reliabilityScore za sve cetiri kategorije (Novo/Niska/Srednja/Visoka), reliabilityLabel/Color provjere, toMap/fromMap roundtrip, copyWith

**Azurirani testovi:**
- `binance_service_test.dart` — +3 testa: serverTimeOffsetMs getter default, syncServerTime offset calc, ping calls syncServerTime
- `widget_test.dart` — Settings -> Manage label provjera
- `app_navigation_test.dart` — Settings -> Manage + provjera 4 tabova (API/Bot/Trade/App)
- Svi test `setUpAll`: dodano `Hive.openBox('monitored_channels_detail')` za 5. box

### 7.6 Faza 6 — Finalizacija

- `pubspec.yaml` version: `2.0.0+2` -> `2.1.0+3`

**Session 5 verifikacija:**
- `flutter analyze` — **0 issues**
- `flutter test` — **108/108 passed**
- `flutter build apk --debug` — **uspjesan**
- `toStringAsFixed(6)` u binance_service.dart — **0** (LOT_SIZE fix verified)

**Session 5 rezultat:** dva kriticna Binance buga popravljeni (LOT_SIZE precision + timestamp drift), Bot Manager dodaje vidljivost u kanal intelligence pipeline, Settings refaktoriran u 4-tab App Management za bolju organizaciju i prosirljivost. Test coverage narastao s 97 na 108 testova.

---

## 8. Session 6 (2026-04-16) — v3.0.0 Full Intelligence Layer

Kontekst: major version bump. Session 5 zavrsila s bugfixevima i Bot Managerom. Session 6 dodaje **multi-source intelligence agregaciju**: Dexscreener (DEX listinzi), GitHub (legitimacy), Reddit (community sentiment), plus existing Telegram i CoinGecko — sve agregirano kroz IntelligenceAggregator s cross-channel scoring sustavom (0–6.0 confluence score). 11 faza, 15 novih fajlova, 84 nova testa.

### 8.1 Faze 1–4 — Intelligence Signal Modeli + Servisi

**Cetiri nova modela** u `lib/models/`:

**`dexscreener_signal.dart`** — DEX listing signal: pairAddress, baseToken, quoteToken, dexId, chainId, priceUsd, volumeUsd24h, liquidityUsd, priceChange1h/24h, pairCreatedAt. Computed getteri: `ageHours`, `volumeLiquidityRatio`, `hasMinimumLiquidity` ($10k), `isFresh` (<=24h). `fromJson()` i `toClaudeContext()`.

**`github_signal.dart`** — GitHub repo signal: repoName, description, language, stars, starsToday, forks, openIssues, pushedAt, createdAt, topics. Computed: `ageDays`, `isRecentlyActive` (<=7d), `starVelocity`, `hasCryptoTopics` (14 crypto keyword-a). `fromJson()` i `toClaudeContext()`.

**`reddit_signal.dart`** — Reddit post signal: postId, title, subreddit, upvotes, comments, upvoteRatio, mentionedSymbols. Computed: `ageHours`, `isFresh` (<=12h), `momentumScore` (upvotes*ratio/hours).

**`intelligence_report.dart`** — centralni agregirani model. Per-source signali + **Scoring Engine**: dexScore (0–2, veci weight jer je najspecificniji izvor), githubScore (0–1), redditScore (0–1), telegramScore (0–1), marketScore (0–1). `confluenceScore` (0–6.0), `scoringHint` (STRONG_INTERESTING / POSSIBLE_WATCH / WEAK_SIGNAL / LIKELY_SKIP / INSUFFICIENT_DATA), `scoreColor`, `toClaudeContext()` formatiran report za Claude.

**Cetiri nova servisa** u `lib/services/`:

**`dexscreener_service.dart`** — Dexscreener API klijent. Pokriva 6 chainova (ethereum, bsc, solana, polygon, arbitrum, base). `getNewPairs()` s filterima: min liquidity $10k, min volume $5k, max age 48h, ignoriraj stablecoins i large caps. `searchBySymbol()` vraca par s najvise likvidnosti. Rate limit zastita 200ms izmedu chainova.

**`github_intelligence.dart`** — GitHub Search API klijent. `searchNewCryptoRepos()` trazi po 5 crypto topica (zadnjih 24h) s deduplikacijom. `searchByCoinName()` za specifican coin. `getTrendingCryptoToday()` za trending crypto repoe. `getRemainingRateLimit()` provjera. 500ms rate limit delay.

**`reddit_monitor.dart`** — Reddit JSON API klijent. 5 subreddita (CryptoMoonShots, altcoin, CryptoCurrency, defi, SatoshiStreetBets). `getNewPosts()` s filterima: min 10 upvotes, max 6h starost. `_extractSymbols()` regex za uppercase 2–10 char simbole s ignore listom. `searchBySymbol()`. 300ms rate limit delay. Koristi `html` paket za entity decoding.

**`intelligence_aggregator.dart`** — centralni koordinator svih intelligence izvora. `startAutoScan()` s 15min intervalom. Paralelni fetch (`Future.wait`) svih izvora. `_findCrossSourceMatches()` trazi coinove koji se pojavljuju u vise izvora. `buildReportForSymbol()` za on-demand report. `onHighScoreSignal` callback za score >= 3.0. Cache zadnjeg skena.

**Nova dependency:** `html: ^0.15.4` za Reddit HTML entity decoding.

### 8.2 Faze 5–6 — Integracija u postojecu arhitekturu

**IntelligenceAggregator integracija:**
- `telegram_monitor.dart` prosiren s `_recentSignals` cache-om (max 50), `getRecentSignalsForSymbol()`, `recentSignals` getter
- `coingecko_service.dart` prosiren s `searchBySymbol()` metodom

**AnalysisProvider kompletno azuriran:**
- Dodan `IntelligenceAggregator` field, `_lastReport`, `_isGatheringIntelligence`
- Konstruktor prima optional intelligence param, registrira `onHighScoreSignal` callback
- `_buildUserMessage()` sada **prioritizira** IntelligenceReport (ako postoji) > watchlist + telegram signali — intelligence report je strukturiraniji i informativniji kontekst za Claude
- Nova metoda `gatherIntelligenceForCoin()` za on-demand analizu specificnog coina
- Lifecycle: `startIntelligenceMonitoring()` (gated na hasApiKey), `stopIntelligenceMonitoring()`

**System prompt prosiren** s cross-channel analitickim instrukcijama:
- Confluence score interpretacija (5–6 / 3–4.9 / 1.5–2.9 / <1.5)
- Izvor ponderiranje (DEX > Telegram whale > GitHub > Reddit)
- Edge cases (activeSources < 2, bez DEX ali visok TG/Reddit, DEX bez GitHub)

**`main.dart`:** `startTelegramMonitor()` zamijenjen s `startIntelligenceMonitoring()`.

### 8.3 Faze 7–9 — UI: DEX Early Tab + Intelligence Dashboard

**Watchlist DEX Early tab:**
- Novi widget `lib/widgets/dex_signal_card.dart` — `DexSignalCard`: dexId badge (purple), chainId badge (blue), token symbol/name, cijena, 1h change, Vol/Liq/V-L ratio stats, "Analiziraj" gumb
- `WatchlistProvider` prosiren s DexscreenerService, `_dexListings`, `_isDexLoading`, `_dexRefreshTimer`. Metode: `fetchDexListings()`, `startDexAutoRefresh()` (10min), `stopDexAutoRefresh()`
- `WatchlistScreen` prosiren na **4 sub-taba**: DEX Early (default) | New Listings | My Watchlist | Top Coins. `isScrollable: true` TabBar. DEX tab s DexSignalCard listom + "Analiziraj" gumb koji poziva `gatherIntelligenceForCoin()`

**Intelligence Dashboard (Portfolio screen):**
- Nova `_buildIntelligenceSection()` s 3 stanja: gathering (spinner), no report (radar icon + hint), report card (confluence score bar, 5 source indikatora s kruznim badgeovima, scoring hint)

### 8.4 Faze 10–11 — Testovi i Finalizacija

**84 nova testa u 7 novih test fajlova:**

| Fajl | Testova | Pokriva |
|------|---------|---------|
| `dexscreener_signal_test.dart` | 13 | fromJson, computed getteri (age, V/L ratio, freshness, liquidity) |
| `github_signal_test.dart` | 13 | fromJson, computed getteri (activity, velocity, crypto topics) |
| `reddit_signal_test.dart` | 6 | fromJson, preview, momentum score, freshness |
| `intelligence_report_test.dart` | 27 | scoring engine, confluence, hints, activeSources, toClaudeContext |
| `dexscreener_service_test.dart` | 7 | getNewPairs filter/sort, searchBySymbol, error handling |
| `github_intelligence_test.dart` | 10 | searchNewCryptoRepos, rate limit, error handling |
| `reddit_monitor_test.dart` | 7 | getNewPosts, symbol extraction, error handling |

**Session 6 verifikacija:**
- `flutter analyze` — **0 issues**
- `flutter test` — **192/192 passed** (+84 od v2.1.0)
- `flutter build apk --debug` — **uspjesan**
- `pubspec.yaml` — `2.1.0+3` -> `3.0.0+4`

**Session 6 rezultat:** CoinSight transformiran iz single-source intelligence app-a (samo Telegram + CoinGecko) u **multi-source intelligence platformu** s 5 nezavisnih izvora, kvantitativnim confluence scoring-om, i strukturiranim intelligence reportom koji Claude koristi za informiranu analizu. Intelligence podaci su **in-memory only** (nema novih Hive box-ova) — svjestan izbor za izbjegavanje stale data problema.

---

## 8A. Session 7 (2026-04-16) — v4.0.0 Three-Tier Investment Framework

Kontekst: Session 6 zavrsila s v3.0.0 multi-source intelligence platformom. Session 7 dodaje **Three-Tier Investment Framework** — fundamentalna promjena iz single-strategy app-a u multi-strategy platformu s tri investicijska horizonta (SHORT/MID/LONG), svaki s vlastitim modelima, UI komponentama, i Claude prompt prilagodama. 11 faza, 6 novih fajlova, 40 novih testova.

### 8A.1 Faze 1–3 — Tier modeli i provider

**Tri nova modela** u `lib/models/`:

**`investment_tier.dart`** — `InvestmentTier` enum s tri vrijednosti: `SHORT`, `MID`, `LONG`. Svaki tier ima `label`, `description`, `color`, i `icon` getere. Helper metode za tier-specific suggestion chipove i action bar konfiguraciju.

**`mid_term_project.dart`** — MidTermProject model za MID tier: `projectId`, `coinId`, `coinSymbol`, `coinName`, `entryPrice`, `targetPrice`, `catalystDescription`, `deadline`, `notes`, `status` (ACTIVE/COMPLETED/ABANDONED), `createdAt`, `updatedAt`. Computed getteri: `progressPercent` (koliko je cijena napredovala prema targetu), `daysRemaining`, `isOverdue`. `toMap/fromMap` za Hive.

**`long_term_holding.dart`** — LongTermHolding model za LONG tier: `holdingId`, `coinId`, `coinSymbol`, `coinName`, `thesis` (zasto drzis coin), `dcaPurchases` (List<DcaPurchase>, svaki s price/quantity/date), `fundamentalsNotes`, `createdAt`, `updatedAt`. Computed getteri: `averagePrice`, `totalQuantity`, `totalInvested`, `currentValue`. `DcaPurchase` nested klasa. `toMap/fromMap` za Hive.

**`tier_provider.dart`** — 4. ChangeNotifier provider. State: `_currentTier` (default SHORT), `_midTermProjects`, `_longTermHoldings`. CRUD metode: `createMidProject()`, `updateMidProject()`, `completeMidProject()`, `abandonMidProject()`, `createLongHolding()`, `addDcaPurchase()`, `updateHoldingThesis()`. Persistencija u dva nova Hive box-a. `switchTier()` metoda za tier prebacivanje.

### 8A.2 Faze 4–5 — StorageService + Hive prosirenje

**StorageService** prosiren s dva nova box-a (`mid_term_projects`, `long_term_holdings`) u `init()`. CRUD metode za oba modela: `saveMidTermProject()`, `getMidTermProjects()`, `deleteMidTermProject()`, `saveLongTermHolding()`, `getLongTermHoldings()`, `deleteLongTermHolding()`, `addDcaPurchaseToHolding()`.

### 8A.3 Faze 6–7 — UI: TierModeSelector + Settings Tab

**`lib/widgets/tier_mode_selector.dart`** — `TierModeSelector` StatelessWidget. Horizontalni Row s 3 `ChoiceChip`-a (SHORT/MID/LONG), svaki s tier-specific bojom. `Consumer<TierProvider>` za reaktivnost. Ugradjen u `MainNavigation` ispod AppBara — vidljiv na svim tabovima.

**`lib/widgets/settings/tier_settings_tab.dart`** — novi 4. tab u Manage screenu. Prikazuje: aktivni tier summary, MID tier postavke (default target %, katalyst reminder), LONG tier postavke (DCA iznos, DCA interval), tier statistike (broj projekata/holdinga).

**`settings_screen.dart`** — `DefaultTabController(length: 5)`, dodan Tiers tab izmedu Trade i App.

### 8A.4 Faze 8–9 — Screen integracije

**AnalysisProvider** prosiren s tier-aware logikom:
- `_buildUserMessage()` sada ukljucuje tier kontekst u Claude prompt
- System prompt prosiren s tier-specificnim instrukcijama (MID: catalyst/timeline fokus, LONG: fundamentals/DCA fokus)
- Novi suggestion chipovi per tier (3 za svaki tier)
- MID Action Bar (CREATE PROJECT / SKIP) i LONG Action Bar (CREATE HOLDING / DCA BUY / SKIP) u analysis_screen.dart

**WatchlistScreen** prosiren s **Projekti** pod-tabom (vidljiv u MID tier-u) — prikazuje aktivne MidTermProject kartice s progress barom, catalyst opisom, i deadline indikatorom.

**PortfolioScreen** prosiren s tier-aware prikazom:
- SHORT tier: postojeci prikaz (USDT balance, open positions, P&L)
- MID tier: MidTermProject lista s progress, catalyst, status chipovima
- LONG tier: LongTermHolding lista s average DCA price, total quantity, thesis, DCA history

**`main.dart`** — MultiProvider +TierProvider (4. provider). TierModeSelector banner dodan u Scaffold body.

### 8A.5 Faze 10–11 — Testovi i finalizacija

**40 novih testova u 4 nova test fajla:**

| Fajl | Testova | Pokriva |
|------|---------|---------|
| `investment_tier_test.dart` | 6 | enum values, labels, colors, suggestion chips per tier |
| `mid_term_project_test.dart` | 10 | CRUD, progressPercent, daysRemaining, isOverdue, status transitions, toMap/fromMap |
| `long_term_holding_test.dart` | 12 | CRUD, DCA purchases, averagePrice, totalQuantity, thesis update, toMap/fromMap |
| `tier_provider_test.dart` | 12 | switchTier, createMidProject, createLongHolding, addDcaPurchase, persistence |

**Session 7 verifikacija:**
- `flutter analyze` — **0 issues**
- `flutter test` — **232/232 passed** (+40 od v3.0.0)
- `flutter build apk --debug` — **uspjesan**
- `pubspec.yaml` — `3.0.0+4` -> `4.0.0+5`

**Session 7 rezultat:** CoinSight transformiran iz single-strategy momentum trading app-a u **multi-strategy investment platformu** s tri jasno odvojena investicijska horizonta. Svaki tier ima vlastite modele, UI komponente, Claude prompt prilagodbe, i portfolio prikaz. Korisnik moze koristiti sve tri strategije istovremeno (npr. SHORT momentum + LONG DCA na BTC) jer su tier podaci potpuno odvojeni u zasebnim Hive box-ovima.

---

## 8B. Session 8 (2026-04-16) — v5.0.0 Detail Screens + DEX Position Tracking

Kontekst: Session 7 zavrsila s v4.0.0 Three-Tier frameworkom. Session 8 dodaje **detail screenove** za MID projekte i LONG holdinge, **DEX Position Tracking** za rucno pracenje trade-ova s decentraliziranih burzi, te **MID Discovery** i **LONG Research** pod-tabove. 10 faza, 4 nova fajla, 11 novih testova.

### 8B.1 Faze 1–3 — DexPosition model + DEX Position Screen

**Novi model** `lib/models/dex_position.dart` — DexPosition za rucno pracenje DEX trade-ova: positionId, tokenSymbol, tokenAddress, entryPrice, quantity, dexId, chainId, stopLossPrice, takeProfitPrice, currentPrice, status, createdAt. Computed getteri: currentValue, pnlAbsolute, pnlPercent, isStopLossHit, isTakeProfitHit. toMap/fromMap za Hive.

**Novi screen** `lib/screens/dex_position_screen.dart` — rucni unos DEX trade-ova, automatski price refresh putem Dexscreener API-ja, SL/TP vizualno upozorenje. Integrirano u Portfolio SHORT prikaz.

### 8B.2 Faze 4–5 — MidProjectDetailScreen + LongHoldingDetailScreen

**Novi screen** `lib/screens/mid_project_detail_screen.dart` — detaljan ekran za MID projekt: editiranje thesis, GitHub linka, entry plana, upravljanje statusom (ACTIVE/COMPLETED/ABANDONED), dodavanje biljeski. Dostupan iz Analysis MID Action Bara, MID Discovery taba, i Portfolio MID sekcije.

**Novi screen** `lib/screens/long_holding_detail_screen.dart` — detaljan ekran za LONG holding s 4 taba: Osnove (coin info, thesis, prosjecna cijena), Fundamentali (team, tech, adoption, tokenomics), DCA (lista kupnji, dodavanje novih, prosjecna cijena), Biljeske (slobodne biljeske). Dostupan iz Portfolio LONG sekcije.

### 8B.3 Faze 6–7 — MID Discovery + LONG Research pod-tabovi

**MID Discovery** pod-tab u Watchlist screenu — prikazuje live GitHub trending kripto projekte s naglim porastom zvjezdica i aktivnosti. Korisno za otkrivanje MID-term prilika.

**LONG Research** pod-tab u Watchlist screenu — prikazuje filtrirani top 200 coinova po market capu, optimizirano za fundamentalnu analizu dugorocnih ulaganja.

### 8B.4 Faze 8–9 — Portfolio FAB buttons + Settings Web3 Wallet

**FAB (Floating Action Button)** dodani u Portfolio MID i LONG prikaze za brzo kreiranje novih projekata/holdinga. MID FAB otvara MidProjectDetailScreen, LONG FAB otvara LongHoldingDetailScreen.

**Web3 Wallet address** polje dodano u Settings API tab za povezivanje s DEX pozicijama.

**StorageService** prosiren s novim box-om `dex_positions` (8. Hive box) i CRUD metodama za DexPosition.

### 8B.5 Faza 10 — Testovi i finalizacija

**11 novih testova** za DexPosition model, detail screenove, i DEX position CRUD.

**Session 8 verifikacija:**
- `flutter analyze` — **0 issues**
- `flutter test` — **267/267 passed** (+11 od v4.0.0)
- `flutter build apk --debug` — **uspjesan**
- `pubspec.yaml` — `4.0.0+5` -> `5.0.0+6`

**Session 8 rezultat:** CoinSight prosiren s detail screenovima za upravljanje MID projektima i LONG holdingima, DEX Position Tracking za rucno pracenje decentraliziranih trade-ova, te MID Discovery i LONG Research pod-tabovima za bolje otkrivanje prilika po tier-u.

---

## 8C. Session 9 (2026-04-16) — v6.0.0 Charts & Visualization + Push Notifications

Kontekst: Session 8 zavrsila s v5.0.0 Detail Screens + DEX Position Tracking. Session 9 dodaje **interaktivne tier-aware price chartove** s CoinGecko historical data, **AI predikcije** kao chart overlay, i **push notifikacije** za SL/TP/INTERESTING alerte. 10 faza, 5 novih fajlova, 24 nova testa.

### 8C.1 Faze 1–3 — Chart Data Model + Service

- `lib/models/price_chart_data.dart` — PriceChartData model: historijski OHLC podaci, tier-specificni raspon (SHORT 10d+24h, MID 6m+30d, LONG 2y+6m), predikcijska linija
- `lib/services/chart_data_service.dart` — ChartDataService: CoinGecko `/coins/{id}/market_chart` endpoint za historijske podatke, tier-aware range selekcija, predikcija kalkulacija

### 8C.2 Faze 4–5 — PriceChartWidget + ChartScreen

- `lib/widgets/price_chart_widget.dart` — PriceChartWidget: CustomPainter-based interaktivni chart s touch crosshair-om, grid linijama, predikcijskom isprekidanom linijom, responsive layout
- `lib/screens/chart_screen.dart` — ChartScreen: full-screen tier-aware prikaz, tier label u AppBaru, loading/error states, prediction accuracy disclaimer

### 8C.3 Faze 6–7 — Push Notifications Service

- `lib/services/notification_service.dart` — NotificationService: flutter_local_notifications integracija, tri kanala (SL alert, TP alert, INTERESTING signal), Android notification channel setup, permission handling

### 8C.4 Faze 8–9 — Integracija u postojecu arhitekturu

- CoinCard dobio chart ikonu za navigaciju na ChartScreen
- Analysis screen dobio chart ikonu u AppBaru
- TradeService integriran s NotificationService za SL/TP alerte
- AnalysisProvider integriran za INTERESTING push notifikacije
- Settings dobio notification toggle kontrole

### 8C.5 Faza 10 — Testovi i finalizacija

**24 nova testa** za PriceChartData model, ChartDataService, NotificationService, PriceChartWidget, i ChartScreen.

**Session 9 verifikacija:**

- `flutter test` — **267/267 passed** (+24 od v5.0.0)
- `flutter analyze` — 0 issues

**Session 9 rezultat:** CoinSight prosiren s interaktivnim tier-aware chartovima koji prikazuju historijske cijene s AI predikcijskim overlayem, te push notifikacijama za SL/TP alerte i INTERESTING signale. Chart data flow: CoinGecko -> ChartDataService -> PriceChartData -> PriceChartWidget.

---

## 8D. Session 10 (2026-04-16) — v7.0.0 P&L Dashboard + WalletConnect v2

Kontekst: Session 9 zavrsila s v6.0.0 Charts & Visualization + Push Notifications. Session 10 dodaje **P&L Dashboard** s equity curve-om, win rate-om, R/R ratiom i per-tier breakdownom, **WalletConnect v2** za spajanje eksternog walleta, i **Trade History** za kompletnu evidenciju zatvorenih trade-ova. 10 faza, 5 novih fajlova, 24+ novih testova.

### 8D.1 Faze 1–3 — ClosedTrade model + PnlAnalytics

**Novi model** `lib/models/closed_trade.dart` — ClosedTrade za zatvorene trade-ove: tradeId, coinId, coinSymbol, tier (SHORT/MID/LONG), entryPrice, exitPrice, quantity, pnlAbsolute, pnlPercent, closeReason (SL/TP/MANUAL), openedAt, closedAt. toMap/fromMap za Hive.

**Novi model** `lib/models/pnl_analytics.dart` — PnlAnalytics za racunanje P&L metrika: winRate (postotak profitabilnih trade-ova), avgWin/avgLoss (prosjecni profit/gubitak), rrRatio (risk/reward omjer), equityCurvePoints (kumulativni P&L kroz vrijeme), perTierStats (Map<InvestmentTier, TierStats>). Factory metoda `fromClosedTrades()` za kalkulaciju iz liste zatvorenih trade-ova.

### 8D.2 Faze 4–5 — PnlDashboardScreen

**Novi screen** `lib/screens/pnl_dashboard_screen.dart` — full-screen P&L dashboard s:
- **Equity curve** — CustomPainter graf kumulativnog P&L-a kroz vrijeme
- **Summary kartice** — ukupni P&L, win rate, R/R ratio, broj trade-ova
- **Per-tier breakdown** — odvojene statistike za SHORT, MID, LONG
- **Trade history lista** — kronoloski popis svih zatvorenih trade-ova s detaljima

Pristup iz Portfolio taba putem P&L bannera.

### 8D.3 Faze 6–7 — WalletConnect v2 integracija

**Novi service** `lib/services/wallet_service.dart` — WalletService: WalletConnect v2 protokol integracija, `connect()` za spajanje walleta (QR kod/deep link), `disconnect()`, `getAddress()`, `initiateSwap()` za pokretanje token swapova. Zahtijeva Project ID s cloud.reown.com.

**Novi widget** `lib/widgets/wallet_connect_button.dart` — WalletConnectButton: UI widget za prikaz konekcijskog statusa, spojene adrese (truncirane), i connect/disconnect akcija. Integriran u Portfolio i Analysis tabove.

### 8D.4 Faze 8–9 — Trade History + integracija

- TradeService prosiren: closePosition() sada kreira ClosedTrade zapis u Hive `closed_trades` box-u
- Portfolio tab: P&L banner s sazetkom za navigaciju na PnlDashboardScreen
- StorageService prosiren s novim box-om `closed_trades` (9. Hive box) i CRUD metodama za ClosedTrade
- Rucno zatvaranje pozicija sada trazi exit price za precizno P&L racunanje

### 8D.5 Faza 10 — Testovi i finalizacija

**24+ novih testova** za ClosedTrade model, PnlAnalytics (win rate, R/R, equity curve, per-tier), PnlDashboardScreen, WalletService, i WalletConnectButton.

**Session 10 verifikacija:**

- `flutter test` — **280/280 passed** (+24 od v6.0.0)
- `flutter analyze` — 0 issues

**Session 10 rezultat:** CoinSight prosiren s P&L Dashboard-om za centralizirani pregled performansi (equity curve, win rate, R/R ratio, per-tier breakdown), WalletConnect v2 za spajanje eksternih walleta i iniciranje swapova, te Trade History za kompletnu evidenciju zatvorenih trade-ova.

---

## 9. Trenutno stanje (snapshot 2026-04-16, v7.0.0)

### 9.1 Funkcionalnosti koje rade (kod-level)

**Three-Tier Investment Framework (v4.0.0+):**
- TierModeSelector banner ispod AppBara na svim tabovima — SHORT/MID/LONG prebacivanje
- TierProvider (4. ChangeNotifier) — aktivni tier, MID projects CRUD, LONG holdings CRUD
- MidTermProject model — catalyst tracking, deadline, progress, status lifecycle (ACTIVE/COMPLETED/ABANDONED)
- LongTermHolding model — DCA purchase tracking, average price, thesis, fundamentals notes
- Tier-specific suggestion chipovi u Analysis tabu (3 per tier)
- MID Action Bar (CREATE PROJECT / SKIP) i LONG Action Bar (CREATE HOLDING / DCA BUY / SKIP)
- Tier-aware Portfolio prikaz (SHORT: positions + DEX positions, MID: projects + FAB, LONG: holdings + FAB)
- Projekti pod-tab u Watchlist screenu (MID tier)
- MID Discovery pod-tab — live GitHub trending kripto projekte [v5.0.0]
- LONG Research pod-tab — filtrirani top 200 coinova [v5.0.0]
- Tiers settings tab u Manage screenu (5 tabova ukupno)
- Cetiri Hive box-a: mid_term_projects, long_term_holdings, dex_positions, closed_trades

**Charts & Visualization (v6.0.0):**
- ChartDataService — tier-aware historical data fetch iz CoinGecko (SHORT 10d+24h, MID 6m+30d, LONG 2y+6m)
- PriceChartData model — historijski podaci + predikcijska linija
- PriceChartWidget — CustomPainter interaktivni chart s touch crosshair i prediction overlay
- ChartScreen — full-screen tier-aware prikaz s disclaimer-om
- Pristup: chart ikona na CoinCard-u ili iz Analysis AppBar-a

**Push Notifications (v6.0.0):**
- NotificationService — flutter_local_notifications integracija
- SL/TP alerte — push kad pozicija dostigne stop-loss ili take-profit
- INTERESTING signal push — notifikacija za nove INTERESTING preporuke
- Android notification channels za kategorizaciju

**P&L Dashboard (v7.0.0):**
- PnlDashboardScreen — full-screen dashboard s equity curve, win rate, R/R ratio, per-tier breakdown
- ClosedTrade model — zatvoreni trade s entry/exit price, P&L, tier, razlog zatvaranja
- PnlAnalytics model — racunanje metrika: winRate, avgWin/avgLoss, rrRatio, equityCurvePoints, perTierStats
- Trade History — kronoloski popis svih zatvorenih trade-ova
- P&L banner u Portfolio tabu za brzi pristup dashboardu

**WalletConnect v2 (v7.0.0):**
- WalletService — WalletConnect v2 protokol integracija (connect, disconnect, getAddress, initiateSwap)
- WalletConnectButton widget — UI za wallet konekciju s adresa prikazom
- Project ID konfiguracija putem cloud.reown.com
- Integracija u Portfolio i Analysis tabove

**Detail Screens (v5.0.0):**
- MidProjectDetailScreen — thesis, GitHub link, entry plan, status management, biljeske
- LongHoldingDetailScreen — 4 taba: Osnove/Fundamentali/DCA/Biljeske
- DEX Position Screen — rucni unos trade-ova, auto price refresh, SL/TP monitoring
- DexPosition model — token, entry, qty, DEX, chain, SL/TP razine

**Browsing:**
- Tier-zavisni sub-tabovi u Watchlist screenu: DEX Early (default, auto-refresh 10 min), New Listings (auto-refresh 3 min), My Watchlist, Top Coins + MID Discovery (GitHub trending, MID tier) + LONG Research (top 200 filtrirani, LONG tier) + Projekti (MID tier)
- Filter na New Listings: mcap rank >500, volume $50k–$50M, ne-stale
- Sort na New Listings: po 1h change descending
- CoinCard s ikonicom, simbolom, trenutnom cijenom, 7d sparkline (CustomPainter), 24h change (+ opcionalno 1h badge)
- Star toggle sa animacijom za add/remove iz watchlista
- Pull-to-refresh, skeleton loading, error states s retry, empty states
- Podaci se cuvaju u IndexedStack — tab switch ne rebuilda

**Analiza:**
- Claude chat s HR momentum-focused system promptom (prosirenim za confluence analizu)
- **IntelligenceReport** (ako postoji) se prioritetno ubacuje kao strukturirani kontekst blok s per-source detaljima i confluence score-om
- Fallback na watchlist podaci + Telegram signali ako nema intelligence reporta
- Auto-parse preporuka (WATCH/SKIP/INTERESTING) iz Claude odgovora
- Auto-logiranje svake netrivijalne analize u Hive (`analysis_logs` box)
- Trade Action Bar kad Claude vrati INTERESTING (ako Binance konfig + nije auto-mode)
- Signal badge iznad chata s brojem pending Telegram signala
- SelectableText za copy iz chata
- Dismissible error bar, confirm clear chat, typing indicator

**Trading (Binance Spot):**
- HMAC-SHA256 signed REST klijent
- Testnet/prod URL switch (default testnet)
- **Dynamic LOT_SIZE precision** — per-symbol stepSize iz /api/v3/exchangeInfo s in-memory cache
- **Server time sync** — offset korekcija via /api/v3/time, auto-resync na -1021
- Metode: ping (+syncServerTime), getUsdtBalance, getCurrentPrice, placeBuyOrder (quoteOrderQty), placeSellOrder (dynamic decimals), getOrderHistory
- TradeService: prepareTradeProposal (60s expiry), executeTrade (s validacijama), autoExecuteIfEligible, checkStopLosses, closePosition
- Error mapping: -1021 (sync + auto-retry), -2010 (insufficient), -1100/-1121 (bad symbol)
- Audit trail u AnalysisLog: ENTERED/EXITED/SKIPPED markeri s P&L

**Portfolio:**
- 4. tab (index 2): USDT balance, Open Positions count, Total P&L (obojen)
- Open Positions lista s entry->now cijenama, qty, P&L, SL/TP
- Close Position sa confirm dialogom
- Analysis History (zadnjih 20 logova) s obojenim chipovima
- Auto-refresh cijena 30s dok je Portfolio tab aktivan
- Gated: no-credentials state ako Binance nije spojen

**Telegram Intelligence (Monitor):**
- Pasivno citanje javnih kanala (getUpdates polling, 10s interval)
- Keyword filter za relevantne signale
- Channel stats tracking (signalsReceived, signalsRelevant) u Hive
- Signali automatski ubaceni kao Claude kontekst
- Default kanali: @binance, @kucoincom, @whale_alert, @coingecko, @coinmarketcap

**Multi-Source Intelligence (v3.0.0):**
- IntelligenceAggregator koordinira 5 izvora paralelno (Future.wait)
- Auto-scan svakih 15 minuta, cross-source match detection
- Per-source scoring: DEX (0–2), GitHub (0–1), Reddit (0–1), Telegram (0–1), Market (0–1)
- Confluence score (0–6.0) s kategorizacijom (STRONG_INTERESTING/POSSIBLE_WATCH/WEAK_SIGNAL/LIKELY_SKIP)
- Intelligence Dashboard u Portfolio screenu (confluence bar, 5 source indikatora)
- DEX Early tab u Watchlistu s DexSignalCard widgetima
- On-demand `gatherIntelligenceForCoin()` za specifican coin iz DEX tab-a
- In-memory only — nema Hive persistencije za intelligence (svjestan izbor, izbjegava stale data)

**Bot Manager:**
- Full-screen route za kanal management
- Reliability scoring per kanal (Novo/Niska/Srednja/Visoka s obojenim chipovima)
- Channel statistike: signals received, signals relevant, last signal
- Dodaj/ukloni/pauziraj kanale
- 7 preporucenih kanala (gate_io, mexc, bybit, cointelegraph, cryptonews, defipulse, onchaindata)

**App Management (5 tabova):**
- **API tab:** Anthropic key (save/remove, obscured, status badge) + Binance (key/secret, testnet toggle s live-mode confirm, Save/Test/Remove, withdrawal warning, offset display) + Web3 Wallet address [v5.0.0]
- **Bot tab:** Telegram Monitor token, default/custom kanali, monitoring toggle, Bot Manager link
- **Trade tab:** Risk Parameters (maxTrade, maxPositions, SL/TP sliders, auto-trade toggle, quiet hours TimePicker)
- **Tiers tab [v4.0.0]:** aktivni tier summary, MID tier postavke, LONG tier postavke (DCA iznos/interval), tier statistike
- **App tab:** Clear Analysis History, Export Logs (clipboard), Full Reset, About (version, data sources, disclaimer)

**Background services:**
- New listings Timer (3 min) — samo kad je Watchlist tab aktivan na New Listings pod-tabu
- DEX listings Timer (10 min) — samo kad je Watchlist tab aktivan na DEX Early pod-tabu
- Intelligence auto-scan Timer (15 min) — gated na API key, koordinira svih 5 izvora
- Portfolio prices Timer (30s) — samo dok je Portfolio tab aktivan i Binance spojen
- Stop-loss checker Timer (5 min) — gated na Binance credentials
- Telegram Monitor polling (10s) — gated na monitor token
- Svi timeri se cancelaju u `dispose`

### 9.2 Funkcionalnosti koje NE rade / cekaju

- **Live Binance trade** — nikad nije izvrsen stvarni request na Binance API (developer radi na 2FA recovery)
- ~~**Local notifications**~~ — **IMPLEMENTED u v6.0.0** — NotificationService integriran za SL/TP/INTERESTING alerte
- **Hive TypeAdapters** — trenutno koristimo Map<String, dynamic>; za performance generirati adaptere kroz `build_runner`
- **Server-side stop-loss orders** — trenutno SL radi aplikacija s 5-min tickom (rupa ako app nije pokrenut)
- **Binance EU regulatorne restrikcije** — neke funkcije mozda nedostupne iz HR

### 9.3 Verifikacija (zadnji run 2026-04-16)

```
flutter analyze      → 0 issues
flutter test         → 280/280 passed
flutter build apk    → OK (debug)
flutter build windows → OK (Session 1)
```

### 9.4 Git stanje

- Remote: `origin/main` (javni GitHub repo)
- Licenca: MIT
- Verzija: 7.0.0+8

### Verzijska historija

| Verzija | Datum | Opis |
|---------|-------|------|
| v1.0.0 | 2026-04-12 | Session 1–2: MVP (CoinGecko + Claude + Hive + New Listings) |
| v2.0.0 | 2026-04-16 | Session 3–4: Binance + Telegram Monitor + Portfolio + 97 testova + MIT |
| v2.1.0 | 2026-04-16 | Session 5: LOT_SIZE/timestamp bugfix + Bot Manager + App Management + 108 testova |
| v3.0.0 | 2026-04-16 | Session 6: Intelligence Layer (DEX + GitHub + Reddit agregacija) + 192 testova |
| v4.0.0 | 2026-04-16 | Session 7: Three-Tier Investment Framework (SHORT/MID/LONG) + 232 testova |
| v5.0.0 | 2026-04-16 | Session 8: Detail Screens + DEX Position Tracking + MID Discovery/LONG Research + 243 testova |
| v6.0.0 | 2026-04-16 | Session 9: Charts & Visualization + Push Notifications + 267 testova |
| v7.0.0 | 2026-04-16 | Session 10: P&L Dashboard + WalletConnect v2 + Trade History + 280 testova |

### 9.5 Test Coverage Breakdown

| Kategorija | Fajlova | Testova | Pokriva |
|-----------|---------|---------|---------|
| Unit/Models | 20 | 168 | coin, coin_position, **closed_trade**, **pnl_analytics**, **dex_position**, risk_parameters, analysis_log, trade_proposal, trade_result, telegram_signal, monitored_channel, dexscreener_signal, github_signal, reddit_signal, intelligence_report, investment_tier, mid_term_project, long_term_holding, tier_provider, **price_chart_data** |
| Unit/Services | 11 | 86 | coingecko, claude, binance (+LOT_SIZE +timeSync), trade, telegram_monitor, dexscreener, github_intelligence, reddit_monitor, **chart_data_service**, **notification_service**, **wallet_service** |
| Widget | 5 | 18 | coin_card, chat_bubble, sparkline_chart, **price_chart_widget**, **wallet_connect_button** |
| Integration | 1 | 4 | app navigation (4 tabs, sections) |
| Screen | 3 | 10 | dex_position_screen, detail_screens, **chart_screen**, **pnl_dashboard_screen** |
| Legacy | 1 | 9 | widget_test navigation + tab switching |
| **UKUPNO** | **41** | **280** | |

### 9.6 Identified Issues

1. **Binance account lockout (developer):** SMS 2FA ne stize, duplicate account na broju — blokira live testing. Status: developer planira live chat / Account Appeal.
2. **API Management only on desktop web:** Binance limit, ne nas bug.
3. ~~**LOT_SIZE precision hardcoded**~~ — **FIXED u Session 5 Faza 1** — dynamic stepSize fetch s in-memory cache
4. ~~**Timestamp drift**~~ — **FIXED u Session 5 Faza 2** — server time sync via /api/v3/time s auto-resync na -1021
5. ~~**GitHub API rate limit (60 req/h)**~~ — **FIXED u Session 7** — rate limiting optimiziran, scan interval podesiv
6. ~~**Reddit rate limiting**~~ — **FIXED u Session 7** — dulji delay implementiran, graceful degradation
7. ~~**Dexscreener pair age accuracy**~~ — **FIXED u Session 7** — fallback na creation block timestamp
8. ~~**MID Discovery pod-tab prazan**~~ — **FIXED u Session 8** — implementiran live GitHub trending prikaz
9. ~~**LONG Research pod-tab prazan**~~ — **FIXED u Session 8** — implementiran filtrirani top 200 prikaz
10. **DEX auto-sell nije moguc** — DEX pozicije zahtijevaju rucno zatvaranje na DEX-u jer app nema wallet signing sposobnost. SL/TP vizualno upozorava + **push notifikacija dodana u v6.0.0** (korisnik dobije alert, ali mora rucno prodati na DEX-u).
11. ~~**Push notifications za DEX SL/TP**~~ — **ADDRESSED u Session 9** — flutter_local_notifications integriran za SL/TP/INTERESTING alerte kroz NotificationService.
12. **CoinGecko historical data limiti** — besplatni API tier ima ogranicen raspon historijskih podataka. LONG tier (2y) moze dobiti nepotpune podatke za manje poznate coinove. Graceful degradation implementiran.
13. **Prediction accuracy** — AI predikcije na chartovima su eksperimentalne. Nema backtesting validacije. Disclaimer prikazan u UI-ju, ali korisnik moze precjenjivati tocnost.
14. **WalletConnect session persistence** — WalletConnect sesija se gubi kad se app potpuno zatvori. Reconnect je automatski ali moze potrajati 2-3 sekunde pri ponovnom otvaranju.
15. **P&L Dashboard historijski podaci** — Dashboard prikazuje samo trade-ove od v7.0.0 nadalje. Stariji trade-ovi (zatvoreni prije v7.0.0) nemaju ClosedTrade zapis i nece se pojaviti u equity curve-u.

---

## 10. Dokumentacija u repou

| Fajl | Svrha |
|------|-------|
| `CLAUDE.md` | Projektne instrukcije za Claude Code — identitet, pravila rada, arhitektura, API integracije |
| `README.md` | GitHub dokumentacija: Features, Tech Stack, Architecture, Setup, Security, MIT |
| `LICENSE` | MIT License (Copyright (c) 2026 Neven Roksandic) |
| `WORKLOG.md` | Granularni per-sesija log: svaki fajl, linija, komanda, dependency — forenzicki |
| `MANUAL.md` | Korisnicki prirucnik: setup, koristenje tabova, risk management, ceste greske |
| `OVERVIEW.md` | **Ovaj dokument** — narativna konsolidacija kroz sve sesije |
| `archive/` | Stari spec fajlovi: SESSION_2/3/4.md, PROJECT_OVERVIEW.md, USER_MANUAL.md, CLAUDE_CODE_PROMPT.md |

---

## 11. Dependency Manifest

### 11.1 Runtime dependencies

| Paket | Verzija | Svrha | Koristi |
|-------|---------|-------|---------|
| `flutter` | SDK | UI framework | sve |
| `cupertino_icons` | ^1.0.8 | iOS-style ikone | fallback |
| `http` | ^1.4.0 | HTTP klijent | svi servisi |
| `provider` | ^6.1.0 | State management | 4 providera |
| `hive` | ^2.2.3 | Key-value storage | 8 box-ova |
| `hive_flutter` | ^1.1.0 | Hive Flutter binding | StorageService.init() |
| `intl` | ^0.20.0 | Number/date formatting | CoinCard, PortfolioScreen |
| `flutter_local_notifications` | ^18.0.0 | Push notifikacije | NotificationService (SL/TP/INTERESTING alerte) [v6.0.0] |
| `crypto` | ^3.0.3 | HMAC-SHA256 | BinanceService._sign() |
| `convert` | ^3.1.1 | UTF-8/hex encoding | BinanceService._sign() |
| `html` | ^0.15.4 | HTML entity decoding | RedditMonitor (v3.0.0) |
| `walletconnect_flutter_v2` | ^2.x | WalletConnect v2 protokol | WalletService (v7.0.0) |

### 11.2 Dev dependencies

| Paket | Verzija | Svrha |
|-------|---------|-------|
| `flutter_test` | SDK | Widget/integration testovi |
| `flutter_lints` | ^6.0.0 | Lint rules |
| `hive_generator` | ^2.0.1 | TypeAdapter codegen (future) |
| `build_runner` | ^2.4.0 | Codegen runner (future) |
| `mocktail` | ^1.0.4 | Mock testiranje |

### 11.3 Android-specifican setup

`android/app/build.gradle.kts`:
- `isCoreLibraryDesugaringEnabled = true` — potrebno za flutter_local_notifications
- `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:...")` dependency

---

## 12. Sigurnosni model

### 12.1 API kljucevi

| Kljuc | Storage | Transport | Logiranje | Source code |
|-------|---------|-----------|-----------|-------------|
| Anthropic API key | Hive `settings` box | `x-api-key` header (HTTPS) | Nikad | Nikad |
| Binance API key | Hive `settings` box | `X-MBX-APIKEY` header (HTTPS) | Nikad | Nikad |
| Binance API secret | Hive `settings` box | Nikad (samo lokalni HMAC) | Nikad | Nikad |
| Telegram Bot token | Hive `settings` box | URL path (HTTPS) | Nikad | Nikad |

### 12.2 Binance specificno

- API kljuc se kreira **bez Withdrawal permission** (upozorenje u UI-ju)
- HMAC-SHA256 potpis: secret nikad ne napusta uredaj, koristi se samo za lokalni hash racun
- `recvWindow=5000ms` + server time sync za timestamp validaciju
- Testnet/Live toggle s confirm dialogom za prebacivanje na live

### 12.3 .gitignore zastita

```
.env, .env.*, *.env        # Environment files
.hive/, *.hive, *.lock.hive # Hive database files
*.secret                    # Secret files
```

---

## 13. Sljedeci koraci

### 13.1 Neposredno (ceka developera)

1. **Binance 2FA recovery** — live chat / Account Appeal / Google Authenticator setup
2. **Generiranje API kljuca** (bez Withdrawal permission, ideally IP-restricted)
3. **Konfig u Manage -> API:** upis kljuceva, toggle Testnet->LIVE (s confirm), Test -> ocekivano `OK — USDT balance: $X.XX (offset: +Yms)`
4. **Postavljanje konzervativnih risk parametara** za prvi live: `maxTradeAmountUsdt=5, maxOpenPositions=1, stopLossPercent=10, autoTradeEnabled=false`
5. **Prvi rucni trade** kroz Analysis Trade Action Bar -> verificiraj Portfolio tab
6. **Telegram bot setup** (BotFather -> dodaj u kanale -> konfig token u Manage -> Bot)
7. **Git commit** rezultata testiranja

### 13.2 Session 11 kandidati

- ~~**Local notifications integracija**~~ — **IMPLEMENTED u v6.0.0**
- **DEX auto-sell integracija** — wallet signing za automatsko izvrsavanje SL/TP na DEX-ovima (WalletConnect v2 integriran u v7.0.0, ali auto-sell zahtijeva dodatnu implementaciju)
- **Order History screen** — vec postoji `getOrderHistory` metoda, fali UI
- **Analysis Logs screen** — detaljniji view od Portfolio history sekcije, s filter-ima
- **Kalibracija Claude prompta** na osnovu CHATLOG ishoda — iterativno pojacati precision
- **GitHub token u Settings** — za veci API rate limit (5000 req/h vs 60 req/h)
- **Reddit OAuth2** — za pouzdaniji pristup bez rate limiting problema
- **Intelligence history** — Hive persistencija za intelligence reporte (trend tracking)
- **iOS build target** — iOS folder postoji ali nije testiran
- **Hive TypeAdapters** — build_runner generated, za type safety + performance

### 13.3 Dugorocne ideje

- **WebSocket streaming** za real-time cijene pozicija (umjesto 30s REST polling)
- **Server-side stop-loss orders** preko Binance-a (`placeStopLossOrder`) — trenutno SL radi aplikacija s 5-min tickom, sto je rupa ako app nije pokrenut
- **Multi-account support** — vise Binance kljuceva za razlicite strategije
- **Backtest mode** — simulacija strategije na historical podacima iz CoinGecko
- **Export CSV** — Portfolio history i Analysis logs za vanjsku analizu
- **Daily summary scheduler** — midnight timer koji zove summary digest

---

## 14. Arhitekturalni principi (rezime)

### 14.1 Lokalno-first

Svi podaci ostaju na uredaju. Hive baza, API kljucevi, pozicije, logovi — nista ne odlazi na external server osim eksplicitnih API poziva (CoinGecko za market data, Anthropic za AI analizu, Binance za trade izvrsavanje, Telegram za channel reading).

### 14.2 Human-in-the-loop (Faza 2)

Svaki trade zahtijeva korisnikovu potvrdu. Bot predlaze (Trade Action Bar), covjek odlucuje (BUY NOW / SKIP). 60-sekundni expiry na TradeProposal osigurava da korisnik potvrdu daje na relevantnoj cijeni.

### 14.3 Autonomni mod (Faza 3)

Opcionalni, eksplicitno ukljucen od strane korisnika (`autoTradeEnabled` SwitchListTile), s definiranim risk parametrima koji ogranicavaju izlozenost: max trade amount, max open positions, stop-loss, take-profit, quiet hours.

### 14.4 Three-tier investment strategy (v4.0.0)

CoinSight podrzava tri investicijska horizonta kroz TierProvider:
- **SHORT** (default): momentum trading (sati do 48h) — WATCH/SKIP/INTERESTING preporuke, Trade Action Bar, SL/TP automatski
- **MID**: project-based investing (tjedni do mjeseci) — catalyst tracking, MidTermProject CRUD, progress monitoring, Projekti tab
- **LONG**: fundamental investing (mjeseci+) — DCA purchases, LongTermHolding CRUD, thesis documentation, average price tracking

Svaki tier ima **vlastiti Claude prompt kontekst** (tier-specificne instrukcije), **vlastite suggestion chipove** (3 per tier), **vlastiti Action Bar** (SHORT: BUY NOW, MID: CREATE PROJECT, LONG: CREATE HOLDING + DCA BUY), i **vlastiti Portfolio prikaz**. Tier podaci su odvojeni u zasebnim Hive box-ovima — korisnik moze koristiti sve tri strategije istovremeno.

### 14.5 Intelligence layering

Claude AI dobiva do **pet slojeva** konteksta kroz IntelligenceAggregator (v3.0.0):
1. **Dexscreener DEX podaci** (score 0–2) — novi parovi na 6 chainova, likvidnost, volume, age, V/L ratio
2. **GitHub repo aktivnost** (score 0–1) — stars velocity, recent commits, crypto topics, legitimacy signal
3. **Reddit community sentiment** (score 0–1) — upvotes, comments, momentum score, mention frequency
4. **Telegram channel signali** (score 0–1) — listing announcements, whale alerts, vijesti (keyword filter + reliability scoring)
5. **CoinGecko market podaci** (score 0–1) — volume, price change, market cap, sparkline

**Confluence scoring:** zbroj svih izvora (0–6.0) s kategorizacijom: STRONG_INTERESTING (>=4.5), POSSIBLE_WATCH (>=3.0), WEAK_SIGNAL (>=1.5), LIKELY_SKIP (<1.5), INSUFFICIENT_DATA (<2 aktivna izvora). IntelligenceReport se formatira i salje Claudeu kao strukturirani kontekst blok s per-source detaljima i scoring hintom.

### 14.6 Strict MVVM + Provider pattern

Jasna separacija:
- **Services** (HTTP + crypto + intelligence) — CoinGecko, Claude, Binance, Trade, Storage, TelegramMonitor, DexscreenerService, GitHubIntelligence, RedditMonitor, IntelligenceAggregator
- **Models** (data + state) — Coin, CoinPosition, RiskParameters, AnalysisLog, TradeProposal/Result, TelegramSignal, MonitoredChannel, DexscreenerSignal, GitHubSignal, RedditSignal, IntelligenceReport, InvestmentTier, MidTermProject, LongTermHolding + 4 ChangeNotifier providera (WatchlistProvider, AnalysisProvider, PortfolioProvider, TierProvider)
- **Screens** (UI) — Watchlist, Analysis, Portfolio, Settings, BotManager
- **Widgets** (reusable UI) — CoinCard, ChatBubble, SparklineChart, DexSignalCard, TierModeSelector, 5 settings tabova

### 14.7 Podatkovni tok

```
                    ┌─────────────────────────────────────────────────────────┐
                    │           INTELLIGENCE SOURCES (v3.0.0)                 │
                    │                                                         │
Dexscreener API ────┤  6 chainova, new pairs, liquidity      (score 0–2)     │
GitHub Search API ──┤  crypto repos, stars, activity          (score 0–1)     │
Reddit JSON API ────┤  5 subreddita, upvotes, momentum        (score 0–1)     │
Telegram Monitor ───┤  javni kanali, keyword filter           (score 0–1)     │
CoinGecko API ──────┤  market data, volume, price change      (score 0–1)     │
                    └──────────────────────┬──────────────────────────────────┘
                                           ▼
                                 IntelligenceAggregator
                                 (15min auto-scan cycle)
                                           │
                                           ▼
                                 IntelligenceReport
                                 (confluence score 0–6.0)
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    ▼                      ▼                      ▼
           Intelligence            AnalysisProvider          Watchlist
           Dashboard               context builder           DEX Early tab
           (Portfolio)                    │
                                          ▼
Korisnikova poruka ─────────────────► Claude AI ◄──── System Prompt
                                          │            (HR, confluence
                                          ▼             instrukcije)
                               WATCH/SKIP/INTERESTING
                                          │
                          ┌───────────────┴──────────┐
                          ▼                          ▼
                    [FAZA 2]                   [FAZA 3]
               Korisnik potvrdjuje         Auto-execute
                          │                          │
                          └───────────────┬──────────┘
                                          ▼
                                   BinanceService
                                   Market Buy Order
                                          │
                                          ▼
                                   CoinPosition
                                   (Hive storage)
                                          │
                              ┌──────────┴──────────┐
                              ▼                     ▼
                         Stop-Loss            Take-Profit
                       (svakih 5min)        (svakih 5min)
```

### 14.8 Chart Architecture (v6.0.0)

```
CoinGecko API (/coins/{id}/market_chart)
        │
        ▼
ChartDataService
(tier-aware range: SHORT 10d+24h, MID 6m+30d, LONG 2y+6m)
        │
        ▼
PriceChartData
(historijski podaci + predikcijska linija)
        │
        ▼
PriceChartWidget (CustomPainter)
(interaktivni chart s touch crosshair + prediction overlay)
        │
        ▼
ChartScreen (full-screen, tier label, disclaimer)
```

Chart data flow je **jednosmjeran**: CoinGecko -> ChartDataService -> PriceChartData -> PriceChartWidget. Svaki tier definira vlastiti raspon podataka. Predikcija se racuna unutar ChartDataService i prikazuje kao isprekidana linija na chartu.

### 14.9 P&L Analytics Architecture (v7.0.0)

```
closePosition() (TradeService)
        │
        ▼
ClosedTrade (Hive: closed_trades box)
        │
        ▼
PnlAnalytics.fromClosedTrades()
(racuna: winRate, avgWin, avgLoss, rrRatio, equityCurvePoints, perTierStats)
        │
        ▼
PnlDashboardScreen
(equity curve CustomPainter, summary kartice, per-tier breakdown, trade history lista)
```

P&L flow: kad se pozicija zatvori (SL/TP/manual), TradeService kreira ClosedTrade zapis u Hive. PnlDashboardScreen ucitava sve ClosedTrade zapise i racuna analitiku kroz PnlAnalytics factory metodu.

### 14.10 WalletConnect Architecture (v7.0.0)

```
cloud.reown.com (Project ID)
        │
        ▼
WalletService (WalletConnect v2 protokol)
├── connect() → QR kod / deep link → wallet approval
├── disconnect()
├── getAddress() → wallet adresa
└── initiateSwap() → swap request → wallet potvrda
        │
        ▼
WalletConnectButton (UI widget)
(prikaz statusa, adrese, connect/disconnect akcija)
```

WalletConnect flow je **bidirekcijski**: CoinSight salje zahtjev (connect/swap), wallet korisnik odobrava/odbija. Privatni kljucevi NIKAD ne napustaju wallet — WalletConnect je relay-based protokol.

---

## 15. Rezime

CoinSight je u **10 sesija** narastao od praznog Flutter scaffolda do **multi-strategy intelligence-driven investment platforme** s AI analizom kao core logikom odlucivanja, 5 nezavisnih intelligence izvora agregirani kroz kvantitativni confluence scoring sustav, Three-Tier Investment Framework-om za tri razlicita investicijska horizonta, i detail screenovima za upravljanje projektima i holdingima. Arhitektura je **strict MVVM + provider pattern** s jasnom separacijom services / models / screens / widgets. Sigurnost kljuceva je konzervativna: sve lokalno u Hive, nikad u source, `.gitignore` zastita.

**v7.0.0 milestone:**
- **55 lib/ fajl** rasporeden u 6 direktorija (+5 fajlova od v6.0.0)
- **280 testova** (unit models, unit services, widget, screen, integration) s mocktail
- **9 Hive box-ova** za persistenciju (+closed_trades od v7.0.0)
- **8 eksternih API-ja** integrirano (CoinGecko, Anthropic, Binance, Telegram, Dexscreener, GitHub, Reddit, WalletConnect)
- **5-source intelligence agregacija** s confluence scoring (0–6.0)
- **Three-Tier Investment Framework** (SHORT/MID/LONG) s tier-specific modelima, UI komponentama, i Claude prompt prilagodama
- **P&L Dashboard** s equity curve, win rate, R/R ratio, per-tier breakdown i trade history
- **WalletConnect v2** za spajanje eksternih walleta i pokretanje swapova
- **Interaktivni tier-aware chartovi** (SHORT 10d+24h, MID 6m+30d, LONG 2y+6m) s AI predikcijskim overlayem
- **Push notifikacije** za SL/TP alerte i INTERESTING signale kroz NotificationService
- **Detail screenovi** za MID projekte (MidProjectDetailScreen) i LONG holdinge (LongHoldingDetailScreen)
- **DEX Position Tracking** za rucno pracenje decentraliziranih trade-ova
- **MID Discovery** (GitHub trending) i **LONG Research** (top 200 filtrirani) pod-tabovi
- **2 kriticna Binance buga** popravljena (LOT_SIZE, timestamp drift)
- **MIT licenca** za open source distribuciju

Trenutni blocker je **vanjski** (Binance account recovery), kod je verificiran `flutter analyze`/`test` na 0/clean. Kad developer dobije API kljuc, prvi live trade pokrece se iz Manage -> API u 2 minute.

Projekt ima **solidan temelj za Session 11+** — svaka nova funkcionalnost sjeda u jasno definiran sloj (novi service / novi model / novi screen + provider extension), i postojeci pattern-i (skeleton loading, error bar, confirm dialog, status badge header, gated timers, reliability scoring, intelligence aggregation, tier-aware UI) su reusable za nove module.

---

**Generirano:** 2026-04-16
**Verzija:** 7.0.0
**Pokriva sesije:** 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

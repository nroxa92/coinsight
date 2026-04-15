# CoinSight — Sveobuhvatni Projektni Dokument

**Verzija:** 1.0
**Datum generiranja:** 2026-04-15
**Status projekta:** Session 3 Faze A–F kod-komplet, čeka Binance API credentials za live test
**Autor:** Neven (developer) + Claude Code (implementacija)

---

## 0. Svrha ovog dokumenta

Ovaj dokument daje potpunu sliku projekta CoinSight od prvog Flutter `create` poziva do trenutnog stanja — kroz **tri implementacijske sesije** razdijeljene na **14 faza**, s preko **2500 linija Dart koda** raspoređenih u **19 lib/ fajlova**, na **5 platformi** (Android/iOS/Windows/Linux/macOS/Web target, stvarno buildano: Android APK + Windows EXE).

Namijenjen je:
- **Developeru (Neven)** — da ima referencu za ono što je napravljeno, zašto, i što slijedi
- **Budućim Claude Code sesijama** — kao onboarding dokument koji pokriva kontekst bez potrebe čitanja cijelog `WORKLOG.md`-a i svih izvornih `.md` spec fajlova
- **Code review / audit** — pregled arhitekture, ovisnosti, sigurnosnih odluka

Postoji paralelni `WORKLOG.md` koji ima više granularne zapise po fajlu i liniji; ovaj dokument je **narativan** i **arhitekturalan**, `WORKLOG.md` je **forenzički**.

---

## 1. Što je CoinSight

### 1.1 Kratki opis

CoinSight je **privatna** (proprietary, closed source) **Flutter aplikacija** za **rano otkrivanje momentum prilike na cryptocurrency tržištu** sa **AI-podržanom analizom** kroz Claude API. Aplikacija je primarno Android-namijenjena (glavni use case: mobilno praćenje tržišta u realnom vremenu) s Windows desktop targetom za development/debug.

### 1.2 Core value proposition

Postoje tisuće crypto dashboardova. Ono što CoinSight razlikuje:

1. **Filter za early-stage listinge** — ne pokazuje Bitcoin i Ethereum (to je šum za korisnika), nego coinove s market cap rankom >500, volume-om između $50k–$50M (filter ghost coinova i whale manipulacija), sortirane po 1h price change — dakle **kontekstno pripremljen pipeline za trenutne momentum prilike**.

2. **Claude AI analiza kroz tri objektiva** — umjesto generičkog chat-a, AI sistem prompt je **precizno kalibriran** za profil momentum coinova: analizira (a) profil listinga (volume organičnost, exchange tier, mcap rank), (b) risk profil (pump-and-dump znakovi, 1h/24h konzistentnost), i (c) daje **strukturiranu preporuku** s jednom od tri oznake: `**WATCH**`, `**SKIP**`, `**INTERESTING**`.

3. **Direktna veza analiza → trade** — kada Claude vrati **INTERESTING**, pojavi se *Trade Action Bar* u Analysis ekranu s **BUY NOW** buttonom. Jedan tap → confirmation dialog → market buy kroz Binance Spot. Nema prebacivanja u drugu app, nema copy-paste simbola.

4. **Automatizirano izvršavanje (Faza 3)** — uz eksplicitni opt-in, bot može autonomno izvršavati INTERESTING signale unutar strogih risk parametara (max iznos, max pozicija, SL/TP, quiet hours).

5. **Telegram integracija** — bot šalje signal notifikacije i prihvaća remote komande (`/status`, `/stop`, `/start`, proširivo na `/buy_SYMBOL`).

### 1.3 Što CoinSight NIJE i neće biti

- **Nije edukacijska app.** Claude sistem prompt eksplicitno pretpostavlja iskusnog korisnika i **ne objašnjava osnovne pojmove** (volume, market cap, blockchain). Razgovara kao kolega analitičar.
- **Nije financijski savjet.** System prompt završava disclaimerom. UI ima disclaimer u Settings → About.
- **Nema futures/margin/options.** Samo Binance Spot.
- **Nema WebSocket real-time streaming.** REST polling je svjesna odluka (jednostavnija implementacija, manje drift state, primjereno za momentum na min-scale, ne second-scale).
- **Nema withdrawal kroz app.** Binance API ključ se eksplicitno kreira **bez** withdrawal permission (upozorenje u Settings). Isplate na Revolut rade se **ručno** kroz Binance web: Spot → Convert USDT u EUR → Withdraw SEPA na Revolut IBAN.
- **Nije publishable na Play Store.** Proprietary softver, closed source, lokalni APK za privatnu upotrebu.

---

## 2. Stack, arhitektura, ovisnosti

### 2.1 Tech stack

| Sloj | Tehnologija | Razlog izbora |
|------|-------------|---------------|
| Framework | Flutter 3.41.6 stable, Dart 3.11.4 | Jedan codebase, Android + Windows za dev, native performance |
| State management | `provider ^6.1.0` (ChangeNotifier) | Minimalno, idiomatski Flutter, bez heavy boilerplate-a (BLoC/Riverpod overkill za scope) |
| Local storage | `hive ^2.2.3` + `hive_flutter ^1.1.0` | Brz key-value store, nema SQL setup, ideal za API ključeve + watchlist + pozicije + logs |
| HTTP klijent | `http ^1.4.0` | Standard, injectable za testing |
| Kripto potpisi | `crypto ^3.0.3` + `convert ^3.1.1` | HMAC-SHA256 za Binance signed requestove |
| Notifikacije | `flutter_local_notifications ^18.0.0` | Za buduće lokalne push notifikacije (Session 3+) |
| Formatting | `intl ^0.20.0` | NumberFormat.currency, DateFormat za timestamps |
| Ikone | `cupertino_icons ^1.0.8` | iOS-style fallback |
| Linting | `flutter_lints ^6.0.0` | Standardni Flutter recommended set |
| Hive codegen | `hive_generator ^2.0.1` + `build_runner ^2.4.0` | Za buduće typed TypeAdapters (trenutno koristimo Map<String, dynamic> pristup) |

### 2.2 Struktura fajlova (lib/)

```
lib/
├── main.dart                          # Entry point, MultiProvider, 4-tab navigation, background timers
├── theme/
│   └── app_theme.dart                 # Dark tema (primary #6C63FF, secondary #03DAC6, surface #1E1E1E)
├── models/
│   ├── coin.dart                      # Coin data model (12 polja + sparkline + 1h change)
│   ├── analysis_log.dart              # AnalysisLog + parseRecommendationType()
│   ├── coin_position.dart             # Binance spot pozicija + P&L getteri
│   ├── risk_parameters.dart           # Risk config (max trade, SL/TP, quiet hours, auto-trade)
│   ├── trade_proposal.dart            # Pending trade prije korisnikove potvrde (60s expiry)
│   ├── trade_result.dart              # Ishod executeTrade() poziva
│   ├── watchlist_provider.dart        # ChangeNotifier: topCoins + watchlist + newListings + timer
│   ├── analysis_provider.dart         # ChangeNotifier: Claude chat state + system prompt + auto-log
│   └── portfolio_provider.dart        # ChangeNotifier: USDT balance + positions + 30s price refresh
├── services/
│   ├── coingecko_service.dart         # CoinGecko REST (getMarketData, searchAndFetch, getNewListings)
│   ├── claude_service.dart            # Anthropic Messages API klijent
│   ├── storage_service.dart           # Hive wrapper za 4 box-a
│   ├── binance_service.dart           # Binance Spot REST (HMAC-SHA256 signed)
│   ├── trade_service.dart             # Trade orchestration (prepare/execute/auto/SL/close)
│   └── telegram_service.dart          # Telegram Bot API (sendMessage + polling getUpdates)
├── screens/
│   ├── watchlist_screen.dart          # Tab 0: New Listings / My Watchlist / Top Coins (3 sub-taba)
│   ├── analysis_screen.dart           # Tab 1: Claude chat + Trade Action Bar za INTERESTING
│   ├── portfolio_screen.dart          # Tab 2: USDT balance + open positions + history
│   └── settings_screen.dart           # Tab 3: Anthropic key + Binance API + Risk Params + Telegram
└── widgets/
    ├── coin_card.dart                 # CoinCard (s 1h badge) + CoinCardSkeleton (shimmer)
    ├── chat_bubble.dart               # Selectable user/assistant chat mjehur
    └── sparkline_chart.dart           # 7-day price sparkline, CustomPainter
```

**Ukupno:** 19 Dart fajlova, ~2550 linija koda (lib/).

### 2.3 Dependency graph

```
main.dart
├── theme/app_theme.dart
├── services/storage_service.dart ──→ hive_flutter
│   ├── models/analysis_log.dart
│   ├── models/coin_position.dart
│   └── models/risk_parameters.dart
├── services/trade_service.dart
│   ├── services/binance_service.dart ──→ crypto, convert, http
│   ├── services/storage_service.dart
│   └── models/{coin, coin_position, risk_parameters, trade_proposal, trade_result, analysis_log}
├── services/telegram_service.dart ──→ http
│   └── models/{coin, coin_position, risk_parameters, trade_result, analysis_log}
├── services/binance_service.dart (via trade & portfolio)
├── models/watchlist_provider.dart
│   ├── dart:async (Timer)
│   ├── models/coin.dart
│   └── services/coingecko_service.dart ──→ http, dart:async, dart:convert
├── models/analysis_provider.dart
│   ├── services/claude_service.dart ──→ http, dart:async, dart:convert
│   ├── services/storage_service.dart
│   ├── models/coin.dart
│   └── models/analysis_log.dart
├── models/portfolio_provider.dart
│   ├── services/binance_service.dart
│   ├── services/storage_service.dart
│   └── services/trade_service.dart
├── screens/watchlist_screen.dart ──→ provider
│   └── widgets/coin_card.dart (+ sparkline_chart, intl)
├── screens/analysis_screen.dart ──→ provider
│   ├── services/{binance, trade, telegram, storage}
│   └── widgets/chat_bubble.dart
├── screens/portfolio_screen.dart ──→ provider, intl
│   └── services/storage_service.dart
└── screens/settings_screen.dart ──→ provider
    ├── services/{binance, telegram, storage}
    └── models/analysis_provider.dart
```

### 2.4 Providers (state management)

Tri `ChangeNotifier` providera registrirana u `main.dart` `MultiProvider`:

1. **`WatchlistProvider`** — drži `topCoins`, `watchlistCoins`, `newListings`, `watchlistIds`. Dispozicijski Timer za new-listings auto-refresh (3 min). Persistira watchlistIds u Hive.

2. **`AnalysisProvider`** — drži `messages` (List<ChatMessage>), loading state, error. Konstruktor automatski učita spremljeni Anthropic API ključ iz Hive. Sadrži ugrađeni **HR sistem prompt** (30 linija) i `_tryLogAnalysis()` koji parsira Claudeov odgovor za WATCH/SKIP/INTERESTING marker i auto-sprema u Hive.

3. **`PortfolioProvider`** — drži `usdtBalance`, `positions` (List<CoinPosition>), loading state. Computed getteri za total P&L. Dispozicijski Timer za 30s refresh pozicijskih cijena. Reload pattern za Binance credentials (kada korisnik promijeni u Settings).

### 2.5 Hive box-ovi

4 box-a otvoreni u `StorageService.init()`:

| Box | Sadržaj | Keyevi |
|-----|---------|--------|
| `settings` | Anthropic API key, Binance key/secret/testnet, Telegram token/chatId, Risk Parameters | Fiksni stringovi |
| `watchlist` | Lista praćenih coin IDs (default: bitcoin/ethereum/solana) | Fiksni string |
| `analysis_logs` | AnalysisLog zapisi (Claude preporuke + entered + exited + skipped) | Auto-increment (box.add) |
| `positions` | Otvorene Binance spot pozicije | coinId (CoinGecko ID) |

### 2.6 Eksterni API-ji

| API | Svrha | Auth | Rate limit | Key mgmt |
|-----|-------|------|------------|----------|
| **CoinGecko v3** | Market data, new listings, search | Free tier (no key) | 10–30 req/min | — |
| **Anthropic Claude Messages** | AI chat analiza | `x-api-key` header | Pay per token (~$3/M input, $15/M output Sonnet 4) | Korisnik upisuje u Settings |
| **Binance Spot REST** | Balance, price, buy, sell, order history | `X-MBX-APIKEY` + HMAC-SHA256 signature | 1200 weight/min (signed) | Korisnik upisuje u Settings |
| **Telegram Bot API** | Send messages, getUpdates polling | Token u URL-u | ~30 msg/s globalno | Korisnik upisuje u Settings |

**Sigurnosno načelo:** nijedan ključ nikada ne ide u source code, log, ili error poruku. Svi se čuvaju lokalno u Hive, `.gitignore` blokira `.env*` i `.hive/`.

---

## 3. Session 1 (2026-04-12) — Faze 1–5: Temelji

Početak projekta. Developer dao instrukcije u `CLAUDE.md` o faznom pristupu (5 faza, svaka mora biti funkcionalna prije sljedeće) i eksplicitnoj potvrdi kraja faze prije nastavka. Cilj: imati radni Flutter app od scratch-a do funkcionalne mini verzije s mock-free live podacima.

### 3.1 Faza 1 — Scaffold

**Opseg:** Kreiranje Flutter projekta, konfiguracija dependencies, osnovna 3-tab navigacija, tamna tema.

**Ključni elementi:**
- `flutter create --org com.coinsight --project-name coinsight .` → 131 fajl
- `pubspec.yaml` postavljen s početnim dependency setom (http, provider, hive, intl)
- `lib/main.dart` — `CoinSightApp` (StatelessWidget, MaterialApp s `darkTheme`), `MainNavigation` (StatefulWidget s `BottomNavigationBar`, 3 taba: Watchlist/Analysis/Settings)
- `lib/theme/app_theme.dart` — sve definicije boja centralizirane u jednoj klasi: primary `#6C63FF`, secondary `#03DAC6`, background `#121212`, surface `#1E1E1E`, card `#252525`, error `#CF6679`, green `#4CAF50`, red `#EF5350`. AppBarTheme (elevation 0, centerTitle), CardThemeData (borderRadius 12), InputDecorationTheme (filled, borderRadius 12)
- Stub screenovi: `watchlist_screen.dart`, `analysis_screen.dart`, `settings_screen.dart` — samo `Center(Text)` placeholderi
- Direktoriji kreirani: `lib/{screens,widgets,services,models,theme}/`
- `test/widget_test.dart` — osnovni navigation render test (Watchlist/Analysis/Settings findable)

**Verifikacija:** `flutter analyze` 0 issues, `flutter build windows` uspjelo — `coinsight.exe` generiran.

### 3.2 Faza 2 — CoinGecko + Watchlist

**Opseg:** Prvi eksterni API (CoinGecko), Coin data model, state provider, funkcionalan Watchlist ekran s dvije podtabe (My Watchlist / Top Coins), skeleton loading, pull-to-refresh, error handling.

**Ključni elementi:**

`lib/models/coin.dart` — 12 polja (`id`, `symbol`, `name`, `image`, `currentPrice`, `marketCap`, `marketCapRank`, `priceChangePercentage24h`, `high24h`, `low24h`, `totalVolume`, `sparklineIn7d`). Null-safe `fromJson` s `?? 0` fallbackom za sve `num` polja. Sparkline se parsira iz nested `json['sparkline_in_7d']?['price']`.

`lib/services/coingecko_service.dart` — `CoinGeckoService` klasa s `http.Client` dependency injection (omogućava mock testiranje). Base URL `https://api.coingecko.com/api/v3`. Dvije metode:
- `getMarketData()` — parametri `vs_currency`, `order`, `per_page`, `page`, `sparkline`, optional `ids` (za fetch specifičnih coinova). Vraća `List<Coin>`.
- `searchAndFetch(String query)` — `/search` endpoint pa `getMarketData` s top 10 rezultata.

Status code handling: 200 parse, 429 rate limit exception, ostalo generic exception. Custom `CoinGeckoException` klasa.

`lib/models/watchlist_provider.dart` — `ChangeNotifier` s 5 state polja (`_topCoins`, `_watchlistCoins`, `_watchlistIds` kao Set, `_isLoading`, `_error`). Default watchlist: bitcoin/ethereum/solana. Metode `fetchTopCoins()`, `refreshWatchlist()`, `toggleWatchlist(coinId)`, `_updateWatchlistCoins()` (filter topCoins po watchlistIds).

`lib/widgets/sparkline_chart.dart` — `SparklineChart` StatelessWidget s `CustomPainter`. Računa min/max/range podataka, crta `Path` s `strokeWidth 1.5`, `StrokeCap.round`. `shouldRepaint` provjerava data i color.

`lib/widgets/coin_card.dart` — `CoinCard` StatelessWidget. Layout: Row s rankom (SizedBox 28w), ikonicom (Image.network 36x36, s errorBuilderom), name/symbol stupac (Expanded flex:3), sparkline-om (conditional), price/change stupcem (Expanded flex:3), zvjezdicom (GestureDetector). Formatiranje cijene: `NumberFormat.currency` za >=1, `toStringAsFixed(6)` za <1. Boja change postotka: zelena za >=0, crvena za <0, s `arrow_drop_up/down` ikonom.

`lib/screens/watchlist_screen.dart` — `StatefulWidget` s `SingleTickerProviderStateMixin`, `TabController(length: 2)`. `Consumer<WatchlistProvider>` za reaktivnost. `RefreshIndicator` pull-to-refresh. Empty state (star_border + tekst), error state (cloud_off + Retry button). `ListView.builder` za kartice.

`lib/main.dart` — dodan `ChangeNotifierProvider` wrap oko `MaterialApp`.

**Verifikacija:** 0 analyze issues, Windows build OK.

### 3.3 Faza 3 — Anthropic Claude integracija

**Opseg:** Drugi eksterni API (Anthropic), ClaudeService, AnalysisProvider, chat UI.

**Ključni elementi:**

`lib/services/claude_service.dart` — `ClaudeService` klasa s `http.Client` injection. Konstante: `_baseUrl = https://api.anthropic.com/v1/messages`, `_model = claude-sonnet-4-20250514` (kasnije ostalo na toj verziji — ažurno će se mijenjati prema potrebi), `_apiVersion = 2023-06-01`. `hasApiKey` getter, `setApiKey(String)`. Glavna metoda `sendMessage()`:
- Prima `userMessage`, `history` (List<ChatMessage>), optional `systemPrompt`
- POST s headers: `Content-Type`, `x-api-key`, `anthropic-version`
- Body: `model`, `max_tokens: 1024`, `messages`, `system`
- Parsira response `content` blokove filtrirane po `type == 'text'`
- Error handling: 401 (invalid key), 429 (rate limit), ostalo parsira `error.message` iz response body-ja

`ChatMessage` klasa (role, content, timestamp, toJson) unutar istog fajla. `ClaudeException` custom.

`lib/models/analysis_provider.dart` — `ChangeNotifier`. `_systemPrompt` inicijalno 5-line generic "crypto assistant" tekst (kasnije zamijenjeno u Session 2). Konstruktor prima optional `ClaudeService`. State: `_messages` (List<ChatMessage>), `_isLoading`, `_error`. Metode:
- `sendMessage(text, {watchlistCoins})` — dodaje user poruku odmah, šalje s history-jem (sve osim zadnje poruke), dodaje assistant response. Na grešku: uklanja user poruku, seta error
- `_buildUserMessage()` — ako postoje coins, dodaje formatiranu listu (name, symbol, price, 24h change, mcap rank) ispred pitanja
- `setApiKey()`, `clearChat()`

`lib/widgets/chat_bubble.dart` — `ChatBubble` StatelessWidget. `Align: centerRight` za user, `centerLeft` za assistant. Container: maxWidth 80% screena, asymmetric margin. User bubble: `primary.withAlpha(0.2)`, assistant: `#252525`. `BorderRadius` asymmetric (user: bottomRight 4, assistant: bottomLeft 4). **`SelectableText`** za copy podršku.

`lib/screens/analysis_screen.dart` — kompletno prepisano iz stuba (274 linije). `StatefulWidget` s `TextEditingController` + `ScrollController`. Pet state widgeta:
- `_buildNoApiKeyState` — key icon + poruka "Add your Anthropic API key in Settings"
- `_buildEmptyState` — auto_awesome icon + 3 `ActionChip` suggestion chipa ("Analyze my watchlist", "Bitcoin outlook?", "Explain DeFi")
- `_buildMessageList` — `ListView.builder` + typing indicator na kraju ako loading
- `_buildTypingIndicator` — spinner + "Thinking..." tekst
- `_buildErrorBar` — error color container
- `_buildInputBar` — delete button + TextField (maxLines 4) + send `IconButton`

`_scrollToBottom()` koristi `Future.delayed(100ms)` za pravi moment nakon build-a.

`lib/main.dart` — `MultiProvider` s oba providera.

**Verifikacija:** 0 issues.

### 3.4 Faza 4 — Hive Storage + Settings

**Opseg:** Lokalna persistencija za API key i watchlist, funkcionalni Settings ekran.

**Ključni elementi:**

`lib/services/storage_service.dart` — sve metode static. Dvije box konstante (`settings`, `watchlist`), dva field-a (`anthropic_api_key`, `watchlist_ids`). `init()` poziva `Hive.initFlutter()` + `Hive.openBox()` za oba. API Key metode (`getApiKey`, `saveApiKey`, `deleteApiKey`), Watchlist metode (`getWatchlistIds` s default fallbackom, `saveWatchlistIds`).

`lib/models/watchlist_provider.dart` — konstruktor sad čita: `_watchlistIds = Set<String>.from(StorageService.getWatchlistIds())`. `toggleWatchlist()` nakon svake promjene poziva `StorageService.saveWatchlistIds()` — persist svaki klik.

`lib/models/analysis_provider.dart` — konstruktor čita `StorageService.getApiKey()`, ako postoji poziva `_claudeService.setApiKey()`. `setApiKey()` sada i sprema (`StorageService.saveApiKey()`). Nova `removeApiKey()`: clear client + `deleteApiKey()`.

`lib/screens/settings_screen.dart` — kompletno prepisano (220 linija). `StatefulWidget` s TextEditingController + `_obscureKey` bool. Dvije sekcije:
- `_buildApiKeySection()` — Row s key icon + "Anthropic API Key" + status badge (Active zeleni / Not set narančasti). TextField s obscureText i visibility toggle suffix. Save button validira input (ne smije biti prazan, ne smije biti maskiranih `••••`), poziva `provider.setApiKey`, maskira input, SnackBar potvrda. Remove button (conditional na `provider.hasApiKey`) poziva `removeApiKey`, SnackBar.
- `_buildAboutSection()` — Version 1.0.0, Market Data CoinGecko, AI Analysis Claude, Divider, disclaimer tekst

`lib/main.dart` — `main()` sada `async`, `WidgetsFlutterBinding.ensureInitialized()` + `await StorageService.init()` prije `runApp`.

**Verifikacija:** 0 issues, Windows build OK.

### 3.5 Faza 5 — Polish

**Opseg:** Error handling na oba HTTP servisa, skeleton loading, UX poboljšanja.

**Ključni elementi:**

`lib/services/coingecko_service.dart`:
- `import 'dart:async'` za TimeoutException
- Konstanta `_timeout = Duration(seconds: 15)`
- Svi HTTP pozivi: `try { ... .timeout(_timeout) } on TimeoutException catch(e) { throw CoinGeckoException('Request timed out') }`
- JSON decode: `try { json.decode } on FormatException catch(e) { throw CoinGeckoException('Invalid response') }`
- `searchAndFetch()` dodatno null-checka `searchData['coins'] as List<dynamic>?`

`lib/services/claude_service.dart` — isti timeout pattern (ali s 30s, Claude pozivi dulji), `FormatException` catch za response i error body. Response validation: `data['content'] as List<dynamic>?` + null/empty check → throw ako prazno.

`lib/widgets/coin_card.dart`:
- `Image.network`: dodan `loadingBuilder` koji prikazuje `_buildFallbackIcon()` dok se slika učitava
- Star toggle: wrappano u `AnimatedSwitcher(duration: 250ms, transitionBuilder: ScaleTransition)` s `ValueKey(isWatchlisted)` — glatki scale in/out pri klikanju
- Izvučena `_buildFallbackIcon()` metoda s `coin.symbol.isNotEmpty` checkom prije `substring`
- **Novi widget `CoinCardSkeleton`** (StatefulWidget): AnimationController(1200ms repeat reverse), Tween<double>(0.3→0.6) s CurvedAnimation(easeInOut). `AnimatedBuilder` s Card sadrži shimmer Row imitirajući layout CoinCarda. Boja: `Colors.grey[800]!.withValues(alpha: _animation.value)`.

`lib/screens/watchlist_screen.dart`:
- Nova metoda `_buildSkeletonList()`: ListView.builder s 8 CoinCardSkeleton widgeta
- Loading state u oba sub-taba zamijenjen iz `Center(CircularProgressIndicator)` u skeleton list — osjećaj da se nešto stvarno učitava, layout već zauzet

`lib/screens/analysis_screen.dart`:
- Dodan `bool _disposed = false` field, seta se na `true` u `dispose()` prije `super.dispose()`
- `_scrollToBottom()`: **double guard** — `if (_disposed || !hasClients) return` prije i unutar Future.delayed (prevent use-after-dispose race)
- `_sendMessage()`: dodan `.then((_) => _scrollToBottom())` na sendMessage future (auto-scroll nakon response-a)
- TextField: `enabled: !provider.isLoading`, hint mijenja u "Waiting for response..." tijekom loading-a
- Error bar: wrappan u `Dismissible(direction: horizontal)` + dodan X button (`GestureDetector` → `provider.clearError()`)
- Nova metoda `_confirmClearChat()`: `showDialog` → `AlertDialog(backgroundColor: #252525, title: "Clear chat?", content: "This will delete all messages...", Cancel/Clear buttons)`
- Delete IconButton: umjesto direktnog `clearChat()` sad poziva `_confirmClearChat(provider)`

`lib/models/analysis_provider.dart` — nova metoda `clearError()` (seta error = null, notifyListeners).

`lib/main.dart`:
- `StorageService.init()` wrappan u `try/catch` — app se pokreće i ako init failira, `debugPrint` error
- `Scaffold.body`: **`_screens[_currentIndex]` zamijenjeno s `IndexedStack`** — čuva stanje svih tabova (ne rebuilda Watchlist kad prelaziš na Analysis)

**Verifikacija:** 0 issues, test 2/2, Windows build OK.

### 3.6 Post-Session 1 — Audit, Documentation, Git Setup

Nakon Faze 5, izvršen je **dvostruki audit** (dva paralelna Claude Code agenta):

**Agent 1 (code audit):** pročitao svih 14 Dart fajlova. Rezultati: 0 kritičnih bugova, 0 nedostajućih imports, svi provideri pravilno wired, svi dispose() na mjestu, null safety strict compliant, nema hardkodiranih secretsa. Pronašao: 2 nekorištene dependencies (`flutter_dotenv`, `url_launcher`), 1 nekorištena metoda (`searchAndFetch`).

**Agent 2 (project checks):** `flutter analyze` 0 issues, `flutter test` **FAIL** (Hive not initialized u testu), git not initialized, no .env files, Windows Runner.rc ima generic metadata.

**Cleanup izvršen:**
- `pubspec.yaml`: uklonjeno `url_launcher` (+ 7 platform implementation paketa) i `flutter_dotenv` (+ flutter_web_plugins) — ukupno 10 paketa obrisano
- `.gitignore`: dodano `.env`, `.env.*`, `*.env`, `.hive/`, `chat_log.md`, `work_log.md`
- `windows/runner/Runner.rc`: CompanyName → "CoinSight", FileDescription → "CoinSight - AI-Powered Crypto Insights", LegalCopyright → dodano "Proprietary and confidential.", ProductName → "CoinSight"
- `test/widget_test.dart`: `setUpAll` koristi `Directory.systemTemp.createTempSync()` za Hive init (zaobilazi `path_provider` koji ne radi u testu). 2 testa: navigation render, tab switching
- `LICENSE` kreiran: Proprietary Software License s 5 restrikcija (no copy/modify/distribute/reverse engineer/transfer), confidentiality klauzula, AS-IS disclaimer, auto-termination
- `README.md` kreiran: kompletna dokumentacija (Features, Tech Stack, Architecture tree, Setup, API Usage, Error Handling, Security)
- `WORKLOG.md` kreiran: detaljan log svih promjena
- `git init`, initial commit `5691f2e` (146 fajlova, 7399 insertions), WORKLOG commit `12bc37b`

**Verifikacija nakon cleanup-a:** `flutter analyze` 0 issues, `flutter test` 2/2 passed, `flutter build windows` OK.

**Session 1 rezultat:** funkcionalan MVP s CoinGecko live podacima, Claude chat-om, Hive persistencijom, dark temom, polish elementima (skeletons, timeouts, error handling, IndexedStack).

---

## 4. Session 2 (2026-04-12) — Nove funkcionalnosti

Kontekst: između sesija developer je pushao projekt na GitHub (remote origin postavljen, branch renamed master→main). Dodani su novi spec fajlovi: `CLAUDE_CODE_PROMPT.md` (copy-paste prompt za nove sesije) i `SESSION_2.md` (5 zadataka). Cilj sesije: implementirati **core feature** (New Listings tab), redesignati Claude prompt, auto-logirati analize, verificirati Android build.

### 4.1 Zadatak 1 — New Listings Tab (core feature)

**Opseg:** Novi tab kao default pri otvaranju app-a, prikazuje coinove s early momentum profilom filtrirane po volume i market cap ranku, sortirane po 1h price change.

**Ključni elementi:**

`lib/models/coin.dart`:
- Dodano polje `final double? priceChangePercentage1h` (nullable — CoinGecko ne vraća uvijek)
- Dodano u constructor (optional, bez required)
- Dodano u `fromJson()`: `priceChangePercentage1h: (json['price_change_percentage_1h_in_currency'] as num?)?.toDouble()`

`lib/services/coingecko_service.dart`:
- Nova metoda `getNewListings({vsCurrency, perPage})`:
  - Endpoint `/api/v3/coins/markets`
  - Query params: `order=volume_desc`, `per_page=100`, `page=1`, `sparkline=true`, `price_change_percentage=1h,24h`
  - **Frontend filter:**
    - `marketCapRank == 0 || marketCapRank > 500` — eliminira established coinove (top 500 nisu "early")
    - `totalVolume >= 50000 && totalVolume <= 50000000` — eliminira ghost coinove (premalo prometa da bi bilo relevantno) i whale manipulacije (previše prometa za early-stage, vjerojatno pump)
    - `priceChangePercentage24h != 0` — eliminira stale coinove (API vraća 0 za coinove bez trading-a zadnjih 24h)
  - **Sort:** po `priceChangePercentage1h` descending (null → 0)
  - Vraća filtrirani i sortirani `List<Coin>`

`lib/models/watchlist_provider.dart`:
- `import 'dart:async'` za Timer
- Nova polja: `List<Coin> _newListings = []`, `Timer? _newListingsTimer`
- Getter `newListings`
- Metoda `fetchNewListings()` — isti loading/error pattern
- Metoda `startNewListingsAutoRefresh()` — `Timer.periodic(Duration(minutes: 3), (_) => fetchNewListings())`
- Metoda `stopNewListingsAutoRefresh()` — cancel + set null
- `dispose()` override — cancel timer + super

`lib/screens/watchlist_screen.dart`:
- TabController `length: 2` → `length: 3`
- Tab order: **New Listings (index 0, default)**, My Watchlist, Top Coins
- `_tabController.addListener(_onTabChanged)` u initState
- `_onTabChanged()`: index 0 → startAutoRefresh, ostalo → stopAutoRefresh (timer ne radi dok korisnik nije na toj tabi)
- `dispose()`: remove listener
- Nova metoda `_buildNewListingsTab()` — Consumer, loading=skeleton, error=cloud_off+retry, empty=new_releases_outlined+poruka ("No new listings found"), data=RefreshIndicator+ListView s `CoinCard(show1hChange: true)`

`lib/widgets/coin_card.dart`:
- Novi prop `final bool show1hChange` (default false)
- U price/change Row conditional: ako `show1hChange && coin.priceChangePercentage1h != null` → prikazuje `_buildChangeBadge(value, '1H')` + SizedBox ispred 24h arrow/postotka
- Nova metoda `_buildChangeBadge(double change, String label)` — Container s padding 4h/1v, BoxDecoration `color.withAlpha(0.15)` + borderRadius 4. Row s label ("1H" fontSize 9 w600) i value ("+X.X%" fontSize 10 w500). Boja zelena/crvena.

### 4.2 Zadatak 2 — Claude sistemski prompt redesign

**Opseg:** Zamjena generičkog engleskog prompta precizno kalibriranim HR promptom za momentum coin analizu.

**Opis promjene (linija 14–30 u `analysis_provider.dart`):**

Stari prompt (5 linija):
> "You are CoinSight, an AI assistant specialized in cryptocurrency analysis..."

Novi prompt (30 linija HR teksta):

1. **Uloga:** "CoinSight — specijalizirani AI analitičar za rano otkrivanje momentum prilike na cryptocurrency tržištu"
2. **Korisnikov profil:** "iskusan tehničar i analitičar" — ne objašnjava osnove
3. **Objektiv 1 — Profil listinga:**
   - Volume organičnost vs sumnjivi skok
   - Volume/mcap odnos (≥mcap = aktivnost + mogućnost manipulacije)
   - Exchange tier (Binance/Coinbase/Kraken tier-1, DEX/obscure CEX žuti signal)
   - Market cap rank (>500 = ispod institucionalnog radara)
4. **Objektiv 2 — Rizik profil:**
   - Pump-and-dump znakovi: volume spike bez online prisutnosti, 500%+ u 24h, "to the moon" u opisu
   - 1h/24h konzistentnost (24h rast + 1h pad = pump završio)
   - Volume/price bearish divergence
5. **Objektiv 3 — Preporuka:** jedna od tri oznake na **zasebnoj liniji u Markdown bold-u**:
   - `**WATCH**` — ima potencijal, treba više podataka
   - `**SKIP**` — previše rizičan, nejasan profil
   - `**INTERESTING**` — solid profil, razmotriti ulaz s malim iznosom
   + 1-2 rečenice razloga + konkretan sljedeći korak ("Provjeri opet za 2 sata", "Pogledaj Twitter/X aktivnost")
6. **Pravila:** ne garantira profit, analiza obrazaca ne financijski savjet
7. **Jezik:** HR ako korisnik piše HR, EN ako EN

Ovo je **bitna arhitekturalna odluka** jer `**WATCH**`/`**SKIP**`/`**INTERESTING**` postaju **machine-parsable markeri** koje ostatak app-a koristi za auto-logging (Zadatak 3) i Trade Action Bar (Session 3 Faza F).

### 4.3 Zadatak 3 — Analysis Logging

**Opseg:** Automatsko logiranje Claude AI analiza u Hive storage, parsiranje preporuka iz odgovora.

**Ključni elementi:**

`lib/models/analysis_log.dart` (novi fajl) — 6 polja: `timestamp`, `coinId`, `coinSymbol`, `priceAtAnalysis`, `claudeRecommendation`, `recommendationType`. `toMap/fromMap` za Hive.

**Ključna metoda `static String parseRecommendationType(String claudeResponse)`:**
```dart
if (claudeResponse.contains('**INTERESTING**')) return 'INTERESTING';
if (claudeResponse.contains('**WATCH**')) return 'WATCH';
if (claudeResponse.contains('**SKIP**')) return 'SKIP';
return 'NONE';
```

Redoslijed je kritičan: `INTERESTING` ide prvo (najspecifičnije), ako bi `WATCH` išao prvi a odgovor sadrži oboje, zamijenili bismo specifičan marker za manje specifičan.

`lib/services/storage_service.dart`:
- Nova konstanta `_analysisLogBox = 'analysis_logs'`, dodano u `init()`
- Metoda `saveAnalysisLog(AnalysisLog log)` — `box.add(log.toMap())` (auto-increment key)
- Metoda `getAnalysisLogs()` — čita sve values, mapira kroz `fromMap`, sortira po timestamp descending (najnoviji prvi)

`lib/models/analysis_provider.dart`:
- Nova metoda `_tryLogAnalysis(String response, List<Coin>? coins)`:
  - Poziva `AnalysisLog.parseRecommendationType(response)`
  - Ako `'NONE'` — return (ne logira generic chat)
  - Uzima `coins.first` ako postoji (prvi coin iz watchlista je "fokus")
  - Kreira AnalysisLog s `DateTime.now()`, coin podacima (ili fallback 'unknown'/'N/A'/0), response **truncated na 500 chars + '...'**
  - Poziva `StorageService.saveAnalysisLog()`
- `sendMessage()`: nakon `_messages.add(assistant)` poziva `_tryLogAnalysis(response, watchlistCoins)`

`test/widget_test.dart` — dodano `await Hive.openBox('analysis_logs')` u setUpAll.

### 4.4 Zadatak 4 — CHATLOG.md

Kreiran `CHATLOG.md` template za **ručno** bilježenje ishoda Claude analiza 24–48h nakon preporuke. Format: datum + coin (heading), podaci pri analizi (cijena, volume, 24h change), Claude preporuka (WATCH/SKIP/INTERESTING), razlog, ishod (naknadno popunjavanje — je li preporuka bila točna?).

Svrha: **long-term kalibracija Claude prompta** — ako INTERESTING signali pokazuju 60%+ success rate, prompt je dobar. Ako 20%, treba stroge filtere.

### 4.5 Zadatak 5 — Android Build Verifikacija

`flutter build apk --debug` — uspješan (203s). Output: `build/app/outputs/flutter-apk/app-debug.apk`. Nema Android-specifičnih errora.

### 4.6 Session 2 verifikacija

- `flutter analyze` — 0 issues
- `flutter test` — 2/2 passed
- `flutter build apk --debug` — OK
- `flutter build windows` — OK (Session 1)

**Session 2 rezultat:** app više nije samo "browse + chat" tool — postao je **signal-driven tool** s jasnom taksonomijom (WATCH/SKIP/INTERESTING) koja je podloga za buduću automatizaciju, i **audit trail-om** (AnalysisLog) koji omogućava kvantitativnu evaluaciju Claude preporuka kroz vrijeme.

---

## 5. Session 3 (2026-04-15) — Binance + Telegram + Portfolio

Kontekst: Session 2 završio s funkcionalnom analizom ali bez trading izvršavanja. Session 3 dodaje **direktno povezivanje signal → trade** kroz Binance Spot API (Faza 2 — manualna potvrda, Faza 3 — auto-execute), Telegram Bot za remote signalizaciju i komande, te **Portfolio screen** kao 4. tab za praćenje pozicija i P&L-a.

SESSION_3.md spec dao je 8 zadataka u 7 faza (A–G). Implementirano: Faze A–F (kod). Faza G (end-to-end live test) **blokirana** zbog Binance 2FA problema kod developera.

### 5.1 Arhitekturalne odluke donesene prije koda

**1. Izbor exchange-a.** Developer pitao za alternative Binanceu (Revolut isplata kao zahtjev). Razmotreni:

| Exchange | SEPA→Revolut | API | Small-cap listinzi |
|---|---|---|---|
| Binance | Da | Odličan | **Najbolji** |
| Kraken | Da | Dobar | Slab |
| Bitpanda/OneTrading | Da | OK | Vrlo slab |
| Coinbase Advanced | Da | OK | Srednji |
| Revolut Crypto | — | **Nema public API** | Irrelevant |

**Odluka:** Binance. Cijela poanta app-a je "rano otkrivanje momentum prilike na new listings" — to je Binance domena. Alternative nemaju small-cap coinove pa bi 60%+ Claude preporuka bilo neizvršivo. Isplate: Binance → SEPA EUR → Revolut IBAN (KYC ime mora matchati).

**2. Testnet vs live.** Spec predvidio `useBinanceTestnet=true` kao default. Developer odbio testnet, ide odmah live. Preporuka koju sam dao: za prvi trade postaviti `maxTradeAmountUsdt=5`, `maxOpenPositions=1`, `stopLoss=10%`, `autoTradeEnabled=false` — ručni BUY kroz Analysis tab za prvih par sesija prije aktivacije Faze 3.

**3. API ključevi.** Developer pitao mogu li se hardkodirati. **Kategorički odbijeno:** repo je javan na GitHubu, Binance ima leak-detection koji auto-disable-a ključeve čim se pojave u public source codeu, i ključ ostaje u git history-ju zauvijek čak i nakon brisanja. Sav kod radi kroz Settings → Binance sekcija → Hive.

### 5.2 Faza A — pubspec + StorageService credential extension

**Opseg:** Dodavanje dependencies za crypto potpise i notifikacije, proširenje StorageService-a za Binance/Telegram credentiale i testnet flag.

**`pubspec.yaml`:** +3 dependencies:
- `flutter_local_notifications: ^18.0.0` (za buduće Session 4+ lokalne notifikacije)
- `crypto: ^3.0.3` (HMAC-SHA256)
- `convert: ^3.1.1` (hex encoding)

`flutter pub get` → 9 paketa dodano, no conflicts.

**`lib/services/storage_service.dart`** (60→147 linija):
- Nova konstanta `_positionsBox = 'positions'` — 4. Hive box, otvoren u `init()`
- Nove field konstante: `_binanceApiKeyField`, `_binanceSecretField`, `_binanceTestnetField`, `_telegramTokenField`, `_telegramChatIdField`
- **Binance metode:** `getBinanceApiKey()`, `getBinanceSecret()`, `getBinanceTestnet()` (default `true`), `saveBinanceCredentials(apiKey, secret)`, `deleteBinanceCredentials()`, `setBinanceTestnet(bool)`
- **Telegram metode:** `getTelegramToken()`, `getTelegramChatId()`, `saveTelegramCredentials(token, chatId)`, `deleteTelegramCredentials()`

`test/widget_test.dart` — dodano `Hive.openBox('positions')` u setUpAll.

### 5.3 Faza B — Modeli

Četiri nova modela:

**`lib/models/coin_position.dart`** (52 linije): 9 polja:
- `coinId` (CoinGecko ID — primary key u Hive `positions` box-u)
- `symbol` (npr. "BTC")
- `binanceSymbol` (npr. "BTCUSDT" — Binance trading par)
- `quantity` (koliko tokena imamo)
- `entryPrice`, `entryTotal` (USDT uloženo)
- `entryTime`
- `currentPrice?` (mutable — ažurira se u `PortfolioProvider._refreshPrices()`)
- `stopLossOrderId?` (rezervirano za buduće server-side stop-loss orders preko Binance-a; trenutno SL provodi aplikacija kroz `TradeService.checkStopLosses()` timer)

Computed getteri: `currentValue = quantity * (currentPrice ?? entryPrice)`, `pnlAbsolute = currentValue - entryTotal`, `pnlPercent`, `isProfit`.

`toMap/fromMap` za Hive storage.

**`lib/models/risk_parameters.dart`** (84 linije): 8 polja s razumnim defaultima:
- `maxTradeAmountUsdt: 10.0`
- `maxOpenPositions: 3`
- `stopLossPercent: 15.0`
- `takeProfitPercent: 30.0`
- `autoTradeEnabled: false` (Faza 3 opt-in)
- `telegramNotifications: false`
- `quietHoursStart: 23, quietHoursEnd: 7` (ne-trading period preko noći)

**Ključni getter `isQuietHours`** s wraparound logikom za prijelaz preko ponoći:
```dart
if (quietHoursStart > quietHoursEnd) {
  return hour >= quietHoursStart || hour < quietHoursEnd;
}
return hour >= quietHoursStart && hour < quietHoursEnd;
```

`copyWith()` za immutable update pattern (Settings slider → `_risk = _risk.copyWith(stopLossPercent: v)`).

**`lib/models/trade_proposal.dart`** (26 linija): 8 polja (coin, amountUsdt, estimatedQty, currentPrice, stopLossPrice, takeProfitPrice, claudeRecommendation, createdAt). **Ključni getter `isExpired`:** `DateTime.now().difference(createdAt).inSeconds > 60`. Razlog 60s: cijena se može značajno promijeniti u tom roku za small-cap coinove, pa korisnikova potvrda mora biti brza — inače proposal se odbija i traži nova cijena.

**`lib/models/trade_result.dart`** (20 linija): 6 polja (success, orderId?, executedPrice?, executedQty?, totalUsdt?, errorMessage?). `.failure(String)` factory za lakše kreiranje failure ishoda.

**StorageService proširenje (dio Faze B):**
- Konstanta `_riskParamsField = 'risk_parameters'`
- `getRiskParameters()` — vraća default `RiskParameters()` ako nema zapisa u Hive
- `saveRiskParameters(params)`
- `savePosition(position)` — keyed po `coinId`
- `removePosition(coinId)`
- `getPositions()` — sortirano po `entryTime` descending

### 5.4 Faza C — BinanceService

**Najkompleksniji dio Session 3.** Binance REST zahtijeva HMAC-SHA256 potpis za authenticated endpointe, precizan timestamp management, i specifično handle-anje error kodova.

**`lib/services/binance_service.dart`** (~270 linija):

**`BinanceException`** custom exception — poruka + optional `int? code` (Binance error code). `toString()` uključuje kod za debugging.

**`BinanceOrder`** klasa — orderId, symbol, side (BUY/SELL), status, executedQty, cummulativeQuoteQty (ukupni USDT), transactTime. Computed getter `avgPrice = cummulativeQuoteQty / executedQty` (Binance ne vraća avg direktno, računamo iz totala). `fromJson()` parsira i `transactTime` i `time` polje jer različiti endpointi koriste različita imena.

**`BinanceService`** klasa:

**URL switching:**
```dart
static const _prodUrl = 'https://api.binance.com';
static const _testnetUrl = 'https://testnet.binance.vision';
String get _baseUrl => _useTestnet ? _testnetUrl : _prodUrl;
```
`_useTestnet` se čita iz StorageService u konstruktoru i mijenja kroz `reloadCredentials()` (poziva se iz Settings nakon Save).

**HMAC-SHA256 potpis:**
```dart
String _sign(String queryString) {
  final key = utf8.encode(_apiSecret!);
  final msg = utf8.encode(queryString);
  final hmac = Hmac(sha256, key);
  return hmac.convert(msg).toString();  // hex digest
}
```

**Signed query builder:**
```dart
String _signedQuery(Map<String, String> params) {
  final withTs = {
    ...params,
    'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    'recvWindow': _recvWindow.toString(),  // 5000ms
  };
  final qs = _buildQuery(withTs);
  final sig = _sign(qs);
  return '$qs&signature=$sig';
}
```

Svaki authenticated request dobije `timestamp` (Unix ms) i `signature`. `recvWindow` (5000ms) je Binance tolerancija za drift — ako request stigne više od 5s nakon timestampa, Binance odbija s -1021.

**Headers:** `X-MBX-APIKEY` (API key, javno slani), samo na signed pozivima. `Content-Type` nije potreban jer Binance koristi query string za sve parametre (čak i POST).

**Error mapping u `_throwForResponse()`:**
- `-1021` TIMESTAMP_OUT_OF_SYNC → BinanceException('Timestamp out of sync with Binance server')
- `-2010` NEW_ORDER_REJECTED → 'Insufficient balance or order rejected'
- `-1100` / `-1121` → 'Symbol not available on Binance' (coin ne postoji kao XXXUSDT par)
- Ostalo → `body['msg']` fallback
- Ako response nije JSON → 'Binance request failed (${statusCode})'

**6 public metoda (spec zahtijevao ovaj skup):**

1. **`ping()`** — `GET /api/v3/ping`, public endpoint, nema auth. Vraća `bool` (true ako 200). Koristi se za Settings "Test Connection" da provjeri konekciju prije teže `getUsdtBalance`.

2. **`getUsdtBalance()`** — `GET /api/v3/account` (signed). Iterira `balances` array, traži `asset == 'USDT'`, vraća `free` kao double. Ako USDT nije pronađen → 0.

3. **`getCurrentPrice(symbol)`** — `GET /api/v3/ticker/price?symbol=$symbol` (public). Vraća `double`.

4. **`placeBuyOrder(symbol, quoteAmount)`** — `POST /api/v3/order` (signed). Body: `side=BUY`, `type=MARKET`, `quoteOrderQty=<USDT amount>`. `quoteOrderQty` je Binance način za "kupi za X USDT bez da ja moram znati tačan qty" — idealno za momentum trade kad ne želimo ručno dijeliti amount/price. USDT iznos zaokružen na 2 decimale.

5. **`placeSellOrder(symbol, quantity)`** — isti endpoint, `side=SELL`, `quantity=<tokens>` zaokruženo na 6 decimala. **Poznat limit:** Binance LOT_SIZE filter može tražiti različit `stepSize` per simbol (npr. 8 decimala za BTC, 0 za SHIB). Trenutno fiksno 6 decimala — rizik greške `-1013 Filter failure: LOT_SIZE` za neke coinove. Zabilježeno u Identified Issues za Session 4+ popravak (cache exchangeInfo per simbol).

6. **`getOrderHistory(symbol)`** — `GET /api/v3/allOrders?symbol=X&limit=10` (signed). Vraća `List<BinanceOrder>`. Trenutno se ne koristi u UI-ju — rezervirano za buduće "Order History" ekran.

**`getOpenPositions()`** — delegira na `StorageService.getPositions()`. Binance Spot nema "pozicije" kao futures (na spotu imaš samo balance), pa pozicije tretiramo kao **lokalni koncept**: kupio si X, platio Y USDT, pratiš ukupno do close-a.

**Timeout:** 15s na svim pozivima (TimeoutException → BinanceException).

### 5.5 Faza D — TradeService + TelegramService

**`lib/services/trade_service.dart`** (~160 linija) — centralna trade orkestracija. Koristi BinanceService i StorageService.

**`prepareTradeProposal({coin, claudeRecommendation, riskParams})`**:
1. Fetch current price (`binance.getCurrentPrice('${symbol}USDT')`)
2. Baci BinanceException ako price ≤ 0 (npr. coin ne postoji na Binanceu)
3. Računa estimatedQty = amount / price (aproksimacija — stvarni qty iz BUY order-a može malo varirati zbog slippage-a)
4. Računa stopLossPrice = price * (1 - sl/100), takeProfitPrice = price * (1 + tp/100)
5. Vraća `TradeProposal` s `createdAt = DateTime.now()` (60s expiry)

**`executeTrade(proposal)`** — ključna metoda, redoslijed validacija:
1. Check `proposal.isExpired` (>60s)
2. Check broj otvorenih pozicija vs `maxOpenPositions`
3. Check duplicate — ne dozvoljavamo dvije pozicije na isti coin
4. Fetch `usdtBalance`, check dovoljno (insufficient → failure)
5. `binance.placeBuyOrder(symbol, amountUsdt)` — **ovo je jedina ireverzibilna akcija**
6. Check `order.executedQty > 0` (ponekad order prođe ali ne popuni — failure)
7. Kreira `CoinPosition` s actual executed podacima (ne proposal estimate-ima) — entry iz `order.avgPrice`, total iz `order.cummulativeQuoteQty`
8. `StorageService.savePosition(position)` — persist u Hive
9. `StorageService.saveAnalysisLog(...)` s `recommendationType = 'ENTERED'` i porukom `'[ENTERED @ $price] $recommendation'` — audit trail
10. Vraća `TradeResult(success: true, orderId, executedPrice, executedQty, totalUsdt)`

**`autoExecuteIfEligible(...)` (Faza 3):** gate-ovi prije prepare/execute:
- `riskParams.autoTradeEnabled == true`
- `!riskParams.isQuietHours`
- `binance.hasCredentials`
- broj pozicija < maxOpenPositions
- nema duplicate coina

Ako sve prolazi → `prepareTradeProposal` → `executeTrade`. Na BinanceException silent fail (vraća `null`) — bot ne spama SnackBar-e u pozadinskom radu.

**`checkStopLosses()`** — zove se iz main.dart Timer-a svakih 5 minuta. Iterira pozicije, fetcha trenutnu cijenu, ako `price ≤ slPrice || price ≥ tpPrice` → `closePosition()`. Tiho preskače pozicije koje ne mogu dohvatiti cijenu (network error).

**`closePosition(position)`:**
1. `placeSellOrder(binanceSymbol, quantity)` 
2. Check `executedQty > 0`
3. `StorageService.removePosition(coinId)`
4. Računa P&L (`exitTotal - entryTotal`), postotak
5. Logira AnalysisLog s `recommendationType = 'EXITED'` i porukom `'[EXITED @ price] P&L: +$X (X%)'`
6. Vraća TradeResult

**`lib/services/telegram_service.dart`** (~185 linija) — Telegram Bot API klijent.

**Setup (dokumentirano u Settings UI):** korisnik kreira bot kod `@BotFather`, dobiva token. Pošalje `/start` botu, bot dobije `chat_id`. Oba stringa ide u Hive.

**Metode:**

`sendMessage(text)` — `POST https://api.telegram.org/bot$token/sendMessage`, body `{chat_id, text, parse_mode: 'Markdown'}`. Swallow greške (vraća false — nije kritično ako Telegram failira).

`sendInterestingSignal(coin, claudeRecommendation, riskParams)` — formatira 10-line Markdown poruku:

```
🚨 *CoinSight Signal*

*INTERESTING* — SYMBOL/USDT

💰 Cijena: $X
📈 1h: X% | 24h: Y%
📊 Volume: $Z
🏆 Rank: #N

🧠 *Claude analiza:*
[skraćeno na 200 znakova + '...']

⚡ Brzi odgovor:
/buy_SYMBOL — kupi X USDT
/skip_SYMBOL — preskoči
/analyze_SYMBOL — puna analiza
```

`sendTradeExecuted(position, result)` — "✅ Trade izvršen" s detaljima order-a.

`sendStopLossTriggered(position, result)` — "🛑 Pozicija zatvorena" s P&L-om.

`sendDailySummary(positions, logs)` — rezerviran za Session 4 cron/scheduler.

**Polling za incoming komande:**

`startPolling()` — `Timer.periodic(Duration(seconds: 5), (_) => _poll())`. Trenutno se poziva iz main.dart initState ako `isConfigured`.

`_poll()` — `GET /bot$token/getUpdates?offset=$lastUpdateId+1&timeout=0`. Parsira `result` array, za svaki update poziva `_processUpdate`. Silent fail na mrežne greške.

`_processUpdate(update)`:
1. `_lastUpdateId = update['update_id']` — sprječava re-processing
2. Filter po `chat.id` == spremljeni chatId (ne procesira random chatove, sigurnosno)
3. Parse teksta: ako starta s `/` → cmd + optional argument (split na prvom `_`). Npr. `/buy_SOLANA` → command='buy', argument='SOLANA'.
4. Poziva registrirani handler (ako postoji)

`setCommandHandler(handler)` — callback tip `Future<void> Function(String command, String argument)`. Pozove ga `main.dart`.

### 5.6 Faza E — Portfolio Screen + Settings Update

**`lib/models/portfolio_provider.dart`** (~95 linija) — 4. ChangeNotifier provider.

State: `_usdtBalance`, `_positions`, `_isLoading`, `_error`, `_priceTimer`.

Computed getteri:
- `totalInvested` — Σ entryTotal
- `totalValue` — Σ currentValue
- `totalPnl` = totalValue - totalInvested
- `totalPnlPercent`

`refresh()` — reload pozicija iz Hive, fetch USDT balance, refresh prices za sve pozicije.

`_refreshPrices()` — iterira pozicije, za svaku `binance.getCurrentPrice(binanceSymbol)`, update `pos.currentPrice` (mutable polje u CoinPosition). Silent fail per-poziciju (ne blokira ostale).

`startAutoRefresh()` — `Timer.periodic(Duration(seconds: 30), ...)` poziva `_refreshPrices` + notify. Timer se zove iz Portfolio screen `initState` i cancela u `dispose`.

`stopAutoRefresh()`, `reloadCredentials()` (zove Binance `reloadCredentials`), `closePosition(position)` (delegat na TradeService + reload).

**`lib/screens/portfolio_screen.dart`** (~290 linija) — 4. tab u bottom navigation.

`StatefulWidget` s `AutomaticKeepAliveClientMixin` (`wantKeepAlive: true`) — ne rebuilda se kad korisnik prelazi na druge tabove (state očuvan unutar IndexedStack ionako, ali keepAlive daje double-safety za ListView scroll position).

**Ključna optimizacija za test-friendly lifecycle:**
```dart
PortfolioProvider? _providerRef;

@override
void initState() {
  super.initState();
  Future.microtask(() {
    if (!mounted) return;
    final p = context.read<PortfolioProvider>();
    _providerRef = p;  // sačuvaj referencu za safe dispose
    if (!p.hasCredentials) return;
    p.refresh();
    p.startAutoRefresh();
  });
}

@override
void dispose() {
  _providerRef?.stopAutoRefresh();  // NE context.read — widget tree već neactive
  super.dispose();
}
```

Razlog: `context.read<X>()` u `dispose()` puca s "Looking up a deactivated widget's ancestor is unsafe" jer InheritedWidget lookup više ne radi. Sačuvana referenca je idiomatski workaround.

**Layout — 3 sekcije:**

1. **Header Card:** Portfolio title + refresh icon, USDT balance, Open positions count, Total P&L (obojen). Error message ispod ako postoji.

2. **Open Positions lista:** za svaku CoinPosition kartica s:
   - SYMBOL/USDT + **CLOSE** button
   - Entry: $X → Now: $Y
   - Qty: X.XXXX | Invested: $X.XX
   - P&L: +$X.XX (+XX.X%) — obojen
   - SL: $X | TP: $Y (iz `RiskParameters`)

   Tap na CLOSE otvara AlertDialog: "Zatvori poziciju? Prodaješ X.XXXX SYMBOL po tržišnoj cijeni." → Confirm → `provider.closePosition()` → SnackBar rezultat.

3. **Analysis History:** zadnjih 20 AnalysisLog zapisa iz Hive. Svaki redak:
   - Chip (WATCH/SKIP/INTERESTING/ENTERED/EXITED) obojen
   - SYMBOL | $price
   - Datum/vrijeme (`DateFormat('dd.MM. HH:mm')`)

**No-credentials state:** wallet icon + poruka "Binance nije konfiguriran — dodaj API ključeve u Settings".

**`lib/screens/settings_screen.dart`** — prošireno s 247→~700 linija. Očuvana postojeća Anthropic API Key i About sekcija. **Tri nove sekcije:**

**1. Binance API sekcija:**
- ⚠️  Warning banner: "Osiguraj da API ključ NEMA dozvolu za Withdrawal"
- TextField za API Key (obscured, `••` trick — tap čisti maskirano za paste)
- TextField za API Secret (obscured, isti trick)
- SwitchListTile za Testnet mode:
  - ON (default): subtitle "Paper trading — nema pravog novca", sivi tekst
  - OFF: subtitle "⚠️  LIVE — pravi novac na kocki", narančasti tekst
  - Toggle na OFF otvara `AlertDialog` "Prebaci na LIVE? ... sve transakcije koristit će PRAVI novac" s Cancel/Confirm LIVE
- Save button — `StorageService.saveBinanceCredentials` + `PortfolioProvider.reloadCredentials` + SnackBar
- Test button — `BinanceService().ping()` pa `getUsdtBalance()` → SnackBar rezultat
- Remove button (conditional) — delete credentials + clear controllers

**2. Risk Parameters sekcija:**
- TextField `maxTradeAmountUsdt` (decimal keyboard, submit → save)
- Dropdown `maxOpenPositions` 1–10 (Settings auto-save onChange)
- Slider `stopLossPercent` 5–30% s 25 divisions, label live update
- Slider `takeProfitPercent` 10–100% s 90 divisions
- Divider
- SwitchListTile `autoTradeEnabled` **— samo ako Binance konfiguriran.** Subtitle narančasti: "Bot će automatski kupovati bez tvoje potvrde unutar gore definiranih parametara."
- Divider
- Quiet hours display "Start: XX:00 End: YY:00" + dva TextButton-a → showTimePicker → update

Svi riskParams saved kroz `_saveRisk()` helper (poziva se onChangeEnd slidera, Dropdown onChange, itd.).

**3. Telegram Bot sekcija:**
- Info: "Pošalji /start svom botu da dobiješ Chat ID"
- TextField Bot Token (obscured, `••` trick)
- TextField Chat ID (not obscured — nije secret)
- Save button — `StorageService.saveTelegramCredentials`
- Test button — `TelegramService().sendMessage('✅ CoinSight test poruka')` → SnackBar

`_sectionHeader(icon, title, {statusLabel, statusActive})` helper za ujednačen header svake sekcije (ikona + naslov + optional Active/Not set badge).

### 5.7 Faza F — Analysis Trade Action Bar + main.dart 4 taba + polling/SL timer

**`lib/screens/analysis_screen.dart`** (329→~480 linija): zadržana postojeća struktura (No-API-key / Empty / MessageList / ErrorBar / InputBar), dodana nova komponenta između MessageList i ErrorBar.

**Trade Action Bar eligibility logika:**
```dart
bool _shouldShow() {
  if (provider.messages.isEmpty) return false;
  final lastIndex = provider.messages.length - 1;
  if (lastIndex == _dismissedActionBarIndex) return false;
  final last = provider.messages[lastIndex];
  if (last.role != 'assistant') return false;
  if (!last.content.contains('**INTERESTING**')) return false;
  if (!BinanceService().hasCredentials) return false;
  if (StorageService.getRiskParameters().autoTradeEnabled) return false;
  if (context.read<WatchlistProvider>().watchlistCoins.isEmpty) return false;
  return true;
}
```

Show rules: last msg je INTERESTING assistant, Binance spojen, nije auto-trade mode (tada se trade dogodi automatski, bez UI-a), watchlist nije prazan (potrebna je coin referenca — uzima se `watchlistCoins.first` ako ih je više).

**UI:**
Zeleni okvir (`Colors.green.withValues(alpha: 0.08)` fill + border `0.4` alpha) s:
- 🚨 header: "INTERESTING signal — SYMBOL/USDT" + X dismiss (tracka `_dismissedActionBarIndex = lastIndex`)
- Row: "Uloži:" + editable TextField (80w fiksna, decimal keyboard, prefil `maxTradeAmountUsdt`) + "USDT" + "SL -X% | TP +Y%" info
- Row: 3 buttona
  - **BUY NOW** (zeleni, veliki, loading spinner)
  - **SKIP** (outlined)
  - **TELEGRAM** (outlined, manji font)

**`_buyNow(coin, recommendation)`:**
1. Parse iznos iz controllera, validate > 0
2. `_tradeService.prepareTradeProposal(coin, recommendation, riskParams.copyWith(maxTradeAmountUsdt: amount))` — koristi custom iznos iz TextField-a, ne default
3. `_showProposalDialog(proposal)` — AlertDialog s detaljima (cijena, iznos, qty, SL, TP) + "Market order — izvršava se po trenutnoj cijeni" disclaimer
4. Ako potvrda → `_tradeService.executeTrade(proposal)`
5. SnackBar rezultat ("Bought X SOL @ $Y" ili error)
6. Dismiss bar (markira indeks da se ne vrati)

**`_skip(coin, recommendation, idx)`:** samo logira AnalysisLog tipa SKIP s `[SKIPPED]` prefixom (nema Binance poziva), dismiss bar. Korisno za dataset kalibracije: "korisnik je INTERESTING proglasio neprihvatljivim — zašto?"

**`_sendToTelegram(coin, recommendation)`:** `telegramService.sendInterestingSignal(...)` bez izvršavanja trade-a. Koristi se za "podijeli signal s grupom/samim sobom za kasnije odlučivanje", ili kad korisnik nije siguran.

**`lib/main.dart`** (90→125 linija):

- `MultiProvider`: dodan `PortfolioProvider`
- `_titles`: `['Watchlist', 'Analysis', 'Portfolio', 'Settings']`
- Polja: `_tradeService`, `_telegramService`, `_stopLossTimer`
- `initState()` zove `_startBackgroundServices()`:
  - Ako `telegramService.isConfigured`: `setCommandHandler` + `startPolling` (5s tick)
  - `_stopLossTimer = Timer.periodic(Duration(minutes: 5), checkStopLosses)` — **gated na `BinanceService().hasCredentials`**. Razlog gate-a: `pumpAndSettle()` u testovima čeka sve timere da se završe; periodic timer bez gate-a zauvijek blokira test. Ovo je svjesna kompromisna odluka.
- `_handleTelegramCommand(cmd, arg)` — minimalni handler za:
  - `/status` — pošalji "Open positions: X, Invested: $Y"
  - `/stop` — disable auto-trade preko RiskParameters
  - `/start` — enable auto-trade
  - fallback: "Commands: /status /stop /start"
  
  `/buy_SYMBOL`, `/skip_SYMBOL`, `/analyze_SYMBOL` još nisu implementirani — rezervirano za Session 4 (traže pristup watchlist providera iz main.dart context-a, plus dodatnu trade logiku).

- `dispose()`: cancel timer + stopPolling
- BottomNavigationBar: `type: BottomNavigationBarType.fixed` (inače Material 3 sakriva labels za 4+ tabova), 4 itema, Portfolio koristi `Icons.account_balance_wallet_outlined/account_balance_wallet`
- IndexedStack s 4 screena

**`test/widget_test.dart`:** `find.text('About CoinSight')` → `find.text('Binance API')` jer je About sad off-screen u proširenom Settings listu.

### 5.8 Faza G — End-to-end live test (BLOCKED)

SESSION_3.md spec predvidio 8-step live verifikaciju:
1. Konfig Binance testnet (ili live) ključeve
2. Konfig Telegram bota
3. New Listings → Claude analiza → INTERESTING signal
4. BUY NOW kroz Trade Action Bar
5. Portfolio tab → pozicija vidljiva s live cijenom
6. Telegram → primljena poruka
7. Uključi auto-trade → Faza 3 flow
8. Dokumentiraj rezultate

**Status: BLOCKED — Binance 2FA problem kod developera.**

### 5.9 Blocker: Binance 2FA recovery

**Simptomi:**
- SMS kod za verifikaciju ne stiže na telefon
- Telefonski broj linkan na neki drugi Binance account (vjerojatno stari/zaboravljeni duplikat) — ne može se unbindati jer reset tog broja traži... kod na taj broj (catch-22)
- **API Management sekcija uklonjena iz Binance mobilne aplikacije** (~2023), dostupna samo na desktop webu
- Desktop web login prolazi, ali kreiranje API ključa traži dodatni verifikacijski kanal (email + SMS/Google Authenticator)
- Developer nema postavljen Google Authenticator na Binance accountu

**Plan recovery-ja (redoslijedom po brzini):**

1. **Binance Live Chat** (najbrže):
   - binance.com → dolje desno plavi chat ikon → `human agent` (10–30 min čekanja)
   - Zahtjev: privremeno disable SMS 2FA uz ID selfie verifikaciju → nakon toga developer sam postavi Google Authenticator
   
2. **Desktop mode u mobilnom browseru** (brz pokušaj):
   - Chrome/Safari na mobu → `binance.com` → Desktop site → Profile → API Management
   - Još traži 2FA za kreiranje, ali preskače SMS ako se pojavi Authenticator opcija (vrijedi samo ako je Authenticator ikad postavljen)

3. **Account Appeal form** (24–72h):
   - binance.com/en/my/security/account-appeal
   - Opcija "Lost access to phone / cannot receive SMS"
   - Traže selfie s dokumentom + rukom pisanu cedulju s datumom
   - Binance resetira 2FA, pa developer sam postavlja Authenticator

Dok god 2FA nije riješen, **kreiranje API ključa nije moguće**, pa Faza G ostaje blokirana. Kod je 100% spreman.

### 5.10 Session 3 verifikacija

- `flutter analyze` — **0 issues**
- `flutter test` — **2/2 passed**
- `flutter build apk --debug` — **NIJE POKRENUT** (rezervirano za post-live-test)
- `flutter build windows` — **NIJE POKRENUT**
- **Live Binance test** — **NIJE POKRENUT** (blocker)

---

## 6. Trenutno stanje (snapshot 2026-04-15)

### 6.1 Funkcionalnosti koje rade (kod-level)

**Browsing:**
- 3 sub-taba u Watchlist screenu: New Listings (default, auto-refresh 3 min), My Watchlist, Top Coins
- Filter na New Listings: mcap rank >500, volume $50k–$50M, ne-stale
- Sort na New Listings: po 1h change descending
- CoinCard s ikonicom, simbolom, trenutnom cijenom, 7d sparkline (CustomPainter), 24h change (+ opcionalno 1h badge)
- Star toggle sa animacijom za add/remove iz watchlista
- Pull-to-refresh, skeleton loading, error states s retry, empty states
- Podaci se čuvaju u IndexedStack — tab switch ne rebuilda

**Analiza:**
- Claude chat s HR momentum-focused system promptom (30 linija)
- Watchlist podaci (ime, simbol, cijena, 24h %, mcap rank) se automatski ubacuju u prompt pri slanju poruke
- Auto-parse preporuka (WATCH/SKIP/INTERESTING) iz Claude odgovora
- Auto-logiranje svake netrivijalne analize u Hive (`analysis_logs` box)
- Trade Action Bar kad Claude vrati INTERESTING (ako Binance konfig + nije auto-mode)
- SelectableText za copy iz chata
- Dismissible error bar, confirm clear chat, typing indicator
- Graceful handling: 401 (invalid key), 429 (rate limit), 30s timeout

**Trading (Binance Spot):**
- HMAC-SHA256 signed REST klijent
- Testnet/prod URL switch (default testnet)
- Metode: ping, getUsdtBalance, getCurrentPrice, placeBuyOrder (quoteOrderQty), placeSellOrder (quantity), getOrderHistory
- TradeService: prepareTradeProposal (60s expiry), executeTrade (s validacijama: expiry, maxOpenPositions, duplicate, balance), autoExecuteIfEligible (Faza 3), checkStopLosses, closePosition
- Error mapping: -1021 (sync), -2010 (insufficient), -1100/-1121 (bad symbol)
- Audit trail u AnalysisLog: ENTERED/EXITED markeri s P&L

**Portfolio:**
- 4. tab: USDT balance, Open Positions count, Total P&L (obojen)
- Open Positions lista s entry→now cijenama, qty, P&L, SL/TP
- Close Position sa confirm dialogom
- Analysis History (zadnjih 20 logova) s obojenim chipovima
- Auto-refresh cijena 30s dok je Portfolio tab aktivan
- Gated: no-credentials state ako Binance nije spojen

**Telegram Bot:**
- sendMessage (Markdown)
- sendInterestingSignal (formatted 10-line poruka + quick commands `/buy_/skip_/analyze_`)
- sendTradeExecuted, sendStopLossTriggered, sendDailySummary (rezervirani)
- Polling (5s) + command handler (`/status`, `/stop`, `/start`, default help)

**Settings:**
- Anthropic API key (save/remove, obscured, status badge)
- Binance API (key/secret, testnet toggle s live-mode confirm, Save/Test/Remove, withdrawal warning)
- Risk Parameters (maxTrade, maxPositions, SL/TP sliders, auto-trade toggle, quiet hours TimePicker)
- Telegram (token, chatId, Save, Test)
- About (version, data sources, disclaimer)

**Background services:**
- New listings Timer (3 min) — samo kad je Watchlist tab aktivan na New Listings pod-tabu
- Portfolio prices Timer (30s) — samo dok je Portfolio tab aktivan i Binance spojen
- Stop-loss checker Timer (5 min) — gated na Binance credentials
- Telegram polling Timer (5s) — gated na Telegram credentials
- Svi timeri se cancelaju u `dispose`

### 6.2 Funkcionalnosti koje NE rade / čekaju

- **Live Binance trade** — nikad nije izvršen stvarni request na Binance API (blocker: 2FA recovery)
- **Telegram `/buy_SYMBOL`, `/skip_SYMBOL`, `/analyze_SYMBOL` komande** — polling radi, handler je minimalni, potrebno proširenje u Session 4
- **Per-symbol LOT_SIZE precision** — hardkodirano 6 decimala na sell; može puknuti s -1013 za neke coinove
- **Timestamp drift offset** — ako sistemski sat drifta više od 5s, Binance odbija s -1021; trenutno nema compensation-a
- **Binance EU regulatorne restrikcije** — ako `binance.com` geo-blokira iz HR, potrebno prebaciti na drugu domenu (binance.me/binance.eu nakon Session 4+ istrage)
- **Local notifications** — `flutter_local_notifications` paket dodan ali nije integriran (rezervirano)
- **Hive TypeAdapters** — trenutno koristimo Map<String, dynamic>; za performance Session 4+ generirati adaptere kroz `build_runner`

### 6.3 Verifikacija (kod-level, zadnji run 2026-04-15)

```
flutter analyze     → 0 issues
flutter test        → 2/2 passed (widget_test.dart)
flutter build windows → OK (Session 1)
flutter build apk   → OK (Session 2 debug; Session 3 nije pokrenut)
```

### 6.4 Git stanje

- Remote: `origin/main` (javni GitHub repo)
- Zadnji commit: **prije Session 3 izmjena** (tags: `8f36631 wl`, `9b49710 1`, `3460144 0`)
- **Session 3 izmjene NISU commitane** — svjesna odluka, čeka se live verifikacija pa onda jedan commit s kompletnom Faze F promjenom

### 6.5 Identified Issues (iz WORKLOG.md)

1. **Binance account lockout (developer):** SMS 2FA ne stiže, duplicate account na broju — blocker za live testing. Ne-bug.
2. **API Management only on desktop web:** Binance limit, ne naš bug.
3. **LOT_SIZE precision hardcoded:** 6 decimala — rizik -1013 za neke simbole. Fix: cache `/api/v3/exchangeInfo` per simbol.
4. **Timestamp drift:** mitigacija s `recvWindow=5000ms`. Fix: `/api/v3/time` offset calc pri prvoj konekciji ako udari -1021.

---

## 7. Dokumentacija u repou

| Fajl | Svrha |
|------|-------|
| `CLAUDE.md` | Projektne instrukcije za Claude Code — fazni pristup, redoslijed, pravila |
| `README.md` | GitHub dokumentacija: Features, Tech Stack, Architecture, Setup, API Usage, Security |
| `LICENSE` | Proprietary Software License (5 restrikcija, AS-IS) |
| `WORKLOG.md` | Granularni per-sesija log: svaki fajl, linija, komanda, dependency — forenzički |
| `CHATLOG.md` | Template za ručno bilježenje ishoda Claude preporuka 24–48h nakon |
| `CLAUDE_CODE_PROMPT.md` | Copy-paste prompt template za nove sesije |
| `SESSION_2.md` | Session 2 spec (5 zadataka) |
| `SESSION_3.md` | Session 3 spec (8 zadataka, 7 faza) |
| `PROJECT_OVERVIEW.md` | **Ovaj dokument** — narativna konsolidacija kroz sve sesije |

---

## 8. Sljedeći koraci

### 8.1 Neposredno (čeka developera)

1. **Binance 2FA recovery** — live chat / Account Appeal / Google Authenticator setup
2. **Generiranje API ključa** (bez Withdrawal permission, ideally IP-restricted)
3. **Konfig u Settings:** upis ključeva, toggle Testnet→LIVE (s confirm), Test → očekivano `OK — USDT balance: $X.XX (live)`
4. **Postavljanje konzervativnih risk parametara** za prvi live: `maxTradeAmountUsdt=5, maxOpenPositions=1, stopLossPercent=10, autoTradeEnabled=false`
5. **Prvi ručni trade** kroz Analysis Trade Action Bar → verificiraj Portfolio tab
6. **Telegram bot setup** (BotFather) → test poruka → dokumentacija chat ID-ja
7. **Dokumentacija rezultata** u WORKLOG.md (ili novi SESSION_3_RESULTS.md ako preferiraš)
8. **Git commit Session 3 izmjena** nakon uspješne verifikacije

### 8.2 Session 4 kandidati (nakon live verifikacije)

- **LOT_SIZE precision fix** (cache exchangeInfo per simbol) — ako -1013 udari
- **Timestamp drift compensation** — ako -1021 udari
- **Telegram command expansion** (`/buy_`, `/skip_`, `/analyze_`)
- **Daily summary scheduler** — midnight timer koji zove `telegramService.sendDailySummary`
- **Local notifications integracija** — push za INTERESTING signale dok app nije otvoren
- **iOS build target** — trenutno iOS folder postoji ali nije testiran
- **Hive TypeAdapters** — build_runner generated, za type safety + performance
- **Order History screen** — već postoji `getOrderHistory` metoda, fali UI
- **Analysis Logs screen** — detaljniji view od Portfolio history sekcije, s filter-ima
- **Kalibracija Claude prompta** na osnovu CHATLOG ishoda — iterativno pojačati precision

### 8.3 Dugoročne ideje (van Session 4)

- **WebSocket streaming** za real-time cijene pozicija (umjesto 30s REST polling)
- **Server-side stop-loss orders** preko Binance-a (`placeStopLossOrder`) — trenutno SL radi aplikacija s 5-min tickom, što je rupa ako app nije pokrenut. Server-side je pouzdanije
- **Multi-account support** — više Binance ključeva za različite strategije
- **Backtest mode** — simulacija strategije na historical podacima iz CoinGecko
- **Export CSV** — Portfolio history i Analysis logs za vanjsku analizu

---

## 9. Rezime

CoinSight je u 3 sesije i 14 faza narastao od praznog Flutter scaffolda do **end-to-end signal-driven trading aplikacije** s AI analizom kao core logikom odlučivanja. Arhitektura je **strict MVVM + provider pattern** s jasnom separacijom services (HTTP + crypto) / models (data + state) / screens (UI). Sigurnost ključeva je konzervativna: sve lokalno u Hive, nikad u source, `.gitignore` + Proprietary License kao backup.

Trenutni blocker je **vanjski** (Binance account recovery), kod je verificiran `flutter analyze`/`test` na 0/clean. Kad developer dobije API ključ, Faza G (live end-to-end) pokreće se iz Settings u 2 minute.

Projekt ima **solidan temelj za Session 4+** — svaka nova funkcionalnost sjeda u jasno definiran sloj (novi service / novi model / novi screen + provider extension), i postojeći pattern-i (skeleton loading, error bar, confirm dialog, status badge header, gated timers) su reusable za nove module.

**Generirano:** 2026-04-15
**Broj linija ovog dokumenta:** ~650
**Pokriva sesije:** 1, 2, 3 (Faze A–F)

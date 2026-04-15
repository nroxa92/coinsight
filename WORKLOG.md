# CoinSight Worklog

---

## Session 1: 2026-04-12 — Initial Build (Faze 1-5)

### Phase 1 — Scaffold
**Status:** Completed

**Opis:** Inicijalni setup Flutter projekta.

**Komande izvršene:**
- `flutter --version` — Flutter 3.41.6 stable, Dart 3.11.4
- `flutter create --org com.coinsight --project-name coinsight .` — 131 fajl kreiran
- `flutter pub get` — dependencies resolved
- `flutter analyze` — 0 issues
- `flutter build windows` — coinsight.exe built

**Kreirani fajlovi:**
- `pubspec.yaml` — dependencies: flutter, cupertino_icons ^1.0.8, http ^1.4.0, provider ^6.1.0, hive ^2.2.3, hive_flutter ^1.1.0, intl ^0.20.0. Dev: flutter_lints ^6.0.0, hive_generator ^2.0.1, build_runner ^2.4.0
- `lib/main.dart` — CoinSightApp (StatelessWidget), MainNavigation (StatefulWidget) sa BottomNavigationBar (3 itema: Watchlist/star, Analysis/auto_awesome, Settings/gear). `_currentIndex` za tab switching
- `lib/theme/app_theme.dart` — AppTheme klasa sa static `darkTheme` getter. Boje: primary #6C63FF, secondary #03DAC6, background #121212, surface #1E1E1E, card #252525, error #CF6679, green #4CAF50, red #EF5350. AppBarTheme (elevation 0, centerTitle), BottomNavigationBarThemeData, CardThemeData (borderRadius 12), InputDecorationTheme (filled, borderRadius 12), ElevatedButtonTheme
- `lib/screens/watchlist_screen.dart` — stub (Center + Text "Watchlist")
- `lib/screens/analysis_screen.dart` — stub (Center + Text "Analysis")
- `lib/screens/settings_screen.dart` — stub (Center + Text "Settings")

**Direktoriji kreirani:** `lib/screens/`, `lib/widgets/`, `lib/services/`, `lib/models/`, `lib/theme/`

**Test ažuriran:** `test/widget_test.dart` — promijenjen iz default counter testa u CoinSightApp navigation test

---

### Phase 2 — CoinGecko + Watchlist
**Status:** Completed

**Opis:** Integracija CoinGecko API-ja i funkcionalan Watchlist screen sa stvarnim podacima.

**Kreirani fajlovi:**

`lib/models/coin.dart` (45 linija):
- Coin klasa sa 12 polja: id (String), symbol (String), name (String), image (String), currentPrice (double), marketCap (double), marketCapRank (int), priceChangePercentage24h (double), high24h (double), low24h (double), totalVolume (double), sparklineIn7d (List<double>?)
- Factory `Coin.fromJson(Map<String, dynamic>)` — null-safe parsing sa `?? 0` fallback za sve num polja. Sparkline parsing: `json['sparkline_in_7d']?['price']`

`lib/services/coingecko_service.dart` (75 linija):
- CoinGeckoService klasa s `http.Client` injection za testabilnost
- `_baseUrl`: `https://api.coingecko.com/api/v3`
- `getMarketData()`: parametri vs_currency, order (market_cap_desc), per_page, page, sparkline, ids (optional). Vraća `List<Coin>`
- `searchAndFetch(String query)`: search endpoint + getMarketData za top 10 rezultata
- `CoinGeckoException` custom exception klasa
- Status code handling: 200 (parse), 429 (rate limit), ostalo (generic error)

`lib/models/watchlist_provider.dart` (88 linija):
- WatchlistProvider extends ChangeNotifier
- State: `_topCoins` (List<Coin>), `_watchlistCoins` (List<Coin>), `_watchlistIds` (Set<String>, default: bitcoin/ethereum/solana), `_isLoading` (bool), `_error` (String?)
- `fetchTopCoins()` — poziva getMarketData(perPage: 25), ažurira oba lista
- `refreshWatchlist()` — poziva getMarketData s watchlist ID-ovima
- `toggleWatchlist(String coinId)` — add/remove iz seta
- `_updateWatchlistCoins()` — filtrira topCoins po watchlistIds

`lib/widgets/sparkline_chart.dart` (65 linija):
- SparklineChart (StatelessWidget) — props: data, color, height (40), width (80)
- `_SparklinePainter` extends CustomPainter — računa min/max/range, crta Path sa strokeWidth 1.5, StrokeCap.round
- shouldRepaint provjerava data i color

`lib/widgets/coin_card.dart` (155 linija):
- CoinCard (StatelessWidget) — props: coin, isWatchlisted, onToggleWatchlist
- Layout: Row s rank (SizedBox 28w), icon (Image.network 36x36 s errorBuilder), name/symbol (Expanded flex:3), sparkline (conditional), price/change (Expanded flex:3), star (GestureDetector)
- Cijena format: `>=1` koristi NumberFormat.currency, `<1` koristi toStringAsFixed(6)
- Change: zelena (>=0) ili crvena (<0), arrow_drop_up/down icon + postotak

**Ažurirani fajlovi:**
- `lib/screens/watchlist_screen.dart` — kompletno prepisano. StatefulWidget s SingleTickerProviderStateMixin. TabController(length: 2). TabBar (My Watchlist / Top Coins). Consumer<WatchlistProvider>. Pull-to-refresh (RefreshIndicator). Empty state (star_border icon + tekst). Error state (cloud_off icon + error + Retry button). ListView.builder za coin kartice
- `lib/main.dart` — dodan `import provider`, ChangeNotifierProvider za WatchlistProvider wrapa MaterialApp

---

### Phase 3 — Anthropic/Claude Integration
**Status:** Completed

**Opis:** Chat sučelje s Claude AI za crypto analizu.

**Kreirani fajlovi:**

`lib/services/claude_service.dart` (102 linija):
- ClaudeService klasa s `http.Client` injection
- Konstante: `_baseUrl` (https://api.anthropic.com/v1/messages), `_model` (claude-sonnet-4-20250514), `_apiVersion` (2023-06-01)
- `hasApiKey` getter, `setApiKey(String)`
- `sendMessage()`: prima userMessage, history (List<ChatMessage>), systemPrompt (optional). Šalje POST s headers: Content-Type, x-api-key, anthropic-version. Body: model, max_tokens (1024), messages, system. Parsira response content blokove type=='text'
- Error handling: 401 (invalid key), 429 (rate limit), ostalo (parsira error.message)
- `ChatMessage` klasa: role, content, timestamp, toJson()
- `ClaudeException` custom exception

`lib/models/analysis_provider.dart` (82 linija):
- AnalysisProvider extends ChangeNotifier
- `_systemPrompt` — generički CoinSight AI crypto assistant prompt (5 linija)
- Konstruktor: prima optional ClaudeService
- State: `_messages` (List<ChatMessage>), `_isLoading`, `_error`
- `sendMessage(text, {watchlistCoins})`: dodaje user message, šalje s history (sve osim zadnje), dodaje assistant response. On error: uklanja user message, seta error
- `_buildUserMessage()`: ako postoje coins, dodaje watchlist podatke (name, symbol, price, 24h change, mcap rank) ispred pitanja
- `setApiKey()`, `clearChat()`

`lib/widgets/chat_bubble.dart` (45 linija):
- ChatBubble (StatelessWidget) — props: text, isUser
- Align: user centerRight, assistant centerLeft
- Container: maxWidth 80% screena, margin asymmetric (user 48L/16R, assistant 16L/48R)
- Decoration: user = primary.withAlpha(0.2), assistant = #252525. BorderRadius asymmetric (user: bottomRight 4, assistant: bottomLeft 4)
- SelectableText za copy

**Ažurirani fajlovi:**
- `lib/screens/analysis_screen.dart` — kompletno prepisano (274 linija). StatefulWidget s TextEditingController + ScrollController. States: _buildNoApiKeyState (key icon + tekst), _buildEmptyState (auto_awesome icon + 3 ActionChip suggestion chips), _buildMessageList (ListView.builder + typing indicator), _buildTypingIndicator (spinner + "Thinking..."), _buildErrorBar (error color container), _buildInputBar (delete + TextField maxLines:4 + send IconButton). `_scrollToBottom()` s Future.delayed(100ms)
- `lib/main.dart` — MultiProvider s oba providera

---

### Phase 4 — Hive Storage + Settings
**Status:** Completed

**Opis:** Lokalna persistencija za watchlist i API key, te Settings screen.

**Kreirani fajlovi:**

`lib/services/storage_service.dart` (43 linija):
- StorageService — sve static metode
- Box konstante: `_settingsBox` ('settings'), `_watchlistBox` ('watchlist')
- Field konstante: `_apiKeyField` ('anthropic_api_key'), `_watchlistIdsField` ('watchlist_ids')
- `init()`: `Hive.initFlutter()`, otvara oba box-a
- API Key: `getApiKey()` -> String?, `saveApiKey(String)`, `deleteApiKey()`
- Watchlist: `getWatchlistIds()` -> List<String> (default: bitcoin/ethereum/solana ako null), `saveWatchlistIds(List<String>)`

**Ažurirani fajlovi:**
- `lib/models/watchlist_provider.dart` — konstruktor: `_watchlistIds = Set<String>.from(StorageService.getWatchlistIds())`. `toggleWatchlist()`: dodano `StorageService.saveWatchlistIds()` nakon svake promjene
- `lib/models/analysis_provider.dart` — konstruktor: čita `StorageService.getApiKey()`, ako postoji poziva `_claudeService.setApiKey()`. `setApiKey()`: dodano `StorageService.saveApiKey(key)`. Nova metoda `removeApiKey()`: seta prazan string + `StorageService.deleteApiKey()`
- `lib/screens/settings_screen.dart` — kompletno prepisano (220 linija). StatefulWidget s TextEditingController + _obscureKey bool. `_buildApiKeySection()`: Row s key icon + "Anthropic API Key" + status badge (Active zeleni / Not set narančasti). TextField s obscureText, onTap čisti masked dots, suffixIcon visibility toggle. Save button: validira (ne prazan, ne dots), poziva setApiKey, maskira, SnackBar "API key saved". Remove button (conditional): poziva removeApiKey, čisti controller, SnackBar "API key removed". `_buildAboutSection()`: info rows (Version 1.0.0, Market Data CoinGecko, AI Analysis Claude), Divider, disclaimer tekst
- `lib/main.dart` — dodano: `WidgetsFlutterBinding.ensureInitialized()`, `await StorageService.init()` u main()

---

### Phase 5 — Polish
**Status:** Completed

**Opis:** Error handling, loading states, UX poboljšanja.

**Ažurirani fajlovi — detalji po fajlu:**

`lib/services/coingecko_service.dart` (promjene na linijama 1, 8, 33-38, 41-46, 71-79):
- Dodan `import 'dart:async'`
- Nova konstanta `_timeout = Duration(seconds: 15)`
- `getMarketData()`: HTTP poziv wrapan u `try { .timeout(_timeout) } on TimeoutException`
- JSON decode wrapan u `try { json.decode } on FormatException`
- `searchAndFetch()`: isti timeout/format pattern. Null check: `searchData['coins'] as List<dynamic>?`

`lib/services/claude_service.dart` (promjene na linijama 1, 9, 49-62, 67-78, 84-90):
- Dodan `import 'dart:async'`
- Nova konstanta `_timeout = Duration(seconds: 30)`
- POST poziv wrapan u `try { .timeout(_timeout) } on TimeoutException`
- Response parsing: `data['content'] as List<dynamic>?` + null/empty check → baca ClaudeException
- JSON decode wraped u FormatException catch za response i error body

`lib/widgets/coin_card.dart` (promjene na linijama 46-56, 134-149, 156-170, dodano 173-271):
- `Image.network` promijenjen: dodan `loadingBuilder` koji prikazuje `_buildFallbackIcon()` dok se slika učitava
- Star toggle: `GestureDetector` → `GestureDetector` + `AnimatedSwitcher(duration: 250ms, transitionBuilder: ScaleTransition)` s `ValueKey(isWatchlisted)`
- `_buildFallbackIcon()`: izvučen u zasebnu metodu, `coin.symbol.isNotEmpty` check prije substring
- **Novi widget** `CoinCardSkeleton` (StatefulWidget): AnimationController(1200ms, repeat reverse), Tween<double>(0.3→0.6) s CurvedAnimation(easeInOut). AnimatedBuilder s Card sadrži shimmer Row: _shimmerBox(28,14) + _shimmerCircle(36) + Column[_shimmerBox(80,14), _shimmerBox(40,10)] + _shimmerBox(80,40) + Column[_shimmerBox(70,14), _shimmerBox(50,10)]. Boja: `Colors.grey[800]!.withValues(alpha: _animation.value)`

`lib/screens/watchlist_screen.dart` (promjene na linijama 58-64, 62, 109):
- Nova metoda `_buildSkeletonList()`: ListView.builder s 8 CoinCardSkeleton widgeta
- `_buildWatchlistTab()`: zamijenjeno `Center(child: CircularProgressIndicator())` s `_buildSkeletonList()`
- `_buildTopCoinsTab()`: ista zamjena

`lib/screens/analysis_screen.dart` (promjene na linijama 15, 19-23, 25-34, 37-44, 61, 204-225, 227-273):
- Dodan `bool _disposed = false` field
- `dispose()`: seta `_disposed = true` prije super.dispose()
- `_scrollToBottom()`: double guard — `if (_disposed || !hasClients) return` prije i u Future.delayed
- `_sendMessage()`: dodano `.then((_) => _scrollToBottom())` na sendMessage future
- TextField: `enabled: !provider.isLoading`, hint mijenja se u "Waiting for response..." dok loading
- Error bar: wrapan u `Dismissible(direction: horizontal)` + dodan X button (`GestureDetector` → `provider.clearError()`)
- Nova metoda `_confirmClearChat()`: `showDialog` → `AlertDialog(backgroundColor: #252525, title: "Clear chat?", content: "This will delete all messages...", Cancel/Clear buttons)`
- Delete button: umjesto direktnog `clearChat()` poziva `_confirmClearChat(provider)`
- Border fix: `Colors.grey[850]!` → `Colors.grey[800]!.withValues(alpha: 0.5)`

`lib/models/analysis_provider.dart` (promjena na liniji 90):
- Nova metoda `clearError()`: seta `_error = null`, poziva `notifyListeners()`

`lib/main.dart` (promjene na linijama 12-15, 57-65):
- `StorageService.init()` wrapan u `try/catch` — app se pokreće čak i ako init failira, `debugPrint` error
- `Scaffold.body`: zamijenjeno `_screens[_currentIndex]` s `IndexedStack(index: _currentIndex, children: [WatchlistScreen(), AnalysisScreen(), SettingsScreen()])` — čuva stanje svih tabova u memoriji

---

### Post-Phase — Audit, Documentation & Git Setup
**Status:** Completed

**Opis:** Detaljna analiza cjelokupnog koda, GitHub dokumentacija, licenca, git inicijalizacija.

**Audit izvršen (dva paralelna agenta):**
- Agent 1 (code audit): čitao svih 14 Dart fajlova. Rezultati: 0 kritičnih bugova, 0 nedostajućih importa, svi provideri pravilno wired, svi dispose() na mjestu, null safety strict compliant, nema hardkodiranih secretsa. Pronašao: 2 nekorištene dependencies (flutter_dotenv, url_launcher), 1 nekorištena metoda (searchAndFetch)
- Agent 2 (project checks): flutter analyze 0 issues, flutter test FAIL (Hive not initialized u testu), git not initialized, no .env files, Windows Runner.rc ima generic metadata

**Cleanup izvršen:**
- `pubspec.yaml`: uklonjeno `url_launcher: ^6.3.0` i `flutter_dotenv: ^5.2.1`
- `flutter pub get`: uklonjena 10 paketa (url_launcher + 7 platformskih implementacija + flutter_dotenv + flutter_web_plugins)

**Kreirani fajlovi:**
- `LICENSE` — Proprietary Software License. 5 restrikcija (no copy, no modify, no distribute, no reverse engineer, no transfer). Confidentiality klauzula. AS-IS disclaimer. Auto-termination pri kršenju
- `README.md` — kompletna dokumentacija: Features (3 sekcije), Tech Stack tablica (6 redova), Architecture tree (14 fajlova), Setup (prerequisites + 4 komande + 3 koraka konfiguracije), API Usage (CoinGecko free tier + Anthropic Claude detalji), Error Handling tablica (6 scenarija), Security (4 bullet pointa), License footer
- `WORKLOG.md` — ovaj fajl

**Ažurirani fajlovi:**
- `.gitignore` — dodano 6 novih pravila: `.env`, `.env.*`, `*.env`, `.hive/`, `chat_log.md`, `work_log.md`
- `windows/runner/Runner.rc` — linija 92: CompanyName "com.coinsight" → "CoinSight", linija 93: FileDescription "coinsight" → "CoinSight - AI-Powered Crypto Insights", linija 96: LegalCopyright dodano "Proprietary and confidential.", linija 98: ProductName "coinsight" → "CoinSight"
- `test/widget_test.dart` — kompletno prepisano. `setUpAll`: `Directory.systemTemp.createTempSync()` za Hive init (zaobilazi path_provider). 2 testa: navigation render (findsWidgets za Watchlist jer se pojavljuje 2x), tab switching (Analysis→API Key Required, Settings→Anthropic API Key + About CoinSight)
- `pubspec.yaml` — uklonjene 2 dependencies

**Git:**
- `git init` na `C:\Users\SeaDoo\Desktop\claude_coinsight`
- `git add` — staged svi projektni fajlovi (isključeni: chat_log.md, work_log.md, build/, .dart_tool/)
- Initial commit `5691f2e`: "Initial commit: CoinSight v1.0.0" — 146 fajlova, 7399 insertions
- WORKLOG commit `12bc37b`: "Add detailed worklog with full session documentation"

**Finalna verifikacija Session 1:**
- `flutter analyze` — 0 issues
- `flutter test` — 2/2 passed
- `flutter build windows` — coinsight.exe built successfully

---
---

## Session 2: 2026-04-12 — New Features (SESSION_2.md zadaci)

**Kontekst:** Dva nova dokumenta dodana u root: `CLAUDE_CODE_PROMPT.md` (copy-paste prompt za nove sesije) i `SESSION_2.md` (5 zadataka za implementaciju). Projekt pushnut na GitHub između sesija (git remote origin postoji, branch promijenjen master→main).

**Cilj sesije:** Implementacija core funkcionalnosti (novi listinzi), popravak Claude prompta, analysis logging, Android build.

---

### Zadatak 1 — New Listings Tab (CORE FEATURE)
**Status:** Completed

**Opis:** Novi tab "New Listings" kao default pri otvaranju, prikazuje coinove s early momentum profilom filtrirane po volume i market cap ranku, sortirane po 1h price change.

**Ažurirani fajlovi — detalji:**

`lib/models/coin.dart` (45→52 linija, promjene na linijama 9, 25, 41-42):
- Dodan novi field: `final double? priceChangePercentage1h` (nullable jer CoinGecko ne vraca uvijek)
- Dodan u constructor: `this.priceChangePercentage1h` (optional, bez required)
- Dodan u `fromJson()`: `priceChangePercentage1h: (json['price_change_percentage_1h_in_currency'] as num?)?.toDouble()`

`lib/services/coingecko_service.dart` (95→146 linija, dodano 56-106):
- Nova metoda `getNewListings({vsCurrency, perPage})`:
  - Endpoint: `GET /api/v3/coins/markets`
  - Query params: `vs_currency=usd`, `order=volume_desc`, `per_page=100`, `page=1`, `sparkline=true`, `price_change_percentage=1h,24h`
  - Timeout 15s, FormatException catch (isto kao getMarketData)
  - **Frontend filter** (linije 84-89): `marketCapRank == 0 || marketCapRank > 500` (eliminira established coins), `totalVolume >= 50000 && totalVolume <= 50000000` (eliminira ghost coins i whale manipulacije), `priceChangePercentage24h != 0` (eliminira stale coins)
  - **Sort** (linije 91-95): po `priceChangePercentage1h` descending (null → 0)
  - Vraća filtrirani i sortirani `List<Coin>`

`lib/models/watchlist_provider.dart` (92→132 linija, promjene na linijama 1, 12, 16, 25, 92-131):
- Dodan `import 'dart:async'` za Timer
- Nova polja: `List<Coin> _newListings = []`, `Timer? _newListingsTimer`
- Novi getter: `List<Coin> get newListings => _newListings`
- Nova metoda `fetchNewListings()` (linije 92-107): isLoading/error pattern, poziva `_service.getNewListings()`, catch CoinGeckoException
- Nova metoda `startNewListingsAutoRefresh()` (linije 109-114): `Timer.periodic(Duration(minutes: 3), (_) => fetchNewListings())`
- Nova metoda `stopNewListingsAutoRefresh()` (linije 117-120): cancel timer, set null
- Dodan `dispose()` override (linije 127-131): cancel timer + super.dispose()

`lib/screens/watchlist_screen.dart` (163→256 linija, praktički prepisano):
- TabController `length: 2` → `length: 3`
- Dodan `_tabController.addListener(_onTabChanged)` u initState
- `initState` microtask: dodano `provider.fetchNewListings()` i `provider.startNewListingsAutoRefresh()`
- Nova metoda `_onTabChanged()`: index 0 → startAutoRefresh, ostalo → stopAutoRefresh
- `dispose()`: dodano `_tabController.removeListener(_onTabChanged)`
- TabBar: 3 taba — "New Listings" (PRVI, default) | "My Watchlist" | "Top Coins". Dodan labelStyle/unselectedLabelStyle (fontSize 13)
- Nova metoda `_buildNewListingsTab()` (linije 86-147): Consumer<WatchlistProvider>. Loading → skeleton. Error → cloud_off + retry. Empty → new_releases_outlined icon + "No new listings found" + "Pull to refresh or check back later". Data → RefreshIndicator + ListView.builder s `CoinCard(show1hChange: true)`
- `_buildWatchlistTab()`: empty state tekst promijenjen "Star coins from Top Coins tab" → "Star coins from other tabs"

`lib/widgets/coin_card.dart` (271→306 linija, promjene na linijama 8, 15, 19, 109-118, 155-175):
- Novi prop: `final bool show1hChange` (default false)
- U constructor: `this.show1hChange = false`
- Price/change Row (linija 109): dodan conditional: `if (show1hChange && coin.priceChangePercentage1h != null)` → prikazuje `_buildChangeBadge()` + SizedBox(width:4) ISPRED 24h arrow/percentage
- Nova metoda `_buildChangeBadge(double change, String label)` (linije 155-175): Container s padding 4h/1v, BoxDecoration s color.withAlpha(0.15) i borderRadius 4. Row s dva Text-a: label ("1H", fontSize 9, fontWeight w600) i value ("+X.X%", fontSize 10, fontWeight w500). Boja: zelena za >=0, crvena za <0

---

### Zadatak 2 — Claude Sistemski Prompt
**Status:** Completed

**Opis:** Zamjena generičkog system prompta s precizno kalibriranim promptom za momentum coin analizu. Tekst 1:1 kopiran iz SESSION_2.md specifikacije.

**Ažurirani fajlovi:**

`lib/models/analysis_provider.dart` (promjena na linijama 14-30):
- `_systemPrompt` konstanta: 5 linija generičkog engleskog teksta → 30 linija specifičnog HR teksta
- Sadržaj novog prompta:
  - Uloga: "CoinSight — specijalizirani AI analitičar za rano otkrivanje momentum prilike"
  - Korisnikov profil: "iskusan tehničar i analitičar" — ne objašnjava osnove
  - OBJEKTIV 1 — PROFIL LISTINGA: volume organičnost, volume/mcap odnos, exchange tier (Binance/Coinbase/Kraken = tier-1, DEX/obscure CEX = žuti signal), mcap rank analiza (>500 = ispod radara)
  - OBJEKTIV 2 — RIZIK PROFIL: pump-and-dump znakovi (500%+ u 24h, volume spike bez online prisutnosti), 1h/24h konzistentnost (24h rast + 1h pad = pump završio), volume/price bearish divergence
  - OBJEKTIV 3 — PREPORUKA: tri oznake na zasebnoj liniji (**WATCH**, **SKIP**, **INTERESTING**) + razlog (1-2 rečenice) + konkretan sljedeći korak ("Provjeri opet za 2 sata", "Pogledaj Twitter/X aktivnost" itd.)
  - Pravila: ne garantira profit, analiza obrazaca ne financijski savjet
  - Jezik: HR ako korisnik piše HR, EN ako EN

---

### Zadatak 3 — Analysis Logging
**Status:** Completed

**Opis:** Automatsko logiranje Claude AI analiza s WATCH/SKIP/INTERESTING preporukama u Hive storage. Prethodno nije postojala nikakva implementacija logginga.

**Kreirani fajlovi:**

`lib/models/analysis_log.dart` (42 linija):
- AnalysisLog klasa sa 6 polja: timestamp (DateTime), coinId (String), coinSymbol (String), priceAtAnalysis (double), claudeRecommendation (String), recommendationType (String)
- `toMap()` → `Map<String, dynamic>`: timestamp kao ISO8601 string, ostalo direktno
- `factory fromMap(Map<dynamic, dynamic>)`: parsira natrag iz Hive mape, DateTime.parse za timestamp
- `static parseRecommendationType(String claudeResponse)` → String: traži `**INTERESTING**` prvo (najspecifičniji), zatim `**WATCH**`, zatim `**SKIP**`. Ako ništa — vraća `'NONE'`. Redoslijed je bitan jer INTERESTING ima prioritet

**Ažurirani fajlovi:**

`lib/services/storage_service.dart` (43→60 linija, promjene na linijama 2, 7, 15, 47-60):
- Dodan `import 'package:coinsight/models/analysis_log.dart'`
- Nova konstanta: `_analysisLogBox = 'analysis_logs'`
- `init()`: dodano `await Hive.openBox(_analysisLogBox)` — treći box
- Nova metoda `saveAnalysisLog(AnalysisLog log)` (linija 48-51): `box.add(log.toMap())` — Hive auto-increment key
- Nova metoda `getAnalysisLogs()` → `List<AnalysisLog>` (linije 53-59): čita sve values iz box-a, mapira kroz `AnalysisLog.fromMap()`, sortira po `timestamp` descending (najnoviji prvi)

`lib/models/analysis_provider.dart` (100→131 linija, promjene na linijama 5, 77, 104-119):
- Dodan `import 'package:coinsight/models/analysis_log.dart'`
- `sendMessage()` linija 77: nakon `_messages.add(assistant)` dodano `_tryLogAnalysis(response, watchlistCoins)`
- Nova metoda `_tryLogAnalysis(String response, List<Coin>? coins)` (linije 104-119):
  - Poziva `AnalysisLog.parseRecommendationType(response)`
  - Ako tip je 'NONE' — return (ne logira)
  - Uzima `coins.first` ako postoji, inače null
  - Kreira `AnalysisLog` s: `DateTime.now()`, coin?.id ?? 'unknown', coin?.symbol.toUpperCase() ?? 'N/A', coin?.currentPrice ?? 0, response (truncated na 500 chars + '...' ako duži), tip
  - Poziva `StorageService.saveAnalysisLog()`

`test/widget_test.dart` (promjena na liniji 12):
- Dodano `await Hive.openBox('analysis_logs')` u setUpAll — treći box za testove

---

### Zadatak 4 — CHATLOG.md
**Status:** Completed

**Kreirani fajlovi:**

`CHATLOG.md` (14 linija):
- Header: "CoinSight — Chat Log"
- Opis: "Ovaj fajl bilježi ključne analitičke sesije i zaključke. Format: datum, coin, preporuka, ishod (popunjava se naknadno)."
- Template unosa s 5 polja: datum + coin symbol (heading), podaci pri analizi (cijena, volume, 24h change), Claude preporuka (WATCH/SKIP/INTERESTING), razlog, ishod (za naknadno popunjavanje 24-48h nakon)

---

### Zadatak 5 — Android Build Verifikacija
**Status:** Completed

**Komande izvršene:**
- `flutter build apk --debug` — **USPJEŠAN** (203.0s)
- Output: `build/app/outputs/flutter-apk/app-debug.apk`
- Nema Android-specifičnih errora, warningova niti compatibility issue-a

---

### Session 2 — Finalna Verifikacija
- `flutter analyze` — **0 issues**
- `flutter test` — **2/2 passed**
- `flutter build apk --debug` — **uspješan** (app-debug.apk)
- `flutter build windows` — verified (Session 1)

---
---

## File Manifest (lib/) — Stanje nakon Session 2

| Fajl | Linije | Opis |
|------|--------|------|
| `main.dart` | 90 | Entry point, MultiProvider, IndexedStack navigacija |
| `models/coin.dart` | 52 | Coin data model, fromJson() s 1h change |
| `models/analysis_log.dart` | 42 | AnalysisLog model, parseRecommendationType() |
| `models/watchlist_provider.dart` | 132 | Watchlist + New Listings state, auto-refresh timer |
| `models/analysis_provider.dart` | 131 | Chat state, Claude API, auto-logging, HR system prompt |
| `services/coingecko_service.dart` | 146 | CoinGecko HTTP client, getMarketData + getNewListings |
| `services/claude_service.dart` | 122 | Anthropic HTTP client, ChatMessage, timeout |
| `services/storage_service.dart` | 60 | Hive wrapper: API key + watchlist + analysis logs |
| `screens/watchlist_screen.dart` | 256 | 3 taba (New Listings/Watchlist/Top), skeleton, refresh |
| `screens/analysis_screen.dart` | 329 | Chat UI, suggestions, typing, error, confirm dialogs |
| `screens/settings_screen.dart` | 247 | API key management, about, confirm dialog |
| `widgets/coin_card.dart` | 306 | CoinCard + 1h badge + CoinCardSkeleton (shimmer) |
| `widgets/chat_bubble.dart` | 50 | Chat mjehurić, SelectableText |
| `widgets/sparkline_chart.dart` | 68 | 7d price chart, CustomPainter |
| `theme/app_theme.dart` | 78 | Dark tema konfiguracija |
| **UKUPNO** | **2109** | **15 Dart fajlova** |

---

## Root File Manifest

| Fajl | Opis |
|------|------|
| `pubspec.yaml` | Flutter dependencies i metadata |
| `pubspec.lock` | Locked dependency versions |
| `analysis_options.yaml` | Dart lint rules |
| `.gitignore` | Git ignore rules (+.env, +.hive/, +dev logs) |
| `CLAUDE.md` | Claude Code project instructions |
| `README.md` | GitHub dokumentacija (features, setup, API, security) |
| `LICENSE` | Proprietary Software License (closed source) |
| `WORKLOG.md` | Ovaj fajl — detaljan log svih promjena |
| `CHATLOG.md` | Template za ručno bilježenje analitičkih sesija |
| `CLAUDE_CODE_PROMPT.md` | Copy-paste prompt za nove Claude Code sesije |
| `SESSION_2.md` | Session 2 task instrukcije |

---

## Dependency Graph — Stanje nakon Session 2

```
main.dart
├── theme/app_theme.dart
├── services/storage_service.dart ──→ hive_flutter
│   └── models/analysis_log.dart
├── models/watchlist_provider.dart
│   ├── dart:async (Timer)
│   ├── models/coin.dart
│   ├── services/coingecko_service.dart ──→ http, dart:async, dart:convert
│   └── services/storage_service.dart
├── models/analysis_provider.dart
│   ├── services/claude_service.dart ──→ http, dart:async, dart:convert
│   ├── services/storage_service.dart
│   ├── models/coin.dart
│   └── models/analysis_log.dart
├── screens/watchlist_screen.dart
│   ├── models/watchlist_provider.dart ──→ provider
│   └── widgets/coin_card.dart
│       ├── models/coin.dart
│       ├── theme/app_theme.dart
│       ├── widgets/sparkline_chart.dart
│       └── intl (NumberFormat)
├── screens/analysis_screen.dart
│   ├── models/analysis_provider.dart ──→ provider
│   ├── models/watchlist_provider.dart ──→ provider
│   └── widgets/chat_bubble.dart
└── screens/settings_screen.dart
    └── models/analysis_provider.dart ──→ provider
```

---

---
---

## Session 3: 2026-04-15 — Binance + Telegram + Portfolio (SESSION_3.md)

**Kontekst:** Session 2 završio s 3 taba i Analysis loggingom. Session 3 dodaje Binance Spot API za trading (Faza 2 manual + Faza 3 auto), Telegram Bot notifikacije i Portfolio screen kao 4. tab. Developer ima problem s Binance login (SMS 2FA + duplikatni account) — Faze A–F implementirane bez live test verifikacije, testnet live test ostaje TODO dok developer ne vrati pristup.

---

### Faza A — pubspec + StorageService credential extension
**Status:** Completed

**Ažurirani fajlovi:**

`pubspec.yaml` — dodane 3 dependencies:
- `flutter_local_notifications: ^18.0.0` (za buduće lokalne notifikacije)
- `crypto: ^3.0.3` (HMAC-SHA256 za Binance potpis)
- `convert: ^3.1.1`

`flutter pub get` — 9 paketa dodano, bez konflikata.

`lib/services/storage_service.dart` (60→147 linija):
- Nova konstanta `_positionsBox = 'positions'`, dodana u `init()` kao 4. Hive box
- Nove konstante: `_binanceApiKeyField`, `_binanceSecretField`, `_binanceTestnetField`, `_telegramTokenField`, `_telegramChatIdField`
- Metode: `getBinanceApiKey/Secret`, `getBinanceTestnet` (default true), `saveBinanceCredentials`, `deleteBinanceCredentials`, `setBinanceTestnet`
- Metode: `getTelegramToken/ChatId`, `saveTelegramCredentials`, `deleteTelegramCredentials`

`test/widget_test.dart` — dodano `Hive.openBox('positions')` u setUpAll.

---

### Faza B — Modeli (CoinPosition, RiskParameters, TradeProposal, TradeResult)
**Status:** Completed

**Kreirani fajlovi:**

`lib/models/coin_position.dart` (52 linije):
- 9 polja: coinId, symbol, binanceSymbol, quantity, entryPrice, entryTotal, entryTime, currentPrice (mutable), stopLossOrderId
- Computed getteri: `currentValue`, `pnlAbsolute`, `pnlPercent`, `isProfit`
- `toMap/fromMap` za Hive

`lib/models/risk_parameters.dart` (84 linije):
- 8 polja s defaultima: maxTradeAmountUsdt (10.0), maxOpenPositions (3), stopLossPercent (15.0), takeProfitPercent (30.0), autoTradeEnabled (false), telegramNotifications (false), quietHoursStart (23), quietHoursEnd (7)
- `isQuietHours` getter s wraparound logikom (23-7 prijelaz preko ponoći)
- `copyWith()`, `toMap/fromMap`

`lib/models/trade_proposal.dart` (26 linija):
- 8 polja: coin, amountUsdt, estimatedQty, currentPrice, stopLossPrice, takeProfitPrice, claudeRecommendation, createdAt
- `isExpired` getter (>60s od kreiranja)

`lib/models/trade_result.dart` (20 linija):
- 6 polja: success, orderId?, executedPrice?, executedQty?, totalUsdt?, errorMessage?
- `.failure(String)` factory

**Ažurirani fajlovi:**

`lib/services/storage_service.dart` — dodane metode:
- `getRiskParameters()` → vraća default `RiskParameters()` ako nema spremljenog
- `saveRiskParameters(RiskParameters)`
- `savePosition(CoinPosition)` — keyed po `coinId`
- `removePosition(String coinId)`
- `getPositions()` → sortirano po entryTime descending
- Konstanta `_riskParamsField = 'risk_parameters'`

---

### Faza C — BinanceService
**Status:** Completed (code only — live test TODO, vidi dolje)

**Kreirani fajlovi:**

`lib/services/binance_service.dart` (~270 linija):
- `BinanceException` — custom exception, optional `code` (Binance error code)
- `BinanceOrder` — orderId, symbol, side, status, executedQty, cummulativeQuoteQty, transactTime. Computed getter `avgPrice = cummulativeQuoteQty / executedQty`. `fromJson()` parsira i `transactTime` i `time` polja
- `BinanceService`:
  - URL switch `_prodUrl` (api.binance.com) / `_testnetUrl` (testnet.binance.vision) ovisno o `StorageService.getBinanceTestnet()`
  - `reloadCredentials()` za refresh nakon Settings save
  - Hasgetter `hasCredentials`, `isTestnet`
  - `_sign(queryString)` — HMAC-SHA256 s `crypto` paketom, UTF-8 encode, hex digest
  - `_signedQuery()` — dodaje `timestamp` (Unix ms) + `recvWindow=5000` + `signature`
  - Header `X-MBX-APIKEY` za signed pozive
  - `_throwForResponse()` — mapira kodove -1021 (timestamp sync), -2010 (insufficient balance), -1100/-1121 (bad symbol), ostalo fallback na `msg`
  - Metode: `ping()` (public), `getUsdtBalance()`, `getCurrentPrice(symbol)`, `placeBuyOrder(symbol, quoteAmount)` koristi `quoteOrderQty` (kupuješ za X USDT), `placeSellOrder(symbol, quantity)` 6 decimala, `getOpenPositions()` delegira na StorageService, `getOrderHistory(symbol)` limit 10
  - Timeout 15s svuda, TimeoutException → BinanceException

---

### Faza D — TradeService + TelegramService
**Status:** Completed (code only — live test TODO)

**Kreirani fajlovi:**

`lib/services/trade_service.dart` (~160 linija):
- `TradeService({BinanceService?})` — koristi injected ili default
- `_binanceSymbol(Coin)` → `${SYMBOL.toUpperCase()}USDT`
- `prepareTradeProposal()`: fetch price, izračuna estimatedQty = amount/price, stopLossPrice = price*(1-sl/100), takeProfitPrice = price*(1+tp/100). Vraća TradeProposal
- `executeTrade(proposal)`: provjerava isExpired, maxOpenPositions, duplicate position, USDT balance. Ako OK, `placeBuyOrder`, kreira `CoinPosition`, sprema u Hive, logira AnalysisLog tipa **ENTERED** (novi tip — marker za buduće dashbording). Vraća `TradeResult`
- `autoExecuteIfEligible()`: gate na autoTradeEnabled + !isQuietHours + hasCredentials + !maxOpenPositions + !duplicate. Zove prepare + execute, vraća null ako ne eligibilan ili pukne
- `checkStopLosses()`: iterira pozicije, fetcha cijenu, ako price <= SL ili >= TP poziva closePosition
- `closePosition(position)`: market sell po `quantity`, brise iz Hive, logira AnalysisLog tipa **EXITED** s P&L u poruci

`lib/services/telegram_service.dart` (~185 linija):
- `TelegramService({http.Client?})` — konstruira, reloadCredentials iz StorageService
- `isConfigured` getter (token i chatId set)
- `setCommandHandler(TelegramCommandHandler)` — callback za procesiranje komandi
- `sendMessage(text)` → Markdown parse, sends `/sendMessage`, timeout 15s, swallow greške vraća false
- `sendInterestingSignal(coin, claudeRecommendation, riskParams)` — formatira 10-line Markdown poruku s 🚨 headerom, brojkama i quick commands `/buy_SYM /skip_SYM /analyze_SYM`
- `sendTradeExecuted(position, result)`, `sendStopLossTriggered(position, result)`, `sendDailySummary(positions, logs)`
- `startPolling()`: Timer.periodic 5s → `_poll()` poziva `getUpdates?offset=${lastUpdateId+1}&timeout=0`, procesira updates preko `_processUpdate`. Parsing: `/command_ARG` → splitta na prvom `_`, filtrira po chatId, poziva handler
- `stopPolling()`: cancel timer

---

### Faza E — Portfolio screen + Settings update
**Status:** Completed

**Kreirani fajlovi:**

`lib/models/portfolio_provider.dart` (~95 linija):
- Extends ChangeNotifier
- State: `_usdtBalance`, `_positions`, `_isLoading`, `_error`, `_priceTimer`
- Computed getteri: `totalInvested`, `totalValue`, `totalPnl`, `totalPnlPercent`
- `refresh()`: reload positions + getUsdtBalance + refresh prices za sve pozicije
- `startAutoRefresh()`: Timer.periodic 30s poziva `_refreshPrices` + notify
- `stopAutoRefresh()`, `reloadCredentials()`, `closePosition(position)`
- `dispose()` cancela timer

`lib/screens/portfolio_screen.dart` (~290 linija):
- StatefulWidget s `AutomaticKeepAliveClientMixin` (`wantKeepAlive: true`)
- `initState` microtask — gate na `hasCredentials` prije start (važno za testove koji nemaju credentialse)
- `_providerRef` čuva provider za safe `dispose()` (izbjegava context.read u dispose)
- **Sekcija 1 — Header Card:** Portfolio title + refresh icon, USDT balance, Open positions count, Total P&L (obojeno zeleno/crveno)
- **Sekcija 2 — Open Positions:** lista CoinPosition cardova (symbol, entry→now, qty+invested, P&L, SL/TP). Close button → confirm dialog → `provider.closePosition()`
- **Sekcija 3 — Analysis History:** zadnjih 20 AnalysisLog zapisa, chip boja po tipu (INTERESTING=green, ENTERED=blue, EXITED=purple, WATCH=orange, SKIP=grey)
- RefreshIndicator wrapa cijeli ListView
- No-credentials state: wallet icon + poruka "Binance nije konfiguriran"

**Ažurirani fajlovi:**

`lib/screens/settings_screen.dart` (247→~700 linija, praktički prepisan):
- Očuvana postojeća Anthropic API Key sekcija + About
- Nova **Binance sekcija**: warning banner (nema withdrawal perm), API Key + Secret (oba obscured, `••` trick za preskip), Testnet SwitchListTile (s confirm dialogom za prebacivanje na LIVE), Save/Test/Remove buttons. Test button poziva `ping() + getUsdtBalance()` i prikazuje SnackBar rezultat
- Nova **Risk Parameters sekcija**: TextField za maxTradeAmountUsdt, Dropdown 1-10 za maxOpenPositions, Slider 5-30% stop-loss, Slider 10-100% take-profit, SwitchListTile za auto-trade (samo ako Binance konfiguriran, s narančastim warningom), TimePicker za quiet hours start/end
- Nova **Telegram sekcija**: Bot Token (obscured), Chat ID, Save + Test button
- `_sectionHeader()` helper widget s icon/title/status badge pattern

**Ažurirani widget_test.dart:** `expect(find.text('About CoinSight'), ...)` → `expect(find.text('Binance API'), ...)` (About sad off-screen u dužem settings listu).

---

### Faza F — Analysis Trade Action Bar + main.dart 4 taba + polling/stop-loss timer
**Status:** Completed

**Ažurirani fajlovi:**

`lib/screens/analysis_screen.dart` (329→~480 linija):
- Dodan `TradeService`, `_amountController`, `_dismissedActionBarIndex`, `_executingTrade`
- Novi widget `_buildTradeActionBarIfEligible()` između MessageList i ErrorBar:
  - Prikazuje se ako: postoji last message, nije dismissed, role='assistant', sadrži `**INTERESTING**`, Binance hasCredentials, !autoTradeEnabled, watchlist nije prazan
  - Zeleni okvir s naslovom `🚨 INTERESTING signal — SYMBOL/USDT`, editable amount TextField (prefilano maxTradeAmountUsdt), SL/TP info, 3 buttona: **BUY NOW** (green), **SKIP**, **TELEGRAM**
  - X dismiss tracka indeks zadnje poruke u `_dismissedActionBarIndex`
- `_buyNow()`: poziva `prepareTradeProposal`, otvara confirm dialog (`_showProposalDialog`), ako OK poziva `executeTrade`, prikazuje SnackBar rezultat, dismissa bar
- `_skip()`: logira AnalysisLog tipa SKIP s `[SKIPPED]` prefixom
- `_sendToTelegram()`: poziva `TelegramService.sendInterestingSignal()`
- `_confirmClearChat`: resetira `_dismissedActionBarIndex = -1`

`lib/main.dart` (90→125 linija):
- MultiProvider dobio `PortfolioProvider`
- `_titles` proširen: `['Watchlist', 'Analysis', 'Portfolio', 'Settings']`
- Novi field `_tradeService`, `_telegramService`, `_stopLossTimer`
- `initState` zove `_startBackgroundServices()`:
  - Telegram polling start ako `isConfigured` + setCommandHandler
  - StopLoss Timer.periodic 5min — **gated na `BinanceService().hasCredentials`** (izbjegava pending timer u testovima bez credentialsa)
- `_handleTelegramCommand()` — minimalna implementacija za `/status`, `/stop`, `/start`, fallback help (prošireno u budućim sesijama za /buy_/skip_/analyze_)
- `dispose()` cancela timer + telegram polling
- BottomNavigationBar: `type: BottomNavigationBarType.fixed` (sprječava label sakrivanje kod 4 taba), 4 taba s ikonama (Portfolio koristi `Icons.account_balance_wallet_outlined/account_balance_wallet`)
- IndexedStack s 4 screena

---

### Session 3 — Finalna Verifikacija
- `flutter analyze` — **0 issues**
- `flutter test` — **2/2 passed** (widget_test.dart)
- `flutter build apk --debug` — **NIJE POKRENUT** (vidi TODO)
- `flutter build windows` — **NIJE POKRENUT** (vidi TODO)

---

### Session 3 — TODO (za kad developer vrati Binance pristup)

1. **Binance account recovery:** developer ima problem s SMS 2FA + duplicate account na broju. Moraju se riješiti putem binance.com Account Appeal ili live chata prije testiranja.
2. **Live test na testnetu:**
   - Otvoriti account na testnet.binance.vision (GitHub auth)
   - Generirati test API ključeve (Enable Spot Trading)
   - U CoinSight Settings upisati ključeve, Testnet ON, kliknuti "Test" → očekivani rezultat: `OK — USDT balance: $XXX.XX (testnet)`
3. **End-to-end workflow test:**
   - Konfigurirati Binance testnet + Telegram bota (kreirati preko @BotFather)
   - Otvoriti New Listings tab, zatražiti od Claudea INTERESTING signal za neki watchlist coin
   - Testirati BUY NOW → potvrda → provjera Portfolio taba (pozicija vidljiva s current price)
   - Testirati Close Position
   - Testirati Telegram /status komandu
   - Uključiti auto-trade toggle, provjeriti Faza 3 flow
4. **flutter build apk --debug** i **flutter build windows** — pokrenuti nakon live testa, dokumentirati u WORKLOG.
5. **Potencijalno potrebne prilagodbe nakon live testa:**
   - Preciznost LOT_SIZE — Binance vraća grešku -1013 ako qty ne poštuje lot step. Trenutno se koristi fiksno 6 decimala za sell — možda treba per-symbol `exchangeInfo` fetch
   - Timestamp sync (-1021) — ako sustav ima skew, treba `/api/v3/time` offset adjustment
   - Binance EU regulatorne restrikcije — neke funkcije možda nedostupne u HR s produkcijskog Binance.com endpointa (potreba prebacivanja na Binance.eu domain?)

---

### File Manifest (lib/) — Stanje nakon Session 3

| Fajl | Linije | Opis |
|------|--------|------|
| `main.dart` | 125 | 4-tab nav, PortfolioProvider, telegram polling, stop-loss timer |
| `models/coin.dart` | 52 | (unchanged) |
| `models/analysis_log.dart` | 42 | (unchanged) |
| `models/coin_position.dart` | 52 | **NEW** — Binance spot pozicija, P&L getteri |
| `models/risk_parameters.dart` | 84 | **NEW** — risk config, isQuietHours, copyWith |
| `models/trade_proposal.dart` | 26 | **NEW** — pending trade, 60s expiry |
| `models/trade_result.dart` | 20 | **NEW** — execute outcome |
| `models/watchlist_provider.dart` | 132 | (unchanged) |
| `models/analysis_provider.dart` | 131 | (unchanged) |
| `models/portfolio_provider.dart` | 95 | **NEW** — Binance balance + positions + 30s price refresh |
| `services/coingecko_service.dart` | 146 | (unchanged) |
| `services/claude_service.dart` | 122 | (unchanged) |
| `services/storage_service.dart` | 147 | Binance + Telegram credentials, positions box, risk params |
| `services/binance_service.dart` | ~270 | **NEW** — HMAC-SHA256 signed REST, testnet/prod switch |
| `services/trade_service.dart` | ~160 | **NEW** — prepare/execute/auto/checkSL/close |
| `services/telegram_service.dart` | ~185 | **NEW** — send signals + 5s polling getUpdates |
| `screens/watchlist_screen.dart` | 256 | (unchanged) |
| `screens/analysis_screen.dart` | ~480 | + Trade Action Bar (INTERESTING trigger) |
| `screens/settings_screen.dart` | ~700 | + Binance + Risk Params + Telegram sekcije |
| `screens/portfolio_screen.dart` | ~290 | **NEW** — header summary + positions + history |
| `widgets/coin_card.dart` | 306 | (unchanged) |
| `widgets/chat_bubble.dart` | 50 | (unchanged) |
| `widgets/sparkline_chart.dart` | 68 | (unchanged) |
| `theme/app_theme.dart` | 78 | (unchanged) |

---

## Identified Issues

- **Binance account lockout (developer):** SMS 2FA ne stiže, duplicate account na broju — blokira live testing. Nije bug u appu, ali blocker za verifikaciju Session 3 rada.
- **LOT_SIZE precision hardcoded:** `placeSellOrder` koristi fiksno 6 decimala — Binance može vratiti -1013 za neke simbole. Rješenje: fetch `/api/v3/exchangeInfo` i cache LOT_SIZE stepSize per simbol. Popravak čeka live test da potvrdi realnu pojavu.
- **Timestamp drift:** ako sistemski sat driftuje, Binance vraća -1021. Trenutno sa `recvWindow=5000ms`. Za robusnost dodati `/api/v3/time` offset calc pri prvoj konekciji.

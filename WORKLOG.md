# CoinSight Worklog

## Session: 2026-04-12

### Phase 1 — Scaffold
**Status:** Completed

**Opis:** Inicijalni setup Flutter projekta.

**Kreirani fajlovi:**
- `pubspec.yaml` — dependencies (http, provider, hive, hive_flutter, intl, cupertino_icons)
- `lib/main.dart` — CoinSightApp entry point, MainNavigation sa bottom nav (3 taba)
- `lib/theme/app_theme.dart` — dark tema (primary #6C63FF, secondary #03DAC6, surface #1E1E1E, card #252525)
- `lib/screens/watchlist_screen.dart` — stub
- `lib/screens/analysis_screen.dart` — stub
- `lib/screens/settings_screen.dart` — stub

**Direktoriji kreirani:** `lib/screens/`, `lib/widgets/`, `lib/services/`, `lib/models/`, `lib/theme/`

**Verifikacija:** `flutter analyze` — 0 issues, `flutter build windows` — uspješan

---

### Phase 2 — CoinGecko + Watchlist
**Status:** Completed

**Opis:** Integracija CoinGecko API-ja i funkcionalan Watchlist screen sa stvarnim podacima.

**Kreirani fajlovi:**
- `lib/models/coin.dart` — Coin model (id, symbol, name, image, currentPrice, marketCap, marketCapRank, priceChangePercentage24h, high24h, low24h, totalVolume, sparklineIn7d). Factory `Coin.fromJson()` za CoinGecko JSON mapping
- `lib/services/coingecko_service.dart` — CoinGeckoService klasa. Endpoint: `GET /api/v3/coins/markets`. Metode: `getMarketData()` (top coins po market cap), `searchAndFetch()` (search + market data). Custom `CoinGeckoException` za error handling
- `lib/models/watchlist_provider.dart` — WatchlistProvider (ChangeNotifier). State: topCoins, watchlistCoins, watchlistIds, isLoading, error. Metode: fetchTopCoins(), refreshWatchlist(), toggleWatchlist(). Default watchlist: bitcoin, ethereum, solana
- `lib/widgets/sparkline_chart.dart` — SparklineChart widget. CustomPainter koji crta 7-day price trend liniju. Props: data (List<double>), color, height, width
- `lib/widgets/coin_card.dart` — CoinCard widget. Prikazuje: rank, coin icon (Image.network), ime/symbol, sparkline, cijena (NumberFormat.currency), 24h change (zelena/crvena), star toggle

**Ažurirani fajlovi:**
- `lib/screens/watchlist_screen.dart` — kompletno prepisano. TabBar sa 2 taba (My Watchlist / Top Coins). Consumer<WatchlistProvider> za reaktivni UI. Pull-to-refresh na oba taba. Empty state za prazan watchlist. Error state s Retry button
- `lib/main.dart` — dodan ChangeNotifierProvider za WatchlistProvider

**Verifikacija:** `flutter analyze` — 0 issues, `flutter build windows` — uspješan

---

### Phase 3 — Anthropic/Claude Integration
**Status:** Completed

**Opis:** Chat sučelje s Claude AI za crypto analizu.

**Kreirani fajlovi:**
- `lib/services/claude_service.dart` — ClaudeService klasa. Endpoint: `POST /v1/messages`. Model: `claude-sonnet-4-20250514`. API version: `2023-06-01`. Max tokens: 1024. Metode: sendMessage() s history support, setApiKey(). Custom `ClaudeException` (401, 429 handling). `ChatMessage` klasa (role, content, timestamp, toJson())
- `lib/models/analysis_provider.dart` — AnalysisProvider (ChangeNotifier). State: messages (List<ChatMessage>), isLoading, error. System prompt: CoinSight AI crypto assistant s DYOR disclaimer. Metode: sendMessage() (s watchlist context injection), setApiKey(), clearChat(). `_buildUserMessage()` automatski dodaje watchlist podatke uz svako pitanje
- `lib/widgets/chat_bubble.dart` — ChatBubble widget. User poruke desno (primary color s alpha), assistant poruke lijevo (card color). SelectableText za copy. Asymmetric border radius

**Ažurirani fajlovi:**
- `lib/screens/analysis_screen.dart` — kompletno prepisano. States: no API key, empty (sa suggestion chips: "Analyze my watchlist", "Bitcoin outlook?", "Explain DeFi"), chat lista, typing indicator ("Thinking..." s spinner), error bar, input bar sa send/clear
- `lib/main.dart` — MultiProvider s WatchlistProvider + AnalysisProvider

**Verifikacija:** `flutter analyze` — 0 issues, `flutter build windows` — uspješan

---

### Phase 4 — Hive Storage + Settings
**Status:** Completed

**Opis:** Lokalna persistencija za watchlist i API key, te Settings screen.

**Kreirani fajlovi:**
- `lib/services/storage_service.dart` — StorageService (static). Dva Hive box-a: 'settings' i 'watchlist'. Metode: init() (async, poziva se u main), getApiKey()/saveApiKey()/deleteApiKey(), getWatchlistIds()/saveWatchlistIds(). Default watchlist IDs ako nema spremljenih

**Ažurirani fajlovi:**
- `lib/models/watchlist_provider.dart` — konstruktor čita watchlist IDs iz Hive. toggleWatchlist() sprema u Hive nakon svake promjene
- `lib/models/analysis_provider.dart` — konstruktor čita API key iz Hive. setApiKey() sprema u Hive. Dodan removeApiKey() koji briše iz Hive i reseta service
- `lib/screens/settings_screen.dart` — kompletno prepisano. API key sekcija: TextField s obscure toggle, Save/Remove dugmad, status badge (Active/Not set), hint "sk-ant-...". About sekcija: verzija, data sources (CoinGecko, Claude), DYOR disclaimer. SnackBar feedback za save/remove
- `lib/main.dart` — dodan `WidgetsFlutterBinding.ensureInitialized()` i `StorageService.init()` prije runApp

**Verifikacija:** `flutter analyze` — 0 issues, `flutter build windows` — uspješan

---

### Phase 5 — Polish
**Status:** Completed

**Opis:** Error handling, loading states, UX poboljšanja.

**Ažurirani fajlovi:**

`lib/services/coingecko_service.dart`:
- Dodan `import 'dart:async'` za TimeoutException
- HTTP timeout: 15 sekundi na sve pozive
- `try/catch TimeoutException` oko svakog HTTP poziva
- `try/catch FormatException` oko svakog `json.decode()`
- Null check na `searchData['coins']` (`as List<dynamic>?`)

`lib/services/claude_service.dart`:
- Dodan `import 'dart:async'` za TimeoutException
- HTTP timeout: 30 sekundi
- `try/catch TimeoutException` oko POST poziva
- Null check na `data['content']` — baca ClaudeException ako je null/empty
- `try/catch FormatException` na response i error parsing

`lib/widgets/coin_card.dart`:
- Image.network s `loadingBuilder` — prikazuje fallback icon dok se slika učitava
- `_buildFallbackIcon()` — izvučen u zasebnu metodu, safe `substring` s isEmpty check
- AnimatedSwitcher na star icon — scale tranzicija (250ms) pri toggle-u
- CoinCardSkeleton widget — shimmer animacija (AnimationController, 1200ms repeat). Prikazuje placeholder boxes za rank, icon, ime, sparkline, cijenu

`lib/screens/watchlist_screen.dart`:
- `_buildSkeletonList()` — 8 CoinCardSkeleton widgeta umjesto CircularProgressIndicator
- Koristi se za oba taba dok se podaci učitavaju

`lib/screens/analysis_screen.dart`:
- `_disposed` flag — sprječava scroll nakon dispose()
- `_scrollToBottom()` — double check `_disposed` i `hasClients` prije i nakon Future.delayed
- `.then((_) => _scrollToBottom())` na sendMessage za scroll nakon odgovora
- TextField `enabled: !provider.isLoading` — disabled input dok čeka odgovor
- Hint text mijenja se u "Waiting for response..." dok je loading
- Error bar pretvoren u Dismissible (swipe) + X button za dismiss
- `_confirmClearChat()` — AlertDialog za potvrdu brisanja chata
- Dodan `clearError()` poziv u AnalysisProvider
- Border color fix: `Colors.grey[800]!.withValues(alpha: 0.5)` umjesto `Colors.grey[850]!`

`lib/models/analysis_provider.dart`:
- Dodan `clearError()` metoda

`lib/main.dart`:
- `try/catch` oko `StorageService.init()` — app se pokreće čak i ako Hive init failira
- `IndexedStack` umjesto direktnog `_screens[_currentIndex]` — čuva stanje tabova

**Verifikacija:** `flutter analyze` — 0 issues, `flutter build windows` — uspješan

---

### Post-Phase — Audit, Documentation & Git Setup
**Status:** Completed

**Opis:** Detaljna analiza koda, GitHub dokumentacija, licenca, git inicijalizacija.

**Audit rezultati:**
- 14 Dart fajlova u lib/, svi ispravni
- 0 kritičnih bugova
- 0 nedostajućih importa
- Svi provideri pravilno wired
- Svi dispose() pozivi na mjestu
- Null safety: strict mode compliant
- Nema hardkodiranih API ključeva ili secretsa

**Cleanup:**
- Uklonjene nekorištene dependencies iz pubspec.yaml: `flutter_dotenv` (5.2.1), `url_launcher` (6.3.0) — instalirane ali nigdje importane
- `flutter pub get` — uklonjena 10 paketa (url_launcher + platformske implementacije + flutter_dotenv)

**Kreirani fajlovi:**
- `LICENSE` — Proprietary Software License. Zabranjuje: kopiranje, modifikaciju, distribuciju, sublicenciranje, reverse engineering, dekompilaciju. Klauzula o povjerljivosti. Automatski prestanak licence pri kršenju
- `README.md` — Features (Watchlist, AI Analysis, Settings), Tech Stack tablica, Architecture tree, Setup upute (prerequisites, run commands, konfiguracija), API Usage (CoinGecko free tier, Anthropic Claude), Error Handling tablica (6 scenarija), Security sekcija, License footer
- `WORKLOG.md` — ovaj fajl

**Ažurirani fajlovi:**
- `.gitignore` — dodano: `.env`, `.env.*`, `*.env`, `.hive/`, `chat_log.md`, `work_log.md`
- `windows/runner/Runner.rc` — CompanyName: "CoinSight", FileDescription: "CoinSight - AI-Powered Crypto Insights", LegalCopyright: "Copyright (C) 2026 CoinSight. All rights reserved. Proprietary and confidential.", ProductName: "CoinSight"
- `test/widget_test.dart` — kompletno prepisano. `Hive.init()` s temp directory (ne koristi path_provider u testu). 2 testa: "App renders with bottom navigation", "Bottom navigation switches tabs" (provjerava tab switching, API Key Required state, Settings content)
- `pubspec.yaml` — uklonjene url_launcher i flutter_dotenv

**Git:**
- `git init` — inicijalizirano
- Initial commit `5691f2e`: "Initial commit: CoinSight v1.0.0" — 146 fajlova, 7399 insertions

**Finalna verifikacija:**
- `flutter analyze` — 0 issues
- `flutter test` — 2/2 passed
- `flutter build windows` — coinsight.exe built successfully

---

## File Manifest (lib/)

| Fajl | Linije | Opis |
|------|--------|------|
| `main.dart` | ~85 | Entry point, MultiProvider, IndexedStack navigacija |
| `models/coin.dart` | ~45 | Coin data model, fromJson() factory |
| `models/watchlist_provider.dart` | ~90 | Watchlist state, Hive persistencija |
| `models/analysis_provider.dart` | ~90 | Chat state, Claude API integracija |
| `services/coingecko_service.dart` | ~90 | CoinGecko HTTP client, timeout, error handling |
| `services/claude_service.dart` | ~110 | Anthropic HTTP client, ChatMessage, timeout |
| `services/storage_service.dart` | ~40 | Hive wrapper, API key + watchlist storage |
| `screens/watchlist_screen.dart` | ~150 | Dva taba, skeleton loader, pull-to-refresh |
| `screens/analysis_screen.dart` | ~270 | Chat UI, suggestions, typing, error, confirm dialogs |
| `screens/settings_screen.dart` | ~220 | API key management, about, confirm dialog |
| `widgets/coin_card.dart` | ~210 | CoinCard + CoinCardSkeleton (shimmer) |
| `widgets/chat_bubble.dart` | ~45 | Chat mjehurić, SelectableText |
| `widgets/sparkline_chart.dart` | ~65 | 7d price chart, CustomPainter |
| `theme/app_theme.dart` | ~75 | Dark tema konfiguracija |

---

## Dependency Graph

```
main.dart
├── theme/app_theme.dart
├── services/storage_service.dart ──→ hive_flutter
├── models/watchlist_provider.dart
│   ├── models/coin.dart
│   ├── services/coingecko_service.dart ──→ http
│   └── services/storage_service.dart
├── models/analysis_provider.dart
│   ├── services/claude_service.dart ──→ http
│   ├── services/storage_service.dart
│   └── models/coin.dart
├── screens/watchlist_screen.dart
│   ├── models/watchlist_provider.dart ──→ provider
│   └── widgets/coin_card.dart
│       ├── models/coin.dart
│       ├── theme/app_theme.dart
│       ├── widgets/sparkline_chart.dart
│       └── intl
├── screens/analysis_screen.dart
│   ├── models/analysis_provider.dart ──→ provider
│   ├── models/watchlist_provider.dart ──→ provider
│   └── widgets/chat_bubble.dart
└── screens/settings_screen.dart
    └── models/analysis_provider.dart ──→ provider
```

---

## Identified Issues

_No unresolved issues at this time._

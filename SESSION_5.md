# CoinSight — SESSION 5
**Datum:** 2026-04-16  
**Verzija:** 2.0.0+2 → 2.1.0+3  
**Cilj:** Bugfix (LOT_SIZE + timestamp), Telegram Bot Manager, App Management screen  

---

## UPUTA ZA CLAUDE CODE

**Prije svega — pročitaj ove fajlove:**
```
CLAUDE.md
WORKLOG.md
lib/services/binance_service.dart
lib/screens/settings_screen.dart
lib/services/telegram_monitor.dart
lib/services/storage_service.dart
lib/models/risk_parameters.dart
pubspec.yaml
```

Nakon čitanja napiši summary u chat (ne u WORKLOG):
- Točne linije `placeSellOrder` gdje je `toStringAsFixed(6)` hardkodiran
- Točne linije `_signedQuery` gdje se timestamp generira
- Broj linija u `settings_screen.dart`
- Postoji li `exchange_info_cache` ili slično u storage servisu

Zatim nastavi **autonomno** kroz faze. Svaka faza završava s `flutter analyze` i WORKLOG unosom. Jedini **[ČEKAJ POTVRDU]** je na kraju Faze 3 prije App Management screena.

---

## FAZA 1 — BUGFIX: LOT_SIZE DYNAMIC PRECISION

**Problem:** `placeSellOrder` koristi hardkodiranih 6 decimala za `quantity`. Binance za svaki trading par definira `LOT_SIZE` filter s `stepSize` koji određuje koliko decimala quantity smije imati. Npr. BTCUSDT ima stepSize 0.00001 (5 decimala), neki altcoini imaju stepSize 1.0 (0 decimala). Hardkodirano 6 decimala uzrokuje Binance error `-1013` za parove s većim stepSize.

**Rješenje:** Dohvati LOT_SIZE stepSize iz `/api/v3/exchangeInfo` i cachej lokalno.

### 1.1 Dodaj u `lib/services/binance_service.dart`

**Cache map** u klasi:
```dart
// In-memory cache: symbol → stepSize decimals
final Map<String, int> _lotSizeCache = {};
```

**Nova metoda `_getLotSizeDecimals()`:**
```dart
/// Dohvaća broj decimala za quantity iz Binance LOT_SIZE filtera.
/// Cache-ira rezultat in-memory za trajanje app sesije.
/// Vraća 6 kao fallback ako fetch faila (konzervativno).
Future<int> _getLotSizeDecimals(String symbol) async {
  if (_lotSizeCache.containsKey(symbol)) {
    return _lotSizeCache[symbol]!;
  }

  try {
    final uri = Uri.parse(
      '$_baseUrl/api/v3/exchangeInfo?symbol=${Uri.encodeQueryComponent(symbol)}'
    );
    final res = await _client.get(uri).timeout(_timeout);
    if (res.statusCode != 200) return 6;

    final data = json.decode(res.body) as Map<String, dynamic>;
    final symbols = data['symbols'] as List<dynamic>? ?? [];
    if (symbols.isEmpty) return 6;

    final symbolInfo = symbols.first as Map<String, dynamic>;
    final filters = symbolInfo['filters'] as List<dynamic>? ?? [];

    for (final f in filters) {
      final filter = f as Map<String, dynamic>;
      if (filter['filterType'] == 'LOT_SIZE') {
        final stepSize = filter['stepSize'] as String? ?? '0.000001';
        final decimals = _stepSizeToDecimals(stepSize);
        _lotSizeCache[symbol] = decimals;
        return decimals;
      }
    }
  } catch (_) {
    // Fallback na 6 decimala ako fetch faila
  }

  _lotSizeCache[symbol] = 6;
  return 6;
}

/// Konvertira Binance stepSize string u broj decimala.
/// '1.00000000' → 0
/// '0.10000000' → 1
/// '0.00100000' → 3
/// '0.00000100' → 6
int _stepSizeToDecimals(String stepSize) {
  final normalized = stepSize.replaceAll(RegExp(r'0+$'), '');
  final dotIndex = normalized.indexOf('.');
  if (dotIndex == -1) return 0;
  final decimals = normalized.length - dotIndex - 1;
  return decimals < 0 ? 0 : decimals;
}
```

**Ažuriraj `placeSellOrder()`** — zamijeni hardkodirani `toStringAsFixed(6)`:

```dart
// STARO:
'quantity': quantity.toStringAsFixed(6),

// NOVO:
final decimals = await _getLotSizeDecimals(symbol);
'quantity': quantity.toStringAsFixed(decimals),
```

`placeSellOrder` postaje `async` ako već nije — provjeri i ažuriraj potpis.

**Verifikacija:**
```bash
flutter analyze  # 0 issues
```
Provjeri da `_getLotSizeDecimals` i `_stepSizeToDecimals` su privatne metode, ne javni API.

---

## FAZA 2 — BUGFIX: TIMESTAMP OFFSET (DRIFT KOREKCIJA)

**Problem:** `_signedQuery` koristi `DateTime.now().millisecondsSinceEpoch` koji ovisi o sistemskom satu telefona. Ako sat driftuje za više od `recvWindow` (5000ms), Binance vraća error `-1021 TIMESTAMP_OUT_OF_SYNC`. Mobilni uređaji mogu imati drift osobito nakon promjene mreže ili buđenja iz sleep modea.

**Rješenje:** Jednom pri inicijalizaciji dohvati Binance server timestamp, izračunaj offset, i primjenjuj ga pri svakom signed requestu.

### 2.1 Dodaj u `lib/services/binance_service.dart`

**Offset field:**
```dart
int _serverTimeOffsetMs = 0;
```

**Nova metoda `syncServerTime()`:**
```dart
/// Sinkronizira lokalni sat s Binance serverom.
/// Poziva se jednom pri prvom authenticated requestu i
/// pri -1021 grešci.
/// Javna metoda — poziva se iz Settings screen TEST gumba.
Future<void> syncServerTime() async {
  try {
    final uri = Uri.parse('$_baseUrl/api/v3/time');
    final res = await _client.get(uri).timeout(_timeout);
    if (res.statusCode != 200) return;

    final data = json.decode(res.body) as Map<String, dynamic>;
    final serverTime = data['serverTime'] as int?;
    if (serverTime == null) return;

    final localTime = DateTime.now().millisecondsSinceEpoch;
    _serverTimeOffsetMs = serverTime - localTime;
    
    debugPrint('Binance time offset: ${_serverTimeOffsetMs}ms');
  } catch (_) {
    _serverTimeOffsetMs = 0;
  }
}

/// Vraća korigirani timestamp u milliseconds
int get _correctedTimestamp =>
    DateTime.now().millisecondsSinceEpoch + _serverTimeOffsetMs;
```

**Ažuriraj `_signedQuery()`** — zamijeni timestamp:
```dart
// STARO:
'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),

// NOVO:
'timestamp': _correctedTimestamp.toString(),
```

**Ažuriraj `_throwForResponse()`** — pri `-1021` automatski resinkaj:
```dart
if (code == -1021) {
  // Auto-resync i vrati bolju poruku
  syncServerTime(); // fire-and-forget
  throw BinanceException(
    'Sat uređaja nije sinkroniziran s Binance serverom. '
    'Pokušaj ponovo — offset je korigiran.',
    code: code,
  );
}
```

**Ažuriraj `ping()`** — dodaj sync pri inicijalizaciji:
```dart
Future<bool> ping() async {
  try {
    final uri = Uri.parse('$_baseUrl/api/v3/ping');
    final res = await _client.get(uri).timeout(_timeout);
    if (res.statusCode == 200) {
      await syncServerTime(); // Sync odmah nakon uspješnog pinga
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}
```

**Ažuriraj Settings screen `_testBinance()`** — TEST KONEKCIJU gumb neka pozove i syncServerTime:
```dart
// Nakon ping() poziva, dodaj:
await binance.syncServerTime();
// U SnackBar poruci dodaj offset info:
'Konekcija OK | USDT: \$${balance.toStringAsFixed(2)} | Offset: ${binance.serverTimeOffsetMs}ms'
```

Dodaj getter u BinanceService za prikaz u UI:
```dart
int get serverTimeOffsetMs => _serverTimeOffsetMs;
```

**Verifikacija:**
```bash
flutter analyze  # 0 issues
```

WORKLOG unos za Faze 1 i 2 zajedno, pa nastavi autonomno s Fazom 3.

---

## FAZA 3 — TELEGRAM BOT MANAGER SCREEN

**Koncept:** Zasebni screen (ne Settings, nego modalni bottom sheet ili novi route) koji daje potpunu kontrolu nad Telegram Monitor botom. Korisnik ovdje vidi gdje bot operira, dodaje/uklanja kanale, prati pouzdanost svakog kanala, i skenira za relevantne kanale.

### 3.1 Kreiraj `lib/models/monitored_channel.dart`

```dart
class MonitoredChannel {
  final String username;      // '@binance'
  final String displayName;   // 'Binance Official'
  final bool isDefault;       // default kanali se ne mogu brisati
  final int signalsReceived;  // ukupno signala primljeno
  final int signalsRelevant;  // prošlo keyword filter
  final DateTime? lastSignal; // zadnji relevantan signal
  final bool isActive;        // korisnik može pauzirati pojedini kanal
  
  // Pouzdanost = relevant / received (ako ima >10 ukupnih)
  double get reliabilityScore {
    if (signalsReceived < 10) return -1; // nedovoljno podataka
    return signalsRelevant / signalsReceived;
  }
  
  String get reliabilityLabel {
    if (reliabilityScore < 0) return 'Novo';
    if (reliabilityScore > 0.3) return 'Visoka';
    if (reliabilityScore > 0.1) return 'Srednja';
    return 'Niska';
  }
  
  Color get reliabilityColor {
    if (reliabilityScore < 0) return Colors.grey;
    if (reliabilityScore > 0.3) return Colors.green;
    if (reliabilityScore > 0.1) return Colors.orange;
    return Colors.red;
  }
  
  // toMap(), fromMap(), copyWith()
}
```

### 3.2 Proširi `lib/services/storage_service.dart`

```dart
static const _monitoredChannelsDetailBox = 'monitored_channels_detail';

// Otvori box u init()

static List<MonitoredChannel> getMonitoredChannelsDetail()
static Future<void> saveMonitoredChannel(MonitoredChannel channel)
static Future<void> updateChannelStats({
  required String username,
  required bool wasRelevant,
})
static Future<void> removeMonitoredChannel(String username)
static Future<void> toggleChannelActive(String username, bool active)
```

### 3.3 Ažuriraj `lib/services/telegram_monitor.dart`

Kad signal stigne, ažuriraj statistiku kanala:
```dart
// U _processUpdate() — na kraju, nakon onSignalReceived poziva:
StorageService.updateChannelStats(
  username: channelUsername,
  wasRelevant: true, // prošlo keyword filter
);

// Za sve poruke koje NE prođu keyword filter, ali su iz praćenog kanala:
StorageService.updateChannelStats(
  username: channelUsername,
  wasRelevant: false,
);
```

### 3.4 Kreiraj `lib/screens/bot_manager_screen.dart`

Ovaj screen se otvara kao **full screen route** (ne modal) — ima vlastiti AppBar s "← Bot Manager" back gumbom.

**Struktura screena — 4 sekcije:**

**Sekcija 1 — Status Header**
```
┌─────────────────────────────────────┐
│  🤖 Telegram Monitor                │
│  Status: [AKTIVAN ●] / [NEAKTIVAN ○]│
│  Ukupno kanala: 7 | Signala danas: 3│
│  Bot: @MyCoinSightBot               │
└─────────────────────────────────────┘
```

**Sekcija 2 — Aktivni kanali (ListView)**

Za svaki kanal prikaži card:
```
┌─────────────────────────────────────┐
│  @binance              [Pouzdanost] │
│  Binance Official                   │
│  Signali: 124 primljeno | 45 rel.  │
│  Zadnji: prije 2h                   │
│  [🟢 Visoka]    [Pauziraj] [Info]  │
│  (za default kanale: nema Delete)   │
└─────────────────────────────────────┘
```

Za custom kanale dodaj Delete gumb s confirmation dialogom.

Kolor chip za pouzdanost: zelena/narančasta/crvena/siva.

**Sekcija 3 — Dodaj kanal ručno**
```
[@channel_username TextField] [DODAJ]
"Bot mora biti administrator tog kanala"
```

Validacija: mora početi s '@', minimalno 3 znaka, ne smije biti duplikat.

**Sekcija 4 — Skeniraj preporučene kanale**

Statična lista preporučenih kanala koje korisnik još ne prati:

```dart
static const _recommendedChannels = [
  {'username': '@gate_io', 'name': 'Gate.io', 'desc': 'Exchange listinzi'},
  {'username': '@mexc_global', 'name': 'MEXC Global', 'desc': 'Exchange listinzi'},
  {'username': '@bybit_official', 'name': 'Bybit', 'desc': 'Exchange'},
  {'username': '@cointelegraph', 'name': 'CoinTelegraph', 'desc': 'Crypto vijesti'},
  {'username': '@cryptonews_official', 'name': 'CryptoNews', 'desc': 'Vijesti'},
  {'username': '@defipulse', 'name': 'DeFi Pulse', 'desc': 'DeFi signali'},
  {'username': '@onchaindata', 'name': 'On-Chain Data', 'desc': 'Whale tracking'},
];
```

Prikaži samo one koje korisnik već ne prati. Za svaki:
```
@gate_io — Gate.io
"Exchange listinzi"
[DODAJ] gumb
```

### 3.5 Dodaj navigaciju do Bot Manager screena

U `lib/screens/settings_screen.dart`, u `_buildTelegramMonitorSection()`, dodaj gumb ispod toggle switcha:

```dart
const SizedBox(height: 12),
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    icon: const Icon(Icons.manage_accounts, size: 18),
    label: const Text('Otvori Bot Manager'),
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BotManagerScreen(),
      ),
    ),
  ),
),
```

**[ČEKAJ POTVRDU]** — Prikaži mi strukturu BotManagerScreen u chatu (ne pišeš kod jos), objasni kako će `MonitoredChannel` statistike biti ažurirane iz `TelegramMonitor` klase, i kako se preporučeni kanali razlikuju od custom kanala u storage-u. Čekam potvrdu koncepta.

---

## FAZA 4 — APP MANAGEMENT SCREEN

**Cilj:** Konsolidirati sve upravljačke funkcionalnosti u jedan pregledan screen koji zamjenjuje trenutni Settings screen koji je narastao na 853 linije.

**Arhitekturalna odluka:** Settings screen se ne briše — refaktorira se. Trenutni Settings postaje App Management, dobiva bolju navigacijsku strukturu kroz `ExpansionTile` ili `NavigationDrawer` pattern.

### 4.1 Refaktoriraj `lib/screens/settings_screen.dart` → App Management

Preimeniaj klasu iz `SettingsScreen` na `AppManagementScreen` ali **zadrži isti fajl** da ne mijenjaš importove u main.dart.

Ažuriraj `lib/main.dart` tab label i ikonu:
```dart
// STARO:
BottomNavigationBarItem(
  icon: Icon(Icons.settings_outlined),
  activeIcon: Icon(Icons.settings),
  label: 'Settings',
),

// NOVO:
BottomNavigationBarItem(
  icon: Icon(Icons.tune_outlined),
  activeIcon: Icon(Icons.tune),
  label: 'Manage',
),
```

Ažuriraj `_titles` listu u `_MainNavigationState`:
```dart
final _titles = const ['Watchlist', 'Analysis', 'Portfolio', 'Manage'];
```

### 4.2 Nova struktura App Management screena

Zamijeni flat scroll listu sekcija s **tabbed layout** unutar screena — `DefaultTabController` s 4 taba unutar screena (ne bottom nav, nego top TabBar unutar Scaffold body-a):

```
┌─────────────────────────────────────┐
│  App Management          (AppBar)   │
├──────┬──────┬──────┬────────────────┤
│  API │ Bot  │Trade │ App            │  ← TabBar
├──────┴──────┴──────┴────────────────┤
│                                     │
│  [Content ovisi o aktivnom tabu]    │
│                                     │
└─────────────────────────────────────┘
```

**Tab 1 — API**

Sadržaj: postojeće Anthropic API Key sekcija + Binance API sekcija, iste kao i sada ali vizualno kompaktnije.

Dodaj na vrhu summary card:
```
┌─────────────────────────────────────┐
│  Claude AI    [●Aktivan / ○Nije]    │
│  Binance      [●Testnet / ○Nije]    │
└─────────────────────────────────────┘
```

**Tab 2 — Bot**

Sadržaj: Intelligence — Telegram Monitor sekcija s bot tokenom, default kanalima, custom kanalima, i monitoring toggle — točno kao sada.

Dodaj **"Otvori Bot Manager"** gumb koji otvara `BotManagerScreen` kao novi route (iz Faze 3).

**Tab 3 — Trade**

Sadržaj: Risk Parameters sekcija — točno kao sada (max trade, max positions, stop-loss slider, take-profit slider, auto-trade toggle, quiet hours).

Dodaj na vrhu summary card s trenutnim postavkama:
```
┌─────────────────────────────────────┐
│  Max trade: $10.00 USDT             │
│  SL: 15% | TP: 30%                 │
│  Auto-trade: [OFF]  Quiet: 23-7h   │
└─────────────────────────────────────┘
```

**Tab 4 — App**

Sadržaj: About sekcija (verzija, API info, DYOR disclaimer).

Dodaj **App Controls** sekciju:
```dart
// Clear all analysis logs
ListTile(
  leading: Icon(Icons.delete_sweep_outlined, color: Colors.orange),
  title: Text('Obriši Analysis History'),
  subtitle: Text('Briše sve WATCH/SKIP/INTERESTING zapise'),
  onTap: _confirmClearAnalysisLogs,
),

// Export logs as text
ListTile(
  leading: Icon(Icons.share_outlined),
  title: Text('Izvezi Analysis Logs'),
  subtitle: Text('Kopiraj logove u clipboard'),
  onTap: _exportLogs,
),

// Reset all settings
ListTile(
  leading: Icon(Icons.restore, color: Colors.red),
  title: Text('Reset svih postavki'),
  subtitle: Text('Briše API ključeve, postavke i logove'),
  onTap: _confirmFullReset,
),
```

**`_exportLogs()` implementacija:**
```dart
Future<void> _exportLogs() async {
  final logs = StorageService.getAnalysisLogs();
  if (logs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nema logova za izvoz')),
    );
    return;
  }
  
  final buffer = StringBuffer();
  buffer.writeln('CoinSight Analysis Export — ${DateTime.now().toIso8601String()}');
  buffer.writeln('─' * 50);
  
  for (final log in logs) {
    buffer.writeln('${log.timestamp.toIso8601String()} | '
        '${log.recommendationType} | '
        '${log.coinSymbol} | '
        '\$${log.priceAtAnalysis.toStringAsFixed(6)}');
  }
  
  // Kopiraj u clipboard
  await Clipboard.setData(ClipboardData(text: buffer.toString()));
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${logs.length} logova kopirano u clipboard')),
  );
}
```

Dodaj import: `import 'package:flutter/services.dart';`

### 4.3 Refaktoring — podijeli settings_screen.dart

853 linije u jednom fajlu je previše. Podijeli u zasebne widget fajlove:

```
lib/widgets/settings/
├── api_settings_tab.dart       ← Anthropic + Binance sekcije
├── bot_settings_tab.dart       ← Telegram Monitor sekcija
├── trade_settings_tab.dart     ← Risk Parameters sekcija
└── app_settings_tab.dart       ← About + App Controls sekcija
```

`settings_screen.dart` ostaje kao container koji samo sastavlja ova 4 taba u `DefaultTabController`.

**Svaki widget tab fajl** prima potrebne callbacks i state kroz constructor parametre — ne čita direktno iz StorageService gdje je moguće (drži state u parent SettingsScreen).

---

## FAZA 5 — AŽURIRANJE TESTOVA

### 5.1 Ažuriraj `test/unit/services/binance_service_test.dart`

Dodaj nove test grupe:

```dart
group('LOT_SIZE precision', () {
  test('_stepSizeToDecimals converts 1.00000000 to 0', ...);
  test('_stepSizeToDecimals converts 0.10000000 to 1', ...);
  test('_stepSizeToDecimals converts 0.00100000 to 3', ...);
  test('_stepSizeToDecimals converts 0.00000100 to 6', ...);
  test('placeSellOrder uses LOT_SIZE decimals from exchangeInfo', ...);
  test('placeSellOrder falls back to 6 decimals if exchangeInfo fails', ...);
  test('LOT_SIZE is cached after first fetch', ...);
});

group('Timestamp sync', () {
  test('syncServerTime calculates correct offset', ...);
  test('_correctedTimestamp applies offset', ...);
  test('ping() calls syncServerTime on success', ...);
  test('-1021 error triggers syncServerTime', ...);
  test('serverTimeOffsetMs getter returns current offset', ...);
});
```

### 5.2 Kreiraj `test/unit/models/monitored_channel_test.dart`

```dart
group('MonitoredChannel', () {
  test('reliabilityScore is -1 when signalsReceived < 10', ...);
  test('reliabilityScore calculates correctly with >10 signals', ...);
  test('reliabilityLabel is Visoka when score > 0.3', ...);
  test('reliabilityLabel is Srednja when score 0.1-0.3', ...);
  test('reliabilityLabel is Niska when score < 0.1', ...);
  test('reliabilityLabel is Novo when insufficient data', ...);
  test('toMap() and fromMap() round-trip', ...);
  test('copyWith() updates only specified fields', ...);
});
```

---

## FAZA 6 — FINALIZACIJA

### 6.1 Bump verzija

U `pubspec.yaml`:
```yaml
version: 2.1.0+3
```

### 6.2 Finalna verifikacija

```bash
flutter pub get
flutter analyze        # mora biti 0 issues
flutter test           # svi testovi moraju proći
flutter build apk --debug  # mora uspjeti
```

Provjeri:
```bash
# Nema starih TelegramService referenci
grep -r "TelegramService\|sendInterestingSignal" lib/
# Nema hardkodiranih secretsa
grep -rn "sk-ant-\|Bearer [A-Za-z]" lib/
# LOT_SIZE bug popravljen
grep "toStringAsFixed(6)" lib/services/binance_service.dart
# Mora vratiti samo _stepSizeToDecimals metodu, ne placeSellOrder
```

### 6.3 WORKLOG finalni unos

Dokumentiraj sve faze prema postojećem formatu. Uključi:
- Bugfixevi (LOT_SIZE, timestamp)
- Novi fajlovi (bot_manager_screen.dart, monitored_channel.dart, settings/ widgets)
- Promijenjeni fajlovi
- Novi testovi
- flutter analyze + flutter test rezultati
- Poznate issue-e ako postoje

### 6.4 Commit poruka — ispiši u chat za copy-paste

```
git add .
git commit -m "v2.1.0: Bot Manager, App Management, bugfixes

Bugfixes:
- Fix LOT_SIZE precision: dynamic stepSize fetch from /exchangeInfo
- Fix timestamp drift: server time sync via /api/v3/time

Features:
- Add BotManagerScreen: channel reliability tracking, add/remove/scan
- Add MonitoredChannel model with stats and reliability scoring
- Refactor SettingsScreen to AppManagementScreen with 4-tab layout
- Split settings_screen.dart into widget tabs (api/bot/trade/app)
- Add export logs and full reset in App tab
- Update bottom nav: Settings → Manage with tune icon

Tests:
- Add LOT_SIZE precision tests (7 tests)
- Add timestamp sync tests (5 tests)  
- Add MonitoredChannel model tests (8 tests)"

git push origin main
```

---

## ŠTO NE RADIŠ U OVOJ SESIJI

- Ne dodaješ WebSocket streaming
- Ne mijenjаš Claude sistemski prompt
- Ne mjenjаš CoinGecko logiku
- Ne dodaješ nove Binance API endpointe osim `/api/v3/exchangeInfo` i `/api/v3/time`
- Ne implementiraš push notifikacije (flutter_local_notifications je u pubspec ali nije prioritet)
- Ne commitaš bez developerovog odobrenja

---

## REDOSLIJED FAZA

```
Faza 1: LOT_SIZE fix          → auto → Faza 2
Faza 2: Timestamp fix         → auto → Faza 3
Faza 3: Bot Manager           → [ČEKAJ POTVRDU koncepta] → implementacija → auto → Faza 4
Faza 4: App Management        → auto → Faza 5
Faza 5: Test ažuriranja       → auto → Faza 6
Faza 6: Finalizacija          → ispiši commit poruku → KRAJ
```

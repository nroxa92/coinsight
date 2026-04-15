# CoinSight — SESSION 3 Instructions
**Datum:** 2026-04-15  
**Status projekta:** Faze 1-5 završene, New Listings tab radi, Claude prompt aktivan, Analysis logging aktivan  
**Cilj ove sesije:** Binance API integracija (Faza 2 + Faza 3), Telegram Bot notifikacije, Portfolio screen  

---

## OBAVEZNO PRIJE BILO ČEGA DRUGOG

Pročitaj redom:
```
CLAUDE.md
WORKLOG.md
lib/services/storage_service.dart
lib/models/analysis_log.dart
lib/models/watchlist_provider.dart
lib/models/analysis_provider.dart
pubspec.yaml
```

Nakon čitanja napiši summary od 6-8 bullet pointa što si našao. Tek nakon developerove potvrde kreni s implementacijom.

**Ne pišeš kod dok ne dobiješ potvrdu summarya.**

---

## KONTEKST PROJEKTA

CoinSight je privatna Flutter Android aplikacija za rano otkrivanje crypto momentum prilike. Trenutno stanje:
- 3 taba: New Listings (default, 3-min auto-refresh), My Watchlist, Top Coins
- Claude AI chat s analizom kroz tri objektiva, vraća WATCH/SKIP/INTERESTING
- Hive lokalni storage za API ključ, watchlist, analysis logs
- AnalysisLog model postoji s parseRecommendationType()
- 0 flutter analyze issues, Windows build potvrđen

**Što dodajemo u ovoj sesiji:**
- Binance Spot API integracija za balance, orders i pozicije
- Faza 2: korisnik potvrđuje svaki trade jednim tapom
- Faza 3: automatski trade bez potvrde unutar risk parametara
- Telegram Bot za signal notifikacije i remote komande
- Portfolio screen (4. tab) za praćenje pozicija i P&L
- Risk Parameters u Settings screenu

---

## PRAVILA RADA

Ne brišeš postojeći kod bez odobrenja.  
Ne dodaješ featuree koji nisu u ovim instrukcijama.  
Ne commitaš — to je developerova nadležnost.  
Pitaš ako nešto nije jasno PRIJE nego kreneš pisati kod.  
Svaka faza mora proći `flutter analyze` s 0 issues prije nastavka.  
Dodaješ WORKLOG.md unos na kraju prema postojećem formatu.  
Bugove koji nisu dio zadatka prijavljuješ u "Identified Issues", ne popravljaš bez pitanja.

---

## NOVA DEPENDENCIES — DODAJ U pubspec.yaml ODMAH

```yaml
dependencies:
  # postojeće ostaju nepromijenjene, dodaj:
  flutter_local_notifications: ^18.0.0
  crypto: ^3.0.3
  convert: ^3.1.1
```

Nakon dodavanja pokreni `flutter pub get` i verificiraj da nema konflikata.

**Napomena:** Telegram Bot integracija radi kroz standardni HTTP paket koji već postoji — ne treba poseban paket.

---

## ZADATAK 1 — Binance API Servis

### 1.1 Kreiraj `lib/services/binance_service.dart`

Binance REST API zahtijeva HMAC-SHA256 potpis za authenticated endpointe.  
Base URL: `https://api.binance.com`  
Test URL (za paper trading): `https://testnet.binance.vision`  
App mora podržavati oba — settings flag `useBinanceTestnet` određuje koji se koristi.

**Klasa BinanceService:**

```dart
// Metode koje MORAJU biti implementirane:

// 1. Provjera konekcije (public endpoint, bez potpisa)
Future<bool> ping()
// GET /api/v3/ping — vraća true ako Binance odgovara

// 2. Dohvat USDT balansa (signed)
Future<double> getUsdtBalance()
// GET /api/v3/account — parsira balances, vraća free USDT kao double

// 3. Dohvat trenutne cijene coina
Future<double> getCurrentPrice(String symbol)
// GET /api/v3/ticker/price?symbol=BTCUSDT — vraća price kao double

// 4. Market buy order (signed)
Future<BinanceOrder> placeBuyOrder(String symbol, double quoteAmount)
// POST /api/v3/order
// side: BUY, type: MARKET, quoteOrderQty: quoteAmount (kupuješ za X USDT)
// Vraća BinanceOrder s orderId, executedQty, cummulativeQuoteQty

// 5. Market sell order (signed)  
Future<BinanceOrder> placeSellOrder(String symbol, double quantity)
// POST /api/v3/order
// side: SELL, type: MARKET, quantity: quantity (prodaješ X tokena)

// 6. Dohvat otvorenih pozicija iz lokalnog storage-a
// (Binance Spot nema "pozicije" kao futures — pratimo ih lokalno)
List<CoinPosition> getOpenPositions()

// 7. Dohvat order historije za simbol
Future<List<BinanceOrder>> getOrderHistory(String symbol)
// GET /api/v3/allOrders?symbol=XXXUSDT&limit=10
```

**HMAC-SHA256 potpis implementacija:**
```dart
String _sign(String queryString) {
  final key = utf8.encode(_apiSecret);
  final msg = utf8.encode(queryString);
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(msg);
  return digest.toString();
}
```
Koristi `crypto` i `convert` pakete.  
Svaki signed request treba `timestamp` (Unix ms) i `signature` parametar.  
API key ide u header: `X-MBX-APIKEY`.

**Custom exception:**
```dart
class BinanceException implements Exception {
  final String message;
  final int? code; // Binance error code ako postoji
  BinanceException(this.message, {this.code});
}
```

Posebno handle-aj:
- `-1021` TIMESTAMP_OUT_OF_SYNC — sinkronizacija vremena
- `-2010` NEW_ORDER_REJECTED — insufficient balance
- `-1100` BAD_SYMBOL — coin ne postoji na Binanceu kao XXXUSDT par

### 1.2 Kreiraj `lib/models/coin_position.dart`

```dart
class CoinPosition {
  final String coinId;        // CoinGecko ID
  final String symbol;        // npr. "COINX"
  final String binanceSymbol; // npr. "COINXUSDT"
  final double quantity;      // koliko tokena imamo
  final double entryPrice;    // cijena pri kupnji
  final double entryTotal;    // koliko USDT smo uložili
  final DateTime entryTime;
  double? currentPrice;       // ažurira se live
  String? stopLossOrderId;    // Binance order ID za stop-loss ako postoji
  
  // Computed:
  double get currentValue => quantity * (currentPrice ?? entryPrice);
  double get pnlAbsolute => currentValue - entryTotal;
  double get pnlPercent => (pnlAbsolute / entryTotal) * 100;
  bool get isProfit => pnlAbsolute > 0;
  
  // toMap() i fromMap() za Hive storage
}
```

### 1.3 Proširi `lib/services/storage_service.dart`

Dodaj Hive box za pozicije i Binance settings:
```dart
static const _positionsBox = 'positions';
static const _binanceApiKeyField = 'binance_api_key';
static const _binanceSecretField = 'binance_secret';
static const _binanceTestnetField = 'binance_testnet';

// Otvori box u init()
await Hive.openBox(_positionsBox);

// Metode:
static String? getBinanceApiKey()
static String? getBinanceSecret()
static bool getBinanceTestnet() // default: true (testnet)
static Future<void> saveBinanceCredentials(String apiKey, String secret)
static Future<void> setBinanceTestnet(bool value)
static Future<void> savePosition(CoinPosition position)
static Future<void> removePosition(String coinId)
static List<CoinPosition> getPositions()
```

---

## ZADATAK 2 — Risk Parameters Model i Provider

### 2.1 Kreiraj `lib/models/risk_parameters.dart`

```dart
class RiskParameters {
  final double maxTradeAmountUsdt;   // max USDT po transkaciji, default 10.0
  final int maxOpenPositions;         // max istovremenih pozicija, default 3
  final double stopLossPercent;       // stop-loss posto, default 15.0
  final double takeProfitPercent;     // take-profit posto, default 30.0
  final bool autoTradeEnabled;        // Faza 3 on/off, default false
  final bool telegramNotifications;   // Telegram notifikacije on/off, default false
  final int quietHoursStart;          // 0-23, default 23
  final int quietHoursEnd;            // 0-23, default 7
  
  // Je li trenutno quiet hours?
  bool get isQuietHours {
    final hour = DateTime.now().hour;
    if (quietHoursStart > quietHoursEnd) {
      return hour >= quietHoursStart || hour < quietHoursEnd;
    }
    return hour >= quietHoursStart && hour < quietHoursEnd;
  }
  
  // toMap() i fromMap() za Hive
  // copyWith() za ažuriranje pojedinih parametara
}
```

### 2.2 Proširi StorageService za RiskParameters

```dart
static const _riskParamsField = 'risk_parameters';
static RiskParameters getRiskParameters() // vraća default ako nema
static Future<void> saveRiskParameters(RiskParameters params)
```

---

## ZADATAK 3 — Trade Execution Logic

### 3.1 Kreiraj `lib/services/trade_service.dart`

TradeService je centralna logika koja koordinira BinanceService, StorageService i notifikacije.

```dart
class TradeService {
  final BinanceService _binance;
  
  // Faza 2 — priprema order za korisnikovu potvrdu
  // Vraća TradeProposal s detaljima, NE izvršava odmah
  Future<TradeProposal> prepareTradeProposal({
    required Coin coin,
    required String claudeRecommendation,
    required RiskParameters riskParams,
  })
  
  // Faza 2 — korisnik potvrdio, izvrši order
  Future<TradeResult> executeTrade(TradeProposal proposal)
  
  // Faza 3 — auto-execute ako su uvjeti zadovoljeni
  // Provjerava: autoTradeEnabled, isQuietHours, maxOpenPositions, balance
  Future<TradeResult?> autoExecuteIfEligible({
    required Coin coin,
    required String claudeRecommendation,
    required RiskParameters riskParams,
  })
  
  // Provjera stop-loss za sve otvorene pozicije
  Future<void> checkStopLosses()
  
  // Zatvori poziciju (market sell)
  Future<TradeResult> closePosition(CoinPosition position)
}
```

**TradeProposal model:**
```dart
class TradeProposal {
  final Coin coin;
  final double amountUsdt;     // koliko USDT trošimo
  final double estimatedQty;   // procijenjeni broj tokena
  final double currentPrice;
  final double stopLossPrice;  // entryPrice * (1 - stopLossPercent/100)
  final double takeProfitPrice;
  final String claudeRecommendation;
  final DateTime createdAt;
  
  // Proposal istječe za 60 sekundi — cijena se može promijeniti
  bool get isExpired => 
    DateTime.now().difference(createdAt).inSeconds > 60;
}
```

**TradeResult model:**
```dart
class TradeResult {
  final bool success;
  final String? orderId;
  final double? executedPrice;
  final double? executedQty;
  final double? totalUsdt;
  final String? errorMessage;
}
```

**Važna pravila u executeTrade():**
1. Provjeri da proposal nije expired — ako jest, odbaci i traži novi
2. Provjeri da USDT balance >= proposal.amountUsdt
3. Provjeri da maxOpenPositions nije dostignut
4. Izvrši market buy
5. Spremi CoinPosition u Hive
6. Logiraj u AnalysisLog s user_action: "entered"
7. Pošalji Telegram notifikaciju ako je enabled

---

## ZADATAK 4 — Telegram Bot Integracija

### 4.1 Kreiraj `lib/services/telegram_service.dart`

Telegram Bot API radi kroz standardni HTTP. Ne treba poseban paket.

**Setup:**
1. Korisnik kreira bota kod @BotFather na Telegramu, dobije Bot Token
2. Korisnik pošalje /start botu, bot dobije chat_id
3. Bot token i chat_id čuvaju se u Hive

**Metode:**
```dart
class TelegramService {
  // Pošalji poruku korisniku
  Future<bool> sendMessage(String text)
  // POST https://api.telegram.org/bot{token}/sendMessage
  // chat_id + text (Markdown formatted)
  
  // Pošalji INTERESTING signal
  Future<void> sendInterestingSignal({
    required Coin coin,
    required String claudeRecommendation,
    required RiskParameters riskParams,
  })
  
  // Pošalji trade executed potvrdu
  Future<void> sendTradeExecuted(CoinPosition position, TradeResult result)
  
  // Pošalji stop-loss triggered notifikaciju
  Future<void> sendStopLossTriggered(CoinPosition position, TradeResult result)
  
  // Pošalji dnevni summary (poziva se u ponoć)
  Future<void> sendDailySummary(List<CoinPosition> positions, List<AnalysisLog> logs)
  
  // Provjeri je li bot konfiguriran
  bool get isConfigured
}
```

**Format INTERESTING signal poruke:**
```
🚨 *CoinSight Signal*

*INTERESTING* — {SYMBOL}/USDT

💰 Cijena: ${price}
📈 1h: {1h_change}% | 24h: {24h_change}%
📊 Volume: ${volume}
🏆 Rank: #{rank}

🧠 *Claude analiza:*
{skraćena preporuka — max 200 znakova}

⚡ Brzi odgovor:
/buy_{symbol} — kupi {maxAmount} USDT
/skip_{symbol} — preskoči
/analyze_{symbol} — puna analiza
```

**Incoming webhook — slušanje komandi:**  
TelegramService mora pokrenuti polling loop u pozadini (Timer.periodic svakih 5 sekundi) koji poziva `getUpdates` endpoint i procesira komande:
- `/buy_SYMBOL` — pripremi TradeProposal i pošalji potvrdu
- `/skip_SYMBOL` — logiraj kao skipped
- `/status` — pošalji portfolio summary
- `/balance` — pošalji USDT balance
- `/stop` — zaustavi auto-trade privremeno
- `/start_auto` — uključi auto-trade

```dart
Future<void> startPolling() // pokreće Timer.periodic
void stopPolling()
Future<void> _processUpdate(Map<String, dynamic> update)
```

**Spremi u StorageService:**
```dart
static const _telegramTokenField = 'telegram_bot_token';
static const _telegramChatIdField = 'telegram_chat_id';
static String? getTelegramToken()
static String? getTelegramChatId()
static Future<void> saveTelegramCredentials(String token, String chatId)
```

---

## ZADATAK 5 — Portfolio Screen

### 5.1 Kreiraj `lib/screens/portfolio_screen.dart`

Četvrti tab u bottom navigaciji s ikonom `Icons.account_balance_wallet_outlined`.  
Naziv taba: "Portfolio"

**Layout — 3 sekcije:**

**Sekcija 1 — Header summary**
```
USDT Balance: $XX.XX        [Refresh icon]
Open Positions: X           
Total P&L: +$X.XX (+X.X%)  ← zeleno/crveno
```

**Sekcija 2 — Open Positions lista**
Za svaku poziciju prikaži card:
```
[Coin icon] SYMBOL/USDT          [Close button]
Entry: $X.XX → Now: $X.XX
Qty: X.XXXX | Invested: $X.XX
P&L: +$X.XX (+XX.X%)     ← zeleno ako profit, crveno ako gubitak
Stop-loss: $X.XX | Take-profit: $X.XX
[CLOSE POSITION button]
```

Tap na Close otvara AlertDialog: "Zatvori poziciju? Prodaješ X.XXXX SYMBOLA po tržišnoj cijeni." s Confirm/Cancel.

**Sekcija 3 — Analysis History**  
Lista zadnjih 20 AnalysisLog zapisa iz Hive, sortirano newest first.  
Svaki unos prikazuje:
```
[WATCH/SKIP/INTERESTING chip] SYMBOL | $price | datum/vrijeme
```
Chip boja: INTERESTING=zelena, WATCH=narančasta, SKIP=siva.

**Auto-refresh cijena pozicija** svakih 30 sekundi dok je Portfolio tab aktivan.

---

## ZADATAK 6 — Analysis Screen Update (Faza 2 integration)

Postojeći `lib/screens/analysis_screen.dart` treba dobiti **Trade Action Bar** koji se pojavljuje ispod Claudeovog odgovora kada odgovor sadrži **INTERESTING** oznaku.

```
┌─────────────────────────────────────────┐
│  🚨 INTERESTING signal detektiran        │
│  Uloži: [10 USDT] ← editable TextField  │
│  Stop-loss: -15% | Take-profit: +30%    │
│  [BUY NOW] [SKIP] [SEND TO TELEGRAM]    │
└─────────────────────────────────────────┘
```

**BUY NOW** — poziva `TradeService.prepareTradeProposal()`, otvara confirmation dialog s detaljima, na potvrdu poziva `executeTrade()`.

**SKIP** — skriva action bar, logira user_action: "skipped" u AnalysisLog.

**SEND TO TELEGRAM** — šalje signal poruku kroz TelegramService bez egzekucije.

Trade action bar se NE prikazuje ako:
- Binance API ključevi nisu konfigurirani
- `autoTradeEnabled` je true (Faza 3 mode — sve ide automatski)
- Coin nije dostupan kao XXXUSDT par na Binanceu

---

## ZADATAK 7 — Settings Screen Update

Postojeći `lib/screens/settings_screen.dart` proširi s dvije nove sekcije.

### Sekcija: Binance API

```
Binance API Key:    [TextField obscured]  [Save] [Remove]
Binance Secret:     [TextField obscured]  [Save] [Remove]
Status:             [Active / Not set badge]
Mode:               [Testnet toggle] ← default ON, upozorenje pri isključivanju
                    "Testnet = paper trading, nema pravog novca"
[TEST CONNECTION button] → ping() + getUsdtBalance() → SnackBar rezultat
```

### Sekcija: Risk Parameters

```
Max trade amount:   [TextField] USDT  (default: 10.0)
Max open positions: [Dropdown 1-10]   (default: 3)
Stop-loss:          [Slider 5%-30%]   (default: 15%)
Take-profit:        [Slider 10%-100%] (default: 30%)

─── Auto-Trade (Faza 3) ──────────────────────
[Toggle] Auto-execute INTERESTING signals
⚠️  "Bot će automatski kupovati bez tvoje potvrde
     unutar gore definiranih parametara."
     [Prikazuj samo ako Binance API je konfiguriran]

─── Quiet Hours ──────────────────────────────
[Toggle] Pauziraj bot između:
[TimePicker start] i [TimePicker end]

─── Telegram Bot ─────────────────────────────
Bot Token:   [TextField] [Save]
Chat ID:     [TextField] [Save]  
             "Pošalji /start svom botu da dobiješ Chat ID"
Status:      [Configured / Not set]
[TEST] → šalje test poruku na Telegram
```

---

## ZADATAK 8 — Main.dart Update

`lib/main.dart` treba proširiti na 4 taba u BottomNavigationBar:

```dart
// Existing tabs (index 0, 1, 2):
// 0: Watchlist (Icons.trending_up)
// 1: Analysis (Icons.chat_bubble_outline)  
// 2: Settings (Icons.settings_outlined)

// Novi tab (index 3):
// 3: Portfolio (Icons.account_balance_wallet_outlined)
```

MultiProvider proširiti s novim providerom ako ga budeš trebao, ili koristiti direktno servise.

TelegramService polling treba startati pri app inicijalizaciji ako su Telegram credentials konfigurirani, i stopati pri app dispose.

TradeService.checkStopLosses() treba se pozivati svakih 5 minuta kroz Timer.periodic u main.dart ako ima otvorenih pozicija.

---

## REDOSLIJED IMPLEMENTACIJE

Svaka faza mora završiti s `flutter analyze` 0 issues prije sljedeće.

**Faza A:** pubspec.yaml update → flutter pub get → StorageService extension (Binance keys, positions, risk params, Telegram credentials) → verifikacija

**Faza B:** CoinPosition model → RiskParameters model → TradeProposal model → TradeResult model → verifikacija

**Faza C:** BinanceService implementacija → TEST: ping() i getUsdtBalance() na testnet → verifikacija

**Faza D:** TradeService implementacija → TelegramService implementacija → verifikacija

**Faza E:** Portfolio screen → Settings screen update → verifikacija

**Faza F:** Analysis screen Trade Action Bar → Main.dart 4 taba → TelegramService polling start → StopLoss timer → verifikacija

**Faza G:** End-to-end test workflow:
1. Konfiguriraj Binance testnet ključeve u Settings
2. Konfiguriraj Telegram bota u Settings
3. Otvori New Listings tab — čekaj INTERESTING signal ili ručno upitaj Claudea
4. Potvrdi trade kroz app (Faza 2)
5. Provjeri Portfolio tab — pozicija se pojavila
6. Provjeri Telegram — dobio poruku
7. Uključi auto-trade toggle (Faza 3)
8. Dokumentiraj rezultate

---

## ŠTO NE RADIŠ U OVOJ SESIJI

- Ne implementiraš futures/margin trading — isključivo Spot
- Ne implementiraš withdrawal ni transfer funkcionalnost
- Ne dodaješ real-time WebSocket streaming (ostajemo na REST polling)
- Ne mijenjaš postojeće CoinGecko logiku niti Claude sistemski prompt
- Ne commitaš
- Ne mijenjaš temu, boje niti vizualni dizajn

---

## KRITIČNE SIGURNOSNE NAPOMENE ZA KOD

Binance API ključ nikad ne ide u log file, konzolu, niti error poruku.  
BinanceSecret nikad ne ide nigdje osim u HMAC funkciju.  
Withdrawal permission mora biti isključen na Binance accountu — ovo je korisnikova odgovornost ali dodaj upozorenje u Settings: *"Osiguraj da API ključ NEMA dozvolu za Withdrawal."*  
Sve iznose zaokruži na 2 decimale za USDT, i na broj decimala koji Binance zahtijeva za quantity (LOT_SIZE filter) — za početak koristi 6 decimala za quantity.  
Ako BinanceService vrati grešku pri order egzekuciji, NIKAD ne pokušavaj automatski ponovo bez korisnikove potvrde.

---

## WORKLOG.md — NA KRAJU SESIJE

Dodaj unos koji dokumentira sve promjene prema postojećem formatu. Uključi:
- Sve nove fajlove s kratkim opisom
- Sve modificirane fajlove
- Nove dependencies
- flutter analyze rezultat
- Poznate issue-e ako postoje
```

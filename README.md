# CoinSight

> AI-powered cryptocurrency signal detector with automated trading

CoinSight je open source Flutter Android aplikacija koja kombinira
real-time tržišne podatke, Telegram intelligence monitoring i Claude AI
analizu za detekciju ranih momentum signala na crypto tržištu — s
opcionalnom automatskom egzekucijom Binance Spot orderima.

## Što radi

- **New Listings detekcija** — prati coinove s malim market cap rankom
  i visokim hourly volumenom koji su potencijalni early momentum kandidati
- **Telegram Intelligence** — čita javne crypto kanale (@binance,
  @whale_alert, @coingecko) i uključuje signale kao kontekst u AI analizu
- **Claude AI analiza** — svaki coin prolazi kroz tri analitička objektiva
  (profil listinga, rizik profil, preporuka) i dobiva WATCH/SKIP/INTERESTING oznaku
- **Trade execution** — INTERESTING signal → jednim tapom Binance Spot
  order s automatskim stop-lossom i take-profitom
- **Auto-trade** — opcionalni autonomni mod koji izvršava ordere bez
  korisnikove potvrde unutar definiranih risk parametara
- **Portfolio tracking** — live P&L praćenje otvorenih pozicija i
  history svih analiza

## Tehnički stack

| Komponenta | Tehnologija |
|---|---|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| State management | Provider |
| Tržišni podaci | CoinGecko API v3 (besplatno) |
| AI analiza | Anthropic Claude API |
| Trading | Binance Spot REST API |
| Intelligence | Telegram Bot API (channel monitoring) |
| Storage | Hive (lokalno, na uređaju) |

## Preduvjeti

- Android uređaj (API 21+) ili emulator
- Flutter SDK 3.41+
- Anthropic API ključ — [console.anthropic.com](https://console.anthropic.com)
- Binance account s API ključem (Spot Trading, bez Withdrawal dozvole)
- Telegram bot token (opcionalno, za channel monitoring)

## Instalacija

```bash
git clone https://github.com/nroxa92/claude_coinsight.git
cd claude_coinsight
flutter pub get
flutter build apk --release
```

APK se nalazi u `build/app/outputs/flutter-apk/app-release.apk`

## Konfiguracija

1. Instaliraj APK na Android uređaj
2. Otvori **Settings** tab
3. Unesi Anthropic API ključ
4. Unesi Binance API ključeve (preporučeno: počni s Testnetom)
5. Opcionalno: konfiguriraj Telegram bot za channel monitoring

Detaljne upute: [MANUAL.md](MANUAL.md)

## Arhitektura

```
lib/
├── main.dart                    # Entry point, navigation, background services
├── models/
│   ├── coin.dart                # CoinGecko data model
│   ├── coin_position.dart       # Otvorena trading pozicija
│   ├── risk_parameters.dart     # Risk management konfiguracija
│   ├── analysis_log.dart        # Log Claude analiza
│   ├── trade_proposal.dart      # Pripremljeni order (pre-execution)
│   ├── trade_result.dart        # Rezultat izvršenog ordera
│   ├── telegram_signal.dart     # Signal iz Telegram kanala
│   ├── watchlist_provider.dart  # Watchlist state
│   ├── analysis_provider.dart   # Chat/AI state + Telegram integration
│   └── portfolio_provider.dart  # Portfolio state + live prices
├── services/
│   ├── coingecko_service.dart   # CoinGecko HTTP client
│   ├── claude_service.dart      # Anthropic Claude HTTP client
│   ├── binance_service.dart     # Binance REST API + HMAC signing
│   ├── trade_service.dart       # Trade execution logic
│   ├── telegram_monitor.dart    # Telegram public channel monitor
│   └── storage_service.dart     # Hive local storage wrapper
├── screens/
│   ├── watchlist_screen.dart    # New Listings, Watchlist, Top Coins
│   ├── analysis_screen.dart     # Claude AI chat + Trade Action Bar
│   ├── portfolio_screen.dart    # Pozicije, P&L, History
│   └── settings_screen.dart     # API keys, Risk params, Telegram monitor
├── widgets/
│   ├── coin_card.dart           # Coin display + skeleton loader
│   ├── chat_bubble.dart         # Chat poruka
│   └── sparkline_chart.dart     # 7-day sparkline
└── theme/
    └── app_theme.dart           # Dark tema
```

## Sigurnost

- API ključevi se čuvaju **isključivo lokalno** na uređaju (Hive)
- Nema servera, nema telemetrije, nema cloud pohrane
- Binance API ključ NIKAD ne smije imati Withdrawal dozvolu
- Testnet mode za sigurno testiranje bez pravog novca

## Upozorenje

Ovo je eksperimentalni alat za osobnu upotrebu. Nije financijski savjet.
Crypto trading nosi visok rizik gubitka kapitala. Koristi isključivo iznose
koje možeš priuštiti izgubiti. DYOR (Do Your Own Research).

## Licenca

MIT — vidi [LICENSE](LICENSE)

## Razvoj

Projekt je razvijen kao eksperiment u AI-assisted development koristeći
Claude Code kroz strukturirane sesije s CLAUDE.md workflow-om.

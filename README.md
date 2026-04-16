# CoinSight

> AI-powered three-tier cryptocurrency investment platform

CoinSight je open source Flutter Android aplikacija koja kombinira
real-time trzisne podatke, multi-source intelligence monitoring, Claude AI
analizu i automatsko trgovanje — organizirano kroz tri investicijska
horizonta (SHORT/MID/LONG) s interaktivnim chart prikazima i push
notifikacijama.

## Three-Tier Investment Framework

| Tier | Horizont | Egzekucija |
|------|----------|------------|
| **SHORT** | Sati do dani | Auto-trade, stop-loss/take-profit, DEX listinzi |
| **MID** | Tjedni do mjeseci | GitHub verifikacija, tokenomics, projekt biljeske |
| **LONG** | Mjeseci do godina | DCA akumulacija, fundamentalna analiza, tim/partneri |

Persistent Tier Mode Selector omogucava brzo prebacivanje — svi screenovi
se adaptiraju aktivnom tieru.

## Features

### Intelligence Layer
- **DEX Early Detection** — Uniswap, PancakeSwap, Raydium i ostali DEX-ovi
- **GitHub Intelligence** — legitimacy signal kroz crypto repo aktivnost
- **Reddit Monitoring** — community sentiment iz crypto subreddita
- **Telegram Monitoring** — javni kanali s keyword filteringom
- **Cross-Channel Scoring** — confluence score 0-6.0 iz 5 izvora

### Trading & Portfolio
- **Binance Spot** — market buy/sell s HMAC-SHA256 potpisom
- **Auto-trade** — autonomni mod unutar risk parametara
- **Stop-Loss / Take-Profit** — automatski monitoring (5min tick)
- **DEX Position Tracking** — rucno pracenje decentraliziranih trade-ova
- **Portfolio** — live P&L, open positions, analysis history

### Charts & Visualization (v6.0.0)
- **Tier-specific chartovi** — SHORT: 10d + 24h, MID: 6m + 30d, LONG: 2y + 6m
- **Interaktivni price chart** — CustomPainter s touch crosshair-om
- **Prediction overlay** — AI-generirane projekcije (disclaimer ukljucen)
- **Pristup** — ikona chart na CoinCard-u ili iz Analysis screena

### Push Notifications (v6.0.0)
- **SL/TP alerte** — notifikacija kad pozicija dostigne stop-loss ili take-profit
- **INTERESTING signali** — push kad Claude oznaci coin kao INTERESTING
- **High-score intelligence** — alert za visok confluence score
- **Konfiguracijski** — toggle po tipu notifikacije u Settings

### Detail Screens
- **MidProjectDetailScreen** — thesis, GitHub, entry plan, status, biljeske
- **LongHoldingDetailScreen** — 4 taba: Osnove, Fundamentali, DCA, Biljeske
- **ChartScreen** — full-screen tier-aware price chart s predikcijom

Novi u CoinSightu? Pogledaj [NEWBIE_GUIDE.md](NEWBIE_GUIDE.md) za korak-po-korak uvod.

## Tehnicki stack

| Komponenta | Tehnologija |
|---|---|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| State management | Provider |
| Trzisni podaci | CoinGecko API v3 (besplatno) |
| AI analiza | Anthropic Claude API |
| Trading | Binance Spot REST API |
| Intelligence | Telegram + Dexscreener + GitHub + Reddit |
| Notifikacije | flutter_local_notifications |
| Storage | Hive (lokalno, na uredaju) |

## Preduvjeti

- Android uredaj (API 21+) ili emulator
- Flutter SDK 3.41+
- Anthropic API kljuc — [console.anthropic.com](https://console.anthropic.com)
- Binance account s API kljucem (Spot Trading, bez Withdrawal dozvole)
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

1. Instaliraj APK na Android uredaj
2. Otvori **Settings** tab
3. Unesi Anthropic API kljuc
4. Unesi Binance API kljuceve (preporuceno: pocni s Testnetom)
5. Opcionalno: konfiguriraj Telegram bot za channel monitoring

Detaljne upute: [MANUAL.md](MANUAL.md)

## Arhitektura

```
lib/
├── main.dart                    # Entry point, navigation, background services
├── models/
│   ├── coin.dart                # CoinGecko data model
│   ├── coin_position.dart       # Otvorena trading pozicija
│   ├── dex_position.dart        # DEX pozicija model
│   ├── risk_parameters.dart     # Risk management konfiguracija
│   ├── analysis_log.dart        # Log Claude analiza
│   ├── trade_proposal.dart      # Pripremljeni order (pre-execution)
│   ├── trade_result.dart        # Rezultat izvrsenog ordera
│   ├── telegram_signal.dart     # Signal iz Telegram kanala
│   ├── dexscreener_signal.dart  # DEX listing signal
│   ├── github_signal.dart       # GitHub repo signal
│   ├── reddit_signal.dart       # Reddit post signal
│   ├── intelligence_report.dart # Agregirani multi-source report
│   ├── investment_tier.dart     # SHORT/MID/LONG enum + config
│   ├── mid_term_project.dart    # MID projekt model
│   ├── long_term_holding.dart   # LONG holding model
│   ├── price_chart_data.dart    # Chart data model (OHLC + predikcija)
│   ├── monitored_channel.dart   # Telegram kanal s reliability scoring
│   ├── watchlist_provider.dart  # Watchlist state
│   ├── analysis_provider.dart   # Chat/AI state + intelligence
│   ├── portfolio_provider.dart  # Portfolio state + live prices
│   └── tier_provider.dart       # Tier state + MID/LONG CRUD
├── services/
│   ├── coingecko_service.dart   # CoinGecko HTTP client
│   ├── claude_service.dart      # Anthropic Claude HTTP client
│   ├── binance_service.dart     # Binance REST API + HMAC signing
│   ├── trade_service.dart       # Trade execution logic
│   ├── telegram_monitor.dart    # Telegram public channel monitor
│   ├── storage_service.dart     # Hive local storage wrapper
│   ├── dexscreener_service.dart # DEX listing discovery
│   ├── github_intelligence.dart # GitHub crypto repo monitoring
│   ├── reddit_monitor.dart      # Reddit sentiment monitoring
│   ├── intelligence_aggregator.dart # Multi-source koordinator
│   ├── chart_data_service.dart  # CoinGecko historical data + predikcija
│   └── notification_service.dart # Push notifikacije (SL/TP/INTERESTING)
├── screens/
│   ├── watchlist_screen.dart    # DEX Early, New Listings, Watchlist, Top Coins
│   ├── analysis_screen.dart     # Claude AI chat + Trade Action Bar
│   ├── portfolio_screen.dart    # Pozicije, P&L, History
│   ├── settings_screen.dart     # API keys, Risk params, Telegram monitor
│   ├── bot_manager_screen.dart  # Channel management + stats
│   ├── mid_project_detail_screen.dart  # MID projekt detail
│   ├── long_holding_detail_screen.dart # LONG holding detail
│   ├── dex_position_screen.dart # DEX pozicije management
│   └── chart_screen.dart        # Full-screen tier-aware price chart
├── widgets/
│   ├── coin_card.dart           # Coin display + skeleton loader
│   ├── chat_bubble.dart         # Chat poruka
│   ├── sparkline_chart.dart     # 7-day sparkline
│   ├── dex_signal_card.dart     # DEX pair kartica
│   ├── tier_mode_selector.dart  # SHORT/MID/LONG selector banner
│   ├── price_chart_widget.dart  # Interaktivni price chart (CustomPainter)
│   └── settings/
│       ├── api_settings_tab.dart
│       ├── bot_settings_tab.dart
│       ├── trade_settings_tab.dart
│       ├── tier_settings_tab.dart
│       └── app_settings_tab.dart
└── theme/
    └── app_theme.dart           # Dark tema
```

## Sigurnost

- API kljucevi se cuvaju **iskljucivo lokalno** na uredaju (Hive)
- Nema servera, nema telemetrije, nema cloud pohrane
- Binance API kljuc NIKAD ne smije imati Withdrawal dozvolu
- Testnet mode za sigurno testiranje bez pravog novca

## Upozorenje

Ovo je eksperimentalni alat za osobnu upotrebu. Nije financijski savjet.
Crypto trading nosi visok rizik gubitka kapitala. Koristi iskljucivo iznose
koje mozes priustiti izgubiti. DYOR (Do Your Own Research).

## Licenca

MIT — vidi [LICENSE](LICENSE)

## Razvoj

Projekt je razvijen kao eksperiment u AI-assisted development koristeci
Claude Code kroz strukturirane sesije s CLAUDE.md workflow-om.

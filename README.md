<div align="center">

# CoinSight

### AI-powered Three-Tier Cryptocurrency Investment Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-8.0.0-blue)](pubspec.yaml)
[![Tests](https://img.shields.io/badge/Tests-352%2F352-brightgreen)]()
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://android.com)

**CoinSight** kombinira multi-source intelligence monitoring, Claude AI analizu
i automatski trading organiziran kroz tri investicijska horizonta.

[Preuzmi APK](#instalacija) | [Vodic za pocetnike](NEWBIE_GUIDE.md) | [Prirucnik](MANUAL.md) | [Arhitektura](OVERVIEW.md)

</div>

---

## Sto je CoinSight?

CoinSight je Android aplikacija koja detektira cryptocurrency prilike **ranije od ostalih** pracenjem DEX listinga koji prethode CEX listingima za 1-14 dana, a zatim koristi Claude AI za duboku analizu kroz tri razlicita investicijska pristupa.

### Tri tiera — jedna aplikacija

| | **SHORT** | **MID** | **LONG** |
|---|---|---|---|
| **Horizont** | Sati-dani | Tjedni-mjeseci | Mjeseci-godine |
| **Filozofija** | Early momentum na DEX-u | Value discovery pre-CEX | Fundamental hold |
| **Intelligence** | DEX listinzi, Telegram, Reddit | GitHub aktivnost, tokenomics | Tim, investitori, partnerstva |
| **Egzekucija** | Auto-trade + SL/TP | Manualni entry | DCA akumulacija |

Jedan tap na **Tier Mode Selector** ispod AppBara — cijela app se adaptira aktivnom tieru.

---

## Znacajke

### Intelligence Layer
Simultano skenira **5 izvora** i kalkulira **confluence score (0-6.0)**:

- **DEX Early Detection** — Uniswap, PancakeSwap, Raydium, Camelot, Aerodrome, QuickSwap (6 blockchaina)
- **GitHub Intelligence** — legitimacy signal kroz crypto repo aktivnost i star velocity
- **Reddit Monitor** — community sentiment iz r/CryptoMoonShots, r/altcoin i srodnih
- **Telegram Monitor** — javni kanali (@whale_alert, @binance, @coingecko...)
- **CoinGecko** — market data, new listings, price confirmation

### Trading & Portfolio
- Binance Spot auto-trade s HMAC-SHA256 potpisom
- Automatski stop-loss i take-profit (5-min monitoring tick)
- DEX position tracking — manualni entry, auto price refresh
- WalletConnect v2 — spajanje MetaMask/Trust Wallet
- P&L Dashboard — equity curve, win rate, R/R ratio, povijest tradeova

### Grafovi i Vizualizacija

| Tier | Historija | Predikcija |
|------|-----------|------------|
| SHORT | 10 dana (hourly) | 24h |
| MID | 6 mjeseci (daily) | 30 dana |
| LONG | 2 godine (daily) | 6 mjeseci |

### Push Notifikacije
- Stop-Loss i Take-Profit alerti
- INTERESTING signal alert (confluence score)

### Detail Screeni
- **MidProjectDetailScreen** — thesis, GitHub, entry plan, notes
- **LongHoldingDetailScreen** — 4 taba: Osnove, Fundamentali, DCA, Biljeske
- **ChartScreen** — tier-aware chart s predikcijom
- **PnlDashboardScreen** — equity curve, per-tier breakdown

---

## Instalacija

### Preuzimanje APK-a
1. Preuzmi `coinsight-v8.0.0.apk` (Assets sekcija)
2. Android: Postavke -> Sigurnost -> Dopusti nepoznate izvore
3. Instaliraj i pokreni

### Iz izvora
```bash
git clone https://github.com/nroxa92/claude_coinsight.git
cd claude_coinsight
flutter pub get
flutter build apk --debug
```

---

## Konfiguracija

| Servis | Obavezno | Namjena |
|--------|----------|---------|
| **Anthropic API Key** | Da | Claude AI analiza |
| **Binance API Key** | Za trading | Spot auto-trade |
| **Telegram Bot Token** | Preporuceno | Channel monitoring |
| **GitHub Token** | Preporuceno | Rate limit 60->5000 req/h |
| **WalletConnect Project ID** | Za DEX | MetaMask spajanje |

Novi korisnik? [NEWBIE_GUIDE.md](NEWBIE_GUIDE.md)

---

## Tehnicki stack

| Komponenta | Tehnologija |
|-----------|-------------|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| AI | Anthropic Claude API (claude-sonnet-4) |
| Market data | CoinGecko + Dexscreener |
| Trading | Binance Spot REST + WalletConnect v2 |
| Intelligence | Telegram + GitHub + Reddit |
| Charts | fl_chart |
| Storage | Hive (lokalno) |

---

## Dokumentacija

| Dokument | Namjena |
|----------|---------|
| [NEWBIE_GUIDE.md](NEWBIE_GUIDE.md) | Vodic za pocetnike |
| [MANUAL.md](MANUAL.md) | Korisnicki prirucnik |
| [OVERVIEW.md](OVERVIEW.md) | Tehnicka arhitektura |
| [WORKLOG.md](WORKLOG.md) | Development log (11 sesija) |

---

## Licenca

Proprietary — All Rights Reserved. © 2026 Neven Roksa. See [LICENSE](LICENSE).

<div align="center">
Izradeno s Claude AI
</div>

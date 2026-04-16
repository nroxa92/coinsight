# CoinSight — Claude Code Instructions

## Identitet
CoinSight je AI-powered crypto signal detector. Flutter/Dart, Provider state management, 
Hive lokalna pohrana. Verzija 2.0.0.

## Pravila rada
- Ako Claude Code primijeti bug koji nije dio zadatka koji rješava, dodaje ga pod 
  sekciju Identified Issues u WORKLOG.md ali ga ne popravlja bez pitanja.
- Ne refaktoriraš ono što radi. Ne mijenjaš arhitekturu bez zahtjeva.
- `flutter analyze` mora biti 0 issues nakon svake promjene.
- API ključevi se nikad ne hardkodiraju u source — samo kroz Settings → Hive storage.

## Arhitektura (lib/)
- `models/` — Coin, CoinPosition, RiskParameters, AnalysisLog, TradeProposal, 
  TradeResult, TelegramSignal, WatchlistProvider, AnalysisProvider, PortfolioProvider
- `services/` — CoinGeckoService, ClaudeService, BinanceService, TradeService, 
  TelegramMonitor, StorageService
- `screens/` — WatchlistScreen (3 taba), AnalysisScreen (chat + trade bar), 
  PortfolioScreen, SettingsScreen
- `widgets/` — CoinCard, ChatBubble, SparklineChart
- `theme/` — AppTheme (dark)

## API integracije
- **CoinGecko** — besplatni tier, 15s timeout, market data + new listings
- **Anthropic Claude** — claude-sonnet-4, 30s timeout, system prompt na HR/EN
- **Binance** — HMAC-SHA256 signed REST, testnet/prod switch, Spot only
- **Telegram Bot API** — TelegramMonitor čita javne kanale, ne šalje poruke

## Hive boxovi
settings, watchlist, analysis_logs, positions

## WORKLOG format
Svaka sesija ima sekciju u WORKLOG.md s fazama, promijenjenim fajlovima 
i verifikacijom (analyze + test + build).

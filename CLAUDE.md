# CoinSight — Claude Code Instructions

## Identitet
CoinSight je AI-powered crypto signal detector. Flutter/Dart, Provider state management, 
Hive lokalna pohrana. Verzija 7.0.0.

## Pravila rada
- Ako Claude Code primijeti bug koji nije dio zadatka koji rješava, dodaje ga pod 
  sekciju Identified Issues u WORKLOG.md ali ga ne popravlja bez pitanja.
- Ne refaktoriraš ono što radi. Ne mijenjaš arhitekturu bez zahtjeva.
- `flutter analyze` mora biti 0 issues nakon svake promjene.
- API ključevi se nikad ne hardkodiraju u source — samo kroz Settings -> Hive storage.

## Arhitektura (lib/)
- `models/` — Coin, CoinPosition, RiskParameters, AnalysisLog, TradeProposal, 
  TradeResult, TelegramSignal, MonitoredChannel, GithubSignal, RedditSignal, 
  IntelligenceReport, DexScreenerSignal, InvestmentTier, MidTermProject, 
  LongTermHolding, DexPosition, PriceChartData, ClosedTrade, PnlAnalytics (EquityPoint, 
  PnlAnalyticsBuilder), WatchlistProvider, AnalysisProvider, PortfolioProvider, TierProvider
- `services/` — CoinGeckoService, ClaudeService, BinanceService, TradeService, 
  TelegramMonitor, StorageService, IntelligenceAggregator, GitHubIntelligence, 
  RedditMonitor, DexScreenerService, ChartDataService, NotificationService, WalletService
- `screens/` — WatchlistScreen (3 taba), AnalysisScreen (chat + trade bar), 
  PortfolioScreen, SettingsScreen (5 tabova: API/Tiers/Bot/Trade/App), 
  BotManagerScreen, DexPositionScreen, MidProjectDetailScreen, 
  LongHoldingDetailScreen, ChartScreen, PnlDashboardScreen
- `widgets/` — CoinCard, ChatBubble, SparklineChart, TierModeSelector, 
  DexSignalCard, PriceChartWidget, WalletConnectButton
- `theme/` — AppTheme (dark)

## API integracije
- **CoinGecko** — besplatni tier, 15s timeout, market data + new listings
- **Anthropic Claude** — claude-sonnet-4, 30s timeout, system prompt na HR/EN
- **Binance** — HMAC-SHA256 signed REST, testnet/prod switch, Spot only
- **Telegram Bot API** — TelegramMonitor cita javne kanale, ne salje poruke
- **GitHub API** — trending repos, crypto project search, rate limit aware
- **Reddit** — r/CryptoMoonShots monitoring, signal extraction
- **DexScreener** — DEX pair discovery, token profiles, boosted tokens
- **WalletConnect v2** — wallet linking via url_launcher

## Hive boxovi
settings, watchlist, analysis_logs, positions, monitored_channels_detail, 
mid_term_projects, long_term_holdings, dex_positions, closed_trades

## Redoslijed implementacije
Implementacija ide fazno i svaka faza mora biti funkcionalna 
prije prelaska na sljedecu. Faza 1 je scaffold projekta, 
pubspec.yaml s dependencies, osnovna navigacija i tamna tema. 
Faza 2 je CoinGecko integracija i Watchlist screen s CoinCard 
widgetom i stvarnim podacima. Faza 3 je Anthropic integracija, 
ClaudeService i Analysis chat screen s osnovnim chat UI-jem. 
Faza 4 je Hive logging i Settings screen za unos API kljuca. 
Faza 5 je polish — error handling, loading states i UX detalji.

Developer eksplicitno potvrduje kraj svake faze prije nego 
Claude Code krece u sljedecu.

## WORKLOG format
Svaka sesija ima sekciju u WORKLOG.md s fazama, promijenjenim fajlovima 
i verifikacijom (analyze + test + build).

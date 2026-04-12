# CoinSight

AI-powered cryptocurrency insights combining real-time market data from CoinGecko with intelligent analysis powered by Claude (Anthropic).

> **Proprietary Software** — See [LICENSE](LICENSE) for terms.

---

## Features

### Watchlist
- Real-time cryptocurrency prices from CoinGecko API
- Top 25 coins by market cap with 7-day sparkline charts
- Personal watchlist with star toggle (persisted locally)
- Pull-to-refresh with skeleton loading states
- 24h price change with color-coded indicators

### AI Analysis
- Chat interface powered by Claude (Anthropic API)
- Automatic watchlist context injection for relevant analysis
- Suggestion chips for quick prompts
- Conversation history within session
- System prompt tuned for crypto analysis with DYOR disclaimer

### Settings
- Secure API key management (stored locally via Hive)
- Key validation and visibility toggle
- Confirmation dialogs for destructive actions
- App information and version display

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| State Management | Provider (ChangeNotifier) |
| Market Data | CoinGecko API v3 (free tier) |
| AI Analysis | Anthropic Claude API (claude-sonnet-4-20250514) |
| Local Storage | Hive (Flutter) |
| UI | Material Design 3 — Custom dark theme |

---

## Architecture

```
lib/
├── main.dart                    # App entry point, provider setup, navigation
├── models/
│   ├── coin.dart                # Coin data model (CoinGecko JSON mapping)
│   ├── watchlist_provider.dart  # Watchlist state management
│   └── analysis_provider.dart   # Chat/AI state management
├── services/
│   ├── coingecko_service.dart   # CoinGecko API client
│   ├── claude_service.dart      # Anthropic Claude API client
│   └── storage_service.dart     # Hive local storage wrapper
├── screens/
│   ├── watchlist_screen.dart    # Watchlist + Top Coins tabs
│   ├── analysis_screen.dart     # AI chat interface
│   └── settings_screen.dart     # API key management + about
├── widgets/
│   ├── coin_card.dart           # Coin display card + skeleton loader
│   ├── chat_bubble.dart         # Chat message bubble
│   └── sparkline_chart.dart     # 7-day price sparkline (CustomPainter)
└── theme/
    └── app_theme.dart           # Dark theme configuration
```

---

## Setup

### Prerequisites
- Flutter SDK 3.41+ ([install](https://docs.flutter.dev/get-started/install))
- Anthropic API key ([console.anthropic.com](https://console.anthropic.com))

### Run

```bash
# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Run on Chrome (web)
flutter run -d chrome

# Build release
flutter build windows
```

### Configuration
1. Launch the app
2. Go to **Settings** tab
3. Enter your Anthropic API key (`sk-ant-...`)
4. Return to **Analysis** tab to start chatting

---

## API Usage

### CoinGecko (Free Tier)
- Endpoint: `GET /coins/markets`
- Rate limit: ~10-30 req/min (free tier)
- No API key required
- Data: prices, market cap, 24h change, 7d sparkline

### Anthropic Claude
- Endpoint: `POST /v1/messages`
- Model: `claude-sonnet-4-20250514`
- Requires API key (user-provided, stored locally)
- Max tokens: 1024 per response

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| No internet | Error message + Retry button |
| CoinGecko rate limit (429) | User-friendly message |
| Claude API invalid key (401) | Redirect to Settings |
| Claude rate limit (429) | User-friendly message |
| Request timeout | 15s (CoinGecko) / 30s (Claude) with message |
| Malformed API response | Graceful fallback with error message |

---

## Security

- API keys are stored locally on-device via Hive (never transmitted except to Anthropic API)
- No analytics, tracking, or telemetry
- No server-side component — all communication is client-to-API
- Obscured key display in Settings with confirmation for deletion

---

## License

This software is proprietary and confidential. Unauthorized copying, modification, distribution, or use of this software is strictly prohibited. See [LICENSE](LICENSE) for full terms.

Copyright (c) 2026 CoinSight. All Rights Reserved.

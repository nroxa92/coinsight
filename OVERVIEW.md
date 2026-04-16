# CoinSight — Tehnički pregled

## Arhitekturalni principi

**Lokalno-first** — svi podaci ostaju na uređaju. Hive baza, API ključevi,
pozicije, logovi — ništa ne odlazi na external server.

**Human-in-the-loop (Faza 2)** — svaki trade zahtijeva korisnikovu
potvrdu. Bot predlaže, čovjek odlučuje.

**Autonomni mod (Faza 3)** — opcionalni, eksplicitno uključen od strane
korisnika, s definiranim risk parametrima koji ograničavaju izloženost.

**Intelligence layering** — Claude AI dobiva tri sloja konteksta:
1. CoinGecko market podaci (volume, price change, market cap)
2. Telegram channel signali (listing announcements, whale alerts)
3. Korisnički watchlist (personalni kontekst)

## Podatkovni tok

```
CoinGecko API ──────────────────────────────────────────►
                                                          Claude AI
Telegram Monitor ──► AnalysisProvider ──► context ──────►
                                                          │
Korisnikova poruka ─────────────────────────────────────►│
                                                          ▼
                                               WATCH/SKIP/INTERESTING
                                                          │
                                          ┌───────────────┴──────────┐
                                          ▼                          ▼
                                    [FAZA 2]                   [FAZA 3]
                               Korisnik potvrđuje          Auto-execute
                                          │                          │
                                          └───────────────┬──────────┘
                                                          ▼
                                                   BinanceService
                                                   Market Buy Order
                                                          │
                                                          ▼
                                                   CoinPosition
                                                   (Hive storage)
                                                          │
                                              ┌──────────┴──────────┐
                                              ▼                     ▼
                                         Stop-Loss            Take-Profit
                                       (svakih 5min)        (svakih 5min)
```

## Sigurnosni model

Binance API ključ prolazi kroz stack:
`Settings UI → StorageService (Hive) → BinanceService._apiKey (memory, lifetime=request)`

Secret nikad ne logira, nikad ne šalje na Anthropic API,
nikad ne pojavljuje u error porukama.

Withdrawal dozvola nije potrebna i ne smije biti uključena.

## Poznata ograničenja

**CoinGecko besplatni tier** — ~10-30 req/min. App koristi 15-sekundni
timeout i 5-minutni auto-refresh da ostane unutar limita.

**Binance Spot only** — nema futures, margin, opcija. Svjesna odluka
za smanjenje rizika.

**Claude API latencija** — ~2-5 sekundi po analizi. Nije real-time
ali prihvatljivo za early momentum detekciju.

**Android background killing** — Android može ubiti app proces u
pozadini. Preporučeno: drži ekran aktivan ili koristi "Don't optimise
battery" za CoinSight u Android postavkama.

## Verzijska historija

| Verzija | Datum | Što je dodano |
|---|---|---|
| v1.0.0 | 2026-04-12 | Inicijalni release: Watchlist, Claude chat, Settings |
| v2.0.0 | 2026-04-16 | Binance trading, Portfolio, Telegram Monitor, Auto-trade, Test suite |

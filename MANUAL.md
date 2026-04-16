# CoinSight — Korisnički priručnik

## Postavljanje (Setup)

### 1. Anthropic API ključ

1. Idi na [console.anthropic.com](https://console.anthropic.com)
2. Kreiraj account i generiraj API ključ
3. U CoinSight Settings → Anthropic API Key → unesi ključ → Save
4. Svaki Claude AI poziv naplaćuje se prema Anthropic tarifi
   (~$0.003 po analizi s claude-sonnet-4)

### 2. Binance API ključevi

**VAŽNO: Nikad ne dodavaj Withdrawal dozvolu na API ključ.**

1. Otvori Binance → Account → API Management
2. Kreiraj novi API ključ
3. Dozvole: Enable Reading, Enable Spot & Margin Trading
4. Dozvole: Enable Withdrawals (ISKLJUČENO)
5. Preporučeno: počni s Testnetom (testnet.binance.vision)
6. U CoinSight Settings → Binance API → unesi ključ i secret → Save
7. Uključi Testnet toggle dok ne budeš siguran da sve radi
8. TEST KONEKCIJU → mora pokazati USDT balans

### 3. Telegram Channel Monitor (opcionalno)

1. Otvori Telegram → napiši @BotFather → /newbot
2. Daj botu ime (npr. "MyCoinSightMonitor")
3. Dobiješ token u formatu: 123456789:AAF...
4. Dodaj bota kao administratora u javne kanale koje želiš pratiti
   - @binance, @kucoincom, @whale_alert, @coingecko, @coinmarketcap
5. U CoinSight Settings → Intelligence → Telegram Monitor → unesi token
6. Uključi "Aktiviraj monitoring"

---

## Korištenje

### New Listings tab

Prikazuje coinove koji zadovoljavaju momentum kriterije:
- Market cap rank: null ili >500 (ispod radara velikih investitora)
- Volume: između $50,000 i $50,000,000
- Sortiranje: po 1h price change, najveći rast prvi

Auto-refresh svakih 3 minute dok si na ovom tabu.

Pull-to-refresh za manualno osvježavanje.

### Analysis tab

Slobodni chat s Claude AI analitičarem. Pita se o coinovima,
tržišnim trendovima, strategijama.

**Telegram signal badge** — ako Telegram monitor ima pending signale,
prikazuje se narančasti banner koji informira da će signali biti
uključeni u sljedeću analizu. Signali se konzumiraju automatski.

**Trade Action Bar** — pojavljuje se kada Claude vrati **INTERESTING**
oznaku u odgovoru:

```
INTERESTING signal — XYZ/USDT
Uloži: [10.00] USDT
SL -15% | TP +30%
[BUY NOW]  [SKIP]
```

- **BUY NOW** → otvara confirmation dialog s detaljima → potvrdi → Binance order
- **SKIP** → logira kao skipped, skriva action bar

### Portfolio tab

Prikazuje:
- USDT balans (live, refresh svakih 30 sekundi)
- Otvorene pozicije s live P&L
- CLOSE POSITION za manualni izlaz
- History zadnjih 20 analiza

### Settings tab

**Anthropic API** — ključ za Claude AI
**Binance API** — ključevi za trading, testnet toggle
**Risk Parameters:**
- Max trade amount — maksimalni USDT po transkakciji
- Max open positions — maksimalni broj istovremenih pozicija
- Stop-loss % — automatski izlaz pri gubitku
- Take-profit % — automatski izlaz pri dobitku
- Auto-trade — Faza 3, izvršava bez potvrde
- Quiet hours — pauza bota u definiranom periodu

**Intelligence — Telegram Monitor** — konfiguracija channel monitoringa

---

## Risk Management

### Stop-Loss
Automatski se provjerava svakih 5 minuta. Kad cijena padne ispod
`entryPrice * (1 - stopLossPercent/100)`, pozicija se automatski zatvara.

### Take-Profit
Isti interval provjere. Kad cijena naraste iznad
`entryPrice * (1 + takeProfitPercent/100)`, pozicija se automatski zatvara.

### Preporučene početne postavke
- Max trade: $10 USDT
- Max pozicija: 3
- Stop-loss: 15%
- Take-profit: 30%
- Auto-trade: ISKLJUČENO dok ne validiraš strategiju

---

## Česte greške

| Greška | Uzrok | Rješenje |
|---|---|---|
| "Insufficient USDT balance" | Nema dovoljno USDT na Binanceu | Depositaj USDT ili smanji max trade amount |
| "API Key invalid (401)" | Pogrešan ključ | Provjeri Settings → Binance API |
| "Max open positions reached" | Dostignut limit | Zatvori pozicije ili povećaj limit |
| "Proposal expired" | Prošlo >60s od pripreme | Tapni BUY NOW brže ili pokaži novu analizu |
| "Could not fetch price" | Coin ne postoji na Binanceu kao XXXUSDT par | Ovaj coin nije dostupan za trading |

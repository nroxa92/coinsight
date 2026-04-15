# CoinSight — Korisnički Priručnik

**Za koga je ovaj priručnik:** netko tko prvi put otvara CoinSight. Ne pretpostavljamo da znaš što je market cap, što je Spot trading, niti kako funkcionira API ključ. Sve se objašnjava u hodu.

**Verzija aplikacije:** 1.0.0
**Platforma:** Android (primarno) + Windows desktop
**Datum priručnika:** 2026-04-15

---

## Kako čitati ovaj priručnik

- Prođi **redom od 1 do 10**. Svaka sekcija se nadovezuje na prethodnu.
- Sekcije **11 nadalje** (Telegram, scenariji, troubleshooting) čitaj po potrebi.
- Gdje god vidiš ▶ **to napravi sad** — to je korak koji bi trebao izvršiti dok čitaš.
- Ako nešto ne razumiješ, potraži pojam u **Rječniku** na kraju (sekcija 16).

---

## Sadržaj

1. [Što je CoinSight i koji je cilj](#1-što-je-coinsight)
2. [Osnovne crypto pojmove koje trebaš razumjeti](#2-osnovne-crypto-pojmove)
3. [Što ti treba prije nego kreneš](#3-što-ti-treba-prije-nego-kreneš)
4. [Prvo pokretanje aplikacije — što ćeš vidjeti](#4-prvo-pokretanje-aplikacije)
5. [Turneja po aplikaciji — 4 taba](#5-turneja-po-aplikaciji)
6. [Postavljanje API ključeva — korak po korak](#6-postavljanje-api-ključeva)
7. [Tvoja prva analiza — tutorijal](#7-tvoja-prva-analiza)
8. [Kako čitati Claudeov odgovor](#8-kako-čitati-claudeov-odgovor)
9. [Tvoj prvi trade — tutorijal](#9-tvoj-prvi-trade)
10. [Praćenje pozicija i stop-loss](#10-praćenje-pozicija-i-stop-loss)
11. [Risk management — koliko riskirati](#11-risk-management)
12. [Automatsko trgovanje (Faza 3)](#12-automatsko-trgovanje-faza-3)
13. [Telegram bot — trebaš li ga](#13-telegram-bot)
14. [Tipični scenariji — što se događa tijekom dana](#14-tipični-scenariji)
15. [Problemi i rješenja](#15-problemi-i-rješenja)
16. [Sigurnost — što moraš znati](#16-sigurnost)
17. [Često postavljana pitanja](#17-često-postavljana-pitanja)
18. [Rječnik pojmova](#18-rječnik-pojmova)

---

## 1. Što je CoinSight

### 1.1 U jednoj rečenici

CoinSight je aplikacija koja ti pomaže **pronaći male kripto valute** koje trenutno rastu, **pitati AI** je li rast stvaran ili prijevara, i **kupiti ih** jednim tapom — sve unutar iste app-e.

### 1.2 Što rješava (ili zašto postoji)

Zamisli uobičajeni proces kad netko želi uhvatiti crypto "pump":

1. Otvara CoinGecko ili CoinMarketCap da vidi top gainere
2. Filtrira po volumenu, ranku, change %
3. Kopira simbol coina
4. Prebacuje se u TradingView ili Twitter da provjeri je li to scam
5. Prebacuje se u Binance, traži coin
6. Ručno računa koliko kupiti
7. Klika Buy, potvrđuje
8. Prebacuje se u neku app za praćenje P&L-a

Traje 10-15 minuta po coinu. **CoinSight sve to radi u jednoj app-i u ~60 sekundi.**

### 1.3 Što CoinSight NIJE

- **Nije magija.** Ne zna budućnost. Njegova AI procjena je korisna u ~60-70% slučajeva, ne 100%.
- **Nije za dugoročno investiranje.** Ne kupuješ Bitcoin preko njega da ga držiš 5 godina. App je fokusiran na **kratkoročne momentum prilike** (sati do dana).
- **Nije financijski savjet.** Ti odlučuješ, ti snosiš gubitke.
- **Nije vlasnik tvog novca.** Tvoj novac ostaje na Binanceu. CoinSight samo komunicira s Binance API-jem u tvoje ime.

### 1.4 Koji AI se koristi

**Claude** od Anthropica — jedan od najnaprednijih AI asistenata. CoinSight ga koristi kroz službeni Anthropic API. AI dobija podatke o coinu (cijena, volumen, trendovi) i vraća procjenu: **WATCH / SKIP / INTERESTING**.

---

## 2. Osnovne crypto pojmove

Pojmovi koje moraš razumjeti prije korištenja app-a. Ako ti je sve poznato, preskoči na sekciju 3.

### 2.1 Coin / Token

Digitalna valuta (kripto) — Bitcoin, Ethereum, Dogecoin, ili neki od **tisuća** manjih. CoinSight targetira male ("micro-cap" i "small-cap"), a ne velike kao BTC ili ETH.

### 2.2 Market cap (tržišna kapitalizacija)

Koliko **ukupno vrijedi** taj coin u cijelom svijetu. Formula: `broj_coinova_u_opticaju × cijena`.

- **Large-cap** (>$10 milijardi): BTC, ETH, BNB — stabilni, spori rast
- **Mid-cap** ($500M–$10B): Solana, Avalanche, Polkadot
- **Small-cap** ($10M–$500M): srednje rizično, brži pokreti
- **Micro-cap** (<$10M): vrlo rizično, moguć 10x ili gubitak 90%

CoinSight lovi **small i micro cap** kod kojih je moguć 20-100% rast u satima.

### 2.3 Market cap rank (rang)

Pozicija coina po market capu. Bitcoin je #1. Ethereum je #2. CoinSight u New Listings tabu prikazuje coinove **s rankom iznad 500** (ili bez ranka) — oni su "ispod radara" većine investitora, što je uvjet za nagli momentum.

### 2.4 Volume (volumen)

Koliko se **tog coina trgovalo u zadnjih 24 sata** u USD-u. Primjer: ako piše volume $2M, to znači da su ljudi u zadnjih 24h kupili i prodali ukupno $2 milijuna vrijednog tog coina.

- **Premali volumen** (<$50k) = malo ljudi trguje = teško prodati kad zatreba = **slippage** (prodaš po goroj cijeni od očekivane)
- **Idealan za CoinSight** ($50k–$50M) = dovoljno aktivnosti da je realno, ne previsoko da bude već mainstream
- **Previsoki volumen** (>$50M) = već je "prošao ispod radara"

### 2.5 Price change (promjena cijene)

- **1h change**: koliko je cijena porasla ili pala u **zadnjem satu**. Pokazuje **trenutni momentum**.
- **24h change**: u **zadnjih 24h**. Pokazuje kratki trend.

CoinSight sortira po 1h — ono što raste **upravo sada** je na vrhu liste.

### 2.6 Sparkline

Mali grafikon u CoinCard-u koji pokazuje **7-dnevnu krivulju cijene**. Brzi vizualni pregled: je li coin u uzlaznom ili silaznom trendu kroz tjedan.

### 2.7 Spot trading

Najosnovniji oblik trgovine: **kupiš coin, imaš ga, možeš prodati**. Za razliku od:
- **Futures** — tradaš derivativima bez posjedovanja coina (CoinSight **NE** podržava — previše rizično za početnike)
- **Margin** — trgovanje posuđenim novcem (CoinSight **NE** podržava)

CoinSight = **isključivo Spot**.

### 2.8 Stop-loss i Take-profit

- **Stop-loss (SL)**: cijena na kojoj app **automatski prodaje** da ograniči gubitak. Ako kupiš po $100 i postaviš SL na 15%, app će prodati ako cijena padne na $85.
- **Take-profit (TP)**: cijena na kojoj app **automatski prodaje** da zaključa profit. Kupiš po $100, TP 30% = prodaje kad dosegne $130.

Oba su **sigurnosne mreže** — ne moraš buljiti u ekran cijeli dan.

### 2.9 Slippage

Razlika između **cijene koju si vidio** i **cijene po kojoj si stvarno kupio/prodao**. Na small-cap coinovima s malim volume-om može biti značajan (1-5%).

### 2.10 API ključ

Sigurnosni "kod" koji aplikacija koristi da komunicira sa servisom (Binance, Claude) u tvoje ime. **Važno**: API ključ **nije tvoja lozinka**. Lozinka je za prijavu na web, API ključ je samo za automatizaciju.

Kod Binance API ključa postoje **permissionsi**:
- **Read**: samo gleda balans i cijene
- **Spot Trading**: kupuje i prodaje u tvoje ime ✅ (potrebno)
- **Withdrawal**: povlači novac s racuna ❌ (NIKAD ne uključuj)

---

## 3. Što ti treba prije nego kreneš

### 3.1 Check-lista

Prije prvog korištenja:

| Stvar | Obavezno? | Gdje nabaviti |
|-------|-----------|---------------|
| Android telefon ili Windows PC | ✅ Obavezno | Tvoj uređaj |
| Internet veza | ✅ Obavezno | — |
| **Anthropic API ključ** (za AI analizu) | ✅ Ako želiš AI | Kreiraš na console.anthropic.com (~10 min) |
| **Binance Spot account** (za kupovanje) | ⚠️ Za trading | binance.com, registracija + KYC (~30 min + čekanje verifikacije) |
| **Binance API ključ** (signira API pozive) | ⚠️ Za trading | Generiraš kad si ulogiran na Binance (~5 min) |
| **Telegram bot** | ❌ Opcionalno | @BotFather na Telegramu (~5 min) |
| **Novac na Binance Spot wallet** | ⚠️ Za stvarno trgovanje | Depozitiraj preko Binance (SEPA uplata iz banke) |

### 3.2 Koliko novca treba?

**Minimalno preporučeno:** $50-100 u USDT-ima na Binance Spot wallet-u.

Zašto toliko:
- CoinSight default kupuje $10 po tradeu
- S 3 istovremene pozicije = $30 angažiranog novca
- Ostatak je "rezerva" za idući signal

**Ne prelaziš** iznos koji si spreman **izgubiti** na prvi dan. Prvi dan je za učenje, ne zaradu.

### 3.3 Trošak korištenja

- **Anthropic AI**: cca **$0.01-0.02 po jednoj analizi**. Mjesečno ~$5-20 ako svakodnevno analiziraš
- **Binance trading fee**: **0.1% po tradeu** (kupuješ $10, plaćaš $0.01 fee). Zanemarivo
- **CoinSight app**: besplatan

Za mjesečni budžet: **$10-30** za AI + fee.

---

## 4. Prvo pokretanje aplikacije

### 4.1 Instalacija

**Android:**
1. Dobiješ APK fajl od developera (CoinSight je privatan, nije na Play Store)
2. Settings → Security → **Allow installation from unknown sources** (ako traži)
3. Otvori APK → Install → Open

**Windows:**
1. Dobiješ `coinsight.exe` i pripadajuće datoteke u ZIP-u
2. Extract ZIP u direktorij po izboru
3. Dupli klik na `coinsight.exe`

### 4.2 Prvi ekran

Kad prvi put otvoriš app vidjet ćeš:

```
┌──────────────────────────────────┐
│         Watchlist                │ ← gornji naslov (AppBar)
├──────────────────────────────────┤
│  [New Listings] [My Watchlist]   │ ← 3 sub-taba
│              [Top Coins]         │
├──────────────────────────────────┤
│  ░░░░░░░░░░░░░░░░░░░░            │
│  ░░░░░░░░░░░░░░░░░░░░            │ ← skeleton (sivi loading)
│  ░░░░░░░░░░░░░░░░░░░░            │   Traje 2-3 sekunde
├──────────────────────────────────┤
│  ⭐  ✨  💼  ⚙                   │ ← bottom nav (4 taba)
└──────────────────────────────────┘
```

Nakon 2-3 sekunde skeleton nestaje i pojavljuju se **stvarni coinovi** — lista 20-ak small-cap coinova koji trenutno rastu.

▶ **Napravi sad:** samo pogledaj listu. Ne moraš još ništa tapnuti.

### 4.3 Što vidiš na svakoj kartici

```
┌────────────────────────────────────────────────┐
│ #523 [🪙] PepeRocket           [1H +12.4%]    │
│      PEPR  ▁▂▄▅▆▇▇▅▃▂▁        $0.000423      │
│                               📈 +45.3% 24H   │
│                                         ⭐    │
└────────────────────────────────────────────────┘
```

Odozgo dolje, lijevo-desno:
- **#523** — market cap rank (523. po veličini, micro-cap)
- **🪙** — ikonica coina (ako ne učita, prikaže se placeholder)
- **PepeRocket** — puno ime coina
- **[1H +12.4%]** — zelena oznaka: u zadnjem satu porasao 12.4%
- **PEPR** — ticker simbol (kratica)
- **▁▂▄▅▆▇▇▅▃▂▁** — sparkline, 7-dnevni trend (raste blago do polovice tjedna pa stabilizacija)
- **$0.000423** — trenutna cijena
- **📈 +45.3% 24H** — zeleno: u zadnjih 24h porasao 45.3%
- **⭐** — zvjezdica za dodavanje u My Watchlist (ako je sjajna, već je u watchlistu)

### 4.4 Pull-to-refresh

Gdje god vidiš listu (New Listings, My Watchlist, Top Coins, Portfolio):
- Stavi prst na vrh liste
- Povuci prema dolje
- Vidjet ćeš spinner
- Pusti → lista se osvježava

### 4.5 Bottom navigacija

Na dnu ekrana su 4 ikone. Tapneš ikonu → mijenjaš tab.

| Ikona | Što radi |
|-------|----------|
| ⭐ Watchlist | Browse coinova (New Listings / My Watchlist / Top Coins) |
| ✨ Analysis | AI analiza (Claude chat) |
| 💼 Portfolio | Tvoje otvorene pozicije, P&L, povijest |
| ⚙️ Settings | Postavke, API ključevi, risk parametri |

Kad tapneš tab, ikona se "puni" (outline verzija postaje solidna).

---

## 5. Turneja po aplikaciji

Sada ćemo proći svaki tab da vidiš što je gdje. **Ne treba ništa konfigurirati još** — samo upoznaj ekrane.

### 5.1 Tab ⭐ Watchlist — 3 pod-taba

Prvi tab koji vidiš kad otvoriš app.

**Pod-tab 1: New Listings (default, prvi)**

Lista small-cap coinova s 1h momentum-om. Objašnjeno gore (sekcija 4.3).

- Auto se osvježava svakih 3 minute (dok si na ovom pod-tabu)
- Pull-to-refresh radi ručno
- Tap zvjezdice ⭐ → coin ide u My Watchlist

**Pod-tab 2: My Watchlist**

Coinovi koje si ti označio. Prazno kad prvi put otvoriš app — osim default-a: Bitcoin, Ethereum, Solana (dodano da nije prazno za početak).

- Ovdje Claude uzima "kontekst" za AI analizu
- Ukloniš coin tapom na već-sjajnu zvjezdicu

**Pod-tab 3: Top Coins**

Top 25 najvećih kripto valuta po market capu. Bitcoin, Ethereum, Tether, itd.

- Tu dodaješ "mainstream" coinove za referencu
- Ne osvježava se automatski — pull-to-refresh ručno

### 5.2 Tab ✨ Analysis — Claude chat

Kad prvi put tapneš ovaj tab **bez Anthropic API ključa**:

```
┌──────────────────────────────────┐
│   🔑                              │
│                                  │
│   API Key Required               │
│                                  │
│   Add your Anthropic API key     │
│   in Settings to start chatting  │
│   with CoinSight AI.             │
│                                  │
└──────────────────────────────────┘
```

Ne brini — objasnit ćemo u sekciji 6.

Kad **dodaš ključ**, tab prelazi u chat sučelje:

```
┌──────────────────────────────────┐
│   ✨                              │
│   CoinSight AI                   │
│                                  │
│   Ask about crypto trends...     │
│                                  │
│   [Analyze my watchlist]         │
│   [Bitcoin outlook?]             │
│   [Explain DeFi]                 │
│                                  │
├──────────────────────────────────┤
│  [Ask about crypto...]  ▶       │ ← input bar
└──────────────────────────────────┘
```

Ispod su 3 "suggestion chipa" — tapneš i pošalje tu poruku umjesto tebe. Dobro za prvi pokušaj.

### 5.3 Tab 💼 Portfolio — tvoje pozicije

Bez Binance ključa:

```
┌──────────────────────────────────┐
│   💼                              │
│                                  │
│   Binance nije konfiguriran      │
│                                  │
│   Dodaj Binance API ključeve     │
│   u Settings da započneš trading.│
└──────────────────────────────────┘
```

Bez trade-ova (imaš ključ ali nisi ništa kupio):

```
┌──────────────────────────────────┐
│ 💼 Portfolio              🔄     │
│ USDT Balance:       $234.56      │
│ Open Positions:     0            │
│ Total P&L:          $0.00        │
├──────────────────────────────────┤
│     📥 No open positions         │
├──────────────────────────────────┤
│ Analysis History                 │
│   (prazno ili tvoji Claude logovi)│
└──────────────────────────────────┘
```

S pozicijom:

```
┌──────────────────────────────────┐
│ 💼 Portfolio              🔄     │
│ USDT Balance:       $224.56      │
│ Open Positions:     1            │
│ Total P&L:          +$1.23 (+12%)│ ← zeleno
├──────────────────────────────────┤
│ PEPR/USDT              [CLOSE]   │
│ Entry: $0.000423 → Now: $0.000473│
│ Qty: 23640.66 | Invested: $10    │
│ P&L: +$1.18 (+11.82%)            │ ← zeleno
│ SL: $0.000359 | TP: $0.000550    │
└──────────────────────────────────┘
```

### 5.4 Tab ⚙ Settings — postavke

Pet sekcija odozgo dolje:
1. **Anthropic API Key** (za Claude AI)
2. **Binance API** (za trading)
3. **Risk Parameters** (koliko rizikovati)
4. **Telegram Bot** (notifikacije, opcionalno)
5. **About CoinSight** (verzija, disclaimer)

Detaljno u sekciji 6.

---

## 6. Postavljanje API ključeva

Sada pravi setup. Proći ćemo tri ključa redom: **Anthropic**, **Binance**, **Telegram** (zadnji opcionalan).

### 6.1 Anthropic API ključ (za AI)

**Svrha:** Ovo omogućava Claude AI analizu u Analysis tabu.

▶ **Napravi sad:**

**Korak 1 — Registracija na Anthropic:**
1. Otvori browser → `console.anthropic.com`
2. **Sign up** s e-mailom (ili Google loginom)
3. Verificiraj e-mail (link u inbox-u)

**Korak 2 — Dodaj način plaćanja:**
1. Ulogiraj se → gornji desni kut → **Settings** → **Billing**
2. **Add payment method** → unesi kreditnu/debitnu karticu
3. **Add credits** → preporučam **$10 za početak** (traje oko 500-1000 analiza)

**Korak 3 — Generiraj ključ:**
1. Settings → **API Keys**
2. **Create Key** → daj ime (npr. "CoinSight")
3. Kopiraj ključ koji počinje s `sk-ant-api03-...`

⚠️ **Ovaj ključ se prikazuje SAMO JEDNOM.** Ako ga izgubiš, moraš kreirati novi.

**Korak 4 — Upiši u CoinSight:**
1. Otvori CoinSight → tapni **⚙ Settings** tab
2. **Anthropic API Key** sekcija → tapni polje ispod teksta `sk-ant-...`
3. Paste ključ (long press → Paste, ili Ctrl+V na PC-u)
4. Tapni **Save Key**
5. Vidjet ćeš "API key saved" potvrdu i status badge se mijenja u zeleni **Active**

✅ Anthropic ključ postavljen.

### 6.2 Binance account i API ključ (za trading)

**Svrha:** Omogućava CoinSight-u da u tvoje ime kupuje/prodaje coinove na Binanceu.

⚠️ **Preduvjet:** moraš imati Binance account i proći KYC (identity verifikaciju). Ako nemaš:

**Korak A — Registracija (ako još nemaš account):**
1. Otvori binance.com
2. Register s e-mailom + lozinkom
3. Verificiraj e-mail
4. **KYC verifikacija**: Account → **Identification** → slikaj osobnu iskaznicu ili putovnicu + selfie. Čekaj 1-48h da Binance odobri.

Bez KYC-a trading API neće raditi.

**Korak B — Deposit USDT-a:**
1. Binance → **Wallet** → **Spot** → **Deposit**
2. Odaberi **USDT** → network **TRC20** ili **BEP20** (za SEPA uplatu iz banke: Deposit → **EUR** → Bank Transfer (SEPA) → slijedi upute)
3. Pošalji $50-100 vrijedno EUR-a, pričekaj uplatu (SEPA traje 1-3 dana)
4. Kad EUR stigne, konvertiraj u USDT: **Convert** → EUR → USDT

**Korak C — Generiranje API ključa:**

⚠️ **BITNO: API Management je dostupan SAMO na desktop webu, ne na mobilnoj Binance app-i.**

Ako si na mobitelu:
- Otvori **Chrome / Safari** (browser, ne Binance app!)
- Idi na `binance.com`
- Tri točkice u browseru → **Desktop site** ili **Request desktop version**
- Nastaviš po koracima ispod

Na PC-u:
1. Uloguj se na `binance.com`
2. Gornji desni kut → **ikona profila** → **Account** → **API Management**
3. **Create API** → odaberi **System generated** → upiši ime (npr. "CoinSight") → prođi 2FA verifikaciju
4. Kopiraj:
   - **API Key** (duži string)
   - **Secret Key** (prikazuje se **samo jednom**)

**Korak D — SIGURNOSNE POSTAVKE (kritično):**

Na novi ključu klikni **Edit restrictions**:

✅ **UKLJUČI:**
- Enable Reading (automatski)
- **Enable Spot & Margin Trading**

❌ **ISKLJUČI OBAVEZNO:**
- **Enable Withdrawals** ← **NIKAD ne uključuj ovo**
- Enable Internal Transfer
- Enable Universal Transfer
- Enable Futures
- Enable Margin
- Enable Options

Ako ovo zaboraviš i neki hacker dođe do tvog ključa → izvuče sav novac. Ako je Withdrawal OFF, hacker ne može ništa izvući.

**IP Restriction** (opcionalno):
- Ako imaš fiksni kućni internet → **Restrict to trusted IPs** i dodaj svoj IP (Google "what is my IP")
- Ako ti se IP mijenja (mobilna mreža, koristiš više WiFi mreža) → **Unrestricted** je OK jer si isključio withdrawal

Save. Sada imaš:
- API Key string
- Secret Key string

**Korak E — Upiši u CoinSight:**
1. CoinSight → ⚙ Settings → **Binance API** sekcija
2. Pročitaj narančasti warning ("Osiguraj da API ključ NEMA dozvolu za Withdrawal")
3. **API Key** polje: paste svoj API Key
4. **API Secret** polje: paste svoj Secret Key
5. **Testnet mode** switch:
   - Ako prvi put i želiš testirati bez pravog novca → **ostavi ON** (alternativa: vidi korak F)
   - Ako ideš odmah pravim novcem → **OFF** (otvorit će se dialog "Prebaci na LIVE?" → Confirm LIVE)
6. Tapni **Save**
7. Tapni **Test** → očekivani rezultat: `OK — USDT balance: $100.00 (live)` ili `(testnet)`

✅ Binance ključ postavljen.

**Korak F — Testnet alternativa (ako želiš vježbati bez pravog novca):**

Umjesto pravog Binance accounta, možeš koristiti testnet:

1. Otvori `testnet.binance.vision`
2. **Login with GitHub** (ne Binance account — odvojen sistem)
3. Odmah dobiješ **10,000 lažnih USDT**
4. **Generate HMAC_SHA256 Key** → kopiraj API Key + Secret
5. U CoinSight Settings → Binance API → paste ključeve → **Testnet switch ON** → Save → Test

Testnet je identičan live Binanceu, samo s lažnim novcem. Savršeno za prvi tjedan učenja.

### 6.3 Telegram bot (opcionalno)

**Svrha:** Dobivati notifikacije o signalima i trejdovima, slati komande botu na daljinu.

Možeš preskočiti ovu sekciju i dodati kasnije. App savršeno radi bez Telegrama.

**Korak 1 — Kreiraj bota:**
1. Otvori Telegram → traži `@BotFather` → Start
2. Pošalji `/newbot`
3. BotFather pita za ime (proizvoljno, npr. "Moj Crypto Signal")
4. BotFather pita za username (mora završiti s `bot`, npr. `mojcrypto_signal_bot`)
5. Kopiraj **Bot Token** koji ti BotFather pošalje (dugi string s `:` u sredini)

**Korak 2 — Pokreni bota:**
1. BotFather ti je dao link na tvog novog bota — tapni ga
2. Pošalji botu `/start` (kod sebe otvori chat)

**Korak 3 — Pronađi svoj Chat ID:**

Najlakše:
1. U Telegramu traži `@userinfobot` → Start
2. Bot ti odgovara tvojim Chat ID-jem (broj, npr. `123456789`)
3. Kopiraj broj

**Korak 4 — Upiši u CoinSight:**
1. CoinSight → ⚙ Settings → **Telegram Bot** sekcija
2. **Bot Token** polje: paste token
3. **Chat ID** polje: paste svoj Chat ID
4. Tapni **Save**
5. Tapni **Test** → na Telegramu bi trebao dobiti poruku `✅ CoinSight test poruka`

✅ Telegram postavljen.

---

## 7. Tvoja prva analiza

Sada radimo **prvi pravi posao**. Pretpostavljamo da imaš Anthropic ključ aktiviran.

### 7.1 Pripremi coin za analizu

▶ **Napravi sad:**

1. Tapni **⭐ Watchlist** tab
2. Budi na **New Listings** pod-tabu (prvi)
3. Pogledaj listu. Tapni zvjezdicu ⭐ na nekom coinu koji ti je zanimljiv — npr. onaj s najvećim 1H porastom
4. Provjeri da je zvjezdica postala **ispunjena** (znači dodan je u watchlist)

Alternativa: neka ti u My Watchlist-u ostaju defaultni Bitcoin/Ethereum/Solana — Claude će analizirati njih.

### 7.2 Pitaj Claudea

▶ **Napravi sad:**

1. Tapni **✨ Analysis** tab
2. Vidjet ćeš empty state s 3 suggestion chipa
3. Tapni **[Analyze my watchlist]**

**Što se dogodi:**
- Tvoja poruka "Analyze my watchlist" se pojavi u chatu (desno, ljubičastom bojom)
- App automatski dodaje tvoje watchlist coinove kao kontekst
- Claude počinje "razmišljati" — vidiš spinner i "Thinking..."
- Nakon 5-15 sekundi, Claude odgovara

### 7.3 Što si upravo dobio

Claudeov odgovor će izgledati otprilike ovako (skraćeno):

> **Bitcoin (BTC)** trenutno u konsolidaciji na $67k. Volume od $28B uz 24h change +2.45% je zdrava aktivnost bez manipulacije...
>
> **Solana (SOL)** pokazuje najsnažniji momentum — 24h +5.33%. Rank #5 s aktivnim DeFi ekosistemom...
>
> **PepeRocket (PEPR)** — 1h +12.4%, 24h +45%. Rank #523 ispod radara. Volume $1.2M odgovara aktivnosti na malom coinu. Ime i branding su meme-coin, što nosi rizik kratkotrajnog pumpa.
>
> **INTERESTING**
>
> PEPR ima profil ranog momentum pokreta, ali meme priroda povećava rizik. Razmisli o ulazu samo s malim iznosom.
>
> Sljedeći korak: provjeri 1h trend za 30 minuta. Ako ostane >+5%, entry je razuman.

### 7.4 Što primjećuješ

1. Claude je analizirao **sve** coinove iz tvog watchlista — ne samo jedan
2. Pri kraju je **odabrao jednog** (PEPR) za koji je dao **INTERESTING** oznaku
3. Tekst **INTERESTING** je **bold** (`**INTERESTING**`) — to je način kako app detektira preporuku
4. Ispod analize, u app-u će se pojaviti **Trade Action Bar** ako:
   - Imaš Binance postavljen
   - Nisi uključio auto-trade
   - Imaš barem jedan coin u watchlistu

---

## 8. Kako čitati Claudeov odgovor

### 8.1 Tri moguće preporuke

Claude uvijek završava jednom od tri oznake:

| Oznaka | Značenje | Što učiniti |
|--------|----------|-------------|
| **WATCH** | Ima potencijal, trebaš više podataka ili potvrde | Stavi u watchlist, provjeri opet za 1-2 sata |
| **SKIP** | Previše rizičan, nejasan profil, pump gotov | Ne diraj, makni iz watchlista |
| **INTERESTING** | Solid profil, razmatraj ulaz s malim iznosom | Možeš kupiti (ako želiš) |

### 8.2 Što još Claude uvijek dodaje

Nakon oznake:
- **1-2 rečenice razloga** — zašto baš ta oznaka
- **Konkretan sljedeći korak** — npr. "Provjeri opet za 2 sata", "Pogledaj Twitter aktivnost", "Volume trend kroz sljedeći sat je ključan"

Ako vidiš samo oznaku bez razloga, ili razlog bez oznake — Claude je imao lošu sesiju, pitaj ga ponovno.

### 8.3 Tri "objektiva" u kojima analizira

Claude (po svom system promptu) uvijek pokriva:

1. **Profil listinga**:
   - Je li volume organski (postepen rast) ili sumnjiv (nagli skok)?
   - Volume / market cap omjer (visok omjer = aktivan coin ali i moguća manipulacija)
   - Na kojim exchangeima je listiran (Binance/Coinbase = tier 1, DEX-only = žuti signal)
   - Market cap rank (>500 = ispod institucionalnog radara)

2. **Risk profil**:
   - Pump-and-dump znakovi (nagli volume spike, +500% u 24h)
   - 1h / 24h konzistentnost (24h rast + 1h pad = pump završio, loše)
   - Volume/price divergencija (volume pada a cijena raste = bearish divergence)

3. **Preporuka**:
   - WATCH / SKIP / INTERESTING
   - Obrazloženje
   - Sljedeći korak

### 8.4 Što Claude NIJE

- **Nije proročanstvo.** Ako kaže INTERESTING, to znači "vrijedi razmotriti", ne "garantirano raste"
- **Nije financijski savjetnik.** Završava s napomenom "analiza obrazaca, ne financijski savjet"
- **Nema live podatke u stvarnom vremenu.** Analizira ono što app pošalje (snapshot u tom trenutku)
- **Ne zna vijesti.** Ako je neki coin pumpan jer je Elon Musk tweetnuo, Claude to ne zna

### 8.5 Koliko vjerovati

Iz iskustva, u momentum tradingu:
- INTERESTING preporuke pogode **~60-70%** vremena
- Znači da **30-40%** vremena kupiš nešto što padne

Zato je **risk management** (sekcija 11) tako važan.

---

## 9. Tvoj prvi trade

### 9.1 Preduvjeti

Provjeri:
- ✅ Imaš Binance API ključ postavljen
- ✅ Imaš USDT na Binance Spot wallet-u (minimum $10-20)
- ✅ **Auto-trade je OFF** u Settings → Risk Parameters (za prvi trade manual je bolji)
- ✅ Claude je upravo dao **INTERESTING** signal u Analysis tabu

### 9.2 Provjeri Risk Parametere

▶ **Napravi sad prije prvog trade-a:**

1. Tapni ⚙ **Settings** → **Risk Parameters** sekcija
2. Postavi **konzervativno**:
   - **Max trade amount**: `5` (ne default 10 — za prvi trade još manje)
   - **Max open positions**: `1`
   - **Stop-loss**: `10%` (klizač na 10)
   - **Take-profit**: `25%` (klizač na 25)
   - **Auto-trade**: **OFF**
   - **Quiet hours**: 23:00 – 07:00 (default)

Zašto ovo: s $5 po trade-u i 10% SL-om **maksimalno možeš izgubiti $0.50 na prvom trade-u**. Čak i ako stvari krenu jako loše, "cijena učenja" je minimalna.

### 9.3 Trade Action Bar

Vrati se na **✨ Analysis** tab. Ispod Claudeove INTERESTING poruke vidiš:

```
┌─────────────────────────────────────────┐
│ 🚨 INTERESTING signal — PEPR/USDT    ✕  │
│                                         │
│ Uloži: [5.00]  USDT   SL -10%|TP +25%   │
│                                         │
│ [  BUY NOW  ] [ SKIP ] [ TELEGRAM ]     │
└─────────────────────────────────────────┘
```

**Detalji:**
- **Coin koji targetiraš**: prvi coin iz My Watchlist-a (u našem primjeru PEPR)
- **Uloži iznos**: preuzeto iz tvojih Risk Parametera ($5). Možeš ovdje editirati za ovaj trade (ne mijenja default)
- **SL/TP**: preuzeto iz Risk Parametera, samo info

### 9.4 Tap BUY NOW

▶ **Napravi sad:**

Tapni **BUY NOW**. Otvara se confirmation dialog:

```
┌──────────────────────────────────────┐
│ Potvrdi kupnju PEPR                  │
├──────────────────────────────────────┤
│ Cijena: $0.000423                    │
│ Iznos: $5.00                         │
│ Qty: ~11820.33                       │
│                                      │
│ SL: $0.000381                        │ ← crveno
│ TP: $0.000529                        │ ← zeleno
│                                      │
│ Market order — izvršava se po         │
│ trenutnoj cijeni.                    │
├──────────────────────────────────────┤
│   [Cancel]     [CONFIRM BUY]         │
└──────────────────────────────────────┘
```

**Što dialog pokazuje:**
- Cijena u tom momentu
- Iznos koji ćeš uložiti ($5)
- **Procjenjen broj tokena** (5 / 0.000423 ≈ 11820). Stvarni broj može malo varirati zbog slippage-a
- SL i TP cijene (računate iz tvojih parametara)

### 9.5 CONFIRM BUY

Tapni **CONFIRM BUY**.

**Što se dogodi (iza scene):**
1. App šalje **market buy order** na Binance s `quoteOrderQty=5` (kupi za $5 USDT-a)
2. Binance izvršava order (milisekunde)
3. App sprema **CoinPosition** u lokalnu bazu s podacima iz odgovora (stvarna cijena, stvarni qty)
4. App logira u **AnalysisLog** s oznakom `ENTERED`
5. **SnackBar** se pojavljuje dolje: "Bought 11820.334 PEPR @ $0.000423"

### 9.6 Provjeri Portfolio

▶ **Napravi sad:**

Tapni **💼 Portfolio** tab.

Vidjet ćeš:

```
┌──────────────────────────────────┐
│ 💼 Portfolio              🔄     │
│ USDT Balance:       $195.00      │ ← smanjen za $5
│ Open Positions:     1            │
│ Total P&L:          $0.00 (0%)   │ ← tek kupio
├──────────────────────────────────┤
│ PEPR/USDT              [CLOSE]   │
│ Entry: $0.000423 → Now: $0.000423│
│ Qty: 11820.33 | Invested: $5.00  │
│ P&L: +$0.00 (0.00%)              │
│ SL: $0.000381 | TP: $0.000529    │
└──────────────────────────────────┘
```

**Čestitam, kupio si svoj prvi coin kroz CoinSight.** 🎉

### 9.7 Što se sada događa

Tvoja pozicija se **automatski prati** u pozadini:

1. **Svakih 30 sekundi** (dok si na Portfolio tabu) — Now cijena i P&L se osvježavaju
2. **Svakih 5 minuta** (bez obzira na koji si tab) — app provjerava SL/TP:
   - Ako cijena padne na $0.000381 ili ispod → **app prodaje poziciju** (SL trigger)
   - Ako cijena naraste na $0.000529 ili iznad → **app prodaje poziciju** (TP trigger)

### 9.8 Ručno zatvaranje

Ako želiš prodati **ručno** (ne čekati SL/TP):

1. Portfolio tab → pozicija koju želiš zatvoriti → tapni **CLOSE**
2. Dialog:
   ```
   Zatvori poziciju?
   Prodaješ 11820.33 PEPR po tržišnoj cijeni.
   ```
3. **Confirm** → app prodaje → pozicija nestaje iz liste, USDT balance se povećava za prodajni iznos

---

## 10. Praćenje pozicija i stop-loss

### 10.1 Kako prati cijene

Dok je **Portfolio tab otvoren**, cijene pozicija se osvježavaju **svakih 30 sekundi**.

Čim odeš na drugi tab, auto-refresh staje (štedi bateriju). Pozicija se i dalje prati za SL/TP, ali samo svakih 5 minuta.

### 10.2 Kako vidiš P&L

U headeru Portfolio taba:
- **Total P&L**: zbroj **svih** pozicija. Ako imaš 3 pozicije, jednu +$2 i dvije -$1, Total = $0
- **Zeleno** = u plusu, **crveno** = u minusu

Na svakoj kartici:
- **P&L apsolutno**: koliko USDT zarade/gubitka (npr. +$1.23)
- **P&L postotno**: u odnosu na uloženo (npr. +11.82%)

### 10.3 Kada se pokreće stop-loss

**Automatski** svakih 5 minuta. Provjera ide:
1. Za svaku otvorenu poziciju
2. Dohvaća **trenutnu cijenu** s Binance-a
3. Uspoređuje s SL cijenom (entryPrice × (1 − SL%/100)) i TP cijenom
4. Ako cijena ≤ SL ili ≥ TP → **market sell**

### 10.4 Što ako cijena padne naglo

Primjer: kupio si PEPR po $0.000423, SL na 10% → $0.000381.

**Scenario A — Sporo opadanje:** Cijena polako pada. Timer u 10:00 vidi $0.000395, u 10:05 vidi $0.000380. SL triggera, sell po ~$0.000379 (malo slippage-a).
- Stvarni gubitak: ~10.5% umjesto 10%

**Scenario B — Flash crash:** Cijena u 10:03 pada s $0.000390 na $0.000300 u 10 sekundi. Timer u 10:05 vidi $0.000310. SL se okida ALI sell ide po trenutnoj cijeni $0.000308.
- Stvarni gubitak: ~27% umjesto 10%

**Zaključak:** SL je "safety net" koji se **povremeno ne aktivira idealno**. Zato:
- Ne investiraj više nego što si spreman izgubiti
- Za volatilne coinove razmisli o većem SL-u (15-20%) da se ne okine previše često na normalnoj buci

### 10.5 Take-profit isto funkcionira

Obrnuto od SL-a: ako cijena raste i dosegne TP granicu, app prodaje i zaključa profit. Isti timer, isti 5-minutni interval.

**Pažnja:** ako coin naraste 50% u trenutku i padne nazad na 25% prije sljedećeg tick-a, TP (na 25%) se neće triggerati zapravo — jer timer je vidio 25% u već-padu, a ne vrh od 50%.

---

## 11. Risk management

### 11.1 Zlatna pravila za početnika

1. **Prva 2 tjedna: testnet ILI pravi novac ali max $5 po tradeu.** Naučiš se na mali iznos.
2. **Nikad ne kupuj više nego što si spreman izgubiti NA ZAKAŽDNJI DAN.** Ako ti nestanak $100 uzrokuje stres, CoinSight nije za tebe s tim iznosom.
3. **Ne povećavaj iznos nakon gubitka.** "Chase the loss" je najbrži put do nule. Ako si izgubio 5 trejdova zaredom, **smanji** iznos ili stani.
4. **Ne vjeruj svakom INTERESTING signalu.** 30-40% će biti gubitnici. To je normalno.

### 11.2 Preporuke za Risk Parameters

**Faza 1 — Prvi tjedan (testnet ili pravi s malim iznosima):**
```
Max trade amount:    5 USDT
Max open positions:  1
Stop-loss:           10-15%
Take-profit:         25-30%
Auto-trade:          OFF
Quiet hours:         23:00 - 07:00
```

**Faza 2 — Nakon 2 tjedna ako si profitabilan:**
```
Max trade amount:    10 USDT
Max open positions:  2-3
Stop-loss:           15%
Take-profit:         30%
Auto-trade:          OFF još uvijek
```

**Faza 3 — Nakon mjesec dana s pozitivnim rezultatima:**
```
Max trade amount:    15-25 USDT
Max open positions:  3-5
Stop-loss:           15-20%
Take-profit:         30-40%
Auto-trade:          ON (ali pazi)
```

### 11.3 Diverzifikacija

**Ne drži sve u jednom coinu.** Ako imaš $100 USDT i sve staviš u jedan small-cap koji padne 50%, izgubio si $50.

S `maxOpenPositions = 3`:
- 3 × $10 = $30 izloženosti
- Čak i ako **svi** padnu na SL (-15%), gubiš $4.50
- Ako 2 padne na SL i 1 pogodi TP (+30%), dobit je $3 - $3 = $0 (break-even)

### 11.4 Quiet hours — zašto postoji

Noć je vrijeme kad:
- Volumen je najmanji (manje ljudi trguje)
- Scam-coinovi često rade pump-and-dump u 2-4h po Pacific vremenu (10-12h po našem)
- Ti spavaš i ne možeš intervenirati

Quiet hours (default 23-7) blokira **automatske kupnje**. Ako si **ručno** u 03:00 još budan i pokušavaš BUY NOW, radi normalno — blokada je samo za auto mode.

---

## 12. Automatsko trgovanje (Faza 3)

### 12.1 Što je Faza 3

**Faza 2** (manual): kad Claude kaže INTERESTING, vidiš Trade Action Bar i **ti odlučuješ** BUY NOW / SKIP.

**Faza 3** (auto): kad Claude kaže INTERESTING, app **sama kupuje** bez tvoje potvrde.

### 12.2 Uvjeti koje mora ispuniti prije auto-buy

App neće automatski kupovati ako:
- Auto-trade je **OFF** u Settings
- Trenutno su **quiet hours**
- Binance nije konfiguriran
- Već imaš `maxOpenPositions` otvorenih
- Već imaš taj isti coin

Ako **sve** prolazi → auto-kupnja.

### 12.3 Kada Fazu 3 uključiti

**Preporuka:** **tek nakon** 2-4 tjedna ručnog korištenja (Faza 2) kad:
- Razumiješ **stvarno** što Claude signali znače
- Imaš pozitivan P&L kroz tjedan
- Vjeruješ svojoj kalibraciji Risk Parametera

**Zašto ne ranije:**
- Ako Claude ima loš dan i da 5 INTERESTING signala zaredom, auto-mode će **svih 5** kupiti (do maxOpenPositions)
- Ako se cijene okrenu, svih 5 na SL → mogući gubitak 15% × 5 × iznos = bolna lekcija

### 12.4 Kako uključiti

1. Settings → Risk Parameters → **Auto-trade toggle ON**
2. Warning se prikaže: "Bot će automatski kupovati bez tvoje potvrde..."
3. **Provjeri** da su parametri konzervativni (max $10-15 po tradeu, max 2 pozicije)
4. Napusti ekran — radi u pozadini

### 12.5 Kako isključiti u panici

Ako vidiš da auto-mode radi glupe stvari:
1. Settings → Auto-trade **OFF**
2. ILI preko Telegrama: `/stop`
3. Ručno zatvori otvorene pozicije u Portfolio tabu

---

## 13. Telegram bot

### 13.1 Što dobiva

Ako konfiguriraš Telegram:
- Dobijaš **poruke o trejdovima** (kad ide kupnja ili prodaja)
- Možeš **slati komande** bota s daljine

### 13.2 Kako koristiti

U chatu sa svojim botom:
- `/status` → bot vraća broj otvorenih pozicija + ukupno uloženo
- `/stop` → isključuje auto-trade
- `/start_auto` → uključuje auto-trade

### 13.3 Kad TELEGRAM button koristiti u Analysis tabu

Kad Claude da INTERESTING i ne želiš **odmah** kupiti:
- Tapneš **TELEGRAM** (umjesto BUY NOW)
- Bot ti šalje formatiran signal sam sebi u chat
- Kasnije, kad odlučiš, otvaraš CoinSight i ručno kupiš

### 13.4 Ograničenje

**Bot radi samo dok je CoinSight app otvoren** (u foregroundu ili pozadini). Kad zatvoriš app, polling staje.

---

## 14. Tipični scenariji

### 14.1 Scenarij A — Jutarnja seansa (15 minuta)

**08:30** — kava, otvaraš CoinSight.

1. ⭐ Watchlist → New Listings — pregled jutrošnjih movers-a
2. Vidiš 3 zanimljiva (1H +10%+) → tapneš zvjezdicu na sva 3
3. ✨ Analysis tab → tapneš "Analyze my watchlist"
4. Claude analizira sva 3 + BTC/ETH/SOL referencu
5. Claude proglašava jednog **INTERESTING**, druge **WATCH** ili **SKIP**
6. Trade Action Bar → BUY NOW → CONFIRM → pozicija otvorena
7. 💼 Portfolio → vidiš novu poziciju, Now cijena, P&L u realnom vremenu
8. Zatvaraš app, ideš na posao

### 14.2 Scenarij B — Pada cijena, SL triggera

**14:00** — radiš posao. App je u pozadini.

- Jutrošnja pozicija PEPR s entry $0.000423, SL $0.000381
- U 13:47 cijena pada na $0.000378 → timer u 13:50 provjeri → SL triggera → market sell
- Ako Telegram konfiguriran → dobijaš poruku "🛑 Pozicija zatvorena — P&L: -$0.52"
- Ako nije → vidiš to kad sljedeći put otvoriš app

### 14.3 Scenarij C — Take-profit pogodak

- Drugi dan, nova pozicija po $0.001, TP na $0.00130 (+30%)
- Coin naraste na $0.00135 u 18:22 → timer provjeri u 18:25 → TP triggera → sell po ~$0.00133
- +$0.63 na $5 početni ulog (12.6% net)
- Portfolio total P&L se ažurira, USDT balance raste

### 14.4 Scenarij D — Tjedan kasnije, pregled

**Nedjelja večer** — pregled tjedna.

1. 💼 Portfolio tab → **Analysis History** sekcija (dolje)
2. Brojiš zapise:
   - 18 INTERESTING signala
   - Od toga 12 ENTERED (ušao)
   - Od toga 7 EXITED s profitom (TP ili manual close u plus)
   - 5 EXITED na SL
3. **Hit rate: 7/12 = 58%**. Net rezultat: +$4.30 za tjedan
4. Koristiš to za kalibraciju — sljedeći tjedan prilagođavaš strategiju

---

## 15. Problemi i rješenja

### 15.1 Claude ne odgovara

**"Invalid API key"** → Settings → Anthropic → Remove → novi ključ s console.anthropic.com

**"Rate limit exceeded"** → Pričekaj minutu, pa ponovi. Ne spamati.

**"credit balance too low"** → Na console.anthropic.com dodaj kredit (par dolara dovoljno).

**"Failed to get response. Check your connection."** → Provjeri internet. Pokušaj na WiFi-u ako si bio na mobilnim.

### 15.2 Binance greške

**"Invalid API-key, IP, or permissions"** → IP restrikcija uključena a IP se ne poklapa. Binance API Management → Edit Restrictions → dodaj IP ili isključi IP restriction.

**"Timestamp out of sync"** → Tvoj sat drifta. Windows: Settings → Time → Sync now. Android: automatski time postavi.

**"Insufficient USDT balance"** → Nemaš dovoljno USDT-a na **Spot wallet**-u. Možda ti je USDT u Funding ili Futures. Na Binanceu: Wallet → Transfer → prebaci u Spot.

**"Max open positions reached"** → Zatvori neku poziciju prije kupnje nove.

**"Filter failure: LOT_SIZE"** → Rijedak bug s nekim specifičnim coinovima. Poznato, fix u sljedećoj verziji. Pokušaj drugi coin.

### 15.3 Portfolio

**Balance $0.00 ali imam USDT** → USDT vjerojatno nije u **Spot wallet-u**. Binance: Wallet → prebaci u Spot.

**Pozicija se ne pojavljuje** → Pull-to-refresh na Portfolio tabu. Ako i dalje ne → provjeri Binance web direktno jesi li stvarno kupio.

**Current Price zastario** → 30s auto-refresh radi samo dok si na tabu. Vrati se na Portfolio → pull-to-refresh.

### 15.4 Telegram

**Test: "Failed to send"** → Provjeri token (kod BotFather-a `/mybots`). Ili Chat ID nije tvoj.

**Bot šuti na moje komande** → App je zatvoren. Otvori ga. Ili nisi pravi Chat ID spremio.

### 15.5 App se zaglavi

Force close → ponovno otvori. Flutter app-e često samo treba restart.

---

## 16. Sigurnost

### 16.1 API ključevi su tajni

- **Nikad** ne dijeli Anthropic, Binance, ili Telegram ključ s nikim
- **Nikad** ne pastaj ih u Discord, Reddit, Twitter ni uz najbolje namjere
- **Nikad** ne vjeruj "Binance support agentu" koji tebe pita za ključeve — **to je scam 100%**

### 16.2 Binance ključ MORA imati isključen Withdrawal

Ponavljam jer je kritično: ako zaboraviš isključiti Withdrawal i netko ukrade ključ → izvuku ti novac. Ako je Withdrawal OFF, u najgorem slučaju mogu ti izgubiti novac kroz loše tradeove — ali ne mogu ga izvući.

### 16.3 Device security

Tvoj telefon/PC = tvoj sef.
- **PIN / lozinka / biometrija**: obavezno
- Ne ostavljaj uređaj nezaključan
- Ako izgubiš uređaj: hitno → Binance web → API Management → delete sve ključeve. Anthropic console → revoke keys. Telegram → BotFather → `/revoke`.

### 16.4 Backup

CoinSight čuva sve lokalno (u svojoj bazi). Ako resetiraš telefon, gubiš:
- Spremljene API ključeve (generiraš nove)
- Watchlist izbor
- Analysis history
- Tvoju snimku pozicija (ali **pozicije ostaju na Binanceu** — vidiš ih kroz Binance web direktno)

Preporuka: u sigurnu bilješku (password manager, Bitwarden/1Password/KeePass) zapiši:
- Anthropic API key
- Binance API key + Secret
- Telegram Bot Token + Chat ID
- Tvoje Risk Parameters

---

## 17. Često postavljana pitanja

**Q: Moram li imati Binance account?**
A: Za Watchlist + Claude chat — ne. Za stvarno trgovanje — da. Binance je jedini podržani exchange.

**Q: Mogu li koristiti Kraken / Coinbase / Revolut?**
A: Trenutno ne. CoinSight je napravljen specifično za Binance Spot.

**Q: Koliko košta mjesečno?**
A: Anthropic AI: $5-30 (ovisno o aktivnosti). Binance fee: 0.1% po tradeu (za $100 trade = $0.10). CoinSight app: besplatno.

**Q: Mogu li izgubiti sav novac?**
A: Da, teoretski. Ako svi trejdovi završe na SL-u i nastaviš, možeš doći na nulu. **Zato postavljaj konzervativne parametre i ne ulaži više nego možeš izgubiti.**

**Q: Je li CoinSight "get rich quick" shema?**
A: Ne. Ovo je alat za discipliniran, sistematičan pristup momentum tradingu. Može biti profitabilan ako si **strpljiv** i **disciplinovan** s risk managementom.

**Q: Što ako Claude daje uzastopne loše signale?**
A: Pauziraj trgovanje, analiziraj CHATLOG.md (tu ti bilježiš ishod). Možda market uvjeti nisu za momentum. Vrati se za dan-dva.

**Q: Kako isplatiti profite na Revolut?**
A: Na Binanceu: Spot → Convert USDT u EUR → Withdraw SEPA na svoj Revolut IBAN. Traje 1-2 radna dana. CoinSight **ne** radi withdrawal.

**Q: Mogu li koristiti VPN s Binanceom?**
A: Binance tehnički dozvoljava ali preporučuje da ne. Ako uključiš IP restrictions na ključu, VPN + IP restrictions = konflikt.

**Q: Što ako Binance banuje moj račun?**
A: CoinSight nije odgovoran. Prati Binance TOS. API ključ bez withdrawal permission je manje rizičan za ban.

**Q: Mogu li CoinSight dijeliti s prijateljem?**
A: Ne. Software je proprietary (vidi LICENSE). Tvoj osobni APK, bez prosljeđivanja.

**Q: Što ako ne razumijem Claudeov odgovor?**
A: Pitaj Claudea dalje. "Objasni detaljnije." Ili "Na hrvatskom molim." Claude prilagođava jezik i detalj.

**Q: Zašto nema detail view za coin (tap na karticu)?**
A: Trenutno nema. Planirano za sljedeću verziju.

---

## 18. Rječnik pojmova

| Pojam | Značenje |
|-------|----------|
| **API ključ** | Kod koji app koristi da komunicira sa servisom (Binance/Claude/Telegram) u tvoje ime |
| **Auto-trade** | Faza 3 — app automatski izvršava INTERESTING signale bez tvoje potvrde |
| **BUY NOW** | Button u Trade Action Baru koji pokreće kupnju nakon potvrde |
| **Chat ID** | Tvoj jedinstveni Telegram ID broj (ne username) |
| **CoinGecko** | Besplatan crypto market data servis. CoinSight ga koristi za Watchlist podatke |
| **Confirm LIVE** | Warning dialog kad prebacuješ s testnet-a na pravi Binance |
| **ENTERED** | Oznaka u Analysis History za trenutak kad si otvorio poziciju |
| **EXITED** | Oznaka u Analysis History za trenutak kad si zatvorio poziciju |
| **Faza 2** | Manualni mode — ti potvrđuješ BUY kroz Trade Action Bar |
| **Faza 3** | Automatski mode — app sama kupuje na INTERESTING |
| **Hive** | Lokalna baza podataka unutar app-e (čuva ključeve, watchlist, pozicije) |
| **INTERESTING** | Claude preporuka "razmatraj ulaz s malim iznosom" |
| **KYC** | "Know Your Customer" — Binance verifikacija identiteta (osobna + selfie) |
| **Market cap** | Ukupna vrijednost svih coinova u opticaju u USD |
| **Market order** | Kupnja/prodaja **po trenutnoj tržišnoj cijeni** (ne limit) |
| **My Watchlist** | Tvoj izbor coinova (označeni zvjezdicom) |
| **New Listings** | Prvi pod-tab, small-cap coinovi s 1h momentum-om |
| **P&L** | "Profit and Loss" — koliko si trenutno u plusu/minusu |
| **Quiet hours** | Sati kad auto-trade NE kupuje (default 23:00-07:00) |
| **Rank** | Market cap rank — pozicija po veličini među svim coinovima |
| **Risk Parameters** | Tvoje postavke u Settings: max iznos, max pozicije, SL%, TP% |
| **SKIP** | Claude preporuka "previše rizično, ne diraj" |
| **Slippage** | Razlika između očekivane i stvarne cijene pri tradu (tipično <1% kod većih coinova) |
| **Sparkline** | Mini 7-dnevni grafikon u CoinCard-u |
| **Spot** | Direktno trgovanje coinom (kupuješ, imaš ga, prodaš). Za razliku od Futures |
| **Stop-loss (SL)** | Donja granica cijene kod koje app prodaje (zaustavi gubitak) |
| **Suggestion chip** | Preddefinirano pitanje u Analysis tabu (tapneš, pošalje umjesto tebe) |
| **Take-profit (TP)** | Gornja granica cijene kod koje app prodaje (zaključa profit) |
| **Testnet** | Binance simulator s lažnim novcem (testnet.binance.vision) |
| **Tier-1 exchange** | Veliki, regulirani exchange (Binance, Coinbase, Kraken) |
| **Top Coins** | Treći pod-tab Watchlist-a, top 25 coinova po market capu |
| **Trade Action Bar** | Zeleni okvir u Analysis tabu koji se pojavljuje kod INTERESTING signala |
| **USDT** | Tether — stablecoin (1 USDT ≈ $1). Koristi se kao "keš" u Binance Spot tradingu |
| **Volume** | 24h trading volumen u USD-u |
| **WATCH** | Claude preporuka "ima potencijal, provjeri opet kasnije" |
| **Withdrawal** | Povlačenje novca s Binance-a (CoinSight NE koristi; API ključ NE smije imati) |

---

## Kraj priručnika

**Sažetak ključnih poruka:**

1. **Instaliraj app** → otvori → Settings → postavi 3 ključa (Anthropic + Binance + Telegram)
2. **Watchlist tab** → pregledaj coinove, označi zvjezdicom
3. **Analysis tab** → pitaj Claudea, dobij INTERESTING/WATCH/SKIP
4. **Trade Action Bar** → BUY NOW za kupnju jednim tapom
5. **Portfolio tab** → prati pozicije, SL/TP rade automatski
6. **Settings Risk Parameters** → kreni konzervativno ($5, 1 pozicija, 10% SL)

**Ako si ovo pročitao sve:** spreman si za prvi dan. Kreni s malim iznosima, bilježi rezultate, i **ne žuri povećavati riziki**. Konzistentnost kroz tjedne pobjeđuje naglu agresivnost.

Sretno! 🚀

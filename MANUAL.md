# CoinSight — Korisnicki Priručnik

**Za koga je ovaj priručnik:** netko tko prvi put otvara CoinSight. Ne pretpostavljamo da znaš što je market cap, što je Spot trading, niti kako funkcionira API ključ. Sve se objašnjava u hodu.

**Verzija aplikacije:** 7.0.0
**Licenca:** MIT (open source)
**Platforma:** Android (primarno) + Windows desktop
**Datum priručnika:** 2026-04-16

---

## Kako čitati ovaj priručnik

- Prodi **redom od 1 do 10**. Svaka sekcija se nadovezuje na prethodnu.
- Sekcije **11 nadalje** (Telegram Monitor, scenariji, troubleshooting) čitaj po potrebi.
- Gdje god vidiš ▶ **to napravi sad** — to je korak koji bi trebao izvršiti dok čitaš.
- Ako nešto ne razumiješ, potraži pojam u **Rječniku** na kraju (sekcija 18).

---

## Sadržaj

1. [Što je CoinSight i koji je cilj](#1-što-je-coinsight)
2. [Osnovne crypto pojmove koje trebaš razumjeti](#2-osnovne-crypto-pojmove)
3. [Što ti treba prije nego kreneš](#3-što-ti-treba-prije-nego-kreneš)
3A. [Three-Tier Investment Framework (v4.0.0)](#3a-three-tier-investment-framework)
3B. [MidProjectDetailScreen (v5.0.0)](#3b-midprojectdetailscreen)
3C. [LongHoldingDetailScreen (v5.0.0)](#3c-longholdingdetailscreen)
3D. [DEX Position Tracking (v5.0.0)](#3d-dex-position-tracking)
3E. [Charts & Visualization (v6.0.0)](#3e-charts--visualization)
3F. [Push Notifications (v6.0.0)](#3f-push-notifications)
3G. [P&L Dashboard (v7.0.0)](#3g-pl-dashboard)
3H. [WalletConnect v2 (v7.0.0)](#3h-walletconnect-v2)
3I. [Trade History (v7.0.0)](#3i-trade-history)
4. [Prvo pokretanje aplikacije — što ćeš vidjeti](#4-prvo-pokretanje-aplikacije)
5. [Turneja po aplikaciji — 4 taba + DEX Early](#5-turneja-po-aplikaciji)
6. [Postavljanje API ključeva — korak po korak](#6-postavljanje-api-ključeva)
7. [Tvoja prva analiza — tutorijal](#7-tvoja-prva-analiza)
8. [Kako čitati Claudeov odgovor](#8-kako-čitati-claudeov-odgovor)
9. [Tvoj prvi trade — tutorijal](#9-tvoj-prvi-trade)
10. [Praćenje pozicija i stop-loss](#10-praćenje-pozicija-i-stop-loss)
11. [Risk management — koliko riskirati](#11-risk-management)
12. [Automatsko trgovanje (Faza 3)](#12-automatsko-trgovanje-faza-3)
13. [Telegram Monitor — pasivno obavještajno prikupljanje](#13-telegram-monitor)
13A. [Intelligence Layer — multi-source obavještajni sustav](#13a-intelligence-layer)
14. [Bot Manager — upravljanje kanalima](#14-bot-manager)
15. [Tipični scenariji — što se dogadja tijekom dana](#15-tipični-scenariji)
16. [Problemi i rješenja](#16-problemi-i-rješenja)
17. [Sigurnost — što moraš znati](#17-sigurnost)
18. [Često postavljana pitanja](#18-često-postavljana-pitanja)
19. [Rječnik pojmova](#19-rječnik-pojmova)

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
5. Pregledava Telegram kanale — čita li netko o tome
6. Prebacuje se u Binance, traži coin
7. Ručno računa koliko kupiti
8. Klika Buy, potvrduje
9. Prebacuje se u neku app za praćenje P&L-a

Traje 10-15 minuta po coinu. **CoinSight sve to radi u jednoj app-i u ~60 sekundi.**

Verzija 3.0.0 dodala je **Intelligence Layer** — sustav koji prati DEX listinge, GitHub aktivnost, Reddit diskusije i Telegram kanale, te sve to objedinjuje u obavještajni izvještaj za Claude analizu.

Verzija 4.0.0 uvodi **Three-Tier Investment Framework** — umjesto jednog pristupa za sve, sada imas tri razlicita investicijska moda: **SHORT** (kratkorocni momentum, do 48h), **MID** (srednjorocni projekti, tjedni do mjeseci) i **LONG** (dugorocna fundamentalna ulaganja, mjeseci do godine). Svaki tier ima vlastite alate, analizu i portfolio prikaz.

Verzija 5.0.0 dodaje **detail screenove** za MID projekte i LONG holdinge, **DEX Position Tracking** za rucno pracenje trade-ova s decentraliziranih burzi, te **MID Discovery** (GitHub trending) i **LONG Research** (filtrirani top 200) pod-tabove u Watchlistu.

Verzija 6.0.0 dodaje **interaktivne tier-aware chartove** (SHORT 10d+24h, MID 6m+30d, LONG 2y+6m), **push notifikacije** (SL/TP/INTERESTING alerte), i znacajno prosiren test suite.

Verzija 7.0.0 dodaje **P&L Dashboard** s equity curve-om, win rate-om, R/R ratiom i per-tier breakdownom, **WalletConnect v2** za spajanje eksternog walleta i pokretanje swapova, te **Trade History** za kompletnu evidenciju zatvorenih trade-ova.

> Ako si potpuni pocetnik u crypto svijetu, pogledaj [NEWBIE_GUIDE.md](NEWBIE_GUIDE.md) za pojednostavljen uvod.

### 1.3 Što CoinSight NIJE

- **Nije magija.** Ne zna budućnost. Njegova AI procjena je korisna u ~60-70% slučajeva, ne 100%.
- **Nije za pasivno držanje bez strategije.** CoinSight podržava tri investicijska horizonta (SHORT/MID/LONG), ali svaki zahtijeva aktivno praćenje i disciplinu. LONG tier nije "kupi i zaboravi" — ukljucuje DCA kupnje i praćenje fundamentala.
- **Nije financijski savjet.** Ti odlučuješ, ti snosiš gubitke.
- **Nije vlasnik tvog novca.** Tvoj novac ostaje na Binanceu. CoinSight samo komunicira s Binance API-jem u tvoje ime.

### 1.4 Koji AI se koristi

**Claude** od Anthropica — jedan od najnaprednijih AI asistenata. CoinSight ga koristi kroz službeni Anthropic API. AI dobija podatke o coinu (cijena, volumen, trendovi) i vraća procjenu: **WATCH / SKIP / INTERESTING**.

U v3.0.0+, Claude automatski prima strukturirani Intelligence Report iz višestrukih izvora — DEX listinzi, GitHub aktivnost, Reddit diskusije, Telegram signali — te ih koristi za precizniju analizu. U v4.0.0, Claude dodatno prilagodava analizu ovisno o aktivnom tier-u (SHORT/MID/LONG) — svaki tier ima vlastite suggestion chipove i action bar akcije.

### 1.5 Open source

CoinSight je open source projekt pod **MIT licencom**. Možeš slobodno koristiti, modificirati i dijeliti kod. Izvorni kod je javno dostupan.

---

## 2. Osnovne crypto pojmove

Pojmovi koje moraš razumjeti prije korištenja app-a. Ako ti je sve poznato, preskoči na sekciju 3.

### 2.1 Coin / Token

Digitalna valuta (kripto) — Bitcoin, Ethereum, Dogecoin, ili neki od **tisuća** manjih. CoinSight targetira male ("micro-cap" i "small-cap"), a ne velike kao BTC ili ETH.

### 2.2 Market cap (tržišna kapitalizacija)

Koliko **ukupno vrijedi** taj coin u cijelom svijetu. Formula: `broj_coinova_u_opticaju x cijena`.

- **Large-cap** (>$10 milijardi): BTC, ETH, BNB — stabilni, spori rast
- **Mid-cap** ($500M-$10B): Solana, Avalanche, Polkadot
- **Small-cap** ($10M-$500M): srednje rizično, brži pokreti
- **Micro-cap** (<$10M): vrlo rizično, moguć 10x ili gubitak 90%

CoinSight lovi **small i micro cap** kod kojih je moguć 20-100% rast u satima.

### 2.3 Market cap rank (rang)

Pozicija coina po market capu. Bitcoin je #1. Ethereum je #2. CoinSight u New Listings tabu prikazuje coinove **s rankom iznad 500** (ili bez ranka) — oni su "ispod radara" većine investitora, što je uvjet za nagli momentum.

### 2.4 Volume (volumen)

Koliko se **tog coina trgovalo u zadnjih 24 sata** u USD-u. Primjer: ako piše volume $2M, to znači da su ljudi u zadnjih 24h kupili i prodali ukupno $2 milijuna vrijedno tog coina.

- **Premali volumen** (<$50k) = malo ljudi trguje = teško prodati kad zatreba = **slippage** (prodaš po goroj cijeni od očekivane)
- **Idealan za CoinSight** ($50k-$50M) = dovoljno aktivnosti da je realno, ne previsoko da bude već mainstream
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
- **Margin** — trgovanje posudjenim novcem (CoinSight **NE** podržava)

CoinSight = **isključivo Spot**.

### 2.8 Stop-loss i Take-profit

- **Stop-loss (SL)**: cijena na kojoj app **automatski prodaje** da ograniči gubitak. Ako kupiš po $100 i postaviš SL na 15%, app će prodati ako cijena padne na $85.
- **Take-profit (TP)**: cijena na kojoj app **automatski prodaje** da zaključa profit. Kupiš po $100, TP 30% = prodaje kad dosegne $130.

Oba su **sigurnosne mreže** — ne moraš buljiti u ekran cijeli dan.

### 2.9 Slippage

Razlika izmedju **cijene koju si vidio** i **cijene po kojoj si stvarno kupio/prodao**. Na small-cap coinovima s malim volume-om može biti značajan (1-5%).

### 2.10 API ključ

Sigurnosni "kod" koji aplikacija koristi da komunicira sa servisom (Binance, Claude) u tvoje ime. **Važno**: API ključ **nije tvoja lozinka**. Lozinka je za prijavu na web, API ključ je samo za automatizaciju.

Kod Binance API ključa postoje **permissionsi**:
- **Read**: samo gleda balans i cijene
- **Spot Trading**: kupuje i prodaje u tvoje ime (potrebno)
- **Withdrawal**: povlači novac s računa (NIKAD ne uključuj)

---

## 3. Što ti treba prije nego kreneš

### 3.1 Check-lista

Prije prvog korištenja:

| Stvar | Obavezno? | Gdje nabaviti |
|-------|-----------|---------------|
| Android telefon ili Windows PC | Obavezno | Tvoj uredjaj |
| Internet veza | Obavezno | — |
| **Anthropic API ključ** (za AI analizu) | Ako želiš AI | Kreiraš na console.anthropic.com (~10 min) |
| **Binance Spot account** (za kupovanje) | Za trading | binance.com, registracija + KYC (~30 min + čekanje verifikacije) |
| **Binance API ključ** (signira API pozive) | Za trading | Generiraš kad si ulogiran na Binance (~5 min) |
| **Telegram bot token** (za Telegram Monitor) | Opcionalno | @BotFather na Telegramu (~5 min) |
| **Novac na Binance Spot wallet** | Za stvarno trgovanje | Depozitiraj preko Binance (SEPA uplata iz banke) |

### 3.2 Koliko novca treba?

**Minimalno preporučeno:** $50-100 u USDT-ima na Binance Spot wallet-u.

Zašto toliko:
- CoinSight default kupuje $10 po tradeu
- S 3 istovremene pozicije = $30 angažiranog novca
- Ostatak je "rezerva" za idući signal

**Ne prelaziš** iznos koji si spreman **izgubiti** na prvi dan. Prvi dan je za učenje, ne zaradu.

### 3.3 Trošak korištenja

- **Anthropic AI**: cca **$0.003-0.01 po jednoj analizi** (ovisno o modelu). Mjesečno ~$5-20 ako svakodnevno analiziraš
- **Binance trading fee**: **0.1% po tradeu** (kupuješ $10, plaćaš $0.01 fee). Zanemarivo
- **CoinSight app**: besplatan, open source (MIT licenca)

Za mjesečni budžet: **$10-30** za AI + fee.

---

## 3A. Three-Tier Investment Framework (v4.0.0)

### 3A.1 Što su tier-ovi

Verzija 4.0.0 uvodi **tri investicijska tier-a** — tri potpuno razlicita nacina koristenja CoinSight-a, svaki s vlastitim alatima, analizom i portfolio prikazom:

| Tier | Horizont | Fokus | Tipicni coinovi |
|------|----------|-------|-----------------|
| **SHORT** | Sati do 48h | Momentum trading, brzi ulaz/izlaz | Micro-cap, meme coinovi, DEX listinzi |
| **MID** | Tjedni do mjeseci | Projekti s katalystom (launch, partnerstvo, upgrade) | Small-cap s jasnim roadmapom |
| **LONG** | Mjeseci do godine+ | Fundamentalna ulaganja, DCA kupnje | Etablirani alt-coinovi, L1/L2, DeFi blue chip |

### 3A.2 Kako prebaciti tier

Na vrhu app-e, odmah ispod AppBara, vidjet ces **TierModeSelector** banner s tri buttona:

```
+------------------------------------------+
|   [SHORT]    [MID]    [LONG]             |
+------------------------------------------+
```

- **SHORT** je default (isto ponasanje kao u v3.0.0)
- Tapni **MID** ili **LONG** za prebacivanje
- Aktivni tier je istaknut bojom (SHORT = primary ljubicasta, MID = teal, LONG = amber)
- Prebacivanje tier-a mijenja: suggestion chipove u Analysis tabu, akcije u Trade Action Baru, prikaz u Portfolio tabu

### 3A.3 SHORT tier (default)

Sve sto si dosad koristio u CoinSight-u. Brzi momentum, WATCH/SKIP/INTERESTING, Trade Action Bar s BUY NOW, SL/TP automatski. Nema promjena u odnosu na v3.0.0 za ovaj tier.

### 3A.4 MID tier — srednjorocni projekti

MID tier je za coinove koje ne kupujes na 2 sata, nego ih **pratis tjednima** s jasnim katalystom (npr. mainnet launch za 3 tjedna, partnerstvo, token unlock).

**Kako koristiti:**

1. Prebaci na **MID** tier u TierModeSelector-u
2. U **Analysis tabu**, suggestion chipovi se mijenjaju u MID-specificne:
   - "Procijeni MID-term potencijal"
   - "Kreiraj MID projekt za [coin]"
   - "Analiziraj katalyst timeline"
3. Kad Claude identificira MID-term priliku, pojavljuje se **MID Action Bar** (umjesto standardnog Trade Action Bara):
   - **CREATE PROJECT** — kreira MidTermProject zapis za taj coin
   - **SKIP** — preskoci
4. Kreirani projekti se vide u **Watchlist → Projekti** pod-tabu (novi pod-tab u v4.0.0)
5. U **Portfolio tabu**, MID sekcija prikazuje tvoje aktivne MID projekte s progress barom do katalysta

**MidTermProject** sadrzi: coin info, entry price, target price, katalyst opis, deadline, notes, status (ACTIVE/COMPLETED/ABANDONED).

### 3A.5 LONG tier — dugorocna fundamentalna ulaganja

LONG tier je za coinove u koje vjerujes dugorocno i kupujes ih postupno kroz **DCA (Dollar-Cost Averaging)** — redovite male kupnje neovisno o cijeni.

**Kako koristiti:**

1. Prebaci na **LONG** tier u TierModeSelector-u
2. U **Analysis tabu**, suggestion chipovi se mijenjaju u LONG-specificne:
   - "Fundamentalna analiza [coin]"
   - "Kreiraj LONG holding za [coin]"
   - "DCA strategija za [coin]"
3. Kad Claude potvrdi fundamentalnu snagu, pojavljuje se **LONG Action Bar**:
   - **CREATE HOLDING** — kreira LongTermHolding zapis
   - **DCA BUY** — izvrsava DCA kupnju za postojeci holding
   - **SKIP** — preskoci
4. U **Portfolio tabu**, LONG sekcija prikazuje tvoje holdinge s prosjecnom kupovnom cijenom, ukupnom kolicinom, i fundamentals summary

**LongTermHolding** sadrzi: coin info, DCA purchases lista (svaka s cijenom, kolicinom, datumom), prosjecna cijena, thesis (zasto drzis ovaj coin), fundamentals notes.

### 3A.6 Tier-ovi i analiza

Claude prilagodava analizu ovisno o aktivnom tier-u:

- **SHORT**: fokus na momentum, volume spike, pump-and-dump rizik, 1h/24h konzistentnost → WATCH/SKIP/INTERESTING
- **MID**: fokus na katalyst timeline, project legitimacy, community growth, token unlock schedule → CREATE PROJECT / SKIP
- **LONG**: fokus na fundamentals (team, tech, adoption, tokenomics), competitive positioning, makro trendovi → CREATE HOLDING / SKIP

---

## 3B. MidProjectDetailScreen (v5.0.0)

### 3B.1 Sto je MidProjectDetailScreen

MidProjectDetailScreen je **detaljan ekran za upravljanje pojedinacnim MID tier projektom**. Otvara se tapom na projekt iz Portfolio MID sekcije ili kreiranjem novog projekta iz Analysis MID action bara ili Discovery taba.

### 3B.2 Kako koristiti

**Kreiranje projekta:**
1. Prebaci na **MID** tier u TierModeSelector-u
2. U **Analysis tabu**, kad Claude identificira MID-term priliku, tapni **CREATE PROJECT** u MID Action Baru
3. Alternativno: u **Watchlist → MID Discovery** tabu pronadi coin i kreiraj projekt direktno

**Sto mozes raditi na detail screenu:**
- **Editiraj thesis** — upisi zasto pratis ovaj projekt, koji je tvoj investicijski teorem
- **Editiraj GitHub link** — dodaj link na GitHub repozitorij projekta za pracenje razvoja
- **Editiraj entry plan** — definisi plan ulaza (cijena, uvjeti, iznos)
- **Upravljaj statusom** — prebaci projekt izmedu statusa: ACTIVE / COMPLETED / ABANDONED
- **Dodaj biljeske** — zapisuj zapazanja, vijesti, katalyst update-ove

### 3B.3 Status lifecycle

| Status | Znacenje |
|--------|----------|
| **ACTIVE** | Projekt se aktivno prati, katalyst u tijeku |
| **COMPLETED** | Uspjesno zavrsen (profit ostvaren ili cilj postignut) |
| **ABANDONED** | Napusten (uvjeti se promijenili, projekt propao) |

---

## 3C. LongHoldingDetailScreen (v5.0.0)

### 3C.1 Sto je LongHoldingDetailScreen

LongHoldingDetailScreen je **detaljan ekran za upravljanje pojedinacnim LONG tier holdingom** s cetiri taba za organizirane informacije.

### 3C.2 Cetiri taba

| Tab | Sadrzaj |
|-----|---------|
| **Osnove** | Osnovne informacije o holdingu: coin info, thesis, prosjecna cijena, ukupna kolicina, ukupna investicija |
| **Fundamentali** | Pracenje fundamentala projekta: team, tehnologija, adoption, tokenomics, competitive positioning |
| **DCA** | Pregled i dodavanje DCA kupnji — svaka kupnja s cijenom, kolicinom i datumom. Prikaz prosjecne DCA cijene |
| **Biljeske** | Slobodne biljeske o holdingu — zapazanja, makro trendovi, rebalancing planovi |

### 3C.3 Kako dodati DCA kupnju

1. Otvori LongHoldingDetailScreen za zeljeni holding
2. Prebaci na **DCA** tab
3. Tapni **+ Dodaj DCA kupnju** button
4. Unesi **cijenu**, **kolicinu** i **datum** kupnje
5. Potvrdi — kupnja se sprema i prosjecna cijena se automatski preracunava

### 3C.4 Upravljanje fundamentalima

Na **Fundamentali** tabu mozes pratiti kljucne aspekte projekta:
- Team kvaliteta i track record
- Tehnoloska inovacija i roadmap progress
- Adoption metrke (korisnici, TVL, transakcije)
- Tokenomics (supply, distribucija, unlock schedule)

---

## 3D. DEX Position Tracking (v5.0.0)

### 3D.1 Sto je DEX Position Tracking

DEX Position Tracking omogucava **rucno pracenje trade-ova s decentraliziranih burzi** (Dexscreener). Buduci da CoinSight ne moze direktno izvrsavati trade-ove na DEX-ovima (za razliku od Binance Spot-a), korisnik rucno unosi podatke o trade-ovima.

### 3D.2 Kako koristiti

1. Izvrsi trade na DEX-u (Uniswap, PancakeSwap, Raydium, itd.) koristeci svoj wallet
2. U CoinSight-u, otvori **Portfolio → SHORT** sekciju → **DEX pozicije**
3. Tapni **+ Nova DEX pozicija**
4. Unesi podatke s Dexscreenera: token adresa/simbol, entry cijena, kolicina, DEX, chain
5. Postavi **SL (Stop-Loss)** i **TP (Take-Profit)** razine

### 3D.3 Automatski price refresh

- CoinSight automatski osvjezava cijenu DEX pozicija putem Dexscreener API-ja
- P&L se racuna u realnom vremenu na osnovu trenutne cijene

### 3D.4 SL/TP monitoring

- App prati SL i TP razine za DEX pozicije
- Kad cijena dosegne SL ili TP, **dobivas vizualno upozorenje** (app ne moze automatski prodati na DEX-u)
- Ti rucno zatvaras poziciju na DEX-u i oznacavas je kao zatvorenu u CoinSight-u

### 3D.5 Vazna razlika od Binance pozicija

| Binance Spot | DEX pozicije |
|-------------|-------------|
| App automatski kupuje/prodaje | Rucni unos trade-ova |
| SL/TP automatski izvrsava sell | SL/TP samo upozorava (vizualno) |
| Podaci iz Binance API-ja | Podaci iz Dexscreener-a + rucni unos |

---

## 3E. Charts & Visualization (v6.0.0)

### 3E.1 Sto su chartovi

CoinSight v6.0.0 dodaje **interaktivne price chartove** za svaki coin. Chartovi prikazuju historijske cijene i (opcionalno) AI-generirane predikcije.

### 3E.2 Kako otvoriti chart

Na bilo kojem **CoinCard-u** (Watchlist, DEX Early, Top Coins) tapni ikonu **chart** (ikona trenda). Alternativno, iz **Analysis screena** tapni ikonu charta u AppBaru nakon sto odaberes coin.

### 3E.3 Sto svaki tier prikazuje

| Tier | Duzi period | Kraci period |
|------|------------|-------------|
| **SHORT** | 10 dana | 24 sata |
| **MID** | 6 mjeseci | 30 dana |
| **LONG** | 2 godine | 6 mjeseci |

Chartovi se automatski prilagodavaju aktivnom tieru. Mozes prebaciti tier kroz TierModeSelector i chart ce se osvjeziti.

### 3E.4 Interakcija

- **Dodir i drzanje** na chartu prikazuje crosshair s tocnom cijenom i datumom
- **Pomicanje** po chartu mijenja tocku crosshair-a
- Predikcijska linija (ako postoji) prikazana je isprekidano

### 3E.5 Tocnost predikcije

**Vazno:** AI predikcije su **eksperimentalne** i sluze kao vizualna pomoc, ne kao financijski savjet. Historijska tocnost varira. Nikad ne donosite investicijske odluke iskljucivo na osnovu predikcije.

---

## 3F. Push Notifications (v6.0.0)

### 3F.1 Sto su push notifikacije

CoinSight v6.0.0 integrira `flutter_local_notifications` za slanje lokalnih push obavijesti cak i kad app nije u prvom planu.

### 3F.2 Tipovi notifikacija

| Tip | Opis |
|-----|------|
| **SL alert** | Pozicija je dostigla stop-loss razinu — potrebna akcija |
| **TP alert** | Pozicija je dostigla take-profit razinu — razmotri prodaju |
| **INTERESTING signal** | Claude je oznacio coin kao INTERESTING — nova prilika |

### 3F.3 Kako konfigurirati

1. Otvori **Manage** tab (ikona tune)
2. Idi na **Trade** pod-tab
3. Toggle za svaki tip notifikacije (SL/TP/INTERESTING)

Notifikacije rade lokalno — nema servera, nema cloud messaginga.

---

## 3G. P&L Dashboard (v7.0.0)

### 3G.1 Sto je P&L Dashboard

P&L Dashboard je **centralizirani pregled performansi** svih tvojih trade-ova. Umjesto da rucno racunas koliko si zaradio ili izgubio, Dashboard automatski prikuplja podatke iz svih zatvorenih trade-ova i prikazuje kljucne metrike.

### 3G.2 Kako pristupiti

P&L Dashboard se otvara tapom na **banner** u **Portfolio** tabu. Banner prikazuje sazetak (ukupni P&L, win rate) i vodi na full-screen PnlDashboardScreen.

### 3G.3 Metrike koje prikazuje

| Metrika | Sto znaci |
|---------|-----------|
| **Equity Curve** | Grafikon koji prikazuje rast ili pad tvog ukupnog portfolija kroz vrijeme. Uzlazna krivulja = ukupno u plusu, silazna = ukupno u minusu |
| **Win Rate** | Postotak trade-ova koji su zavrsili s profitom. Npr. 60% win rate znaci da je 6 od 10 trade-ova bilo profitabilno |
| **R/R Ratio (Risk/Reward)** | Prosjecni omjer profita naspram gubitka. R/R 2.0 znaci da prosjecni profitabilni trade donosi 2x vise nego sto prosjecni gubitnicki trade gubi |
| **Per-tier breakdown** | P&L razdvojen po tieru — vidis koliko zaradjujes/gubis u SHORT vs MID vs LONG strategiji |

### 3G.4 Equity Curve objasnjenje

Equity curve je **najvazniji grafikon** za praćenje performansi. X-os je vrijeme (datumi trade-ova), Y-os je kumulativni P&L.

- **Ravnomjerno rastuci** graf = konzistentno profitabilna strategija
- **Rastuci s oscilacijama** = profitabilna ali s volatilnoscu (normalno)
- **Padajuci** graf = strategija gubi novac — razmotri prilagodbu parametara ili pauzu

### 3G.5 Per-tier breakdown

Dashboard prikazuje odvojene statistike za svaki tier:

```
+------------------------------------------+
| SHORT tier:  Win 65% | R/R 1.8 | +$42   |
| MID tier:    Win 55% | R/R 2.5 | +$78   |
| LONG tier:   Win 70% | R/R 3.1 | +$120  |
+------------------------------------------+
```

Ovo ti pomaze identificirati koji tier je tvoja najjaca strategija i gdje trebas prilagoditi pristup.

### 3G.6 Kad početi pratiti Dashboard

P&L Dashboard postaje koristan **nakon 10+ zatvorenih trejdova**. S manje podataka, win rate i R/R ratio su statistički nepouzdani — 3 trejda od 5 profitabilnih (60% win rate) može biti slučajnost.

Preporučeni ritam: pregledaj Dashboard **jednom tjedno** (npr. nedjelja večer). Tražiš trendove, ne dnevne fluktuacije.

Ako equity curve konzistentno pada kroz 3+ tjedna — **stani i analiziraj** zašto, ne nastavljaj s istom strategijom.

### 3G.7 Zatvaranje DEX pozicija i trade history

Kad zatvoriš DEX poziciju tapom na **CLOSE** u Portfolio tabu:
1. App traži **exit cijenu** (predlaže trenutnu tržišnu cijenu, možeš promijeniti)
2. P&L se kalkulira: `(exit_cijena × količina) - uloženi_USDT`
3. Trad se sprema u `closed_trades` — pojavljuje se u P&L Dashboardu
4. DEX pozicija dobiva status `CLOSED`

Ako SL ili TP automatski triggeraju — app automatski zatvara poziciju i sprema je u historiju bez tvoje intervencije.

---

## 3H. WalletConnect v2 (v7.0.0)

### 3H.1 Sto je WalletConnect

WalletConnect je **otvoreni protokol** za sigurno spajanje crypto walleta (MetaMask, Trust Wallet, Phantom i drugi) na decentralizirane aplikacije. CoinSight koristi **WalletConnect v2** za povezivanje tvog walleta s aplikacijom.

### 3H.2 Postavljanje

**Preduvjet:** Trebas **Project ID** s WalletConnect Cloud platforme.

▶ **Napravi sad:**

**Korak 1 — Registracija na WalletConnect Cloud:**
1. Otvori browser i idi na: **https://cloud.reown.com**
2. Registriraj se (GitHub login ili email)
3. Kreiraj novi projekt (npr. "CoinSight")
4. Kopiraj **Project ID** koji dobijes

**Korak 2 — Unesi Project ID u CoinSight:**
1. Otvori CoinSight --> **Manage** tab --> **API** pod-tab
2. Pronadi polje **"WalletConnect Project ID"**
3. Zalijepi kopirani Project ID
4. Tapni **"Save"**

### 3H.3 Kako spojiti wallet

1. U Portfolio tabu ili Analysis tabu tapni **WalletConnect button**
2. Pojavljuje se QR kod ili deep link
3. Otvori svoj wallet (MetaMask, Trust Wallet, Phantom...)
4. U walletu skeniraj QR kod ili odobri konekciju
5. Wallet adresa se prikazuje u CoinSightu

### 3H.4 Sto omogucava

- **Prikaz wallet adrese** u aplikaciji — vidis spojeni wallet
- **Pokretanje swapova** — iz CoinSight-a mozes inicirati token swap na DEX-u
- **Veza s DEX pozicijama** — automatsko povezivanje wallet adrese s DEX Position Trackingom

> **Vazno:** WalletConnect NE daje CoinSightu pristup tvojim privatnim kljucevima. Svaka transakcija zahtijeva tvoju eksplicitnu potvrdu u walletu.

---

## 3I. Trade History (v7.0.0)

### 3I.1 Sto je Trade History

Trade History je **kompletna evidencija svih zatvorenih trade-ova**. Svaki put kad se pozicija zatvori (rucno, SL trigger, ili TP trigger), CoinSight zapisuje ClosedTrade zapis s detaljima.

### 3I.2 Sto se zapisuje

Za svaki zatvoreni trade:
- **Coin** — koji coin je bio trgovan
- **Tier** — u kojem tieru (SHORT/MID/LONG)
- **Entry price** — cijena ulaza
- **Exit price** — cijena izlaza
- **Quantity** — kolicina tokena
- **P&L** — apsolutni i postotni profit/gubitak
- **Razlog zatvaranja** — SL trigger, TP trigger, rucno zatvaranje
- **Datum otvaranja i zatvaranja**

### 3I.3 Rucno zatvaranje s exit price-om

Kad rucno zatvoras poziciju (CLOSE button u Portfolio tabu), CoinSight sada trazi **exit price** za precizno racunanje P&L-a. App automatski predlaze trenutnu trzisnu cijenu, ali mozes unijeti i drugu cijenu (npr. ako si vec prodao na DEX-u po drugoj cijeni).

### 3I.4 Gdje vidjeti

Trade History se prikazuje u:
- **P&L Dashboard** — kompletna lista u Trade History sekciji
- **Portfolio tab** — zadnjih N zatvorenih trade-ova u Analysis History sekciji

---

## 4. Prvo pokretanje aplikacije

### 4.1 Instalacija

**Android:**
1. Preuzmi APK iz GitHub repozitorija ili build-aj iz izvornog koda
2. Settings → Security → **Allow installation from unknown sources** (ako traži)
3. Otvori APK → Install → Open

**Windows:**
1. Preuzmi `coinsight.exe` i pripadajuće datoteke iz GitHub releasea (ili build-aj lokalno)
2. Extract ZIP u direktorij po izboru
3. Dupli klik na `coinsight.exe`

**Build iz izvora:**
1. Kloniraj repozitorij: `git clone <repo-url>`
2. Instaliraj Flutter SDK (3.x)
3. `flutter pub get`
4. `flutter run` (za debug) ili `flutter build apk` / `flutter build windows`

### 4.2 Prvi ekran

Kad prvi put otvoriš app vidjet ćeš:

```
+------------------------------------------+
|         Watchlist                         | <-- gornji naslov (AppBar)
+------------------------------------------+
|   [SHORT]    [MID]    [LONG]             | <-- TierModeSelector (v4.0.0)
+------------------------------------------+
| [DEX Early] [New Listings] [My Watchlist] | <-- pod-tabi (scrollable)
|              [Projekti] [Top Coins]       |     5 pod-tabova u MID modu
+------------------------------------------+
|  ░░░░░░░░░░░░░░░░░░░░                    |
|  ░░░░░░░░░░░░░░░░░░░░                    | <-- skeleton (sivi loading)
|  ░░░░░░░░░░░░░░░░░░░░                    |   Traje 2-3 sekunde
+------------------------------------------+
|  [*]  [**]  [$]  [=]                     | <-- bottom nav (4 taba)
|  Watch Analy Portf Manage                |
+------------------------------------------+
```

Nakon 2-3 sekunde skeleton nestaje i pojavljuju se **stvarni coinovi** — lista 20-ak small-cap coinova koji trenutno rastu.

**TierModeSelector banner (v4.0.0):** Ispod AppBara vidis tri buttona — SHORT, MID, LONG. Default je SHORT (ljubicasti). Ovo kontrolira koji investicijski tier je aktivan i utjece na suggestion chipove u Analysis tabu, akcije u Trade Action Baru, i prikaz u Portfolio tabu. Za pocetak ostavi na SHORT.

▶ **Napravi sad:** samo pogledaj listu. Ne moraš još ništa tapnuti.

### 4.3 Što vidiš na svakoj kartici

```
+------------------------------------------------+
| #523 [ikona] PepeRocket           [1H +12.4%]  |
|      PEPR  ..../\....             $0.000423     |
|                               +45.3% 24H       |
|                                         [*]     |
+------------------------------------------------+
```

Odozgo dolje, lijevo-desno:
- **#523** — market cap rank (523. po veličini, micro-cap)
- **[ikona]** — ikonica coina (ako ne učita, prikaže se placeholder)
- **PepeRocket** — puno ime coina
- **[1H +12.4%]** — zelena oznaka: u zadnjem satu porasao 12.4%
- **PEPR** — ticker simbol (kratica)
- **..../\....** — sparkline, 7-dnevni trend (raste blago do polovice tjedna pa stabilizacija)
- **$0.000423** — trenutna cijena
- **+45.3% 24H** — zeleno: u zadnjih 24h porasao 45.3%
- **[*]** — zvjezdica za dodavanje u My Watchlist (ako je sjajna, već je u watchlistu)

### 4.4 Pull-to-refresh

Gdje god vidiš listu (New Listings, My Watchlist, Top Coins, Portfolio):
- Stavi prst na vrh liste
- Povuci prema dolje
- Vidjet ćeš spinner
- Pusti → lista se osvježava

### 4.5 Bottom navigacija

Na dnu ekrana su **4 ikone**. Tapneš ikonu → mijenjaš tab.

| Ikona | Tab | Što radi |
|-------|-----|----------|
| [*] | **Watchlist** | Browse coinova (New Listings / My Watchlist / Top Coins) |
| [**] | **Analysis** | AI analiza (Claude chat) |
| [$] | **Portfolio** | Tvoje otvorene pozicije, P&L, povijest |
| [=] | **Manage** | Postavke, API ključevi, risk parametri, Telegram Monitor |

Kad tapneš tab, ikona se "puni" (outline verzija postaje solidna).

**Napomena:** od v3.0.0 nadalje, četvrti tab se zove **Manage** (ikona tune/equalizera), ne "Settings" kao u ranijim verzijama.

---

## 5. Turneja po aplikaciji

Sada ćemo proći svaki tab da vidiš što je gdje. **Ne treba ništa konfigurirati još** — samo upoznaj ekrane.

### 5.1 Tab [*] Watchlist — pod-tabi (tier-zavisni)

Prvi tab koji vidiš kad otvoriš app. Tab bar je **scrollable** (isScrollable: true) — swipe lijevo-desno ako ti ne stanu svi na ekran. Broj i sadrzaj pod-tabova ovisi o aktivnom tier-u.

**SHORT tier:** DEX Early | New Listings | My Watchlist | Top Coins
**MID tier:** DEX Early | New Listings | My Watchlist | **MID Discovery** | Projekti | Top Coins
**LONG tier:** DEX Early | New Listings | My Watchlist | **LONG Research** | Top Coins

**MID Discovery (v5.0.0):** Prikazuje **live GitHub trending** kripto projekte — repozitorije s naglim porastom zvjezdica i aktivnosti u zadnjih 24h. Korisno za otkrivanje novih projekata s razvojnim momentumom.

**LONG Research (v5.0.0):** Prikazuje **filtrirani top 200** coinova po market capu, optimizirano za fundamentalnu analizu — fokus na etablirane projekte s dokazanim track recordom pogodne za dugorocno drzanje.

**Pod-tab 1: DEX Early (default, prvi) — NOVO u v3.0.0**

Prikazuje **DexscreenerSignal** kartice — svježe DEX listinge koje je Intelligence Layer detektirao na 6 lanaca (Ethereum, BSC, Solana, Polygon, Arbitrum, Base).

```
+------------------------------------------------+
| [ETH]  [DEX]  UniswapV3                        |
| PEPE2.0                          $0.00000142    |
| Vol: $234K  |  Liq: $89K  |  V/L: 2.63        |
|                                                |
|                          [Analiziraj]           |
+------------------------------------------------+
```

Svaka kartica prikazuje:
- **Chain badge** (ETH, BSC, SOL, POLY, ARB, BASE) — na kojem lancu je token
- **DEX badge** — na kojem DEX-u je listiran (UniswapV3, PancakeSwap, Raydium...)
- **Ime tokena** i **cijena**
- **Volume** (24h trading volumen)
- **Liquidity** (koliko likvidnosti je u pool-u)
- **V/L ratio** (Volume/Liquidity) — viši omjer = aktivniji trading u odnosu na likvidnost
- **"Analiziraj" button** — pokreće punu intelligence analizu za taj coin (vidi sekciju 5.6)

- Auto se osvježava svakih 3 minute
- Pull-to-refresh radi ručno

**Pod-tab 2: New Listings**

Lista small-cap coinova s 1h momentum-om. Objašnjeno gore (sekcija 4.3).

- Auto se osvježava svakih 3 minute (dok si na ovom pod-tabu)
- Pull-to-refresh radi ručno
- Tap zvjezdice [*] → coin ide u My Watchlist

**Pod-tab 3: My Watchlist**

Coinovi koje si ti označio. Prazno kad prvi put otvoriš app — osim default-a: Bitcoin, Ethereum, Solana (dodano da nije prazno za početak).

- Ovdje Claude uzima "kontekst" za AI analizu
- Ukloniš coin tapom na već-sjajnu zvjezdicu

**Pod-tab 4: Top Coins**

Top 25 najvećih kripto valuta po market capu. Bitcoin, Ethereum, Tether, itd.

- Tu dodaješ "mainstream" coinove za referencu
- Ne osvježava se automatski — pull-to-refresh ručno

### 5.6 "Analiziraj" button na DEX karticama

Kad tapneš **"Analiziraj"** na DEX Early kartici:

1. App pokreće **puno intelligence prikupljanje** za taj specifični coin
2. IntelligenceAggregator provjerava svih 5 izvora (DEX, GitHub, Reddit, Telegram, Market Cap)
3. Gradi se **IntelligenceReport** s confluence score-om (0-6.0)
4. Report se šalje Claudeu kao strukturirani multi-source kontekst
5. Claude odgovara s analizom koja uzima u obzir **sve** prikupljene podatke

Ovo je moćnije od obične analize jer Claude ne dobija samo watchlist brojke, nego kompletan obavještajni izvještaj iz više nezavisnih izvora.

### 5.2 Tab [**] Analysis — Claude chat

Kad prvi put tapneš ovaj tab **bez Anthropic API ključa**:

```
+----------------------------------+
|   [kljuc]                        |
|                                  |
|   API Key Required               |
|                                  |
|   Add your Anthropic API key     |
|   in Manage to start chatting    |
|   with CoinSight AI.             |
|                                  |
+----------------------------------+
```

Ne brini — objasnit ćemo u sekciji 6.

Kad **dodaš ključ**, tab prelazi u chat sučelje:

```
+----------------------------------+
|   [**]                           |
|   CoinSight AI                   |
|                                  |
|   Ask about crypto trends...     |
|                                  |
| [Analiziraj New Listings]        |
| [Koji coin sada ima momentum?]   |
| [Procijeni rizik watchliste]     |
|                                  |
+----------------------------------+
|  [Ask about crypto...]  [>]     | <-- input bar
+----------------------------------+
```

Ispod su 3 "suggestion chipa" — tapneš i pošalje tu poruku umjesto tebe. Dobro za prvi pokušaj.

**Suggestion chipovi ovise o aktivnom tier-u (v4.0.0):**

**SHORT tier (default):**
1. **"Analiziraj New Listings"** — Claude pregleda sve coinove iz New Listings taba
2. **"Koji coin sada ima momentum?"** — traži momentum analizu svih coinova
3. **"Procijeni rizik watchliste"** — Claude analizira risk profil tvog watchlista

**MID tier:**
1. **"Procijeni MID-term potencijal"** — Claude analizira srednjorocne prilike
2. **"Kreiraj MID projekt za [coin]"** — priprema MidTermProject
3. **"Analiziraj katalyst timeline"** — analiza predstojecih katalysta

**LONG tier:**
1. **"Fundamentalna analiza [coin]"** — duboka analiza fundamentala
2. **"Kreiraj LONG holding za [coin]"** — priprema LongTermHolding
3. **"DCA strategija za [coin]"** — preporuka DCA rasporeda

**Intelligence Report kontekst (v3.0.0):**

Kad postoji aktivan Intelligence Report (npr. generiran "Analiziraj" buttonom na DEX kartici), Claude ga automatski prima kao strukturirani multi-source kontekst umjesto samo watchlist podataka. Report sadrži podatke iz svih 5 izvora s confluence score-om.

**Signal badge (narančasti banner):**

Ako je Telegram Monitor aktivan i ima pending signala, na vrhu Analysis taba vidiš:

```
+----------------------------------+
| [!] 3 Telegram signala cekaju   | <-- narančasti banner
+----------------------------------+
|   CoinSight AI                   |
|   ...                            |
```

Ti signali se automatski uključuju u sljedeću Claude analizu kao dodatni kontekst. Ne moraš ih ručno čitati — Claude ih procesira i uzima u obzir.

### 5.3 Tab [$] Portfolio — tvoje pozicije

Bez Binance ključa:

```
+----------------------------------+
|   [$]                            |
|                                  |
|   Binance nije konfiguriran      |
|                                  |
|   Dodaj Binance API ključeve     |
|   u Manage da započneš trading.  |
+----------------------------------+
```

Bez trade-ova (imaš ključ ali nisi ništa kupio):

```
+----------------------------------+
| [$] Portfolio              [R]   |
| USDT Balance:       $234.56      |
| Open Positions:     0            |
| Total P&L:          $0.00        |
+----------------------------------+
|     Nema otvorenih pozicija      |
+----------------------------------+
| Analysis History                 |
|   (prazno ili tvoji Claude logovi)|
+----------------------------------+
```

S pozicijom:

```
+----------------------------------+
| [$] Portfolio              [R]   |
| USDT Balance:       $224.56      |
| Open Positions:     1            |
| Total P&L:          +$1.23 (+12%)| <-- zeleno
+----------------------------------+
| PEPR/USDT              [CLOSE]   |
| Entry: $0.000423 -> Now: $0.000473|
| Qty: 23640.66 | Invested: $10    |
| P&L: +$1.18 (+11.82%)            | <-- zeleno
| SL: $0.000359 | TP: $0.000550    |
+----------------------------------+
```

**SHORT Portfolio prikaz (v5.0.0):**

Uz Binance Spot pozicije, SHORT tier sada prikazuje i **DEX pozicije** — rucno unesene trade-ove s decentraliziranih burzi s automatskim price refreshom i SL/TP monitoringom. Vidi sekciju 3D za detalje.

**MID Portfolio prikaz (v4.0.0+):**

Kad je aktivan MID tier, Portfolio tab prikazuje tvoje **MidTermProject** zapise — svaki projekt s coin info, katalyst opisom, target cijenom, deadline-om, i progress barom do katalysta. **Novo u v5.0.0:** FAB (Floating Action Button) za brzo kreiranje novog MID projekta direktno iz Portfolio taba. Tap otvara MidProjectDetailScreen.

**LONG Portfolio prikaz (v4.0.0+):**

Kad je aktivan LONG tier, Portfolio tab prikazuje tvoje **LongTermHolding** zapise — svaki holding s prosjecnom DCA cijenom, ukupnom kolicinom, thesis opisom, i listom svih DCA kupnji. **Novo u v5.0.0:** FAB (Floating Action Button) za brzo kreiranje novog LONG holdinga direktno iz Portfolio taba. Tap otvara LongHoldingDetailScreen.

**Intelligence Dashboard (v3.0.0):**

Ispod pozicija, Portfolio tab sada prikazuje **Intelligence Dashboard** — zadnji Intelligence Report:

```
+------------------------------------------+
| Intelligence Report                      |
| Score: [=====>        ] 3.2 / 6.0        |
| Sources: [DEX] [GH] [Reddit] [TG] [MCap]|
|           *     .      *       .     *   |
|  * = signal  . = no signal               |
| Hint: 3+ izvora = jaka konfluencija      |
+------------------------------------------+
```

- **Score bar**: vizualni prikaz confluence score-a (0-6.0)
- **5 source indikatora**: DEX, GitHub, Reddit, Telegram, Market Cap — ispunjeni ako je izvor dao signal
- **Scoring hint**: objašnjenje da 3+ aktivnih izvora znači jaku konfluenciju signala

### 5.4 Tab [=] Manage — postavke i konfiguracija

**Manage tab** je u v4.0.0 organiziran u **5 pod-tabova** (dodan Tiers tab):

```
+------------------------------------------+
| Manage                                   |
+------------------------------------------+
| [API]  [Bot]  [Trade]  [Tiers]  [App]   |
+------------------------------------------+
|                                  |
|    (sadržaj aktivnog pod-taba)   |
|                                  |
+----------------------------------+
```

**Pod-tab 1: API**

Konfiguracija API ključeva:
- **Anthropic API Key** — za Claude AI analizu
- **Binance API** — za Spot trading (ključ + secret + testnet toggle + Test button)
- **Web3 Wallet address (v5.0.0)** — adresa tvog Web3 walleta (MetaMask, Trust Wallet, Phantom...) za povezivanje s DEX pozicijama

**Pod-tab 2: Bot**

Konfiguracija Telegram Monitora:
- **Bot Token** polje — Telegram bot token
- **Aktiviraj monitoring** toggle
- **"Otvori Bot Manager"** button — otvara full-screen Bot Manager ekran (sekcija 14)
- Status indikatora: zeleno = aktivan, sivo = neaktivan

**Pod-tab 3: Trade**

Risk parametri za trgovanje:
- **Max trade amount** (USDT) — koliko maksimalno po jednom tradeu
- **Max open positions** — koliko pozicija istovremeno
- **Stop-loss %** — klizač
- **Take-profit %** — klizač
- **Auto-trade** toggle — Faza 3 (auto kupnja)
- **Quiet hours** — vremenski raspon kad auto-trade ne kupuje

**Pod-tab 4: Tiers (NOVO v4.0.0)**

Konfiguracija Three-Tier Investment Framework-a:
- **Aktivni tier** prikaz — trenutno odabrani tier (SHORT/MID/LONG)
- **MID tier postavke** — default target %, katalyst reminder interval
- **LONG tier postavke** — DCA iznos, DCA interval (tjedno/mjesecno), fundamentals checklist
- **Tier statistike** — broj aktivnih projekata/holdinga po tier-u

**Pod-tab 5: App**

Opće postavke i kontrole:
- **About CoinSight** — verzija, MIT licenca, disclaimer
- **Clear analysis history** — briše lokalne Claude chat logove
- **Export logs to clipboard** — kopira logove u clipboard za dijeljenje/debugging
- **Full reset** — resetira sve postavke, ključeve i lokalne podatke na tvorničko stanje

---

## 6. Postavljanje API ključeva

Sada pravi setup. Proći ćemo dva obavezna ključa: **Anthropic** i **Binance**. Telegram Monitor (opcionalan) se postavlja u sekciji 13.

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
3. **Add credits** → preporučam **$10 za početak** (traje oko 1000-3000 analiza s claude-sonnet modelom)

**Korak 3 — Generiraj ključ:**
1. Settings → **API Keys**
2. **Create Key** → daj ime (npr. "CoinSight")
3. Kopiraj ključ koji počinje s `sk-ant-api03-...`

UPOZORENJE: **Ovaj ključ se prikazuje SAMO JEDNOM.** Ako ga izgubiš, moraš kreirati novi.

**Korak 4 — Upiši u CoinSight:**
1. Otvori CoinSight → tapni **[=] Manage** tab
2. Odaberi **API** pod-tab (prvi, default)
3. **Anthropic API Key** sekcija → tapni polje ispod teksta `sk-ant-...`
4. Paste ključ (long press → Paste, ili Ctrl+V na PC-u)
5. Tapni **Save Key**
6. Vidjet ćeš "API key saved" potvrdu i status badge se mijenja u zeleni **Active**

Anthropic ključ postavljen.

### 6.2 Binance account i API ključ (za trading)

**Svrha:** Omogućava CoinSight-u da u tvoje ime kupuje/prodaje coinove na Binanceu.

UPOZORENJE: **Preduvjet:** moraš imati Binance account i proći KYC (identity verifikaciju). Ako nemaš:

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

UPOZORENJE: **BITNO: API Management je dostupan SAMO na desktop webu, ne na mobilnoj Binance app-i.**

Ako si na mobitelu:
- Otvori **Chrome / Safari** (browser, ne Binance app!)
- Idi na `binance.com`
- Tri točkice u browseru → **Desktop site** ili **Request desktop version**
- Nastaviš po koracima ispod

Na PC-u:
1. Uloguj se na `binance.com`
2. Gornji desni kut → **ikona profila** → **Account** → **API Management**
3. **Create API** → odaberi **System generated** → upiši ime (npr. "CoinSight") → prodji 2FA verifikaciju
4. Kopiraj:
   - **API Key** (duži string)
   - **Secret Key** (prikazuje se **samo jednom**)

**Korak D — SIGURNOSNE POSTAVKE (kritično):**

Na novi ključu klikni **Edit restrictions**:

UKLJUČI:
- Enable Reading (automatski)
- **Enable Spot & Margin Trading**

ISKLJUČI OBAVEZNO:
- **Enable Withdrawals** <-- **NIKAD ne uključuj ovo**
- Enable Internal Transfer
- Enable Universal Transfer
- Enable Futures
- Enable Margin
- Enable Options

Ako ovo zaboraviš i neki hacker dodje do tvog ključa → izvuče sav novac. Ako je Withdrawal OFF, hacker ne može ništa izvući.

**IP Restriction** (opcionalno):
- Ako imaš fiksni kućni internet → **Restrict to trusted IPs** i dodaj svoj IP (Google "what is my IP")
- Ako ti se IP mijenja (mobilna mreža, koristiš više WiFi mreža) → **Unrestricted** je OK jer si isključio withdrawal

Save. Sada imaš:
- API Key string
- Secret Key string

**Korak E — Upiši u CoinSight:**
1. CoinSight → **[=] Manage** → **API** pod-tab
2. **Binance API** sekcija
3. Pročitaj narančasti warning ("Osiguraj da API ključ NEMA dozvolu za Withdrawal")
4. **API Key** polje: paste svoj API Key
5. **API Secret** polje: paste svoj Secret Key
6. **Testnet mode** switch:
   - Ako prvi put i želiš testirati bez pravog novca → **ostavi ON** (alternativa: vidi korak F)
   - Ako ideš odmah pravim novcem → **OFF** (otvorit će se dialog "Prebaci na LIVE?" → Confirm LIVE)
7. Tapni **Save**
8. Tapni **Test** → očekivani rezultat: `OK — USDT balance: $100.00 (live)` ili `(testnet)`

Binance ključ postavljen.

**Korak F — Testnet alternativa (ako želiš vježbati bez pravog novca):**

Umjesto pravog Binance accounta, možeš koristiti testnet:

1. Otvori `testnet.binance.vision`
2. **Login with GitHub** (ne Binance account — odvojen sistem)
3. Odmah dobiješ **10,000 lažnih USDT**
4. **Generate HMAC_SHA256 Key** → kopiraj API Key + Secret
5. U CoinSight Manage → API → Binance API → paste ključeve → **Testnet switch ON** → Save → Test

Testnet je identičan live Binanceu, samo s lažnim novcem. Savršeno za prvi tjedan učenja.

---

## 7. Tvoja prva analiza

Sada radimo **prvi pravi posao**. Pretpostavljamo da imaš Anthropic ključ aktiviran.

### 7.1 Pripremi coin za analizu

▶ **Napravi sad:**

1. Tapni **[*] Watchlist** tab
2. Budi na **New Listings** pod-tabu (prvi)
3. Pogledaj listu. Tapni zvjezdicu [*] na nekom coinu koji ti je zanimljiv — npr. onaj s najvećim 1H porastom
4. Provjeri da je zvjezdica postala **ispunjena** (znači dodan je u watchlist)

Alternativa: neka ti u My Watchlist-u ostaju defaultni Bitcoin/Ethereum/Solana — Claude će analizirati njih.

### 7.2 Pitaj Claudea

▶ **Napravi sad:**

1. Tapni **[**] Analysis** tab
2. Vidjet ćeš empty state s 3 suggestion chipa
3. Tapni **[Analiziraj New Listings]**

**Što se dogodi:**
- Tvoja poruka "Analiziraj New Listings" se pojavi u chatu (desno, ljubičastom bojom)
- App automatski dodaje tvoje watchlist coinove kao kontekst
- Ako su prisutni Telegram signali, i oni se uključuju (vidiš narančasti badge koji nestaje)
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

Ako je Telegram Monitor uhvatio relevantne signale (npr. whale alert za PEPR, listing na novom exchange-u), Claude ih može eksplicitno spomenuti:

> **Telegram Intel:** Whale Alert detektirao transfer 500M PEPR na Binance hot wallet prije 2 sata. Ovo može ukazivati na predstojeći listing ili veliki sell — praćenje je obavezno.

### 7.4 Što primjećuješ

1. Claude je analizirao **sve** coinove iz tvog watchlista — ne samo jedan
2. Pri kraju je **odabrao jednog** (PEPR) za koji je dao **INTERESTING** oznaku
3. Tekst **INTERESTING** je **bold** (`**INTERESTING**`) — to je način kako app detektira preporuku
4. Telegram signali su automatski uključeni u analizu (ako su postojali)
5. Ispod analize, u app-u će se pojaviti **Trade Action Bar** ako:
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

### 8.4 Telegram Intel u analizi

U v3.0.0, ako je Telegram Monitor aktivan, Claude takodjer koristi četvrti "objektiv":

4. **Telegram Intelligence**:
   - Signali iz javnih kripto kanala (whale alerti, listing najave, breaking news)
   - Pouzdanost kanala (koliko % prethodnih signala se pokazalo točnima)
   - Korelacija izmedju Telegram buzz-a i price action-a

Claude eksplicitno navodi koje Telegram signale je uzeo u obzir i koliko su utjecali na preporuku.

### 8.5 Što Claude NIJE

- **Nije proročanstvo.** Ako kaže INTERESTING, to znači "vrijedi razmotriti", ne "garantirano raste"
- **Nije financijski savjetnik.** Završava s napomenom "analiza obrazaca, ne financijski savjet"
- **Nema live podatke u stvarnom vremenu.** Analizira ono što app pošalje (snapshot u tom trenutku)
- **Ne zna vijesti direktno.** Ali ako je Telegram Monitor aktivan, dobija signale iz kanala koji pokrivaju vijesti

### 8.6 Koliko vjerovati

Iz iskustva, u momentum tradingu:
- INTERESTING preporuke pogode **~60-70%** vremena
- Znači da **30-40%** vremena kupiš nešto što padne

Zato je **risk management** (sekcija 11) tako važan.

---

## 9. Tvoj prvi trade

### 9.1 Preduvjeti

Provjeri:
- Imaš Binance API ključ postavljen
- Imaš USDT na Binance Spot wallet-u (minimum $10-20)
- **Auto-trade je OFF** u Manage → Trade pod-tab (za prvi trade manual je bolji)
- Claude je upravo dao **INTERESTING** signal u Analysis tabu

### 9.2 Provjeri Risk Parametre

▶ **Napravi sad prije prvog trade-a:**

1. Tapni **[=] Manage** → **Trade** pod-tab
2. Postavi **konzervativno**:
   - **Max trade amount**: `5` (ne default 10 — za prvi trade još manje)
   - **Max open positions**: `1`
   - **Stop-loss**: `10%` (klizač na 10)
   - **Take-profit**: `25%` (klizač na 25)
   - **Auto-trade**: **OFF**
   - **Quiet hours**: 23:00 - 07:00 (default)

Zašto ovo: s $5 po trade-u i 10% SL-om **maksimalno možeš izgubiti $0.50 na prvom trade-u**. Čak i ako stvari krenu jako loše, "cijena učenja" je minimalna.

### 9.3 Trade Action Bar

Vrati se na **[**] Analysis** tab. Ispod Claudeove INTERESTING poruke vidiš:

```
+------------------------------------------+
| [!] INTERESTING signal — PEPR/USDT    X  |
|                                          |
| Uloži: [5.00]  USDT   SL -10%|TP +25%  |
|                                          |
| [  BUY NOW  ]              [ SKIP ]     |
+------------------------------------------+
```

**Detalji:**
- **Coin koji targetiraš**: prvi coin iz My Watchlist-a (u našem primjeru PEPR)
- **Uloži iznos**: preuzeto iz tvojih Risk Parametera ($5). Možeš ovdje editirati za ovaj trade (ne mijenja default)
- **SL/TP**: preuzeto iz Risk Parametera, samo info
- **Dva buttona**: BUY NOW i SKIP (u v3.0.0+ nema TELEGRAM buttona — Telegram je sada Monitor, ne notifikacijski bot)

**Napomena (v4.0.0):** Ovaj Trade Action Bar je za **SHORT tier**. Ako si na **MID tier-u**, umjesto toga vidis **MID Action Bar** s CREATE PROJECT / SKIP buttonima. Na **LONG tier-u** vidis **LONG Action Bar** s CREATE HOLDING / DCA BUY / SKIP buttonima. Vidi sekciju 3A za detalje.

### 9.4 Tap BUY NOW

▶ **Napravi sad:**

Tapni **BUY NOW**. Otvara se confirmation dialog:

```
+--------------------------------------+
| Potvrdi kupnju PEPR                  |
+--------------------------------------+
| Cijena: $0.000423                    |
| Iznos: $5.00                         |
| Qty: ~11820.33                       |
|                                      |
| SL: $0.000381                        | <-- crveno
| TP: $0.000529                        | <-- zeleno
|                                      |
| Market order — izvršava se po        |
| trenutnoj cijeni.                    |
+--------------------------------------+
|   [Cancel]     [CONFIRM BUY]         |
+--------------------------------------+
```

**Što dialog pokazuje:**
- Cijena u tom momentu
- Iznos koji ćeš uložiti ($5)
- **Procijenjen broj tokena** (5 / 0.000423 = ~11820). Stvarni broj može malo varirati zbog slippage-a
- SL i TP cijene (računate iz tvojih parametara)

### 9.5 CONFIRM BUY

Tapni **CONFIRM BUY**.

**Što se dogodi (iza scene):**
1. App šalje **market buy order** na Binance s `quoteOrderQty=5` (kupi za $5 USDT-a)
2. Binance izvršava order (milisekunde)
3. App sprema **CoinPosition** u lokalnu bazu s podacima iz odgovora (stvarna cijena, stvarni qty)
4. App logira u **AnalysisLog** s oznakom `ENTERED`
5. **SnackBar** se pojavljuje dolje: "Bought 11820.334 PEPR @ $0.000423"

**LOT_SIZE handling (v3.0.0):** App sada automatski dohvaća `stepSize` iz Binance `/exchangeInfo` endpointa za svaki coin. To znači da se količina za sell order pravilno zaokružuje — nema više "Filter failure: LOT_SIZE" grešaka koje su postojale u ranijim verzijama.

### 9.6 Provjeri Portfolio

▶ **Napravi sad:**

Tapni **[$] Portfolio** tab.

Vidjet ćeš:

```
+----------------------------------+
| [$] Portfolio              [R]   |
| USDT Balance:       $195.00      | <-- smanjen za $5
| Open Positions:     1            |
| Total P&L:          $0.00 (0%)   | <-- tek kupio
+----------------------------------+
| PEPR/USDT              [CLOSE]   |
| Entry: $0.000423 -> Now: $0.000423|
| Qty: 11820.33 | Invested: $5.00  |
| P&L: +$0.00 (0.00%)              |
| SL: $0.000381 | TP: $0.000529    |
+----------------------------------+
```

**Čestitam, kupio si svoj prvi coin kroz CoinSight.**

### 9.7 Što se sada dogadja

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

**Napomena (v3.0.0):** Sell orderi sada koriste dinamički `stepSize` iz Binance `/exchangeInfo`, što eliminira LOT_SIZE filter greške. Količina se automatski zaokružuje na ispravan broj decimala.

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
3. Usporeduje s SL cijenom (entryPrice x (1 - SL%/100)) i TP cijenom
4. Ako cijena <= SL ili >= TP → **market sell**

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

### 10.6 Timestamp sinkronizacija (v3.0.0)

App automatski sinkronizira vrijeme sa Binance serverom putem `/api/v3/time` endpointa. Ovo je bitno jer Binance odbija zahtjeve s vremenskim pomakom većim od 1000ms.

Ako se pojavi greška **-1021 (Timestamp for this request is outside of the recvWindow)**, app automatski:
1. Dohvaća server time
2. Računa offset izmedju lokalnog i server vremena
3. Dodaje offset na sve buduće zahtjeve
4. Ponavlja neuspjeli zahtjev

Ne moraš ručno intervenirati — app se sam sinkronizira.

---

## 11. Risk management

### 11.1 Zlatna pravila za početnika

1. **Prva 2 tjedna: testnet ILI pravi novac ali max $5 po tradeu.** Naučiš se na mali iznos.
2. **Nikad ne kupuj više nego što si spreman izgubiti NA SVAKI DAN.** Ako ti nestanak $100 uzrokuje stres, CoinSight nije za tebe s tim iznosom.
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
- 3 x $10 = $30 izloženosti
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
- Auto-trade je **OFF** u Manage → Trade
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
- Ako se cijene okrenu, svih 5 na SL → mogući gubitak 15% x 5 x iznos = bolna lekcija

### 12.4 Kako uključiti

1. Manage → **Trade** pod-tab → **Auto-trade toggle ON**
2. Warning se prikaže: "Bot će automatski kupovati bez tvoje potvrde..."
3. **Provjeri** da su parametri konzervativni (max $10-15 po tradeu, max 2 pozicije)
4. Napusti ekran — radi u pozadini

### 12.5 Kako isključiti u panici

Ako vidiš da auto-mode radi glupe stvari:
1. Manage → Trade → Auto-trade **OFF**
2. Ručno zatvori otvorene pozicije u Portfolio tabu

---

## 13. Telegram Monitor — pasivno obavještajno prikupljanje

### 13.1 Što je Telegram Monitor

Telegram Monitor je **potpuno drugačiji** od klasičnog Telegram bota. Ne šalje ti poruke, ne prima tvoje komande. Umjesto toga:

- **Čita poruke** iz javnih kripto Telegram kanala
- **Filtrira** poruke po ključnim riječima (listing, whale, alert, breaking, pump, moon...)
- **Sprema signale** lokalno
- **Šalje signale Claudeu** kao dodatni kontekst pri sljedećoj analizi

Zamišljaj ga kao **pasivnog obavještajca** koji sjedi u Telegram kanalima i sluša. Kad čuje nešto zanimljivo, zapisuje i prosljeduje AI-u.

### 13.2 Zašto je ovo korisno

Bez Telegram Monitora, Claude analizira samo **brojke** — cijena, volumen, rank. Ali ne zna **zašto** coin raste. Možda raste jer:
- Whale Alert javlja transfer 500M tokena na exchange (mogući dump)
- Binance najavljuje listing novog coina (legitimni rast)
- KuCoin community širi vijest o partnerstvu

S Telegram Monitorom, Claude dobija i taj kontekst. Njegova analiza postaje preciznija jer vidi i **narativ** iza brojki.

### 13.3 Setup — korak po korak

**Svrha:** Omogućiti CoinSight-u da čita poruke iz javnih Telegram kanala.

Možeš preskočiti ovu sekciju i dodati kasnije. App savršeno radi bez Telegram Monitora — samo nećeš imati "intelligence" sloj.

▶ **Napravi sad:**

**Korak 1 — Kreiraj Telegram bota:**
1. Otvori Telegram → traži `@BotFather` → Start
2. Pošalji `/newbot`
3. BotFather pita za ime (proizvoljno, npr. "MyCoinSightMonitor")
4. BotFather pita za username (mora završiti s `bot`, npr. `coinsight_monitor_bot`)
5. Kopiraj **Bot Token** koji ti BotFather pošalje (dugi string s `:` u sredini, npr. `123456789:AAF...`)

UPOZORENJE: Token se prikazuje jednom. Spremi ga na sigurno.

**Korak 2 — Dodaj bota kao admina u javne kanale:**

Bot mora biti admin u kanalima da bi mogao čitati poruke.

Za svaki kanal koji želiš pratiti:
1. Otvori kanal u Telegramu (npr. @whale_alert)
2. Ako je kanal javan i dozvoljava dodavanje admina:
   - Kanal Settings → Administrators → Add Administrator → traži username tvog bota
   - Dodaj ga s **minimalnim permissionima** (samo Read je dovoljno)

**Napomena:** Mnogi veliki kanali (poput @binance) ne dozvoljavaju random korisnicima da dodaju admine. U tom slučaju, bot čita poruke kao subscriber ako je kanal javan. Bot Manager (sekcija 14) ima listu preporučenih kanala koji rade.

**Korak 3 — Upiši u CoinSight:**
1. CoinSight → **[=] Manage** → **Bot** pod-tab
2. **Bot Token** polje: paste token
3. Tapni **Save**
4. Uključi **"Aktiviraj monitoring"** toggle

Status indikator se mijenja u zeleno — monitor je aktivan.

Telegram Monitor postavljen.

### 13.4 Chat ID — NIJE potreban

Za razliku od starijih verzija, **ne treba ti Chat ID**. Telegram Monitor ne šalje poruke tebi — samo čita kanale. Bot Token je jedino što treba.

### 13.5 Preporučeni kanali (default)

CoinSight dolazi s listom preporučenih kanala:

| Kanal | Što pokriva |
|-------|-------------|
| **@binance** | Službene Binance najave, listinzi |
| **@kucoincom** | KuCoin najave i listinzi |
| **@whale_alert** | Velike transakcije (whale movements) |
| **@coingecko** | CoinGecko vijesti i trendovi |
| **@coinmarketcap** | CMC vijesti, trending coinovi |

Ove kanale možeš dodavati i uklanjati kroz **Bot Manager** (sekcija 14).

### 13.6 Keyword filtering

Monitor ne sprema **sve** poruke iz kanala — to bi bilo previše šuma. Umjesto toga, filtrira po ključnim riječima:

| Ključna riječ | Što signalizira |
|---------------|-----------------|
| **listing** | Novi coin na exchange-u |
| **whale** | Velika transakcija |
| **alert** | Hitno upozorenje |
| **breaking** | Udarna vijest |
| **pump** | Nagli rast (može biti i scam) |
| **moon** | Optimistična projekcija |
| **airdrop** | Besplatna distribucija tokena |
| **partnership** | Novo partnerstvo |
| **hack** | Sigurnosni incident |
| **regulation** | Regulatorna vijest |

Kad poruka u kanalu sadrži jednu ili više ovih riječi, Monitor je sprema kao **signal**.

### 13.7 Kako signali dolaze u analizu

1. Monitor čita kanal
2. Poruka sadrži keyword → sprema se kao pending signal
3. Na Analysis tabu pojavljuje se **narančasti badge**: "3 Telegram signala čekaju"
4. Kad napišeš sljedeće pitanje Claudeu (ili tapneš suggestion chip), **svi pending signali** se automatski dodaju u kontekst
5. Claude ih procesira i uključuje u analizu
6. Signali se označavaju kao "consumed" (konzumirani) — badge nestaje

Ti ne moraš ručno čitati signale niti ih kopirati. Automatski flow je:

```
Telegram kanal --> Monitor --> Pending signali --> Claude kontekst --> Analiza
```

### 13.8 Što Monitor NIJE

- **Ne šalje ti poruke** — nema notifikacija, nema push poruka na tvoj Telegram
- **Ne odgovara na komande** — nema /status, /stop, /start
- **Ne trguje sam** — samo prikuplja podatke za Claudea
- **Ne čita privatne razgovore** — samo javne kanale u kojima je bot admin/subscriber

### 13.9 Ograničenje

**Monitor radi samo dok je CoinSight app otvoren** (u foregroundu ili pozadini). Kad zatvoriš app, polling staje. Kad opet otvoriš, nastavlja od zadnje pozicije.

---

## 13A. Intelligence Layer — multi-source obavještajni sustav (v3.0.0)

### 13A.1 Što je Intelligence Layer

Intelligence Layer je **nadogradnja na Telegram Monitor** koja prikuplja podatke iz **5 nezavisnih izvora** i objedinjuje ih u jedinstveni obavještajni izvještaj (IntelligenceReport). Umjesto da se oslonjaš samo na cijenu i volumen, Claude sada dobija slojevitu sliku iz više perspektiva.

### 13A.2 Pet izvora podataka

| Izvor | Što prati | Detalji |
|-------|-----------|---------|
| **Dexscreener** | Svježi DEX listinzi | Prati 6 lanaca: Ethereum, BSC, Solana, Polygon, Arbitrum, Base. Detektira nove tokene na decentraliziranim burzama. |
| **GitHub Intelligence** | Aktivnost kripto repozitorija | Prati commitove, zvjezdice (stars), fork-ove relevantnih kripto projekata. Aktivniji repo = aktivniji razvoj. |
| **Reddit Monitor** | Diskusije na 5 subreddita | Čita: r/CryptoMoonShots, r/altcoin, r/CryptoCurrency, r/defi, r/SatoshiStreetBets. Filtrira po relevantnosti. |
| **Telegram Monitor** | Javni kripto kanali | Isti sustav kao sekcija 13 — filtrira signale po ključnim riječima. |
| **Market Cap** | Tržišni podaci | CoinGecko podaci o cijeni, volumenu, ranku, promjenama. |

### 13A.3 IntelligenceAggregator i Confluence Score

**IntelligenceAggregator** je srce sustava. Uzima podatke iz svih 5 izvora i gradi **IntelligenceReport** s **confluence score-om** od **0 do 6.0**.

Kako se računa score:
- Svaki izvor koji daje pozitivan signal doprinosi score-u
- Više nezavisnih izvora koji se slažu = viši score = jača konfluencija
- Score 0-1.0: slab signal (jedan izvor, nesigurno)
- Score 1.0-3.0: umjeren signal (2-3 izvora, vrijedi pratiti)
- Score 3.0-5.0: jak signal (3-4 izvora, ozbiljan momentum)
- Score 5.0-6.0: vrlo jak signal (4-5 izvora, rijetko ali značajno)

### 13A.4 Kako koristiti Intelligence Layer

**Automatski (kroz DEX Early tab):**
1. Otvori [*] Watchlist → **DEX Early** pod-tab
2. Pregledaj DexscreenerSignal kartice
3. Na zanimljivom tokenu tapni **"Analiziraj"**
4. Intelligence Layer automatski prikuplja podatke iz svih izvora
5. Claude prima kompletni IntelligenceReport i daje detaljnu analizu

**Kroz Analysis tab:**
- Kad postoji aktivan Intelligence Report, Claude ga automatski koristi kao kontekst
- Umjesto samo "cijena X, volumen Y, rank Z", Claude dobija: DEX likvidnost, GitHub aktivnost, Reddit sentiment, Telegram signale, i market podatke
- Analiza je znatno preciznija jer vidi **narativ iz više kutova**

**Kroz Portfolio tab:**
- Intelligence Dashboard na dnu Portfolio taba pokazuje zadnji report
- Score bar vizualno prikazuje snagu konfluencije
- 5 source indikatora pokazuju koji su izvori dali signal

### 13A.5 Dexscreener monitoring — detalji

Dexscreener komponenta prati **6 blockchain lanaca**:

| Lanac | Primjeri DEX-ova |
|-------|-----------------|
| **Ethereum** | Uniswap V2/V3, SushiSwap |
| **BSC** | PancakeSwap |
| **Solana** | Raydium, Orca |
| **Polygon** | QuickSwap |
| **Arbitrum** | Camelot, SushiSwap |
| **Base** | Aerodrome, BaseSwap |

Za svaki detektirani token prikazuje:
- **Cijena** u USD
- **24h Volume** — koliko se trguje
- **Liquidity** — koliko je likvidnosti u DEX pool-u
- **V/L ratio** (Volume/Liquidity) — mjera aktivnosti u odnosu na pool veličinu. Viši ratio = aktivniji trading.

### 13A.6 GitHub Intelligence — detalji

Prati javne GitHub repozitorije kripto projekata:
- **Commitovi**: koliko često se kod ažurira (više = aktivniji razvoj)
- **Stars**: koliko ljudi prati projekt (mjera interesa zajednice)
- **Fork-ovi**: koliko kopija repozitorija postoji

Projekt s aktivnim razvojem (redoviti commitovi, rastuće zvjezdice) ima veću šansu za dugoročnu održivost od projekta čiji je zadnji commit bio prije 6 mjeseci.

### 13A.7 Reddit Monitor — detalji

Prati **5 subreddita** fokusiranih na kripto:

| Subreddit | Fokus |
|-----------|-------|
| **r/CryptoMoonShots** | Rani micro-cap projekti, spekulativni |
| **r/altcoin** | Altcoin diskusije i analize |
| **r/CryptoCurrency** | Opće kripto vijesti i diskusije |
| **r/defi** | Decentralizirane financije |
| **r/SatoshiStreetBets** | Momentum i hype-driven trading |

Reddit signal je koristan za mjerenje **sentimenta zajednice** — ako se coin počinje spominjati na više subreddita istovremeno, to može ukazivati na rastuće zanimanje.

### 13A.8 Što Intelligence Layer NIJE

- **Nije garancija.** Čak i confluence score 6.0 ne znači da će coin sigurno rasti.
- **Nije real-time.** Podaci se prikupljaju u intervalima, ne u milisekundama.
- **Nije zamjena za vlastitu procjenu.** Intelligence Layer daje podatke, ti i Claude interpretirate.

---

## 14. Bot Manager — upravljanje kanalima

### 14.1 Kako otvoriti

1. **[=] Manage** → **Bot** pod-tab
2. Tapni **"Otvori Bot Manager"** button
3. Otvara se full-screen ekran

### 14.2 Što vidiš

```
+------------------------------------------+
| Bot Manager                     [<-]     |
+------------------------------------------+
| Active Channels          [+ Add Channel] |
+------------------------------------------+
| @whale_alert                             |
|   Reliability: 87%  |  Signals: 142      |
|   Last signal: 23 min ago                |
|   [Remove]                               |
+------------------------------------------+
| @binance                                 |
|   Reliability: 94%  |  Signals: 89       |
|   Last signal: 1h ago                    |
|   [Remove]                               |
+------------------------------------------+
| @kucoincom                               |
|   Reliability: 72%  |  Signals: 56       |
|   Last signal: 4h ago                    |
|   [Remove]                               |
+------------------------------------------+
|                                          |
| Recommended Channels                     |
+------------------------------------------+
| @coingecko            [Add]              |
| @coinmarketcap        [Add]              |
| @crypto_news_feed     [Add]              |
+------------------------------------------+
```

### 14.3 Channel Reliability Stats

Za svaki aktivni kanal vidiš:
- **Reliability %** — postotak signala iz tog kanala koji su se poklopili s kasnijim price movementom. Viši % = pouzdaniji kanal.
- **Signals** — ukupni broj signala koje je Monitor uhvatio iz tog kanala
- **Last signal** — koliko davno je zadnji signal stigao

Ovi podaci se nakupljaju vremenom. Prvih tjedan dana nemoj očekivati precizne reliability brojke — treba barem 20-30 signala za smislenu statistiku.

### 14.4 Dodavanje kanala

1. Tapni **[+ Add Channel]** na vrhu
2. Upiši username kanala (npr. `@crypto_signals_xyz`)
3. Tapni **Add**
4. Monitor počinje pratiti taj kanal

Alternativno, iz **Recommended Channels** sekcije tapni **[Add]** pored kanala.

### 14.5 Uklanjanje kanala

Na aktivnom kanalu tapni **[Remove]**. Confirm dialog → kanal se uklanja. Postojeći signali iz tog kanala ostaju u povijesti, ali novi se više ne skupljaju.

### 14.6 Preporuke za kanale

- **Počni s default-ima** (@binance, @kucoincom, @whale_alert, @coingecko, @coinmarketcap)
- **Dodaj specifične** tek kad vidiš da ti trebaju (npr. kanali fokusirani na DeFi, meme coinove, itd.)
- **Prati Reliability %** — ako kanal ima <50% reliability nakon 50+ signala, razmisli o uklanjanju
- **Ne dodaj previše** — 5-10 kanala je optimalno. Previše kanala = previše šuma

---

## 15. Tipični scenariji

### 15.1 Scenarij A — Jutarnja seansa (15 minuta)

**08:30** — kava, otvaraš CoinSight.

1. [*] Watchlist → New Listings — pregled jutrošnjih movers-a
2. Vidiš 3 zanimljiva (1H +10%+) → tapneš zvjezdicu na sva 3
3. [**] Analysis tab → primjećuješ narančasti badge "2 Telegram signala čekaju" — whale_alert i binance su nešto uhvatili preko noći
4. Tapneš **"Analiziraj New Listings"**
5. Claude analizira sva 3 + BTC/ETH/SOL referencu + Telegram signale
6. Claude proglašava jednog **INTERESTING**, napominjući da Telegram intel potvrduje volumen trend
7. Trade Action Bar → BUY NOW → CONFIRM → pozicija otvorena
8. [$] Portfolio → vidiš novu poziciju, Now cijena, P&L u realnom vremenu
9. Zatvaraš app, ideš na posao

### 15.2 Scenarij B — Pada cijena, SL triggera

**14:00** — radiš posao. App je u pozadini.

- Jutrošnja pozicija PEPR s entry $0.000423, SL $0.000381
- U 13:47 cijena pada na $0.000378 → timer u 13:50 provjeri → SL triggera → market sell
- Kad sljedeći put otvoriš app, u Portfolio vidiš zatvorenu poziciju u History sekciji
- P&L: -$0.52

### 15.3 Scenarij C — Take-profit pogodak

- Drugi dan, nova pozicija po $0.001, TP na $0.00130 (+30%)
- Coin naraste na $0.00135 u 18:22 → timer provjeri u 18:25 → TP triggera → sell po ~$0.00133
- +$0.63 na $5 početni ulog (12.6% net)
- Portfolio total P&L se ažurira, USDT balance raste

### 15.4 Scenarij D — Telegram signal pomaže

**11:00** — na poslu si, otvoriš CoinSight na pauzi.

1. Narančasti badge na Analysis tabu: "1 Telegram signal čeka"
2. Otvoriš Analysis, signal kaže: "whale_alert: 200M XYZ transferred to Binance"
3. Pitaš Claudea: "Koji coin sada ima momentum?"
4. Claude odgovara: "XYZ je zanimljiv — whale alert potvrduje da se velika količina premješta na exchange, što može značiti predstojeći listing ili veliki trade. WATCH — provjeri za sat vremena je li volumen nastavio rasti."
5. Dodaješ XYZ u watchlist, čekaš sat, pitaš opet
6. Claude: "XYZ volumen se utrostručio u zadnjem satu, consistent s Telegram signalom. INTERESTING."
7. BUY NOW → pozicija otvorena s dodatnim kontekstom

### 15.5 Scenarij E — Tjedan kasnije, pregled

**Nedjelja večer** — pregled tjedna.

1. [$] Portfolio tab → **Analysis History** sekcija (dolje)
2. Brojiš zapise:
   - 18 INTERESTING signala
   - Od toga 12 ENTERED (ušao)
   - Od toga 7 EXITED s profitom (TP ili manual close u plus)
   - 5 EXITED na SL
3. **Hit rate: 7/12 = 58%**. Net rezultat: +$4.30 za tjedan
4. Otvoriš Bot Manager → provjeravaš channel reliability — @whale_alert na 87%, @binance na 94%
5. Koristiš to za kalibraciju — sljedeći tjedan prilagodavaš strategiju

### 15.6 Scenarij F — Korištenje App kontrola

**Kraj mjeseca** — čistka.

1. [=] Manage → **App** pod-tab
2. **Export logs to clipboard** → paste u bilješku ili pošalji developeru za debug
3. **Clear analysis history** → briše stare Claude chat logove (pozicije na Binanceu ostaju netaknute)
4. Po potrebi: **Full reset** → vraća sve na tvorničko stanje (korisno ako mijenjaš uredjaj ili počinješ iznova)

---

## 16. Problemi i rješenja

### 16.1 Claude ne odgovara

**"Invalid API key"** → Manage → API → Anthropic → Remove → novi ključ s console.anthropic.com

**"Rate limit exceeded"** → Pričekaj minutu, pa ponovi. Ne spamati.

**"credit balance too low"** → Na console.anthropic.com dodaj kredit (par dolara dovoljno).

**"Failed to get response. Check your connection."** → Provjeri internet. Pokušaj na WiFi-u ako si bio na mobilnim.

### 16.2 Binance greške

**"Invalid API-key, IP, or permissions"** → IP restrikcija uključena a IP se ne poklapa. Binance API Management → Edit Restrictions → dodaj IP ili isključi IP restriction.

**"Timestamp out of sync" / Error -1021** → App u v3.0.0 automatski sinkronizira vrijeme sa Binance serverom. Ako se greška ponavlja:
- Windows: Settings → Time → Sync now
- Android: automatski time postavi (Settings → Date & time → Automatic)
- App automatski dohvaća server time putem `/api/v3/time` i računa offset

**"Insufficient USDT balance"** → Nemaš dovoljno USDT-a na **Spot wallet**-u. Možda ti je USDT u Funding ili Futures. Na Binanceu: Wallet → Transfer → prebaci u Spot.

**"Max open positions reached"** → Zatvori neku poziciju prije kupnje nove.

**"Filter failure: LOT_SIZE"** → U v3.0.0 ovo je riješeno — app dinamički dohvaća `stepSize` iz `/exchangeInfo`. Ako se ipak pojavi, zatvori i ponovo otvori app. Ako problem ostane, prijavi kao bug.

**"Filter failure: MIN_NOTIONAL"** → Iznos tradea je premali za taj coin. Povećaj Max trade amount u Manage → Trade.

### 16.3 Portfolio

**Balance $0.00 ali imam USDT** → USDT vjerojatno nije u **Spot wallet-u**. Binance: Wallet → prebaci u Spot.

**Pozicija se ne pojavljuje** → Pull-to-refresh na Portfolio tabu. Ako i dalje ne → provjeri Binance web direktno jesi li stvarno kupio.

**Current Price zastario** → 30s auto-refresh radi samo dok si na tabu. Vrati se na Portfolio → pull-to-refresh.

### 16.4 Telegram Monitor

**Monitor ne hvata signale** → Provjeri:
1. Je li Bot Token ispravan? Manage → Bot → provjeri token
2. Je li "Aktiviraj monitoring" uključen?
3. Je li bot dodan kao admin u kanale?
4. Jesu li kanali javni? (Privatni kanali zahtijevaju poziv)
5. Objavljuju li kanali uopće nešto s ključnim riječima?

**Signal badge se ne pojavljuje** → Provjeri da su kanali aktivni i da objavljuju sadržaj s keywordima. Otvori Bot Manager → provjeri "Last signal" za svaki kanal.

**Bot Manager pokazuje Reliability 0%** → Normalno na početku. Treba barem 20-30 signala za smislenu statistiku. Daj mu tjedan-dva.

### 16.5 App se zaglavi

Force close → ponovno otvori. Flutter app-e često samo treba restart.

### 16.6 Timestamp greške (-1021)

Specifično za Binance — server odbija zahtjev jer je razlika u vremenu prevelika.

**v3.0.0 rješenje:** App automatski sinkronizira putem Binance `/api/v3/time` endpointa. Ako se -1021 pojavi, app automatski:
1. Dohvaća server time
2. Računa offset
3. Ponavlja zahtjev

Ako se greška uporno ponavlja (rijetko), provjeri da tvoj uredjaj ima **automatsko postavljanje vremena** uključeno.

---

## 17. Sigurnost

### 17.1 API ključevi su tajni

- **Nikad** ne dijeli Anthropic, Binance, ili Telegram ključ s nikim
- **Nikad** ne pastaj ih u Discord, Reddit, Twitter ni uz najbolje namjere
- **Nikad** ne vjeruj "Binance support agentu" koji tebe pita za ključeve — **to je scam 100%**

### 17.2 Binance ključ MORA imati isključen Withdrawal

Ponavljam jer je kritično: ako zaboraviš isključiti Withdrawal i netko ukrade ključ → izvuku ti novac. Ako je Withdrawal OFF, u najgorem slučaju mogu ti izgubiti novac kroz loše tradeove — ali ne mogu ga izvući.

### 17.3 Device security

Tvoj telefon/PC = tvoj sef.
- **PIN / lozinka / biometrija**: obavezno
- Ne ostavljaj uredjaj nezaključan
- Ako izgubiš uredjaj: hitno → Binance web → API Management → delete sve ključeve. Anthropic console → revoke keys. Telegram → BotFather → `/revoke`.

### 17.4 Backup

CoinSight čuva sve lokalno (u Hive bazi). Ako resetiraš telefon, gubiš:
- Spremljene API ključeve (generiraš nove)
- Watchlist izbor
- Analysis history
- Telegram Monitor konfiguraciju i signal povijest
- Tvoju snimku pozicija (ali **pozicije ostaju na Binanceu** — vidiš ih kroz Binance web direktno)

Preporuka: u sigurnu bilješku (password manager, Bitwarden/1Password/KeePass) zapiši:
- Anthropic API key
- Binance API key + Secret
- Telegram Bot Token
- Tvoje Risk Parameters

### 17.5 Open source sigurnost

CoinSight je open source (MIT licenca). To znači:
- Kod je javno dostupan za inspekciju
- Nema "skrivene" funkcionalnosti
- Zajednica može prijaviti sigurnosne probleme
- Ti možeš verificirati da app radi upravo ono što kaže

Ako nadješ sigurnosni problem u kodu, prijavi ga kao GitHub Issue.

### 17.6 Telegram Monitor sigurnost

- Bot Token daje pristup samo **čitanju** poruka iz kanala u kojima je bot admin
- Bot **ne može** pristupiti tvojim privatnim porukama
- Bot **ne može** slati poruke u tvoje ime
- Bot **ne može** pristupiti tvom Telegram accountu

### 17.7 WalletConnect sigurnosna pravila

- **Nikad ne odobravaj transakciju** u MetaMask/Phantom ako ne prepoznaješ što se traži
- **Provjeri iznos i token** u MetaMask potvrdi prije tapanja "Confirm"
- **Diskonektaj wallet** iz CoinSight kad ga ne koristiš (Portfolio tab → WalletConnect button → Disconnect)
- **Koristit manji wallet** za DEX trading — nemoj spajati wallet s većinom svojih sredstava. Drži samo iznos koji planiraš koristiti za trading (npr. $50-100 u BNB/SOL za gas + tradeable iznos)
- **Seed phrase ostaje offline** — WalletConnect nikad ne traži seed phrase. Ako itko ili ikoja app traži seed phrase, to je scam.

---

## 18. Često postavljana pitanja

**Q: Moram li imati Binance account?**
A: Za Watchlist + Claude chat — ne. Za stvarno trgovanje — da. Binance je jedini podržani exchange.

**Q: Mogu li koristiti Kraken / Coinbase / Revolut?**
A: Trenutno ne. CoinSight je napravljen specifično za Binance Spot.

**Q: Koliko košta mjesečno?**
A: Anthropic AI: $5-30 (ovisno o aktivnosti). Binance fee: 0.1% po tradeu (za $100 trade = $0.10). CoinSight app: besplatno (open source).

**Q: Mogu li izgubiti sav novac?**
A: Da, teoretski. Ako svi trejdovi završe na SL-u i nastaviš, možeš doći na nulu. **Zato postavljaj konzervativne parametre i ne ulaži više nego možeš izgubiti.**

**Q: Je li CoinSight "get rich quick" shema?**
A: Ne. Ovo je alat za discipliniran, sistematičan pristup momentum tradingu. Može biti profitabilan ako si **strpljiv** i **disciplinovan** s risk managementom.

**Q: Što ako Claude daje uzastopne loše signale?**
A: Pauziraj trgovanje, pregledaj Analysis History u Portfolio tabu. Možda market uvjeti nisu za momentum. Vrati se za dan-dva.

**Q: Kako isplatiti profite na Revolut?**
A: Na Binanceu: Spot → Convert USDT u EUR → Withdraw SEPA na svoj Revolut IBAN. Traje 1-2 radna dana. CoinSight **ne** radi withdrawal.

**Q: Mogu li koristiti VPN s Binanceom?**
A: Binance tehnički dozvoljava ali preporučuje da ne. Ako uključiš IP restrictions na ključu, VPN + IP restrictions = konflikt.

**Q: Što ako Binance banuje moj račun?**
A: CoinSight nije odgovoran. Prati Binance TOS. API ključ bez withdrawal permission je manje rizičan za ban.

**Q: Mogu li CoinSight dijeliti s prijateljem?**
A: Da! CoinSight je open source pod MIT licencom. Slobodno dijeli, forkaj, modificiraj. Izvorni kod je javno dostupan.

**Q: Što ako ne razumijem Claudeov odgovor?**
A: Pitaj Claudea dalje. "Objasni detaljnije." Ili "Na hrvatskom molim." Claude prilagodava jezik i detalj.

**Q: Zašto nema detail view za coin (tap na karticu)?**
A: Trenutno nema. Planirano za sljedeću verziju.

**Q: Što je Telegram Monitor i moram li ga koristiti?**
A: Telegram Monitor pasivno čita javne kripto kanale i skuplja intelligence signale za Claudea. Nije obavezan — app radi i bez njega. Ali s njim Claude ima bolji kontekst za analizu.

**Q: Treba li mi Chat ID za Telegram?**
A: Ne. Chat ID više nije potreban. Telegram Monitor samo treba Bot Token jer čita kanale, ne šalje poruke tebi.

**Q: Zašto se više ne može slati signal na Telegram?**
A: TELEGRAM button je uklonjen iz Trade Action Bara. Telegram je u v3.0.0 prenamijenjen iz notifikacijskog bota u intelligence monitor. Trade Action Bar sada ima samo BUY NOW i SKIP.

**Q: Što je LOT_SIZE greška?**
A: U ranijim verzijama, sell orderi ponekad nisu poštivali Binance-ov zahtjev za preciznost količine. U v3.0.0, app dinamički dohvaća `stepSize` iz `/exchangeInfo` i pravilno zaokružuje količinu. Greška bi trebala biti riješena.

**Q: Što su tri tier-a (SHORT/MID/LONG) i koji koristiti?**
A: Three-Tier Investment Framework (v4.0.0) ti omogucava tri razlicita pristupa investiranju. **SHORT** je za brzi momentum trading (sati do 48h) — isto kao sto je CoinSight radio prije. **MID** je za srednjorocne projekte s jasnim katalystom (tjedni do mjeseci) — koristis ga kad vidis coin s predstojecim launchom ili partnerstvom. **LONG** je za dugorocna fundamentalna ulaganja s DCA kupnjama (mjeseci+) — koristis ga za coinove u koje dugorocno vjerujes. Pocni s SHORT, prebaci na MID/LONG kad ti bude trebalo.

**Q: Što je Intelligence Layer i kako ga koristiti?**
A: Intelligence Layer je sustav koji prikuplja podatke iz 5 izvora (Dexscreener, GitHub, Reddit, Telegram, Market Cap) i gradi obavještajni izvještaj s confluence score-om (0-6.0). Najlakše ga koristiš tapom na "Analiziraj" button na DEX Early kartici. Vidi sekciju 13A za detalje.

**Q: Što je confluence score?**
A: Mjera koliko nezavisnih izvora se slaže oko signala za coin. Score ide od 0 do 6.0. Viši score = više izvora potvrduje isti trend = jači signal. Score 3+ znači da barem 3 izvora daju pozitivan signal.

**Q: Što ako mi se app resetira?**
A: Koristi Manage → App → Export logs before reset. Za potpuni reset: Manage → App → Full reset. Binance pozicije ostaju na Binanceu neovisno o app-u.

**Q: Koliko testova ima CoinSight?**
A: Test suite sadrži **280 testova** koji pokrivaju servise, widgete i integracije.

**Q: Što znači "Timestamp out of sync" greška?**
A: Binance zahtijeva da se tvoj sat poklapa sa server vremenom. App u v3.0.0 automatski sinkronizira putem `/api/v3/time`. Ako se greška ponovi, provjeri da je automatsko vrijeme uključeno na uredjaju.

**Q: Trebam li WalletConnect za korištenje CoinSighta?**
A: Ne. WalletConnect je opcionalan. App savršeno radi bez njega — možeš analizirati, pratiti i trgovati kroz Binance. WalletConnect dodaješ samo ako planiraš DEX trading s MetaMask walletom.

**Q: Je li moj wallet siguran s WalletConnectom?**
A: Da. WalletConnect **nikad** ne daje CoinSightu pristup tvojim privatnim ključevima ili seed phrase-u. Svaka transakcija zahtijeva tvoje eksplicitno odobrenje u MetaMask/Phantom aplikaciji. Bez tvog tapa "Approve" — ništa se ne događa.

**Q: Što je P&L Dashboard i komu služi?**
A: P&L Dashboard (Manage → Portfolio → banner) prikazuje ukupne performanse svih tvojih trade-ova: equity curve (grafikon rasta/pada), win rate (% profitabilnih trejdova), R/R ratio (prosječni profit vs gubitak), i breakdown po tieru. Koristan nakon prvih 5-10 trejdova — do tada je previše malo podataka za smislene zaključke.

---

## 19. Rječnik pojmova

| Pojam | Značenje |
|-------|----------|
| **API ključ** | Kod koji app koristi da komunicira sa servisom (Binance/Claude/Telegram) u tvoje ime |
| **Auto-trade** | Faza 3 — app automatski izvršava INTERESTING signale bez tvoje potvrde |
| **Bot Manager** | Full-screen ekran za upravljanje Telegram Monitor kanalima i statistikama |
| **Bot Token** | Tajni ključ za Telegram bota, dobiven od @BotFather |
| **BUY NOW** | Button u Trade Action Baru koji pokreće kupnju nakon potvrde |
| **ClosedTrade** | Model za zatvoreni trade — cuva entry/exit price, P&L, tier, razlog zatvaranja |
| **CoinGecko** | Besplatan crypto market data servis. CoinSight ga koristi za Watchlist podatke |
| **Confluence Score** | Mjera koliko nezavisnih izvora se slaže oko signala (0-6.0). Viši = jači signal |
| **Confirm LIVE** | Warning dialog kad prebacuješ s testnet-a na pravi Binance |
| **DCA (Dollar-Cost Averaging)** | Strategija kupnje fiksnog iznosa u redovitim intervalima, neovisno o cijeni — smanjuje utjecaj volatilnosti |
| **DEX** | Decentralizirana burza (Decentralized Exchange) — trgovanje bez posrednika, direktno na blockchainu (npr. Uniswap, PancakeSwap) |
| **DEX Early** | Prvi pod-tab Watchlist-a, prikazuje svježe DEX listinge detektirane putem Dexscreenera |
| **DEX Position Screen** | Ekran za upravljanje DEX pozicijama — rucni unos trade-ova, automatski price refresh, SL/TP monitoring |
| **DexPosition** | Model za rucno pracenu DEX poziciju: token, entry cijena, kolicina, DEX, chain, SL/TP razine |
| **Dexscreener** | Servis koji prati nove tokene na decentraliziranim burzama. Intelligence Layer ga koristi za DEX Early tab |
| **ENTERED** | Oznaka u Analysis History za trenutak kad si otvorio poziciju |
| **Equity Curve** | Grafikon kumulativnog P&L-a kroz vrijeme — prikazuje ukupni rast ili pad portfolija |
| **EXITED** | Oznaka u Analysis History za trenutak kad si zatvorio poziciju |
| **exchangeInfo** | Binance endpoint koji vraća pravila za svaki trading par (stepSize, minNotional, itd.) |
| **Faza 2** | Manualni mode — ti potvrduješ BUY kroz Trade Action Bar |
| **Faza 3** | Automatski mode — app sama kupuje na INTERESTING |
| **Fundamental Hold** | LONG tier pristup — kupnja coina na osnovu duboke fundamentalne analize (team, tech, adoption) |
| **Full reset** | Opcija u Manage → App koja briše sve lokalne podatke i vraća app na tvorničko stanje |
| **Hive** | Lokalna baza podataka unutar app-e (čuva ključeve, watchlist, pozicije) |
| **Intelligence Layer** | Multi-source obavještajni sustav koji prikuplja podatke iz 5 izvora (DEX, GitHub, Reddit, Telegram, MCap) |
| **Intelligence Report** | Obavještajni izvještaj koji Intelligence Layer generira, sadrži podatke iz svih izvora i confluence score |
| **IntelligenceAggregator** | Komponenta koja objedinjuje podatke iz svih 5 izvora u IntelligenceReport |
| **InvestmentTier** | Enum koji definira tri investicijska moda: SHORT, MID, LONG — kontrolira ponasanje Analysis i Portfolio tabova |
| **INTERESTING** | Claude preporuka "razmatraj ulaz s malim iznosom" |
| **Keyword filtering** | Filtriranje Telegram poruka po ključnim riječima (listing, whale, alert...) |
| **KYC** | "Know Your Customer" — Binance verifikacija identiteta (osobna + selfie) |
| **Liquidity** | Količina sredstava dostupnih u DEX pool-u za trgovanje. Veća likvidnost = manji slippage |
| **LONG Research** | Pod-tab u Watchlist-u (LONG tier), prikazuje filtrirani top 200 coinova po market capu za fundamentalnu analizu |
| **LONG tier** | Dugorocni investicijski mod (mjeseci do godine+) — fokus na fundamentalnu analizu, DCA kupnje, i praćenje fundamentala |
| **LongHoldingDetailScreen** | Detaljan ekran za LONG holding s 4 taba: Osnove, Fundamentali, DCA, Biljeske |
| **LOT_SIZE** | Binance filter koji definira minimalnu i maksimalnu količinu tokena te stepSize za trade |
| **Manage tab** | Četvrti tab u navigaciji (ikona tune), sadrži 5 pod-tabova: API, Bot, Trade, Tiers, App |
| **Market cap** | Ukupna vrijednost svih coinova u opticaju u USD |
| **MID Discovery** | Pod-tab u Watchlist-u (MID tier), prikazuje live GitHub trending kripto projekte |
| **MID tier** | Srednjorocni investicijski mod (tjedni do mjeseci) — fokus na projekte s katalystom, target price, i deadline praćenje |
| **MidProjectDetailScreen** | Detaljan ekran za MID projekt — editiranje thesis, GitHub linka, entry plana, upravljanje statusom i biljeske |
| **Market order** | Kupnja/prodaja **po trenutnoj tržišnoj cijeni** (ne limit) |
| **MIT licenca** | Open source licenca koja dozvoljava slobodno korištenje, modifikaciju i distribuciju |
| **My Watchlist** | Tvoj izbor coinova (označeni zvjezdicom) |
| **New Listings** | Drugi pod-tab Watchlist-a, small-cap coinovi s 1h momentum-om |
| **P&L** | "Profit and Loss" — koliko si trenutno u plusu/minusu |
| **P&L Dashboard** | Full-screen ekran s equity curve, win rate, R/R ratio, per-tier breakdown i trade history |
| **PnlAnalytics** | Model koji racuna P&L metrike: win rate, R/R ratio, equity curve podatke, per-tier statistike |
| **Quiet hours** | Sati kad auto-trade NE kupuje (default 23:00-07:00) |
| **Rank** | Market cap rank — pozicija po veličini medju svim coinovima |
| **Reliability %** | Postotak točnosti signala iz pojedinog Telegram kanala (prikazan u Bot Manageru) |
| **R/R Ratio (Risk/Reward)** | Prosjecni omjer profita naspram gubitka na trade-ovima — visi R/R = bolje upravljanje rizikom |
| **Risk Parameters** | Tvoje postavke u Manage → Trade: max iznos, max pozicije, SL%, TP% |
| **Signal badge** | Narančasti banner na Analysis tabu koji pokazuje broj pending Telegram signala |
| **SKIP** | Claude preporuka "previše rizično, ne diraj" |
| **Slippage** | Razlika izmedju očekivane i stvarne cijene pri tradu (tipično <1% kod većih coinova) |
| **Sparkline** | Mini 7-dnevni grafikon u CoinCard-u |
| **Spot** | Direktno trgovanje coinom (kupuješ, imaš ga, prodaš). Za razliku od Futures |
| **stepSize** | Minimalni inkrement količine za Binance order (npr. 0.001 znači 3 decimale) |
| **Stop-loss (SL)** | Donja granica cijene kod koje app prodaje (zaustavi gubitak) |
| **Suggestion chip** | Preddefinirano pitanje u Analysis tabu (tapneš, pošalje umjesto tebe) |
| **Take-profit (TP)** | Gornja granica cijene kod koje app prodaje (zaključa profit) |
| **Telegram Intel** | Obavještajni podaci prikupljeni iz Telegram kanala putem Monitora |
| **Telegram Monitor** | Pasivni sustav koji čita javne Telegram kanale i filtrira signale za AI analizu |
| **Testnet** | Binance simulator s lažnim novcem (testnet.binance.vision) |
| **TierModeSelector** | UI widget (banner ispod AppBara) s tri buttona (SHORT/MID/LONG) za prebacivanje aktivnog investicijskog tier-a |
| **Tier-1 exchange** | Veliki, regulirani exchange (Binance, Coinbase, Kraken) |
| **Timestamp sync** | Automatska sinkronizacija vremena s Binance serverom putem /api/v3/time |
| **Top Coins** | Četvrti pod-tab Watchlist-a, top 25 coinova po market capu |
| **Trade Action Bar** | Okvir u Analysis tabu koji se pojavljuje kod INTERESTING signala (BUY NOW / SKIP) |
| **USDT** | Tether — stablecoin (1 USDT = ~$1). Koristi se kao "keš" u Binance Spot tradingu |
| **V/L ratio** | Volume/Liquidity omjer — mjera aktivnosti tradinga u odnosu na likvidnost DEX pool-a |
| **Value Discovery** | MID tier pristup — identifikacija coinova s neotkrivenom vrijednoscu i predstojecim katalystom |
| **Volume** | 24h trading volumen u USD-u |
| **WATCH** | Claude preporuka "ima potencijal, provjeri opet kasnije" |
| **WalletConnect** | Otvoreni protokol za sigurno spajanje crypto walleta na dApps — CoinSight koristi v2 za wallet konekciju i swap inicijaciju |
| **Withdrawal** | Povlačenje novca s Binance-a (CoinSight NE koristi; API ključ NE smije imati) |
| **Win Rate** | Postotak trade-ova koji su zavrsili s profitom — kljucna metrika u P&L Dashboardu |

---

## Kraj priručnika

### Korak-po-korak za prvi dan

```
1. Instaliraj APK → pokreni → prihvati dozvole
2. Manage → API → Anthropic API Key → zalijepi → Save
3. Manage → API → Binance API → zalijepi oba ključa → Testnet ON → Save → Test
4. Manage → Bot → Bot Token → zalijepi → Save → uključi monitoring
5. (Opcionalno) Manage → API → WalletConnect Project ID → Save
6. Watchlist → DEX Early → pregledaj svježe listinge
7. Analysis → tapni suggestion chip → pročitaj Claude analizu
8. Portfolio → provjeri balans
9. Manage → Trade → postavi konzervativno (5 USDT, 1 pozicija, 10% SL)
10. Analysis → INTERESTING signal → BUY NOW → CONFIRM → prva pozicija
```

### Ključna pravila koja ne smiješ zaboraviti

1. **Binance API** — Withdrawal dozvola mora biti **ISKLJUČENA**
2. **Seed phrase** — samo na papiru, nikad digitalno, nikad ne dijeli
3. **Počni malim** — $5 po trejdu, 1 pozicija, prvih 2 tjedna
4. **Stop-loss je obavezan** — uvijek postavljaj, bez iznimke
5. **INTERESTING nije garancija** — 30-40% trejdova će biti gubitnici (normalno)
6. **Konzistentnost pobjeđuje** — bolje 60% win rate s malim iznosima nego 90% win rate koji se ne može ponoviti

**CoinSight v7.0.0** — Open Source, MIT License, 280/280 testova

Sretno!

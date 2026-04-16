# CoinSight v7.0.0 — Vodic za pocetnike

**Verzija:** 7.0.0 | **Datum:** 2026  
**Jezik:** Hrvatski (HR)  
**Ciljna publika:** Potpuni pocetnici — nikad koristili kripto, wallet ili trading app

> Ovaj vodic objasnjava SVE sto trebas znati da postavis i koristis
> CoinSight, cak i ako nikad nisi cuo za API kljuceve, crypto wallet
> ili decentralizirane burze. Kreci polako, korak po korak.

---

## Sadrzaj

1. [Sto je CoinSight i sto radi?](#1-sto-je-coinsight-i-sto-radi)
2. [Sto ti treba za pocetak](#2-sto-ti-treba-za-pocetak)
3. [Claude AI postavljanje](#3-claude-ai-postavljanje)
4. [Telegram Monitor postavljanje](#4-telegram-monitor-postavljanje)
5. [MetaMask wallet postavljanje](#5-metamask-wallet-postavljanje)
6. [Phantom wallet postavljanje (Solana)](#6-phantom-wallet-postavljanje-solana)
7. [Binance racun](#7-binance-racun)
8. [Prvi koraci u CoinSightu](#8-prvi-koraci-u-coinsightu)
9. [Razumijevanje tri tiera (SHORT/MID/LONG)](#9-razumijevanje-tri-tiera-shortmidlong)
10. [Tvoja prva analiza s Claudeom](#10-tvoja-prva-analiza-s-claudeom)
11. [Tvoj prvi trade](#11-tvoj-prvi-trade)
12. [Razumijevanje grafikona](#12-razumijevanje-grafikona)
12A. [WalletConnect postavljanje](#12a-walletconnect-postavljanje)
12B. [P&L Dashboard za pocetnike](#12b-pl-dashboard-za-pocetnike)
13. [Rjecnik pojmova](#13-rjecnik-pojmova)
14. [Sigurnosna pravila](#14-sigurnosna-pravila)

---

## 1. Sto je CoinSight i sto radi?

CoinSight je tvoj **pametni asistent za pracenje cryptocurrency trzista**.

Zamisli ga ovako: umjesto da sam satima sijedis i pratis grafikone,
citas vijesti na 10 razlicitih kanala, analiziras podatke i pokusavas
zakljuciti sto se dogadja na trzistu — CoinSight to radi za tebe.

**Kako to funkcionira?**

```
+-------------------+     +------------------+     +------------------+
|  IZVORI PODATAKA  | --> |    COINSIGHT      | --> |   TI ODLUCUJES   |
|                   |     |                   |     |                  |
| - CoinGecko API   |     | - Skuplja podatke |     | - Kupi / Ne kupi |
| - DEX skeneri     |     | - Salje Claudeu   |     | - Postavi SL/TP  |
| - Telegram kanali |     | - Prikazuje       |     | - Prati P&L      |
| - On-chain podaci |     |   analizu         |     |                  |
| - Drustvene mreze |     |                   |     |                  |
+-------------------+     +------------------+     +------------------+
```

**Jednostavno receno:**
- CoinSight **prikuplja** informacije iz vise izvora
- **Salje** ih Claude AI-u na analizu
- **Prikazuje** ti rezultat — s preporukom i ocjenom
- **Ti odlucujes** sto ces napraviti s tom informacijom

CoinSight **nije** automatski bot koji trguje za tebe bez pitanja.
CoinSight **jest** alat koji ti daje pametne informacije da sam doneses
bolju odluku.

### Tri nacina rada (Tiera)

CoinSight ima tri potpuno razlicita nacina rada, svaki za drugu
strategiju ulaganja:

| Tier | Naziv | Vremenski horizont | Rizik | Za koga |
|------|-------|--------------------|-------|---------|
| ⚡ | SHORT | Sati do dana | Visok | Iskusnije korisnike |
| 📈 | MID | Tjedni do mjeseci | Srednji | Vecinu korisnika |
| 🏛️ | LONG | Mjeseci do godina | Nizi | Sve korisnike |

Vise o svakom tieru u [poglavlju 9](#9-razumijevanje-tri-tiera-shortmidlong).

---

## 2. Sto ti treba za pocetak

> **Kratka verzija za nestrpljive:**
> Jedino što je **obavezno** je **Anthropic API ključ** (sekcija 3).
> Sve ostalo (Telegram, MetaMask, Phantom, Binance) dodaješ po potrebi.
> Možeš početi koristiti CoinSight za analizu i praćenje **bez ijednog drugog servisa**.

### Minimalni zahtjevi

- 📱 **Smartphone** (Android ili iOS) ili **racunalo** s browserom
- 🌐 **Internet konekcija** — stabilna, ne mora biti brza
- 📧 **Email adresa** — za registraciju na servise
- 💳 **Kartica** (Visa/Mastercard) — za Anthropic i/ili Binance deposit

### Sto ces registrirati (redoslijedom)

```
+-------+---------------------------+------------+------------------+
| Korak | Servis                    | Obavezno?  | Traje            |
+-------+---------------------------+------------+------------------+
|   1   | Anthropic (Claude AI)     | DA         | 5 minuta         |
|   2   | Telegram (Bot)            | Preporuceno| 10 minuta        |
|   3   | MetaMask (ETH/BSC wallet) | Za SHORT   | 10 minuta        |
|   4   | Phantom (Solana wallet)   | Za SHORT   | 10 minuta        |
|   5   | Binance (centralna burza) | Za MID/LONG| 15 min + KYC     |
+-------+---------------------------+------------+------------------+
```

### Preporuceni raspored

Nemoj pokusavati sve odjednom. Idi dan po dan:

```
Dan 1:  Anthropic API kljuc --> instaliraj CoinSight --> testiraj analizu
Dan 2:  Telegram bot --> dodaj u kanale --> testiraj Intelligence feed
Dan 3:  MetaMask --> dodaj BSC mrezu --> kupi 5-10 EUR BNB za gas
Dan 4:  Phantom --> kupi 0.1 SOL za gas
Dan 5:  Binance API --> testnet prvo --> provjeri TEST CONNECTION
Dan 6+: Pocni s malim iznosima (5-25 EUR) --> prati rezultate
```

---

## 3. Claude AI postavljanje

### Sto je Claude AI?

Claude je umjetna inteligencija koju je napravio Anthropic. CoinSight
koristi Claudea za analizu kripto podataka — salje mu sve prikupljene
informacije i Claude vraca strukturiranu analizu s ocjenom i preporukom.

**Svaka analiza kosta oko ~0.003 USD** (manje od 1 lipe). Cak i ako
napravis 100 analiza dnevno, to je oko 0.30 USD (~2 kune).

### Korak po korak: Registracija i API kljuc

▶ **Napravi sad:**

**Korak 3.1 — Otvori Anthropic Console**

1. Otvori browser i idi na: **https://console.anthropic.com**
2. Klikni **"Sign Up"** (ili "Get Started")
3. Unesi svoju email adresu
4. Postavi lozinku (snaznu, barem 12 znakova)
5. Potvrdi email — otvori inbox i klikni link za verifikaciju

**Korak 3.2 — Dodaj nacin placanja**

1. Nakon sto si ulogiran, idi na **"Billing"** u lijevom meniju
2. Klikni **"Add Payment Method"**
3. Unesi podatke kartice (Visa ili Mastercard)
4. Nece ti se odmah nista naplatiti — placa se samo ono sto potrosis

> 💡 **Savjet:** Anthropic obicno daje $5 besplatnog kredita novim
> korisnicima. To je dovoljno za ~1600 analiza!

**Korak 3.3 — Generiraj API kljuc**

1. U lijevom meniju klikni **"API Keys"**
2. Klikni **"Create Key"**
3. Daj kljucu ime, npr. `CoinSight-Mobile`
4. Klikni **"Create"**
5. Pojavit ce se kljuc koji izgleda ovako:

```
sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

6. **ODMAH GA KOPIRAJ!** Ovo je jedini put kad ces ga vidjeti u cijelosti.

> ⚠️ **VAZNO:** Ako zatvaris prozor bez kopiranja, moras generirati novi kljuc.
> Stari vise neces moci vidjeti.

**Korak 3.4 — Unesi kljuc u CoinSight**

1. Otvori CoinSight aplikaciju
2. Idi na **Manage** tab (ikona zupcanika)
3. Tapni na **"API"** sekciju
4. Pronadi polje **"Anthropic API Key"**
5. Zalijepi kopirani kljuc
6. Tapni **"Save"**
7. Tapni **"Test Connection"** — trebas vidjeti zelenu kvacicu ✅

```
+------------------------------------------+
|  Manage > API Configuration              |
+------------------------------------------+
|                                          |
|  Anthropic API Key                       |
|  +------------------------------------+  |
|  | sk-ant-api03-xxxxxxxxxxxxxxxxxx... |  |
|  +------------------------------------+  |
|                                          |
|  [Save]        [Test Connection ✅]      |
|                                          |
+------------------------------------------+
```

### Rjesavanje problema

| Problem | Rjesenje |
|---------|----------|
| "Invalid API Key" | Provjeri da si kopirao cijeli kljuc, ukljucujuci `sk-ant-` prefiks |
| "Insufficient credits" | Dodaj sredstva na Billing stranici Anthropica |
| "Connection timeout" | Provjeri internet konekciju i pokusaj ponovo |
| "Rate limited" | Sacekaj 60 sekundi i pokusaj ponovo |

---

## 4. Telegram Monitor postavljanje

### Sto je Telegram Monitor?

CoinSight moze pratiti javne Telegram kanale kripto burzi, whale
alertova i kripto zajednica. Bot cita objave i ukljucuje ih kao
kontekst u Claude analizu — tako Claude zna sto se trenutno dogadja
na trzistu.

**Primjer:** Ako Binance najavi listing novog coina na svom Telegram
kanalu, CoinSight ce to pokupiti i ukljuciti u analizu.

### Korak po korak: Kreiranje Telegram bota

▶ **Napravi sad:**

**Korak 4.1 — Kreiraj bota preko BotFathera**

1. Otvori **Telegram** aplikaciju (na mobitelu ili desktopu)
2. U trazilici upisi: `@BotFather`
3. Otvori razgovor s BotFatherom (ima plavu kvacicu ✅)
4. Posalji poruku: `/newbot`
5. BotFather ce te pitati za ime bota — upisi npr:
   ```
   MyCoinSightBot
   ```
6. Zatim trazi username koji mora zavrsiti na `bot`:
   ```
   my_coinsight_bot
   ```
7. BotFather ti salje poruku s tokenom:

```
Done! Your bot was created.
Token: 123456789:AAF-aBcDeFgHiJkLmNoPqRsTuVwXyZ
```

8. **Kopiraj token!** (cijeli string ukljucujuci broj i slova)

**Korak 4.2 — Unesi token u CoinSight**

1. Otvori CoinSight --> **Manage** tab
2. Idi na **"Bot"** sekciju
3. Zalijepi token u polje **"Telegram Bot Token"**
4. Tapni **"Save"**
5. Tapni **"Test"** — trebas vidjeti potvrdu da bot radi

**Korak 4.3 — Dodaj bota u kanale**

Bot mora biti dodan kao **administrator** kanala koje zelis pratiti.

1. Otvori Telegram kanal (npr. @binance_announcements)
2. Idi na **Settings** kanala (ili info)
3. **Administrators** --> **Add Administrator**
4. Pretrazi username svog bota (npr. `@my_coinsight_bot`)
5. Dodaj ga s minimalnim dozvolama (samo citanje je dovoljno)

**Preporuceni kanali za pracenje:**

```
+----------------------------+---------------------------+
| Kanal                      | Sto prati                 |
+----------------------------+---------------------------+
| @binance                   | Binance objave i listingi |
| @kucoincom                 | KuCoin objave             |
| @whale_alert               | Velike transakcije        |
| @coingecko                 | Trzisni podaci            |
| @coinmarketcap             | Trzisne vijesti           |
+----------------------------+---------------------------+
```

> 💡 **Napomena:** Telegram Monitor NIJE obavezan. CoinSight radi i bez
> njega, ali analiza ce biti bogatija ako ima vise izvora informacija.

---

## 5. MetaMask wallet postavljanje

### Sto je crypto wallet?

Crypto wallet (digitalni novcani) je aplikacija koja cuva tvoje
kriptovalute. Zamislj ga kao digitalni novcanik — ali umjesto kuna i
eura, u njemu drzis Bitcoin, Ethereum, BNB i ostale tokene.

**Vazna razlika od banke:** Banka moze resetirati tvoju lozinku.
Crypto wallet NEMA tu opciju. Ako izgubis pristup — izgubio si novac.
Zato je backup (seed phrase) kriticno vazan.

### Sto je MetaMask?

MetaMask je najpopularniji wallet za **Ethereum** i **BSC (Binance
Smart Chain)** blockchaine. Koristit ces ga za kupnju tokena koji jos
nisu dostupni na centralnim burzama kao Binance.

### Zasto BSC a ne Ethereum?

| | Ethereum | BSC |
|---|---|---|
| Gas fee (naknada) | $5 - $30 po transakciji | ~$0.01 po transakciji |
| Brzina | 15-60 sekundi | 3-5 sekundi |
| Za male iznose | ❌ Neisplativo | ✅ Idealno |

**Zakljucak:** Za pocetnika koji trguje s malim iznosima (5-50 EUR),
BSC je jedina razumna opcija jer su naknade zanemarive.

### Korak po korak: Instalacija i postavljanje

▶ **Napravi sad:**

**Korak 5.1 — Preuzmi MetaMask**

1. Idi na **https://metamask.io** (PAZI na tocnu adresu — postoje lazne stranice!)
2. Klikni **"Download"**
3. Odaberi svoju platformu:
   - **Android** --> Google Play Store
   - **iOS** --> Apple App Store
   - **Desktop** --> Chrome/Firefox/Brave extension

> ⚠️ **VAZNO:** NIKADA ne preuzimaj MetaMask s nesluzbenjih izvora.
> Samo metamask.io ili sluzbeni app store.

**Korak 5.2 — Kreiraj novi wallet**

1. Otvori MetaMask
2. Klikni **"Create a new wallet"**
3. Postavi lozinku za aplikaciju (barem 8 znakova)
4. Prihvati uvjete koristenja

**Korak 5.3 — Zapisi seed phrase (KRITICNO!)**

1. MetaMask ce ti prikazati **12 rijeci** — to je tvoj **seed phrase**
2. **Uzmi papir i olovku ODMAH**
3. Zapisi svih 12 rijeci, redoslijedom, citljivo
4. Provjeri da si tocno zapisao — MetaMask ce te testirati
5. Spremi papir na sigurno mjesto (sef, ladica na kljuc)

```
+--------------------------------------------------+
|  ⚠️  TVOJ SEED PHRASE  ⚠️                        |
|                                                  |
|  1. apple     2. banana    3. cherry             |
|  4. dragon    5. eagle     6. forest             |
|  7. guitar    8. harbor    9. island             |
|  10. jungle   11. kitten   12. lemon             |
|                                                  |
|  ZAPISI NA PAPIR! NE SCREENSHOT! NE EMAIL!       |
+--------------------------------------------------+
```

**Pravila za seed phrase:**
- ❌ NIKADA ne radi screenshot
- ❌ NIKADA ne spremi u Notes app, email ili cloud
- ❌ NIKADA ne dijeli s NIKIM (ni CoinSight ga ne trazi!)
- ❌ NIKADA ne upisuj na web stranicu
- ✅ ZAPISI na papir, spremi na fizicki sigurno mjesto
- ✅ Napravi 2 kopije i spremi na 2 razlicita mjesta

> 🔐 **Zasto je seed phrase vazan?**
> Seed phrase = tvoj novac. Tko ima seed phrase, ima pristup svemu
> u walletu. Ako izgubis telefon ali imas seed phrase — mozes
> povratiti wallet na novom uredjaju. Ako nemas seed phrase —
> novac je zauvijek izgubljen.

**Korak 5.4 — Dodaj BSC mrezu**

MetaMask po defaultu ima samo Ethereum. Moramo dodati BSC:

1. Otvori MetaMask
2. Tapni na naziv mreze na vrhu (pise "Ethereum Mainnet")
3. Tapni **"Add Network"** ili **"Add a network manually"**
4. Unesi sljedece podatke:

```
+----------------------------------+-----------------------------------+
| Polje                            | Vrijednost                        |
+----------------------------------+-----------------------------------+
| Network Name                     | BNB Smart Chain                   |
| New RPC URL                      | https://bsc-dataseed.binance.org  |
| Chain ID                         | 56                                |
| Currency Symbol                  | BNB                               |
| Block Explorer URL               | https://bscscan.com               |
+----------------------------------+-----------------------------------+
```

5. Klikni **"Save"**
6. Prebaci se na **BNB Smart Chain** mrezu

**Korak 5.5 — Napuni wallet s BNB (za gas fee)**

Trebas malo BNB-a za placanje transakcijskih naknada (gas):

1. Na Binanceu kupi BNB (ili ga vec imas)
2. Idi na **Withdraw** na Binanceu
3. Odaberi **BNB**
4. Za mrezu odaberi **BSC (BEP20)** — NE ERC20!
5. Zalijepi svoju MetaMask adresu (pocinje s `0x...`)
6. Iznos: **5-10 EUR** vrijednosti BNB je dovoljno za stotine transakcija
7. Potvrdi withdrawal

> ⚠️ **PAZI na mrezu!** Ako posaljes BNB preko krive mreze (npr. ERC20
> umjesto BEP20), novac ces IZGUBITI. Uvijek provjeri da je odabran BSC/BEP20.

```
+-----------------------------------------+
|  MetaMask                    BSC ▼      |
+-----------------------------------------+
|                                         |
|  Adresa: 0x7a3B...4f2E                  |
|                                         |
|  BNB:  0.025 (~8.50 EUR)               |
|                                         |
|  Tokens:                                |
|  (jos nema tokena)                      |
|                                         |
+-----------------------------------------+
```

---

## 6. Phantom wallet postavljanje (Solana)

### Sto je Phantom?

Phantom je **wallet za Solana blockchain** — isto kao sto je MetaMask
za Ethereum/BSC. Solana i Ethereum su potpuno razliciti blockchains
koji ne komuniciraju medjusobno, pa trebas poseban wallet za svaki.

### Zasto Solana?

| | BSC | Solana |
|---|---|---|
| Gas fee | ~$0.01 | ~$0.001 |
| Brzina transakcije | 3-5 sek | <1 sekunda |
| DEX-ovi | PancakeSwap | Raydium, Orca, Jupiter |
| Popularnost za nove tokene | Visoka | Vrlo visoka |

Solana je u 2025-2026 postala najpopularniji blockchain za nove
tokene i meme coinove. Mnogi zanimljivi projekti se prvo pojave
na Solani.

### Korak po korak

▶ **Napravi sad:**

**Korak 6.1 — Preuzmi Phantom**

1. Idi na **https://phantom.app** (opet, pazi na tocnu adresu!)
2. Preuzmi za svoju platformu:
   - **Android** --> Google Play Store
   - **iOS** --> Apple App Store
   - **Desktop** --> Chrome/Firefox/Brave extension

**Korak 6.2 — Kreiraj wallet**

1. Otvori Phantom
2. Klikni **"Create New Wallet"**
3. Postavi lozinku/biometriju
4. **ZAPISI SEED PHRASE NA PAPIR** — ista pravila kao MetaMask!
5. Potvrdi seed phrase

**Korak 6.3 — Napuni wallet sa SOL-om (za gas)**

1. Na Binanceu kupi SOL (ili ga vec imas)
2. Idi na **Withdraw**
3. Odaberi **SOL**
4. Za mrezu odaberi **Solana**
5. Zalijepi svoju Phantom adresu (izgleda drugacije od ETH adrese)
6. Iznos: **0.1 - 0.5 SOL** je dovoljno za tisuce transakcija
7. Potvrdi withdrawal

> 💡 Na Solani je gas fee tako nizak (~$0.001) da 0.1 SOL (~1.5 EUR)
> traje za otprilike 10,000+ transakcija. Zaista minijalan trosak.

```
+-----------------------------------------+
|  Phantom                   Solana       |
+-----------------------------------------+
|                                         |
|  Adresa: 7xKq...3mPv                   |
|                                         |
|  SOL:  0.15 (~2.25 EUR)                |
|                                         |
|  Tokens:                                |
|  (jos nema tokena)                      |
|                                         |
+-----------------------------------------+
```

**Razlika Phantom adrese vs MetaMask adrese:**
- MetaMask (ETH/BSC): `0x7a3B8c...4f2E` (pocinje s `0x`, hex format)
- Phantom (Solana): `7xKqW8...3mPv` (base58 format, nema `0x` prefiks)

Ove adrese su **potpuno nekompatibilne**. Nikada ne salji SOL na
MetaMask adresu ili BNB na Phantom adresu — novac ces izgubiti.

---

## 7. Binance racun

### Sto je Binance?

Binance je **najveca centralizirana kripto burza** na svijetu (CEX).
Tu mozes kupovati i prodavati kriptovalute koristeci klasicne valute
(EUR, USD) i karticu.

**Razlika CEX vs DEX:**
```
CEX (Binance, Coinbase)          DEX (Uniswap, PancakeSwap)
+---------------------------+    +---------------------------+
| - Registracija + KYC      |    | - Bez registracije        |
| - Veci izbor parova       |    | - Samo novi/mali tokeni   |
| - Nize naknade             |    | - Vise naknade (gas)      |
| - Fiat deposit (EUR, USD)  |    | - Samo kripto             |
| - Regulirano               |    | - Neregulirano            |
| - Veca sigurnost           |    | - Ti si odgovoran         |
+---------------------------+    +---------------------------+
```

### Korak po korak: Registracija

▶ **Napravi sad:**

**Korak 7.1 — Registracija**

1. Idi na **https://www.binance.com**
2. Klikni **"Register"** ili **"Sign Up"**
3. Unesi email i postavi snaznu lozinku
4. Potvrdi email
5. Postavi **2FA (Two-Factor Authentication)** — obavezno!
   - Preporuka: Google Authenticator app

**Korak 7.2 — KYC verifikacija**

KYC (Know Your Customer) je obavezan postupak provjere identiteta:

1. Idi na **"Identification"** ili **"Verify Identity"**
2. Odaberi svoju drzavu
3. Pripremi: osobnu iskaznicu ili putovnicu
4. Slikaj prednju i straznju stranu dokumenta
5. Napravi selfie za provjeru
6. Cekaj odobrenje (obicno 10 min - 24h)

> 💡 Bez KYC verifikacije ne mozes deponirati novac niti povlaciti
> vece iznose. KYC je regulatorni zahtjev, ne Binanceov hir.

**Korak 7.3 — Deposit (uplata novca)**

1. Idi na **"Deposit"** --> **"Fiat"**
2. Odaberi **EUR**
3. Odaberi metodu:
   - **Kartica (Visa/Mastercard)** — odmah, ali visa naknada (~1.8%)
   - **SEPA transfer** — 0 naknada, ali traje 1-3 radna dana
4. Unesi iznos (za pocetak preporucamo 50-100 EUR)
5. Potvrdi uplatu

**Korak 7.4 — Generiranje API kljuca**

> ⚠️ **VAZNO:** API sekcija je dostupna samo na **desktop webu**,
> ne na mobilnoj aplikaciji!

1. Prijavi se na Binance na **racunalu** (ne mobitelu)
2. Idi na: **Account** --> **API Management**
3. Klikni **"Create API"**
4. Odaberi **"System Generated"** tip
5. Daj kljucu ime: npr. `CoinSight-Trading`
6. Prodi 2FA verifikaciju

**KRITICNO — Postavi dozvole TOCNO ovako:**

```
+----------------------------------+----------+
| Dozvola                          | Stanje   |
+----------------------------------+----------+
| ✅ Enable Reading                | UKLJUCI  |
| ✅ Enable Spot & Margin Trading  | UKLJUCI  |
| ❌ Enable Withdrawals            | ISKLJUCI |
| ❌ Enable Futures                | ISKLJUCI |
+----------------------------------+----------+
```

> 🔐 **Zasto je "Enable Withdrawals" ISKLJUCENO?**
> Bez te dozvole, cak i ako netko dobije tvoj API kljuc, moze
> samo kupovati i prodavati na tvom racunu — ali NE MOZE poslati
> tvoj novac van Binancea. To je kriticna sigurnosna mjera.

7. Kopiraj **API Key** i **Secret Key**

```
API Key:    xJ7kL9mN2pQ4rS6tU8vW0xY1zA3bC5dE
Secret Key: fG7hI9jK2lM4nO6pQ8rS0tU1vW3xY5zA
```

8. **Secret Key se prikazuje samo jednom!** Kopiraj ga odmah.

**Korak 7.5 — Unesi u CoinSight**

1. Otvori CoinSight --> **Manage** --> **API** sekcija
2. Pronadi **"Binance"** sekciju
3. Zalijepi **API Key** i **Secret Key**
4. Tapni **"Save"**
5. Tapni **"Test Connection"**

**Korak 7.6 — Testnet za vjezbanje (PREPORUCENO)**

Prije nego pocnes s pravim novcem, testiraj na Binance testnet-u:

1. Idi na **https://testnet.binance.vision**
2. Registriraj se (odvojen account od pravog Binancea)
3. Generiraj testnet API kljuceve
4. U CoinSightu ukljuci **"Use Testnet"** opciju
5. Vjezbaj kupnju/prodaju s virtualnim novcima — bez rizika

```
+-----------------------------------------+
|  Manage > API > Binance                 |
+-----------------------------------------+
|                                         |
|  API Key:                               |
|  +-----------------------------------+  |
|  | xJ7kL9mN2pQ4rS...               |  |
|  +-----------------------------------+  |
|                                         |
|  Secret Key:                            |
|  +-----------------------------------+  |
|  | ********************************* |  |
|  +-----------------------------------+  |
|                                         |
|  [x] Use Testnet                        |
|                                         |
|  [Save]        [Test Connection ✅]     |
|                                         |
+-----------------------------------------+
```

---

## 8. Prvi koraci u CoinSightu

### Navigacija

Nakon sto si postavio API kljuceve, otvori CoinSight i upoznaj se
s osnovnim tabovima:

```
+--------------------------------------------------+
|  CoinSight                              [Manage]  |
+--------------------------------------------------+
|                                                  |
|               (glavni sadrzaj)                   |
|                                                  |
+--------------------------------------------------+
|  [Watchlist] [DEX Early] [Analiza] [Portfolio]   |
+--------------------------------------------------+
```

**Opis tabova:**

| Tab | Sto radi |
|-----|----------|
| **Watchlist** | Tvoja lista coinova koje pratis — cijene u realnom vremenu |
| **DEX Early** | Novi tokeni na decentraliziranim burzama (SHORT tier) |
| **Analiza** | Chat s Claudeom za analizu coinova |
| **Portfolio** | Pregled svih tvojih pozicija i P&L |
| **Manage** | Postavke, API kljucevi, konfiguracija |

### Konfiguracija postavki

▶ **Napravi sad:**

1. Idi na **Manage** tab
2. Provjeri da su svi API kljucevi uneseni i testirani
3. Postavi **default tier** — ako si pocetnik, pocni s **MID**
4. Postavi **valuta prikaza** na EUR ili USD
5. Ukljuci **notifikacije** za Stop-Loss i Take-Profit alerte

### Dodavanje coinova na Watchlist

▶ **Napravi sad:**

1. Idi na **Watchlist** tab
2. Tapni **"+"** ili **"Add Coin"**
3. Pretrazi coin (npr. "Bitcoin" ili "BTC")
4. Tapni na coin da ga dodas
5. Ponovi za 3-5 coinova koji te zanimaju

**Preporuka za pocetnike — pocni s pracenjem:**

```
BTC  (Bitcoin)      — "digitalno zlato", najveci po market capu
ETH  (Ethereum)     — platforma za smart contracte
SOL  (Solana)       — brzi blockchain, popularan za nove projekte
BNB  (BNB)          — Binanceov token, placa gas na BSC
LINK (Chainlink)    — infrastrukturni projekt (oracle)
```

---

## 9. Razumijevanje tri tiera (SHORT/MID/LONG)

### ⚡ SHORT Tier — Brzi lovac

**Sto je:** Trazenje coinova koji su tek izlistani na decentraliziranim
burzama (DEX) i imaju potencijal za brzi rast.

**Vremenski horizont:** Sati do nekoliko dana

**Kako funkcionira:**

```
1. CoinSight skenira DEX-ove (Uniswap, PancakeSwap, Raydium)
   za nove parove mlalje od 48h

2. Filtrira po volumenu, likvidnosti i drugim metrikama

3. Prikazuje ti listu potencijalno zanimljivih tokena

4. Ti odabires coin --> Claude analizira

5. Ako je ocjena dobra --> kupis mali iznos (5-25 EUR)

6. CoinSight prati cijenu svakih 5 min

7. Kad cijena dostigne SL ili TP --> dobis notifikaciju
```

**Rizik:** ⚠️ VISOK. Mnogi novi tokeni su scam ili padnu na nulu.

**Pravilo:** Nikada ne ulazi s vise od 5% svog ukupnog budzeta u
jednu SHORT poziciju.

**Koristis:** MetaMask (za BSC tokene) ili Phantom (za Solana tokene)

---

### 📈 MID Tier — Istrazivc

**Sto je:** Trazenje legitimnih projekata koji su jos nepoznati siroj
publici, ali imaju solidne temelje i tim iza sebe.

**Vremenski horizont:** Tjedni do nekoliko mjeseci

**Kako funkcionira:**

```
1. Pratis coin na Watchlistu ili ga nadjes kroz Claude analizu

2. Claude evaluira:
   - Tim iza projekta
   - Tehnologiju
   - Tokenomics (distribucija tokena)
   - Zajednicu i aktivnost
   - Partnerstva

3. Ako je analiza pozitivna --> kupis na Binanceu (ili DEX-u)

4. Postavljas SL/TP za automatski izlaz

5. Periodicki trazis novu analizu za provjeru stanja
```

**Rizik:** Srednji. Bolji projekti, ali i dalje nesigurno.

**Pravilo:** Diversificiraj — 5-10 razlicitih pozicija, svaka maks 10%
budzeta.

**Koristis:** Binance (za coinove koji su vec izlistani) ili DEX wallet

---

### 🏛️ LONG Tier — Strateg

**Sto je:** Duboka analiza infrastrukturnih projekata za dugorocno
drzanje. Ovo su projekti koji grade temelj kripto ekosustava.

**Vremenski horizont:** Mjeseci do godina

**Kako funkcionira:**

```
1. Claude radi dubinsku analizu:
   - Whitepaper review
   - On-chain metrike (aktivni addressi, TVL)
   - Competitive analysis
   - Makroekonomski kontekst

2. Odlucujes o DCA strategiji (kupujes malo po malo)

3. Drzis dugorocno, ne reagiras na dnevne oscilacije

4. Periodicki (mjesecno) trazis novu analizu
```

**Rizik:** Nizi (u kontekstu kriptovaluta — i dalje rizicnije od
tradicionalnih investicija).

**Pravilo:** Ulazi samo u projekte koje razumijes i u koje vjerujes
dugorocno. BTC i ETH su klasicni primjeri.

**Koristis:** Binance za kupnju, Binance ili hardware wallet za
drzanje

---

### Usporedba tiera

```
+--------+------------+--------+-----------+------------------+
| Tier   | Horizont   | Rizik  | Budzet %  | Platforma        |
+--------+------------+--------+-----------+------------------+
| SHORT  | Sati-dani  | Visok  | Maks 20%  | DEX (MetaMask/   |
|        |            |        |           | Phantom)         |
+--------+------------+--------+-----------+------------------+
| MID    | Tjedni-mj. | Srednji| 30-50%    | Binance / DEX    |
+--------+------------+--------+-----------+------------------+
| LONG   | Mj.-godine | Nizi   | 30-50%    | Binance /        |
|        |            |        |           | Hardware wallet  |
+--------+------------+--------+-----------+------------------+
```

> 💡 **Savjet za pocetnika:** Pocni SAMO s LONG tierom. Kupi malo BTC
> i ETH na Binanceu, prati ih na Watchlistu, koristi Claude analizu
> za ucenje. Tek kad se osjecas sigurno, isprobaj MID pa onda SHORT.

---

## 10. Tvoja prva analiza s Claudeom

### Korak po korak

▶ **Napravi sad:**

**Korak 10.1 — Otvori Analiza tab**

1. U CoinSightu tapni na **"Analiza"** tab
2. Vidjet ces chat sucelje slicno messaging aplikaciji

**Korak 10.2 — Postavi pitanje**

Upisi pitanje na hrvatskom ili engleskom, npr:

```
"Analiziraj Bitcoin za dugorocno drzanje. Kakav je trenutni
 trend i sto sugeriraju on-chain metrike?"
```

Ili jednostavnije:

```
"Sto mislis o Ethereumu za sljedecih 6 mjeseci?"
```

**Korak 10.3 — Citanje odgovora**

Claude ce ti vratiti strukturiranu analizu:

```
+--------------------------------------------------+
|  Claude Analiza: Bitcoin (BTC)                   |
+--------------------------------------------------+
|                                                  |
|  Tier: LONG                                      |
|  Confluence Score: 4.2 / 6.0                     |
|  Sentiment: BULLISH                              |
|                                                  |
|  Sazetak:                                        |
|  Bitcoin je trenutno u fazi akumulacije nakon     |
|  korekcije od ATH. On-chain metrike pokazuju...  |
|                                                  |
|  Kljucni faktori:                                |
|  + Institucijski kapital raste                   |
|  + Hash rate na ATH                              |
|  - Makro nesigurnost (kamate)                    |
|  - Kratkorocna volatilnost                       |
|                                                  |
|  Preporuka: ACCUMULATE (DCA strategija)          |
|  Rizik: 3/5                                      |
|                                                  |
+--------------------------------------------------+
```

**Sto znace ovi pojmovi:**
- **Confluence Score** — ukupna ocjena iz svih izvora (0-6.0). Vise = bolje
- **Sentiment** — opci dojam (BULLISH = optimistican, BEARISH = pesimistican)
- **ACCUMULATE** — preporuka da kupujes postepeno (DCA)
- **Rizik 3/5** — srednji rizik

**Korak 10.4 — Postavi follow-up pitanja**

Chat je konverzacijski — mozes nastaviti pitati:

```
"Koji je dobar entry point za DCA?"
"Usporedi BTC i ETH za dugorocno drzanje"
"Objasni mi sto znaci hash rate na ATH"
```

> 💡 **Savjet:** Ne boj se pitati "glupa" pitanja. Claude je tu da
> ti objasni sve — od osnovnih pojmova do naprednih analiza.

---

## 11. Tvoj prvi trade

### Preporuka: Pocni s Binance testnetom

Prije pravog tradinga, napravi barem 5-10 testnih tradova na
testnet-u da razumijes kako sustav funkcionira.

### Korak po korak: MID tier kupnja na Binanceu

▶ **Napravi sad:**

**Korak 11.1 — Odaberi coin**

1. Napravi analizu s Claudeom (poglavlje 10)
2. Odaberi coin koji Claude ocijeni pozitivno
3. Npr. Claude preporuci LINK s Confluence Score 4.5

**Korak 11.2 — Postavi poziciju**

1. Na **Portfolio** ili **Analiza** tabu vidjet ces opciju **"Buy"**
2. Unesi iznos koji zelis uloziti

```
+--------------------------------------------------+
|  Nova pozicija: LINK/USDT                        |
+--------------------------------------------------+
|                                                  |
|  Tier: MID                                       |
|  Trenutna cijena: $14.50                         |
|                                                  |
|  Iznos: [______] USDT                            |
|                                                  |
|  Stop-Loss:  $12.00  (-17.2%)                    |
|  Take-Profit: $22.00  (+51.7%)                   |
|                                                  |
|  [Prilagodi SL/TP]                               |
|                                                  |
|  [Cancel]              [Confirm Buy]             |
|                                                  |
+--------------------------------------------------+
```

**Korak 11.3 — Postavi Stop-Loss i Take-Profit**

- **Stop-Loss (SL):** Cijena pri kojoj automatski prodajes da
  ogranicis gubitak. Npr. 15-20% ispod kupovne cijene.
- **Take-Profit (TP):** Cijena pri kojoj automatski prodajes da
  osiguras profit. Npr. 30-50% iznad kupovne cijene.

> 💡 **Zlatno pravilo:** UVIJEK postavi Stop-Loss. Bez njega,
> pozicija moze pasti 90%+ i nikad se ne vratiti.

**Korak 11.4 — Potvrdi i prati**

1. Tapni **"Confirm Buy"**
2. CoinSight izvrsava narudzbu preko Binance API-ja
3. Pozicija se pojavljuje u **Portfolio** tabu
4. Vidis P&L (profit/loss) u realnom vremenu

```
+--------------------------------------------------+
|  Portfolio                                       |
+--------------------------------------------------+
|                                                  |
|  LINK/USDT     MID                               |
|  Kupljeno: $14.50  |  Trenutno: $15.20           |
|  P&L: +$0.70 (+4.8%) 🟢                          |
|  SL: $12.00  |  TP: $22.00                       |
|                                                  |
+--------------------------------------------------+
```

**Korak 11.5 — Cekaj i reagiraj**

- Ako cijena padne do SL --> CoinSight te obavjestava, pozicija se zatvara
- Ako cijena naraste do TP --> CoinSight te obavjestava, pozicija se zatvara
- Mozes rucno zatvoriti poziciju bilo kad

---

## 12. Razumijevanje grafikona

### Osnovni elementi grafikona

Kad otvoris detalje coina u CoinSightu, vidjet ces grafikon cijene.
Evo sto znaci svaki element:

```
Cijena ($)
  ^
  |         *
  |        * *        *
  |       *   *      * *     <-- Lokalni vrh (resistance)
  |      *     *    *   *
  |     *       *  *     *
  |    *         **       *
  |   *                    *  <-- Lokalno dno (support)
  |  *
  +---------------------------------> Vrijeme
      1d   3d   1w   2w   1m
```

### Kljucni pojmovi na grafikonu

**Cijena (Price):**
Vertikalna os prikazuje cijenu. Sto je vise = skuplje.

**Vrijeme (Time):**
Horizontalna os. Mozes odabrati raspon: 1h, 24h, 7d, 30d, 1y.

**Volumen (Volume):**
Stupci na dnu grafikona. Veci volumen = vise se trguje.
Visok volumen potvdjuje trend — ako cijena raste s visokim volumenom,
to je jaci signal nego rast s niskim volumenom.

```
Cijena
  ^
  |    ****
  |   *    ***
  |  *        **
  | *           *
  +------------------------> Vrijeme
  |  ##
  | ####  ##
  | #### ####  ##
  | #### #### ####
  +------------------------> Volumen
```

**Zeleno / Crveno:**
- 🟢 Zelena svijeca/stupac = cijena je rasla u tom periodu
- 🔴 Crvena svijeca/stupac = cijena je padala u tom periodu

### Candlestick (svijecni) grafikon

Ako CoinSight prikazuje candlestick grafikon, svaka "svijeca"
pokazuje 4 informacije:

```
     |        <-- Highest price (wick/shadow)
   +---+
   |   |      <-- Open (pocetak) ili Close (kraj)
   |   |          Zelena: Close > Open (cijena rasla)
   |   |          Crvena: Close < Open (cijena padala)
   +---+
     |        <-- Lowest price (wick/shadow)
```

### Sto pratiti kao pocetnik

1. **Opci trend** — ide li cijena uglavnom gore ili dolje?
2. **Volumen** — trguje li se aktivno ili je mirno?
3. **Veliki skokovi** — nagle promjene obicno znace veliku vijest
4. **Support/Resistance** — razine na kojima se cijena "odbija"

> 💡 **Savjet:** Ne pokusavaj postati ekspert za tehnicku analizu
> odmah. Claude radi tehnicku analizu za tebe. Grafikoni su tu da
> vizualno razumijes sto se dogadja.

---

## 12A. WalletConnect postavljanje

### Sto je WalletConnect?

WalletConnect je nacin da sigurno **spojis svoj crypto wallet** (MetaMask,
Trust Wallet, Phantom i drugi) s CoinSight-om. Zamisli to kao Bluetooth
pairing — tvoj wallet i CoinSight se "upoznaju", ali wallet i dalje
ima kontrolu nad tvojim novcem.

**Vazno:** WalletConnect NIKADA ne daje CoinSightu tvoj privatni kljuc
ili seed phrase. Svaku transakciju moras odobriti u svom walletu.

### Zasto bih koristio WalletConnect?

Bez WalletConnect-a, kad trgujed na DEX-u (PancakeSwap, Uniswap...),
moras rucno unositi podatke o trade-ovima u CoinSight. S WalletConnect-om
mozes:

- **Vidjeti svoju wallet adresu** direktno u CoinSightu
- **Pokrenuti swap** iz CoinSight-a (ali ga odobri u walletu)
- **Povezati DEX pozicije** s walletom automatski

### Korak po korak: Postavljanje WalletConnect-a

**Korak 12A.1 — Registriraj se na WalletConnect Cloud**

1. Otvori browser i idi na: **https://cloud.reown.com**
2. Klikni **"Sign Up"** ili **"Get Started"**
3. Mozes se registrirati putem **GitHub accounta** ili **emaila**
4. Kreiraj novi projekt:
   - Klikni **"Create Project"** ili **"New Project"**
   - Daj ime projektu, npr. `CoinSight`
   - Odaberi tip: **App**
5. Na stranici projekta vidjet ces **Project ID** — dugacak string
   koji izgleda ovako:
   ```
   a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
   ```
6. **Kopiraj Project ID!**

> Registracija je **besplatna** za osobnu upotrebu.

**Korak 12A.2 — Unesi Project ID u CoinSight**

1. Otvori CoinSight --> **Manage** tab --> **API** pod-tab
2. Pronadi polje **"WalletConnect Project ID"**
3. Zalijepi kopirani Project ID
4. Tapni **"Save"**

**Korak 12A.3 — Spoji wallet**

1. U **Portfolio** ili **Analysis** tabu vidjet ces **WalletConnect button**
2. Tapni ga — pojavljuje se QR kod
3. Otvori svoj wallet (MetaMask, Trust Wallet, Phantom...)
4. U walletu pronadi opciju **"WalletConnect"** ili **"Scan QR"**
5. Skeniraj QR kod prikazan u CoinSightu
6. U walletu tapni **"Connect"** ili **"Approve"**
7. Gotovo! Tvoja wallet adresa se prikazuje u CoinSightu

```
+-----------------------------------------+
|  WalletConnect              [Connected] |
+-----------------------------------------+
|                                         |
|  Adresa: 0x7a3B...4f2E                  |
|  Mreza: BSC                             |
|                                         |
|  [Disconnect]                           |
|                                         |
+-----------------------------------------+
```

### Rjesavanje problema

| Problem | Rjesenje |
|---------|----------|
| "Invalid Project ID" | Provjeri da si kopirao cijeli ID s cloud.reown.com |
| QR kod ne radi | Provjeri internet konekciju na oba uredaja |
| Wallet se ne pojavljuje | Azuriraj wallet app na najnoviju verziju |
| Konekcija se prekida | Normalno kad se app zatvori — reconnect je automatski |

---

## 12B. P&L Dashboard za pocetnike

### Sto je P&L Dashboard?

P&L Dashboard je tvoj **osobni izvjestaj o performansama**. Kao sto
sportasi imaju statistiku (golovi, asistencije, pobjedeni%), tako i
ti imas statistiku svojih trade-ova.

**P&L = Profit and Loss** = koliko si zaradio ili izgubio.

### Kako pristupiti

1. Otvori **Portfolio** tab
2. Na vrhu ces vidjeti **P&L banner** s kljucnim brojkama
3. Tapni banner za otvaranje full-screen **P&L Dashboard-a**

### Sto znace brojke na Dashboardu

```
+------------------------------------------+
| P&L Dashboard                            |
+------------------------------------------+
|                                          |
| Ukupni P&L: +$42.50                     |
| Win Rate: 62%                            |
| R/R Ratio: 1.8                           |
| Ukupno trade-ova: 24                     |
|                                          |
| [======Equity Curve graf=======]         |
|                                          |
| SHORT: Win 65% | +$15                    |
| MID:   Win 55% | +$12                    |
| LONG:  Win 70% | +$15.50                |
|                                          |
+------------------------------------------+
```

**Win Rate (62%):**
Od svih trade-ova koje si napravio, 62% ih je zavrsilo u plusu.
To je kao u kosarci — koliko posto suteva je pogodilo.

**R/R Ratio (1.8):**
Kad zaradis, prosjecno zaradis 1.8x vise nego sto izgubis kad
gubis. Npr. prosjecno zaradis $9 po dobrom trade-u i izgubis
$5 po losom. $9/$5 = 1.8.

Sto je R/R visi, to bolje. R/R iznad 1.5 je solidno za pocetnika.

**Equity Curve (graf):**
Zamislji ga kao grafikon tvog "stanja racuna" kroz vrijeme.
Ako linija ide GORE — generalno zaradujes. Ako ide DOLJE —
generalno gubis. Idealno: linija koja postupno raste s malim
padovima tu i tamo (normalna volatilnost).

**Per-tier breakdown:**
Razdvojene statistike za svaku strategiju:
- **SHORT** — kratkorocni trade-ovi (sati do dana)
- **MID** — srednjorocni projekti (tjedni do mjeseci)
- **LONG** — dugorocna drzanja (mjeseci do godina)

Ovo ti pomaze vidjeti koja strategija ti najbolje lezi.

### Savjeti za pocetnike

- **Ne brini** se o Dashboardu prvih tjedan dana — nemas dovoljno
  podataka za smislenu statistiku
- **Win Rate ispod 50%** ne znaci nuzno gubitak — ako je R/R visok
  (npr. 3.0), mozes gubiti 60% trade-ova i i dalje biti u plusu
- **Equity Curve pad** kroz vise dana znaci da trebas **pauzirati**
  i preispitati strategiju
- **Per-tier breakdown** koristiti za fokusiranje na tier koji ti
  najbolje ide

### Kako čitati equity curve

Equity curve je tvoj "financijski dnevnik u grafikonu". Svaki zatvoreni trade dodaje točku.

**Primjer čitanja:**

```
$+15  |                    *---*
$+10  |           *---*---*
$+5   |      *---*
$0    |--*---*
$-5   |
      +----------------------------
        Jan  Feb  Mar  Apr  Maj
```

Ovaj grafikon kaže: počeo si s 2 gubitna trejda, pa si stabilizirao i počeo rasti. Ukupno u plusu $15. Zdravi trend.

**Crveni flag:**
```
$0    |--*---*
$-5   |      *---*
$-10  |           *---*
$-15  |                *---*---*
```

Ovo je problem — konzistentno padanje. Znači strategija ne radi, parametri su krivi, ili tržišni uvjeti su loši za momentum trading. **Stani i analiziraj.**

### Moj prvi tjedan — realna očekivanja

| Tjedan | Cilj | Nije cilj |
|--------|------|-----------|
| 1 | Naučiti se koristiti app, razumjeti signale | Zaraditi |
| 2 | Kalibrirati Risk Parameters na tvoj stil | Biti profitabilan |
| 3-4 | Pratiti vlastitu win rate statistiku | Dramatično povećati iznose |
| Mjesec 2+ | Konzistentna profitabilnost s malim iznosima | Brzo bogatstvo |

**Ključna istina:** Momentum trading je vještina. Kao svaka vještina — treba tjedne prakse. CoinSight daje alat, iskustvo dolaziš sam.

---

## 13. Rjecnik pojmova

Abecednim redom, svi pojmovi koje ces sresti koristeci CoinSight
i kripto trziste opcenito:

---

**Airdrop**
Besplatna distribucija tokena korisnicima, obicno kao promocija
ili nagrada za rano koristenje platforme.

**All-Time High (ATH)**
Najvisa cijena koju je coin ikad dostigao u svojoj povijesti.

**All-Time Low (ATL)**
Najniza cijena koju je coin ikad imao.

**Altcoin**
Svaka kriptovaluta osim Bitcoina. Ethereum, Solana, BNB — sve su
altcoini.

**API Key (API kljuc)**
Lozinka za programatski pristup servisu. CoinSight koristi API
kljuceve za komunikaciju s Claudeom, Binanceom i Telegramom.
Format: dugacki string alfanumerickih znakova.

**Ask / Bid**
Ask je cijena po kojoj netko zeli prodati. Bid je cijena po kojoj
netko zeli kupiti. Razlika izmedju njih je "spread".

**Bearish**
Pesimistican stav prema trzistu — ocekivanje pada cijena.
Suprotno od bullish.

**Blockchain**
Decentralizirana baza podataka u kojoj se zapisuju sve transakcije.
Svaki "blok" sadrzi grupu transakcija i povezan je s prethodnim
blokom — otuda ime "lanac blokova".

**BSC (BNB Smart Chain)**
Blockchain koji je napravio Binance. Jeftine transakcije (~$0.01),
popularan za DEX trading. Koristi BNB za gas fee.

**Bullish**
Optimistican stav prema trzistu — ocekivanje rasta cijena.
Suprotno od bearish.

**Burn**
Trajno uklanjanje tokena iz opticaja (slanje na "mrtvu" adresu).
Smanjuje ukupnu ponudu, teorijski povecava vrijednost preostalih.

**Candlestick**
Tip grafikona koji prikazuje otvaranje, zatvaranje, najvisu i
najnizu cijenu za svaki vremenski period. Vidi poglavlje 12.

**CEX (Centralized Exchange)**
Centralizirana kripto burza: Binance, Coinbase, Kraken.
Zahtijeva registraciju i KYC verifikaciju.

**Circulating Supply**
Broj tokena koji su trenutno u opticaju (dostupni na trzistu).

**Confluence Score**
CoinSightov ukupni signal score iz svih intelligence izvora.
Raspon: 0 do 6.0. Vise = jaci signal.

**Contract Address**
Jedinstvena adresa smart contracta tokena na blockchainu.
Koristis ju za provjeru da kupujes pravi token (a ne kopiju/scam).

**DCA (Dollar Cost Averaging)**
Strategija kupovanja u vise navrata po razlicitim cijenama, umjesto
sve odjednom. Smanjuje rizik loseg tajminga. Npr: kupi $50 BTC
svaki tjedan, neovisno o cijeni.

**ClosedTrade**
Zapis o trade-u koji je zavrsen (zatvoren). Cuva podatke o entry/exit
cijeni, profitu ili gubitku, tieru, i razlogu zatvaranja (SL, TP,
rucno). Koristi se za P&L Dashboard statistike.

**DeFi (Decentralized Finance)**
Financijski servisi izgradjeni na blockchainu — lending, borrowing,
trading — bez banaka i posrednika.

**DEX (Decentralized Exchange)**
Decentralizirana burza: Uniswap, PancakeSwap, Raydium, Jupiter.
Nema registracije, nema KYC-a. Koristis wallet direktno.

**DYOR (Do Your Own Research)**
"Napravi vlastito istrazivanje." Zlatno pravilo kriptovaluta:
nikad ne ulazi u investiciju samo zato sto je netko drugi rekao
da je dobra. CoinSight analizira — ti odlucujes.

**Equity Curve**
Grafikon koji prikazuje kumulativni profit ili gubitak kroz vrijeme.
Ako linija ide gore — strategija zaradduje. Ako ide dolje — gubi.
Vidljiv u P&L Dashboardu.

**Entry Point**
Cijena po kojoj planiras kupiti coin. Dobar entry point je kad je
cijena niza od tvoje procjene fer vrijednosti.

**ERC-20**
Standard za tokene na Ethereum blockchainu. Vecina ETH tokena je
ERC-20 kompatibilna.

**Fiat**
Tradicionalne valute koje izdaju drzave: EUR, USD, HRK.
"Fiat deposit" znaci uplata klasicnog novca.

**FOMO (Fear of Missing Out)**
Strah da ces propustiti priliku. Opasan osjecaj koji vodi u
impulzivne kupnje. Izbjegavaj FOMO odluke!

**FUD (Fear, Uncertainty, Doubt)**
Sirenje straha i nesigurnosti oko nekog projekta ili trzista
opcenito. Moze biti opravdano ili manipulativno.

**Gas Fee**
Naknada za procesiranje transakcije na blockchainu. Placa se
minerima/validatorima. Na Ethereumu moze biti skupa ($5-30),
na BSC-u (~$0.01) i Solani (~$0.001) je minimalna.

**Hardware Wallet**
Fizicki uredjaj (USB) za sigurno cuvanje kriptovaluta offline.
Primjeri: Ledger, Trezor. Najsigurnija opcija za dugorocno
drzanje vecih iznosa.

**HODL**
Kripto sleng za "drzati" (hold) — ne prodavati unatoc
kratkorocnim padovima. Nastao kao greska u tipkanju (hold -> hodl)
i postao meme/strategija.

**KYC (Know Your Customer)**
Postupak provjere identiteta koji zahtijevaju regulirane burze
(CEX). Ukljucuje slanje osobne iskaznice i selfieja.

**Leverage**
Trgovanje s posudjenim novcem. Npr. 10x leverage znaci da
kontroliras 10x veci iznos. IZRAZITO RIZICNO — mozes izgubiti
vise nego si ulozio. CoinSight NE koristi leverage.

**Limit Order**
Narudzba za kupnju/prodaju po odredjenoj cijeni. Izvrsava se
tek kad trzisna cijena dosegne tvoju postavljenu cijenu.

**Liquidity (Likvidnost)**
Kolicina novca/tokena dostupna za trgovanje. Veca likvidnost =
lakse kupiti/prodati bez utjecaja na cijenu. Niska likvidnost =
cijena se lako pomice.

**Listing**
Dodavanje coina na burzu. "Binance listing" znaci da se coin
moze kupiti na Binanceu. Novi listingi cesto izazovu rast cijene.

**LP (Liquidity Pool)**
Bazen tokena zaklucanih u smart contractu koji omogucavaju
trgovanje na DEX-u. Korisnici mogu dodavati likvidnost i
zaraddivati naknade.

**Market Cap (Trzisna kapitalizacija)**
Ukupna vrijednost svih tokena u opticaju.
Formula: cijena x circulating supply.
BTC market cap ~$1T = Bitcoin vrijedi ~$1 trilijun ukupno.

**Market Order**
Narudzba za kupnju/prodaju po trenutnoj trzisnoj cijeni.
Izvrsava se odmah, ali cijena moze malo varirati (slippage).

**Memecoin**
Kriptovaluta nastala kao sala ili meme (DOGE, PEPE, SHIB).
Izrazito spekulativna, cesto bez realne korisnosti.

**MetaMask**
Najpopularniji crypto wallet za Ethereum i BSC ecosystem.
Vidi poglavlje 5 za postavljanje.

**Mining**
Proces stvaranja novih blokova na blockchainu koristenjem
racunalne snage. Mineri dobivaju nagradu u kriptovaluti.

**NFT (Non-Fungible Token)**
Jedinstveni digitalni token koji predstavlja vlasnistvo nad
digitalnim ili fizickim predmetom (slika, glazba, igra).

**On-chain**
Podaci koji su zapisani direktno na blockchainu. On-chain
analiza gleda transakcije, adrese i aktivnost na blockchainu.

**P&L (Profit and Loss)**
Dobit ili gubitak na poziciji. Prikazuje se u apsolutnom iznosu
($) i postotku (%). Zeleno = profit, crveno = gubitak.

**P&L Dashboard**
Centralizirani ekran u CoinSightu koji prikazuje equity curve,
win rate, R/R ratio, per-tier breakdown i trade history. Pristupa
se iz Portfolio taba tapom na P&L banner.

**PnlAnalytics**
Interni model koji racuna sve P&L metrike iz zatvorenih trade-ova:
win rate, prosjecni profit/gubitak, R/R ratio, equity curve podatke.

**Pair (Par)**
Dva tokena koji se trguju jedan za drugi. BTC/USDT znaci da
kupujes Bitcoin za USDT (stablecoin). LINK/ETH znaci da kupujes
Chainlink za Ethereum.

**Phantom**
Crypto wallet za Solana ecosystem. Vidi poglavlje 6.

**Portfolio**
Ukupnost svih tvojih kripto pozicija i drzanja.

**Private Key**
Tajni kljuc koji daje pristup tvom walletu. Seed phrase je
ljudski citljiva verzija private keya. NIKAD ne dijeli!

**Pump and Dump**
Manipulativna shema: grupa ljudi umjetno podize cijenu (pump)
i onda prodaje (dump), ostavljajuci kasne kupce s gubitkom.

**Resistance**
Razina cijene na kojoj se cijena obicno "odbija" i pada.
Ako cijena probije resistance, to je bullish signal.

**R/R Ratio (Risk/Reward)**
Omjer prosjecnog profita naspram prosjecnog gubitka. R/R 2.0 znaci
da prosjecno zaradis dvaput vise kad zaradis nego sto izgubis kad
gubis. Prikazan u P&L Dashboardu.

**ROI (Return on Investment)**
Povrat na investiciju. Ako si ulozio $100 i sad vrijedi $150,
ROI je 50%.

**Rug Pull**
Tip scama gdje developeri projekta povuku svu likvidnost iz
LP-a i nestanu s novcem. Cest na DEX-ovima s novim tokenima.

**Seed Phrase (Recovery Phrase)**
12 ili 24 rijeci koje su master kljuc za tvoj wallet. S njima
mozes povratiti wallet na bilo kojem uredjaju. NIKAD NE DIJELI!
Vidi poglavlje 5.3 za detalje.

**Slippage**
Razlika izmedju ocekivane i stvarne cijene pri izvrsavanju
narudzbe. Dogadja se kod tokena s niskom likvidnoscu.
Npr. ocekujes kupiti po $1.00, kupis po $1.03 = 3% slippage.

**Smart Contract**
Automatski program koji zivi na blockchainu. Izvrsava se tocno
onako kako je napisan, bez mogucnosti promjene. DEX-ovi, tokeni
i DeFi protokoli su svi smart contracti.

**SOL (Solana)**
Kriptovaluta Solana blockchaina. Koristi se za gas fee na Solani.

**Spot Trading**
Kupnja i prodaja kriptovaluta po trenutnoj trzisnoj cijeni.
CoinSight koristi spot trading (ne futures, ne leverage).

**Spread**
Razlika izmedju najvise ponude za kupnju (bid) i najnize
ponude za prodaju (ask). Manji spread = veca likvidnost.

**Stablecoin**
Kriptovaluta cija je cijena vezana za fiat valutu (obicno USD).
USDT, USDC, DAI — svi vrijede ~$1. Koristis ih kao "digitalne
dolare" za trgovanje.

**Staking**
Zaklucavanje tokena u mrezi za zaradu nagrada. Slicno stednom
racunu u banci, ali s vecim prinosima i rizicima.

**Stop-Loss (SL)**
Automatski izlaz iz pozicije ako cijena padne ispod zadane
razine. OBAVEZAN za upravljanje rizikom. Npr. SL na -15%
znaci da ces izgubiti maksimalno 15%.

**Support**
Razina cijene na kojoj se cijena obicno "odbija" i raste.
Ako cijena probije support prema dolje, to je bearish signal.

**Take-Profit (TP)**
Automatski izlaz iz pozicije kad cijena dostigne zadanu razinu
profita. Npr. TP na +50% znaci da prodajes kad cijena naraste 50%.

**Testnet**
Testna verzija blockchaina ili burze gdje se koristi virtualan
novac. Savrseno za vjezbanje bez rizika.

**Token**
Digitalna valuta na blockchainu. BTC, ETH, LINK, SOL, PEPE —
svi su tokeni. Razliciti tokeni zive na razlicitim blockchainima.

**Tokenomics**
Ekonomski model tokena: koliko ih ukupno postoji, koliko je u
opticaju, kako se distribuiraju, postoji li burn mehanizam.

**Total Supply**
Ukupan broj tokena koji ce ikad postojati. BTC: 21 milijun.

**TVL (Total Value Locked)**
Ukupna vrijednost tokena zaklucanih u DeFi protokolu. Veci TVL
= vise povjerenja i koristenja platforme.

**USDT (Tether)**
Najpopularniji stablecoin. 1 USDT = ~1 USD. Koristis ga kao
"digitalni dolar" za trgovanje parovima na burzama.

**Validator**
Cvor u mrezsi koji potvdjuje transakcije i dodaje nove blokove.
Na Proof-of-Stake blockchainima (Ethereum, Solana) validatori
moraju stakati tokene kao kolateral.

**Volatility (Volatilnost)**
Mjera koliko se cijena mijenja u odredjenom periodu. Visoka
volatilnost = velike i brze promjene cijene. Kriptovalute su
generalno vrlo volatilne u usporedbi s tradicionalnim financijama.

**Volume (Volumen)**
Kolicina tokena koja se trguje u odredjenom periodu (obicno 24h).
Visok volumen = aktivno trgovanje, veca likvidnost.

**Wallet**
Digitalni novcanik za cuvanje kripto imovine. Moze biti softverski
(MetaMask, Phantom) ili hardverski (Ledger, Trezor).

**WalletConnect**
Protokol za sigurno spajanje walleta na decentralizirane aplikacije
(dApps). Skeniras QR kod walletom da se spojis. CoinSight koristi
WalletConnect v2 za povezivanje walleta i pokretanje swapova.
Zahtijeva besplatan Project ID s cloud.reown.com.

**Win Rate**
Postotak trade-ova koji su zavrsili s profitom. Npr. 60% win rate
znaci da je 6 od 10 trade-ova bilo profitabilno. Prikazan u P&L
Dashboardu.

**Whale (Kit)**
Investitor s velikim iznosom kripto imovine. Whale transakcije
mogu znacajno utjecati na cijenu. CoinSight prati whale alertove
preko Telegrama.

**Whitepaper**
Tehnicki dokument koji opisuje projekt, njegov cilj, tehnologiju
i tokenomics. Svaki ozbiljni kripto projekt ima whitepaper.

**Yield**
Prinos od stakinga, lendinga ili liquidity providinga. Izrazava
se u godisnjim postocima (APY — Annual Percentage Yield).

---

## 14. Sigurnosna pravila

### Zlatna pravila sigurnosti

Ovo su pravila koja NIKADA ne smis krsiti. Krsenje bilo kojeg od
ovih pravila moze rezultirati **trajnim gubitkom novca**.

---

### Pravilo 1: Seed Phrase — Sveti Gral

```
+----------------------------------------------------------+
|                                                          |
|   SEED PHRASE = TVOJ NOVAC                               |
|                                                          |
|   Tko ima seed phrase, ima sve u tvom walletu.           |
|   Nema "zaboravio sam lozinku" opcije.                   |
|   Nema korisnicke podrske koja ti moze pomoci.           |
|                                                          |
+----------------------------------------------------------+
```

- ❌ NIKADA ne radi screenshot seed phrasea
- ❌ NIKADA ne spremi u Notes app, email ili cloud (iCloud, Google Drive)
- ❌ NIKADA ne dijeli s nikim — ni s "podriskom", ni s "adminima"
- ❌ NIKADA ne upisuj na web stranicu
- ❌ NIKADA ne salji u chat, DM ili bilo koji digitalni kanal
- ✅ ZAPISI na papir, citljivo, tocnim redoslijedom
- ✅ Napravi 2 kopije i spremi na 2 fizicki odvojena mjesta
- ✅ Razmotri metalnu plocu za dugotrajno cuvanje (otpornije od papira)

> ⚠️ **Cesti scamovi:** "Posalji nam seed phrase za verifikaciju
> walleta" — SCAM. Nijedan legitimni servis NIKADA nece traziti
> tvoj seed phrase. Cak ni CoinSight ga NE trazi i NE treba.

---

### Pravilo 2: API kljucevi — Dozvole su kriticne

```
Binance API kljuc:
+-----------------------------------+--------+
| ✅ Enable Reading                 | DA     |
| ✅ Enable Spot & Margin Trading   | DA     |
| ❌ Enable Withdrawals             | NE!    |
| ❌ Enable Futures                 | NE!    |
+-----------------------------------+--------+
```

**Zasto?** Bez Withdrawal dozvole, cak i ako netko ukrade tvoj API
kljuc, NE MOZE poslati tvoj novac van Binancea. Najgore sto moze
napraviti je kupiti/prodati — ali novac ostaje na tvom racunu.

Dodatne mjere:
- Postavi **IP whitelist** na Binanceu (samo tvoja IP adresa)
- Periodicki rotiraj API kljuceve (svakih 3-6 mjeseci)
- Nikada ne dijeli API Secret Key

---

### Pravilo 3: Testnet uvijek prvi

Prije nego sto napravis BILO STO s pravim novcem:

1. Testiraj na **Binance Testnet** (testnet.binance.vision)
2. Napravi barem 5-10 test tradova
3. Provjeri da SL i TP rade ispravno
4. Tek onda prebaci na pravi (mainnet) racun

**Testnet je besplatan i koristi virtualni novac.** Nema razloga
preskociti ovaj korak.

---

### Pravilo 4: Mali iznosi na pocetku

```
Preporuceni budzet za pocetnika:

Ukupno: 50-100 EUR (novac koji MOZES IZGUBITI)

Raspodjela:
- 5-10 EUR BNB za gas (MetaMask)
- 1-2 EUR SOL za gas (Phantom)
- 40-90 EUR na Binanceu za trading

Prva pozicija: 5-10 EUR (ne vise!)
```

> 💡 Smisao malih iznosa: ucis na stvarnom trzistu s pravim
> emocijama (strah, pohlepa, FOMO) — ali gubitak od 5 EUR
> nece utjecati na tvoj zivot.

---

### Pravilo 5: DYOR — Uvijek istrazuj sam

CoinSight ti daje analizu i podatke. Ali **TI** donosid konacnu
odluku. Nikada ne ulazi u investiciju samo zato sto:

- Claude je rekao da je bullish
- Netko na Telegramu je preporucio
- "Svi kupuju"
- FOMO te uhvatio

**Uvijek se pitaj:**
1. Razumijem li sto ovaj projekt radi?
2. Mogu li si priustiti izgubiti ovaj novac?
3. Imam li plan za izlaz (SL/TP)?
4. Jesam li emocionalan ili racionalan upravo sad?

---

### Pravilo 6: Nikada ne ulazi vise nego mozes izgubiti

```
+----------------------------------------------------------+
|                                                          |
|   CRYPTOCURRENCY TRADING NOSI VISOK RIZIK                |
|   GUBITKA KAPITALA.                                      |
|                                                          |
|   Ne ulazi novac koji ti treba za:                       |
|   - Stanarinu / rezije                                   |
|   - Hranu                                                |
|   - Hitne troskove                                       |
|   - Otplatu duga                                         |
|                                                          |
|   Ulazi SAMO novac kojeg mozes                           |
|   100% izgubiti bez utjecaja na zivot.                   |
|                                                          |
+----------------------------------------------------------+
```

---

### Sigurnosna provjera prije svakog tradea

Prije nego kliknes "Buy", prodi kroz ovu listu:

- [ ] Imam li postavljen Stop-Loss?
- [ ] Jesam li na pravoj mrezi (BSC, Solana, Ethereum)?
- [ ] Provjerio sam contract address tokena?
- [ ] Iznos je unutar mog budzeta za rizik?
- [ ] Nisam emocionalno uzbudjen (FOMO)?
- [ ] Razumijem sto kupujem?

Ako na bilo koji odgovor NE MOZES odgovoriti "DA" — ne trguj.

---

### Sto napraviti ako sumnjad na problem

| Situacija | Akcija |
|-----------|--------|
| Mislis da je API kljuc kompromitiran | Odmah ga obrisi na Binanceu i generiraj novi |
| Dobio si poruku "posalji seed phrase" | SCAM! Ignoriraj i blokiraj posiljatelja |
| MetaMask trazi seed phrase na webu | Zatvori stranicu — to je phishing |
| Coin je pao 50%+ odjednom | NE panicaraj. Provjeri vijesti, Claude analizu |
| Ne razumijes sto se dogadja | ZAUSTAVI SE. Pitaj Claudea za objasnjenje |

---

### 14.7 WalletConnect sigurnosna pravila

- **Nikad ne dijeli seed phrase** — WalletConnect je POTPUNO DRUGAČIJI od seed phrase-a. WalletConnect je privremena veza između app-e i walleta. Seed phrase je master ključ.
- **Koristit namjenski "trading wallet"** — Kreiraj novi MetaMask wallet samo za CoinSight trading. Na njega stavi samo iznos koji planiraš tradati. Tvoje "glavne" uštedine drži odvojeno.
- **Disconnect kad ne koristiš** — U Portfolio tabu, kad završiš s tradingom, tapni WalletConnect button → Disconnect.
- **Provjeri svaku transakciju u MetaMask** — Kad CoinSight inicira swap, MetaMask otvori prozor s detaljima. Pročitaj koji token, koji iznos, koja gas naknada. Tek tada tapni Confirm.

### 14.8 Što napraviti ako posumnjate da ste hakirani

1. **Odmah** — Binance web → API Management → Delete sve ključeve
2. **Odmah** — Anthropic Console → API Keys → Revoke
3. **Odmah** — Telegram → @BotFather → `/revoke`
4. **Odmah** — MetaMask/Phantom → premjesti sredstva na novi wallet s novim seed phrase-om
5. **Potom** — Manage → App → Full Reset (obriše sve lokalne podatke)
6. **Potom** — generiraj sve ključeve iznova na čistom uređaju

---

## Zavrsna rijec

CoinSight je mocaan alat, ali je i dalje samo alat. Najvaznije
stvari za uspjeh su:

1. **Strpljenje** — ne juri za brzim profitom
2. **Disciplina** — uvijek postavi SL/TP, drzji se plana
3. **Edukacija** — svaki dan nauci nesto novo
4. **Kontrola emocija** — ne trguj kad si uzbudjen ili u panici
5. **Upravljanje rizikom** — mali iznosi, diversifikacija

Kreni polako. Dan po dan. Korak po korak. Sretno! 🚀

---

*CoinSight je alat za analizu i pracenje. Nije financijski savjet.
Cryptocurrency trading nosi visok rizik gubitka kapitala. Proslji
rezultati ne garantiraju buduce prinose.*

---

**Verzija dokumenta:** 1.1  
**Zadnja izmjena:** 2026-04-16  
**Aplikacija:** CoinSight v7.0.0

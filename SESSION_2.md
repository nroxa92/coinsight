# CoinSight — SESSION 2 Instructions
**Datum:** 2026-04-12  
**Status projekta:** Faze 1-5 završene, app radi na Windowsu  
**Cilj ove sesije:** Implementacija core funkcionalnosti (novi listinzi), popravak Claude prompta, Android build

---

## OBAVEZNO PRIJE BILO ČEGA DRUGOG

Pročitaj sljedeće fajlove redom prije nego kreneš s ikakvim kodom:

```
CLAUDE.md
WORKLOG.md
lib/services/coingecko_service.dart
lib/services/claude_service.dart
lib/models/watchlist_provider.dart
lib/models/analysis_provider.dart
lib/screens/watchlist_screen.dart
```

Ne pretpostavljaj što je u kodu. Pročitaj stvarni kod.  
Nakon čitanja napiši kratki summary što si našao, pa tek onda kreni s implementacijom.

---

## KONTEKST PROJEKTA

CoinSight je privatna Flutter Android aplikacija za praćenje novih cryptocurrency listinga i AI-potpomognutu analizu. App postoji i radi. Sve 5 originalnih razvojnih faza su završene.

**Što app trenutno radi:**
- Watchlist screen: prikazuje top 25 coinova po market capu (Bitcoin, Ethereum itd.)
- Analysis screen: Claude AI chat s context injection watchlista
- Settings screen: upravljanje Anthropic API ključem
- Hive persistencija za watchlist i API ključ
- Shimmer skeleton loaderi, pull-to-refresh, error handling

**Što nedostaje i mora biti implementirano:**  
Vidi Tasks sekciju ispod.

---

## PRAVILA RADA — STROGO SE PRIDRŽAVAJ

**Ne brišeš** postojeći kod bez eksplicitnog odobrenja developera.  
**Ne dodaješ** featuree koji nisu u ovim instrukcijama.  
**Ne refaktoriraš** ono što nije pokvareno.  
**Ne commitaš** — to je isključivo nadležnost developera.  
**Pitaš** ako nešto nije jasno PRIJE nego kreneš pisati kod.  
**Dodaješ** unos u WORKLOG.md na kraju svake promjene prema postojećem formatu.  
Ako naiđeš na bug koji nije dio zadatka — prijavi u WORKLOG.md pod "Identified Issues", ali ne popravljaj bez pitanja.

---

## ZADACI — PRIORITETNI REDOSLIJED

### ZADATAK 1 — Novi listinzi (CORE FEATURE, KRITIČNO)

**Problem:** App trenutno prikazuje top 25 coinova po market capu. To nije svrha CoinSighta. Svrha je loviti **nove coinove koji su tek listarani** — startup projekte s early momentum potencijalom.

**Što treba napraviti:**

Dodaj novi tab u WatchlistScreen koji se zove **"New Listings"** pored postojećih tabova "My Watchlist" i "Top Coins". New Listings tab mora biti **prvi tab i default** pri otvaranju aplikacije.

**CoinGecko endpoint za nove listinge:**
```
GET https://api.coingecko.com/api/v3/coins/list?include_platform=false
```
Ovaj endpoint vraća sve coinove. Problem je što nema datum listanja direktno. Koristi alternativni pristup:

```
GET https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=id_asc&per_page=250&page=1&sparkline=true&price_change_percentage=1h,24h
```

Zapravo, najpouzdaniji pristup za "nove" coinove je:
```
GET https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=volume_desc&per_page=100&page=1&sparkline=true&price_change_percentage=1h,24h
```

Filtriraj rezultate na frontend strani po sljedećim kriterijima koji definiraju "zanimljiv novi coin":
- `market_cap_rank` je null ILI veći od 500 (eliminiraj established coinove)  
- `total_volume` između 50,000 USD i 50,000,000 USD (eliminiraj ghost coinove i whale manipulacije)
- `price_change_percentage_24h` dostupan (nije null)

Sortiraj po `price_change_percentage_1h` descending — najveći hourly rast prvi.

**Coin model** (`lib/models/coin.dart`) proširi s:
```dart
final double? priceChangePercentage1h;
```
Dodaj u `fromJson()` factory:
```dart
priceChangePercentage1h: json['price_change_percentage_1h_in_currency']?.toDouble(),
```

**CoinCard widget** za New Listings tab mora prikazivati i 1h change badge pored 24h, jasno označen kao "1H" u manjoj tipografiji. Boja zelena/crvena isto kao 24h.

**WatchlistProvider** dodaj:
```dart
List<Coin> _newListings = [];
List<Coin> get newListings => _newListings;
Future<void> fetchNewListings() async { ... }
```

Auto-refresh za New Listings tab je **3 minute** (češće od ostalih jer pratimo momentum).

---

### ZADATAK 2 — Claude sistemski prompt (KRITIČNO)

**Problem:** Trenutni sistemski prompt u `lib/models/analysis_provider.dart` je generički. Mora biti precizno kalibriran za naš use case — analizu startup coinova s early momentum profilom.

**Pronađi** konstantu koja sadrži sistemski prompt u `analysis_provider.dart`.  
**Zamijeni** je s točno ovim tekstom (ne mijenjaj ništa):

```
Ti si CoinSight — specijalizirani AI analitičar za rano otkrivanje momentum prilike na cryptocurrency tržištu. Tvoja jedina uloga je pomoći korisniku analizirati coinove s potencijalnim ranim rastom i donijeti informiranu odluku: pratiti, preskočiti, ili razmotriti ulaz.

Korisnikov profil: iskusan tehničar i analitičar koji razumije tržišne mehanizme, volatilnost i rizik. Ne objašnjavaš što je blockchain, što je volume, niti što znači market cap. Razgovaraš s njim kao kolega s jednakim znanjem.

Kada dobiješ podatke o coinu, analiziraj kroz tri objektiva:

OBJEKTIV 1 — PROFIL LISTINGA
Je li volume organički ili sumnjivo skočio bez jasnog razloga? Kakav je odnos volumea prema market capu — volumen koji je jednak ili veći od market capa je snažan signal aktivnosti ali i potencijalne manipulacije. Na kojim exchangeima je listiran — tier-1 exchange (Binance, Coinbase, Kraken) govori da je prošao KYC i audit, dok listing samo na DEX-ovima ili obscure CEX-ovima je žuti signal. Kakav je market cap rank — iznad 500 znači da je ispod radara institutional investitora što može biti prednost ili zamka.

OBJEKTIV 2 — RIZIK PROFIL  
Postoje li znakovi pump-and-dump mehanike: nagli volume spike bez prethodne online prisutnosti, price change od 500%+ u 24h na malom market capu, ime coina s previše exclamation markova ili "to the moon" u opisu. Je li 1h i 24h change konzistentan (zdrav trend) ili postoji 24h rast ali 1h pad (moguće da je pump završio). Je li volume padao dok cijena raste (bearish divergence).

OBJEKTIV 3 — PREPORUKA
Završi svaku analizu s jednom od tri oznake na zasebnoj liniji:

**WATCH** — ima potencijal ali treba više podataka ili potvrde trenda  
**SKIP** — previše rizičan, nejasan profil, ili pump već gotov  
**INTERESTING** — solid profil, razmatraj ulaz s malim iznosom

Nakon oznake, jedna do dvije rečenice konkretnog razloga. Zatim predloži jedan konkretan sljedeći korak: "Provjeri opet za 2 sata", "Pogledaj Twitter/X aktivnost", "Volume trend kroz sljedeći sat je ključan" i slično.

Kada nemaš dovoljno podataka za procjenu, reci koji točno podatak nedostaje — ne davaj praznu analizu.

Nikad ne garantiraš profit. Ovo je analiza obrazaca, ne financijski savjet.

Jezik: ako korisnik piše na hrvatskom, odgovaraj na hrvatskom. Ako na engleskom, na engleskom.
```

---

### ZADATAK 3 — Analysis Logging (PROVJERI I DOPUNI)

**Provjeri** postoji li u `lib/services/storage_service.dart` ili drugdje implementacija koja logira Claude AI analize lokalno s poljima: timestamp, coin_id, coin_symbol, price_at_analysis, claude_recommendation, recommendation_type (WATCH/SKIP/INTERESTING).

**Ako ne postoji** — implementiraj `AnalysisLog` model i `saveAnalysisLog()` metodu u StorageService. Svaki Claude odgovor koji sadrži **WATCH**, **SKIP** ili **INTERESTING** mora automatski biti logiran.

Parsiranje recommendation_type iz Claude odgovora:
```dart
String parseRecommendationType(String claudeResponse) {
  if (claudeResponse.contains('**INTERESTING**')) return 'INTERESTING';
  if (claudeResponse.contains('**WATCH**')) return 'WATCH';
  if (claudeResponse.contains('**SKIP**')) return 'SKIP';
  return 'NONE';
}
```

---

### ZADATAK 4 — CHATLOG.md

**Kreiraj** fajl `CHATLOG.md` u root direktoriju projekta s ovim inicijalnim sadržajem:

```markdown
# CoinSight — Chat Log

Ovaj fajl bilježi ključne analitičke sesije i zaključke.
Format: datum, coin, preporuka, ishod (popunjava se naknadno).

---

## Template unosa

### [DATUM] — [COIN SYMBOL]
**Podaci pri analizi:** cijena X USD, volume Y USD, 24h change Z%  
**Claude preporuka:** WATCH / SKIP / INTERESTING  
**Razlog:** ...  
**Ishod:** (popunjava se 24-48h nakon)  

---
```

---

### ZADATAK 5 — Android Build Verifikacija

**Nakon što su Zadaci 1-4 završeni i verificirani s `flutter analyze`:**

Pokušaj Android debug build:
```
flutter build apk --debug
```

Ako postoje Android-specifični errori koji nisu bili vidljivi u Windows buildu, prijavi ih u WORKLOG.md pod "Identified Issues" s točnim error messagom i zahvaćenim fajlom.

Ne pokušavaj sam popraviti Android build probleme bez odobrenja — samo dokumentiraj.

---

## VERIFIKACIJA NA KRAJU SESIJE

Prije nego završiš sesiju, pokreni:
```
flutter analyze
```
Mora biti 0 issues. Ako ima warningova ili errora, popravi ih prije završetka.

Dodaj unos u WORKLOG.md koji opisuje sve što je napravljeno u ovoj sesiji prema postojećem formatu iz prethodnih sesija.

---

## ŠTO NE RADIŠ U OVOJ SESIJI

- Ne mijenjaj temu ili vizualni dizajn aplikacije
- Ne dodaješ nove dependencies bez odobrenja
- Ne implementiraš trading/kupovinu/prodaju unutar aplikacije
- Ne dodaješ nikakve analytics ili tracking
- Ne commitaš na GitHub
- Ne mijenjaš LICENSE niti README bez pitanja

---

## NAPOMENA O PRIRODI PROJEKTA

CoinSight je privatni analitički alat. Nije namijenjen distribuciji. Sav kod ostaje lokalno. Ovo nije software development kompanija niti open source projekt. Claude Code ovdje djeluje kao Flutter developer koji implementira točno definirane zahtjeve — ne kao autonomni arhitekt koji donosi samostalne odluke o smjeru projekta.

# Claude Code — Copy-Paste Prompt za novu sesiju

Zalijepi ovo direktno u Claude Code terminal kao prvu poruku nove sesije:

---

```
Pročitaj redom sljedeće fajlove bez preskakanja:
1. CLAUDE.md
2. WORKLOG.md  
3. SESSION_2.md

Nakon čitanja napiši mi kratki summary u 5-6 bullet pointa što si našao u kodu i koji su zadaci za ovu sesiju. Tek nakon moje potvrde summary-ja kreni s implementacijom Zadatka 1.

Ne pišeš kod dok ne dobiješ moju potvrdu summarya.
```

---

## Što očekivati nakon što Claude Code pročita fajlove

Claude Code treba ti vratiti summary koji sadrži otprilike ovo:

- App ima 3 taba: My Watchlist, Top Coins — oba prikazuju market data ali NE nove listinge
- CoinGecko service postoji i radi, model Coin postoji ali nema `priceChangePercentage1h` field
- Claude service postoji, sistemski prompt je generički i treba zamjenu
- Analysis logging: postoji ili ne postoji (ovisno o što nađe)
- CHATLOG.md ne postoji u projektu
- Android build nije testiran, samo Windows

Ako summary odgovara — potvrdi i reci: **"Kreni sa Zadatkom 1."**

---

## Tijek sesije — kako voditi razgovor

**Nakon Zadatka 1:**
```
Pokreni flutter analyze. Ako je 0 issues, pokaži mi kako sada izgleda New Listings tab — opiši mi što točno vidim na ekranu. Zatim kreni sa Zadatkom 2.
```

**Nakon Zadatka 2:**
```
Pokaži mi točno koji tekst si stavio kao sistemski prompt u kod. Potvrdit ću je li točan. Zatim kreni sa Zadatkom 3.
```

**Nakon Zadatka 3:**
```
Pokaži mi implementaciju logging funkcije i parsiranje WATCH/SKIP/INTERESTING. Zatim kreni sa Zadatkom 4.
```

**Nakon Zadatka 4:**
```
Kreni sa Zadatkom 5 — Android debug build. Samo build, ne popravljaš errore bez mog odobrenja.
```

**Na kraju sesije:**
```
Dodaj unos u WORKLOG.md za sve što smo napravili danas. Pokaži mi taj unos prije nego ga zapišeš.
```

---

## Ako Claude Code počne lutati

Ako Claude Code počne predlagati stvari koje nisu u SESSION_2.md, sam refaktorira kod koji nije pokvaren, ili dodaje featuree koje nisi tražio — zaustavi ga s:

```
Stop. Vrati se na SESSION_2.md zadatke. Nisi tražio to što predlažeš. Fokusiraj se isključivo na zadatak koji smo dogovorili.
```

---

## Napomena o CLAUDE.md u repou

Trenutni CLAUDE.md u repou je nepotpun — sadrži samo zadnji dio originalnog dokumenta. Nakon što Claude Code završi sesiju i sve verificira, zamijeni sadržaj CLAUDE.md s kompletnim dokumentom koji imate lokalno ili zatraži od Claude Codea da rekonstruira puni CLAUDE.md iz WORKLOG.md konteksta.

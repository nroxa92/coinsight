Ako Claude Code primijeti bug koji nije dio zadatka koji 
rješava, dodaje ga pod sekciju Identified Issues u WORKLOG.md 
ali ga ne popravlja bez pitanja.

## Redoslijed implementacije

Implementacija ide fazno i svaka faza mora biti funkcionalna 
prije prelaska na sljedeću. Faza 1 je scaffold projekta, 
pubspec.yaml s dependencies, osnovna navigacija i tamna tema. 
Faza 2 je CoinGecko integracija i Watchlist screen s CoinCard 
widgetom i stvarnim podacima. Faza 3 je Anthropic integracija, 
ClaudeService i Analysis chat screen s osnovnim chat UI-jem. 
Faza 4 je Hive logging i Settings screen za unos API ključa. 
Faza 5 je polish — error handling, loading states i UX detalji.

Developer eksplicitno potvrđuje kraj svake faze prije nego 
Claude Code kreće u sljedeću.
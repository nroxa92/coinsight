import 'package:flutter/foundation.dart';
import 'package:coinsight/services/claude_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/telegram_monitor.dart';
import 'package:coinsight/services/intelligence_aggregator.dart';
import 'package:coinsight/models/coin.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/models/telegram_signal.dart';
import 'package:coinsight/models/intelligence_report.dart';
import 'package:coinsight/models/investment_tier.dart';

class AnalysisProvider extends ChangeNotifier {
  final ClaudeService _claudeService;
  final TelegramMonitor _telegramMonitor;
  final IntelligenceAggregator _intelligence;
  final List<TelegramSignal> _pendingSignals = [];

  IntelligenceReport? _lastReport;
  bool _isGatheringIntelligence = false;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  static const _shortSystemPrompt =
      'Ti si CoinSight — specijalizirani AI analitičar za rano otkrivanje momentum prilike na cryptocurrency tržištu. Tvoja jedina uloga je pomoći korisniku analizirati coinove s potencijalnim ranim rastom i donijeti informiranu odluku: pratiti, preskočiti, ili razmotriti ulaz.\n\n'
      'Korisnikov profil: iskusan tehničar i analitičar koji razumije tržišne mehanizme, volatilnost i rizik. Ne objašnjavaš što je blockchain, što je volume, niti što znači market cap. Razgovaraš s njim kao kolega s jednakim znanjem.\n\n'
      'Kada dobiješ podatke o coinu, analiziraj kroz tri objektiva:\n\n'
      'OBJEKTIV 1 — PROFIL LISTINGA\n'
      'Je li volume organički ili sumnjivo skočio bez jasnog razloga? Kakav je odnos volumea prema market capu — volumen koji je jednak ili veći od market capa je snažan signal aktivnosti ali i potencijalne manipulacije. Na kojim exchangeima je listiran — tier-1 exchange (Binance, Coinbase, Kraken) govori da je prošao KYC i audit, dok listing samo na DEX-ovima ili obscure CEX-ovima je žuti signal. Kakav je market cap rank — iznad 500 znači da je ispod radara institutional investitora što može biti prednost ili zamka.\n\n'
      'OBJEKTIV 2 — RIZIK PROFIL\n'
      'Postoje li znakovi pump-and-dump mehanike: nagli volume spike bez prethodne online prisutnosti, price change od 500%+ u 24h na malom market capu, ime coina s previše exclamation markova ili "to the moon" u opisu. Je li 1h i 24h change konzistentan (zdrav trend) ili postoji 24h rast ali 1h pad (moguće da je pump završio). Je li volume padao dok cijena raste (bearish divergence).\n\n'
      'OBJEKTIV 3 — PREPORUKA\n'
      'Završi svaku analizu s jednom od tri oznake na zasebnoj liniji:\n\n'
      '**WATCH** — ima potencijal ali treba više podataka ili potvrde trenda\n'
      '**SKIP** — previše rizičan, nejasan profil, ili pump već gotov\n'
      '**INTERESTING** — solid profil, razmatraj ulaz s malim iznosom\n\n'
      'Nakon oznake, jedna do dvije rečenice konkretnog razloga. Zatim predloži jedan konkretan sljedeći korak: "Provjeri opet za 2 sata", "Pogledaj Twitter/X aktivnost", "Volume trend kroz sljedeći sat je ključan" i slično.\n\n'
      'Kada nemaš dovoljno podataka za procjenu, reci koji točno podatak nedostaje — ne davaj praznu analizu.\n\n'
      'Nikad ne garantiraš profit. Ovo je analiza obrazaca, ne financijski savjet.\n\n'
      'Jezik: ako korisnik piše na hrvatskom, odgovaraj na hrvatskom. Ako na engleskom, na engleskom.\n\n'
      'KADA DOBIJEŠ INTELLIGENCE REPORT:\n'
      'Intelligence Report sadrži podatke iz do 5 izvora: DEX listing, GitHub, Reddit, Telegram i CoinGecko market data. Svaki izvor ima težinu i score.\n\n'
      'Confluence analiza — kako interpretirati:\n'
      'Score 5.0-6.0: Svi izvori konvergiraju pozitivno. Rijetko se događa, ali kad se dogodi — ozbiljan signal. Provjeri duplo jer visok score zna privući i manipulatore.\n'
      'Score 3.0-4.9: Više izvora se slaže. Vrijedi detaljnija analiza kroz sva tri objektiva.\n'
      'Score 1.5-2.9: Slabi signal, jedan do dva izvora. WATCH je maksimalna preporuka.\n'
      'Score <1.5: Nedovoljno podataka ili slabi signal. SKIP osim ako postoji jasan specifičan razlog.\n\n'
      'DEX listing uvijek ponderiraš više nego ostale jer je vremenski najraniji signal — coin još nije na CEX-u.\n'
      'GitHub signal je legitimacy filter — nema repo ili neaktivan repo = žuti signal bez obzira na ostale izvore.\n'
      'Reddit signal ponderiraš manje — retail kasni za smartim novcem.\n'
      'Telegram whale alert ponderiraš visoko — smart money se pomiče.\n\n'
      'Scoring hint koji dobiješ (STRONG_INTERESTING, POSSIBLE_WATCH, itd.) je matematička kalkulacija — nije tvoja obveza složiti se. Tvoja analiza kroz tri objektiva ima prioritet.\n\n'
      'Ako dobiješ report s activeSources < 2 — jasno napiši da nema dovoljno podataka za pouzdanu analizu.\n'
      'Ako dobiješ report bez DEX signala ali s visokim Telegram/Reddit score-om — to može biti CEX listing koji dolazi — WATCH, prati.\n'
      'Ako dobiješ report s DEX signalom ali bez GitHub-a — povećani rizik scama, naglasi u analizi.';

  static const _midSystemPrompt =
      'Ti si CoinSight MID-TERM analiti\u010Dar. Specijaliziran si za value discovery \u2014 '
      'pronala\u017Eenje legitimnih projekata koji su jo\u0161 nepoznati mainstream zajednici '
      'ali imaju solidne temelje za rast u horizontu od tjedna do nekoliko '
      'mjeseci.\n\n'
      'Korisnikov profil: iskusan tehni\u010Dar koji razumije tr\u017Ei\u0161te. Ne obja\u0161njava\u0161 '
      'osnove \u2014 razgovara\u0161 kao kolega analiti\u010Dar.\n\n'
      'Za MID tier analizu fokusira\u0161 se na pet osi:\n\n'
      'OS 1 \u2014 TIM I LEGITIMNOST\n'
      'Tko su osniva\u010Di? Jesu li javno poznati i verificirani? GitHub repo \u2014 postoji '
      'li, je li aktivan, koliko contributora? Anonimni tim na nepoznatom projektu '
      'je crvena zastava za MID. Iskusan tim s prethodnim uspje\u0161nim projektom '
      'je zelena zastava.\n\n'
      'OS 2 \u2014 TOKENOMICS\n'
      'Distribucija tokena \u2014 previsok % za tim ili investitore zna\u010Di potencijalni '
      'dump. Vesting schedule \u2014 kad se otklju\u010Davaju team tokeni? Supply \u2014 '
      'inflatoran ili deflatoran model? Ima li token stvarni use case ili je '
      'samo spekulativni instrument?\n\n'
      'OS 3 \u2014 REAL WORLD USE CASE\n'
      '\u0160to projekt konkretno rje\u0161ava? Postoji li MVP ili samo whitepaper? '
      'Ima li stvarnih korisnika koji pla\u0107aju za uslugu? Raste li organic '
      'usage neovisno o token cijeni?\n\n'
      'OS 4 \u2014 COMPETITIVE LANDSCAPE\n'
      'Tko su direktni konkurenti? Za\u0161to je ovaj projekt bolji ili druga\u010Diji? '
      'Je li ni\u0161a dovoljno velika za vi\u0161e igra\u010Da ili pobjednik uzima sve?\n\n'
      'OS 5 \u2014 TIMING\n'
      'Je li pre-CEX (DEX only) ili early CEX faza? Kakav je roadmap \u2014 '
      'jesu li do sada ispunjavali obe\u0107anja? Je li dobra to\u010Dka za ulaz ili '
      'je bolje \u010Dekati korekciju?\n\n'
      'Nakon analize zaklju\u010Duje\u0161 s jednom od oznaka na zasebnoj liniji:\n\n'
      '**RESEARCH_MORE** \u2014 potrebno vi\u0161e podataka\n'
      '**WATCHLIST** \u2014 legitiman projekt, \u010Dekaj bolji entry\n'
      '**ENTER** \u2014 solid projekt i pravo vrijeme\n'
      '**AVOID** \u2014 previ\u0161e crvenih zastava ili kasno za MID\n\n'
      'Uz oznaku: 2-3 re\u010Denice razloga i jedan konkretan sljede\u0107i korak '
      '(\u0161to provjeriti, \u0161to \u010Dekati, ili koji podatak nedostaje).\n\n'
      'Nikad ne garantira\u0161 profit. Ovo je analiza obrazaca i fundamentala. '
      'Jezik: prilagodi korisniku.';

  static const _longSystemPrompt =
      'Ti si CoinSight LONG-TERM analiti\u010Dar. Specijaliziran si za identifikaciju '
      'infrastrukturnih projekata koji rje\u0161avaju stvaran problem i imaju potencijal '
      'za 10x\u2013100x return u horizontu od nekoliko mjeseci do godina.\n\n'
      'Ovo je ultra rigorozna analiza. Svaka LONG preporuka mora pro\u0107i kroz '
      'sve kriterije bez iznimke. Ovo nije trading \u2014 svaka pogre\u0161ka ve\u017Ee kapital '
      'na dugo.\n\n'
      'Korisnikov profil: strate\u0161ki razmi\u0161lja\u010D koji tra\u017Ei asimetri\u010Dnu priliku.\n\n'
      'LONG HOLD KRITERIJI \u2014 svi moraju biti razmotreni:\n\n'
      'KRITERIJ 1 \u2014 TIM (kriti\u010Dan za LONG)\n'
      'Osniva\u010Di moraju biti javno poznati i verificirani \u2014 LinkedIn, prethodna '
      'iskustva, javni nastupi. Anonimni tim = automatski AVOID_LONG. '
      'Koliko dugo su u crypto industriji? Imaju li prethodne uspje\u0161ne projekte?\n\n'
      'KRITERIJ 2 \u2014 INVESTITORI\n'
      'Koji tier-1 VC-evi su investirali? '
      'Tier-1: a16z, Paradigm, Multicoin Capital, Sequoia Crypto, Pantera Capital, '
      'Polychain, Dragonfly. Prisutnost tier-1 investitora zna\u010Di da je projekt '
      'pro\u0161ao ozbiljnu due diligence. Tier-2 ili nepoznati VC-evi = \u017Euti signal.\n\n'
      'KRITERIJ 3 \u2014 REAL WORLD ADOPTION\n'
      'Postoje li stvarni korisnici koji pla\u0107aju? Za DeFi: TVL trend (raste ili '
      'pada?). Za infrastructure: broj integracija s drugim projektima. '
      'Organic growth nezavisan od token incentiva?\n\n'
      'KRITERIJ 4 \u2014 INFRASTRUKTURA vs SPEKULACIJA\n'
      'Projekt mora rje\u0161avati fundamentalni blockchain problem: oracle, layer 2 '
      'scaling, cross-chain bridging, privacy, decentralized identity, data '
      'availability. Nije: jo\u0161 jedan DEX, yield farm, ili meme coin.\n\n'
      'KRITERIJ 5 \u2014 TOKENOMICS RIGOROZNO\n'
      'Circulating supply vs max supply \u2014 FDV (Fully Diluted Valuation). '
      'Unlock schedule \u2014 kad team tokeni postaju liquid i mogu biti prodani? '
      'Burn mehanizmi ako postoje. Inflation rate.\n\n'
      'KRITERIJ 6 \u2014 COMPETITIVE MOAT\n'
      'Network effect \u2014 postaje li projekt vrijedniji s vi\u0161e korisnika? '
      'Switching cost \u2014 je li skupo ili te\u0161ko pre\u0107i na konkurenta? '
      'Tehnolo\u0161ka prednost koja je te\u0161ka za replicirati?\n\n'
      'Nakon kompletne analize zaklju\u010Duje\u0161 s jednom od oznaka:\n\n'
      '**STRONG_HOLD** \u2014 zadovoljava sve kriterije, confidence 8-10/10\n'
      '**CONDITIONAL_HOLD** \u2014 zadovoljava ve\u0107inu, postoje 1-2 rezerve\n'
      '**INVESTIGATE_MORE** \u2014 nedovoljno podataka za LONG odluku\n'
      '**AVOID_LONG** \u2014 ne zadovoljava LONG kriterije\n\n'
      'Uz oznaku obavezno navedi:\n'
      '- Confidence: X/10\n'
      '- Top 3 razloga ZA\n'
      '- Top 3 razloga PROTIV (rizici)\n'
      '- Preporu\u010Deni entry price range\n'
      '- Target exit price range\n'
      '- Key metric koji treba pratiti\n\n'
      'Nikad ne garantira\u0161 profit. Ovo je analiza obrazaca i fundamentala. '
      'Jezik: prilagodi korisniku.';

  String get _activeSystemPrompt {
    final tier = StorageService.getActiveTier();
    switch (tier) {
      case InvestmentTier.short: return _shortSystemPrompt;
      case InvestmentTier.mid:   return _midSystemPrompt;
      case InvestmentTier.long:  return _longSystemPrompt;
    }
  }

  List<String> get suggestionChips {
    final tier = StorageService.getActiveTier();
    switch (tier) {
      case InvestmentTier.short:
        return [
          'Analiziraj New Listings',
          'Koji coin ima momentum?',
          'Procijeni rizik watchliste',
        ];
      case InvestmentTier.mid:
        return [
          'Analiziraj GitHub aktivnost ovog projekta',
          'Procijeni tokenomics i distribuciju',
          'Je li ovo legitiman tim?',
          'Komparativna analiza s konkurentima',
        ];
      case InvestmentTier.long:
        return [
          'Duboka analiza fundamentala',
          'Procijeni dugoro\u010Dni use case',
          'Tko su investitori i partneri?',
          'Je li roadmap realan i ispunjavan?',
        ];
    }
  }

  AnalysisProvider({
    ClaudeService? claudeService,
    TelegramMonitor? telegramMonitor,
    IntelligenceAggregator? intelligence,
  })  : _claudeService = claudeService ?? ClaudeService(),
        _telegramMonitor = telegramMonitor ?? TelegramMonitor(),
        _intelligence = intelligence ?? IntelligenceAggregator() {
    final savedKey = StorageService.getApiKey();
    if (savedKey != null && savedKey.isNotEmpty) {
      _claudeService.setApiKey(savedKey);
    }
    _telegramMonitor.onSignalReceived = (signal) {
      _pendingSignals.add(signal);
      if (_pendingSignals.length > 10) _pendingSignals.removeAt(0);
      notifyListeners();
    };
    _intelligence.onHighScoreSignal = (report) {
      _lastReport = report;
      notifyListeners();
    };
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiKey => _claudeService.hasApiKey;
  int get pendingSignalsCount => _pendingSignals.length;
  IntelligenceReport? get lastReport => _lastReport;
  bool get isGatheringIntelligence => _isGatheringIntelligence;

  void setApiKey(String key) {
    _claudeService.setApiKey(key);
    StorageService.saveApiKey(key);
    notifyListeners();
  }

  void removeApiKey() {
    _claudeService.setApiKey('');
    StorageService.deleteApiKey();
    notifyListeners();
  }

  Future<void> sendMessage(String text, {List<Coin>? watchlistCoins}) async {
    _error = null;

    final userContent = _buildUserMessage(text, watchlistCoins);
    _messages.add(ChatMessage(role: 'user', content: text));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _claudeService.sendMessage(
        userMessage: userContent,
        history: _messages.length > 1
            ? _messages.sublist(0, _messages.length - 1)
            : [],
        systemPrompt: _activeSystemPrompt,
      );

      _messages.add(ChatMessage(role: 'assistant', content: response));
      _tryLogAnalysis(response, watchlistCoins);
    } on ClaudeException catch (e) {
      _error = e.message;
      _messages.removeLast();
    } catch (e) {
      _error = 'Failed to get response. Check your connection.';
      _messages.removeLast();
    }

    _isLoading = false;
    notifyListeners();
  }

  String _buildUserMessage(String text, List<Coin>? coins) {
    final buffer = StringBuffer();

    // 1. Intelligence Report (najvažniji kontekst)
    if (_lastReport != null) {
      buffer.writeln(_lastReport!.toClaudeContext());
      buffer.writeln();
      _lastReport = null;
    } else {
      // 2. Watchlist kontekst
      if (coins != null && coins.isNotEmpty) {
        final coinData = coins.map((c) {
          final change = c.priceChangePercentage24h >= 0 ? '+' : '';
          return '${c.name} (${c.symbol.toUpperCase()}): '
              '\$${c.currentPrice.toStringAsFixed(2)}, '
              '$change${c.priceChangePercentage24h.toStringAsFixed(2)}% 24h, '
              'MCap rank #${c.marketCapRank}';
        }).join('\n');
        buffer.writeln('Watchlist kontekst:\n$coinData\n');
      }

      // 3. Telegram signali
      if (_pendingSignals.isNotEmpty) {
        final signalContext =
            _pendingSignals.map((s) => s.toClaudeContext()).join('\n\n');
        buffer.writeln(
            '[TELEGRAM INTELLIGENCE — ${_pendingSignals.length} signala]:\n$signalContext\n');
        _pendingSignals.clear();
      }
    }

    if (buffer.isNotEmpty) {
      buffer.write('Pitanje: $text');
      return buffer.toString();
    }
    return text;
  }

  void _tryLogAnalysis(String response, List<Coin>? coins) {
    final type = AnalysisLog.parseRecommendationType(response);
    if (type == 'NONE') return;

    final coin = (coins != null && coins.isNotEmpty) ? coins.first : null;
    StorageService.saveAnalysisLog(AnalysisLog(
      timestamp: DateTime.now(),
      coinId: coin?.id ?? 'unknown',
      coinSymbol: coin?.symbol.toUpperCase() ?? 'N/A',
      priceAtAnalysis: coin?.currentPrice ?? 0,
      claudeRecommendation: response.length > 500
          ? '${response.substring(0, 500)}...'
          : response,
      recommendationType: type,
    ));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearChat() {
    _messages = [];
    _error = null;
    notifyListeners();
  }

  /// Korisnik pita o specifičnom coinu — sakupi intelligence odmah
  Future<void> gatherIntelligenceForCoin(String symbol,
      {Coin? marketData}) async {
    _isGatheringIntelligence = true;
    notifyListeners();

    try {
      _lastReport = await _intelligence.buildReportForSymbol(
        symbol: symbol,
        marketData: marketData,
      );
    } catch (_) {
      _lastReport = null;
    }

    _isGatheringIntelligence = false;
    notifyListeners();
  }

  // Intelligence + Telegram lifecycle
  void startIntelligenceMonitoring() {
    // Only start background scanning if user has API key configured
    if (hasApiKey) {
      _intelligence.startAutoScan();
    }
    _telegramMonitor.reloadCredentials();
    if (_telegramMonitor.isConfigured) {
      _telegramMonitor.startMonitoring();
    }
  }

  void stopIntelligenceMonitoring() {
    _intelligence.stopAutoScan();
    _telegramMonitor.stopMonitoring();
  }

  // Keep for backward compatibility with settings
  void startTelegramMonitor() {
    _telegramMonitor.reloadCredentials();
    if (_telegramMonitor.isConfigured) {
      _telegramMonitor.startMonitoring();
    }
  }

  void stopTelegramMonitor() => _telegramMonitor.stopMonitoring();

  Future<String?> testTelegramMonitor() => _telegramMonitor.testConnection();
}

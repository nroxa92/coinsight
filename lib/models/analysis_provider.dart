import 'package:flutter/foundation.dart';
import 'package:coinsight/services/claude_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/models/coin.dart';
import 'package:coinsight/models/analysis_log.dart';

class AnalysisProvider extends ChangeNotifier {
  final ClaudeService _claudeService;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  static const _systemPrompt =
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
      'Jezik: ako korisnik piše na hrvatskom, odgovaraj na hrvatskom. Ako na engleskom, na engleskom.';

  AnalysisProvider({ClaudeService? claudeService})
      : _claudeService = claudeService ?? ClaudeService() {
    final savedKey = StorageService.getApiKey();
    if (savedKey != null && savedKey.isNotEmpty) {
      _claudeService.setApiKey(savedKey);
    }
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiKey => _claudeService.hasApiKey;

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
        systemPrompt: _systemPrompt,
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
    if (coins == null || coins.isEmpty) return text;

    final coinData = coins.map((c) {
      final change = c.priceChangePercentage24h >= 0 ? '+' : '';
      return '${c.name} (${c.symbol.toUpperCase()}): '
          '\$${c.currentPrice.toStringAsFixed(2)}, '
          '$change${c.priceChangePercentage24h.toStringAsFixed(2)}% 24h, '
          'MCap rank #${c.marketCapRank}';
    }).join('\n');

    return 'My watchlist:\n$coinData\n\nQuestion: $text';
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
}

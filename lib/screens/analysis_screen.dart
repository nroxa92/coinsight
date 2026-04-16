import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/models/coin.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/models/trade_proposal.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/tier_provider.dart';
import 'package:coinsight/models/mid_term_project.dart';
import 'package:coinsight/models/long_term_holding.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/trade_service.dart';
import 'package:coinsight/widgets/chat_bubble.dart';
import 'package:coinsight/screens/chart_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _amountController = TextEditingController();
  final _tradeService = TradeService();
  bool _disposed = false;
  int _dismissedActionBarIndex = -1;
  int _dismissedMidBarIndex = -1;
  int _dismissedLongBarIndex = -1;
  bool _executingTrade = false;

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    _scrollController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_disposed || !_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_disposed || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage(AnalysisProvider provider) {
    final text = _controller.text.trim();
    if (text.isEmpty || provider.isLoading) return;

    final watchlist = context.read<WatchlistProvider>().watchlistCoins;
    _controller.clear();
    provider.sendMessage(text, watchlistCoins: watchlist).then((_) {
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AnalysisProvider, TierProvider>(
      builder: (context, provider, tierProvider, _) {
        if (!provider.hasApiKey) {
          return _buildNoApiKeyState(context);
        }
        final tier = tierProvider.activeTier;
        return Column(
          children: [
            _buildSignalBadge(provider),
            Expanded(
              child: provider.messages.isEmpty
                  ? _buildEmptyState(provider)
                  : _buildMessageList(provider),
            ),
            _buildChartButton(provider, tierProvider),
            _buildTradeActionBarIfEligible(provider, tier),
            _buildMidActionBarIfEligible(provider, tier),
            _buildLongActionBarIfEligible(provider, tier),
            if (provider.error != null) _buildErrorBar(provider),
            _buildInputBar(provider),
          ],
        );
      },
    );
  }

  Widget _buildSignalBadge(AnalysisProvider provider) {
    if (provider.pendingSignalsCount == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('📡 ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              '${provider.pendingSignalsCount} Telegram signal(a) čeka — bit će uključen u sljedeću analizu',
              style: const TextStyle(fontSize: 11, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoApiKeyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.key, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'API Key Required',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your Anthropic API key in Settings to start chatting with CoinSight AI.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AnalysisProvider provider) {
    final chips = provider.suggestionChips;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'CoinSight AI',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask about crypto trends, coin analysis, or blockchain concepts. '
              'Your watchlist data is shared for context.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: chips.map((c) => _buildSuggestionChip(c)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, _) {
        return ActionChip(
          label: Text(text, style: const TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFF252525),
          onPressed: () {
            _controller.text = text;
            _sendMessage(provider);
          },
        );
      },
    );
  }

  Widget _buildMessageList(AnalysisProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.messages.length) {
          return _buildTypingIndicator();
        }
        final message = provider.messages[index];
        return AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          offset: Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: 1.0,
            child: ChatBubble(
              text: message.content,
              isUser: message.role == 'user',
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Chart Button ─────────
  Widget _buildChartButton(AnalysisProvider provider, TierProvider tierProvider) {
    if (provider.messages.isEmpty) return const SizedBox.shrink();
    final last = provider.messages.last;
    if (last.role != 'assistant') return const SizedBox.shrink();

    // Pronađi simbol iz analize (regex)
    final symbolMatch = RegExp(r'\b([A-Z]{2,10})\b').firstMatch(last.content);
    if (symbolMatch == null) return const SizedBox.shrink();
    final symbol = symbolMatch.group(1)!;

    // Ne prikazuj za poznate ne-coin uppercase riječi
    const ignore = {'WATCH', 'SKIP', 'INTERESTING', 'ENTER', 'AVOID',
        'DEX', 'CEX', 'TVL', 'DCA', 'SL', 'TP', 'ATH', 'ATL'};
    if (ignore.contains(symbol)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.show_chart, size: 16),
          label: Text('Prikaži $symbol chart'),
          style: OutlinedButton.styleFrom(
            foregroundColor: tierProvider.activeTier.color,
            side: BorderSide(
                color: tierProvider.activeTier.color.withValues(alpha: 0.5)),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChartScreen(
                symbol: symbol,
                tier: tierProvider.activeTier,
                claudeAnalysis: last.content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Trade Action Bar (SHORT tier only) ─────────
  Widget _buildTradeActionBarIfEligible(AnalysisProvider provider, InvestmentTier tier) {
    if (tier != InvestmentTier.short) return const SizedBox.shrink();
    if (provider.messages.isEmpty) return const SizedBox.shrink();
    final lastIndex = provider.messages.length - 1;
    if (lastIndex == _dismissedActionBarIndex) {
      return const SizedBox.shrink();
    }
    final last = provider.messages[lastIndex];
    if (last.role != 'assistant') return const SizedBox.shrink();
    if (!last.content.contains('**INTERESTING**')) {
      return const SizedBox.shrink();
    }

    final binance = BinanceService();
    if (!binance.hasCredentials) return const SizedBox.shrink();

    final riskParams = StorageService.getRiskParameters();
    if (riskParams.autoTradeEnabled) return const SizedBox.shrink();

    final coins = context.read<WatchlistProvider>().watchlistCoins;
    if (coins.isEmpty) return const SizedBox.shrink();
    final coin = coins.first;

    if (_amountController.text.isEmpty) {
      _amountController.text = riskParams.maxTradeAmountUsdt.toStringAsFixed(2);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚨 ',
                  style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  'INTERESTING signal — ${coin.symbol.toUpperCase()}/USDT',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _dismissedActionBarIndex = lastIndex),
                child: Icon(Icons.close,
                    size: 16, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Uloži:', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                height: 36,
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text('USDT', style: TextStyle(fontSize: 12)),
              const Spacer(),
              Text(
                'SL -${riskParams.stopLossPercent.toStringAsFixed(0)}% | TP +${riskParams.takeProfitPercent.toStringAsFixed(0)}%',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: _executingTrade
                      ? null
                      : () => _buyNow(coin, last.content),
                  child: _executingTrade
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('BUY NOW',
                          style:
                              TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _skip(coin, last.content, lastIndex),
                  child: const Text('SKIP'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _buyNow(Coin coin, String recommendation) async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesi valjani iznos')),
      );
      return;
    }
    setState(() => _executingTrade = true);
    try {
      final riskParams = StorageService.getRiskParameters();
      final proposal = await _tradeService.prepareTradeProposal(
        coin: coin,
        claudeRecommendation: recommendation,
        riskParams: riskParams.copyWith(maxTradeAmountUsdt: amount),
      );
      if (!mounted) return;
      final ok = await _showProposalDialog(proposal);
      if (!ok) return;
      final result = await _tradeService.executeTrade(proposal);
      if (!mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Bought ${result.executedQty?.toStringAsFixed(6)} ${coin.symbol.toUpperCase()} @ \$${result.executedPrice?.toStringAsFixed(6)}')),
        );
        setState(() =>
            _dismissedActionBarIndex = context
                    .read<AnalysisProvider>()
                    .messages
                    .length -
                1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Trade failed')),
        );
      }
    } on BinanceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _executingTrade = false);
    }
  }

  Future<bool> _showProposalDialog(TradeProposal p) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: Text('Potvrdi kupnju ${p.coin.symbol.toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cijena: \$${p.currentPrice.toStringAsFixed(6)}'),
            Text('Iznos: \$${p.amountUsdt.toStringAsFixed(2)}'),
            Text('Qty: ~${p.estimatedQty.toStringAsFixed(6)}'),
            const SizedBox(height: 8),
            Text('SL: \$${p.stopLossPrice.toStringAsFixed(6)}',
                style:
                    const TextStyle(color: Color(0xFFEF5350), fontSize: 12)),
            Text('TP: \$${p.takeProfitPrice.toStringAsFixed(6)}',
                style: const TextStyle(color: Colors.green, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              'Market order — izvršava se po trenutnoj cijeni.',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('CONFIRM BUY',
                style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _skip(Coin coin, String recommendation, int idx) async {
    await StorageService.saveAnalysisLog(AnalysisLog(
      timestamp: DateTime.now(),
      coinId: coin.id,
      coinSymbol: coin.symbol.toUpperCase(),
      priceAtAnalysis: coin.currentPrice,
      claudeRecommendation: '[SKIPPED] ${recommendation.length > 200 ? '${recommendation.substring(0, 200)}...' : recommendation}',
      recommendationType: 'SKIP',
    ));
    if (!mounted) return;
    setState(() => _dismissedActionBarIndex = idx);
  }

  // ───────── MID Action Bar ─────────
  Widget _buildMidActionBarIfEligible(AnalysisProvider provider, InvestmentTier tier) {
    if (tier != InvestmentTier.mid) return const SizedBox.shrink();
    if (provider.messages.isEmpty) return const SizedBox.shrink();
    final lastIndex = provider.messages.length - 1;
    if (lastIndex == _dismissedMidBarIndex) return const SizedBox.shrink();
    final last = provider.messages[lastIndex];
    if (last.role != 'assistant') return const SizedBox.shrink();
    if (!last.content.contains('**WATCHLIST**') &&
        !last.content.contains('**ENTER**')) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF03DAC6).withValues(alpha: 0.08),
        border: Border.all(color: const Color(0xFF03DAC6).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\uD83D\uDCC8 ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  'MID tier signal \u2014 dodaj u istra\u017Eivanje?',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF03DAC6),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _dismissedMidBarIndex = lastIndex),
                child: Icon(Icons.close, size: 16, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03DAC6),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => _addMidProject(last.content, lastIndex),
                  child: const Text('DODAJ U ISTRA\u017DIVANJE',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _dismissedMidBarIndex = lastIndex),
                  child: const Text('PRESKO\u010CI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addMidProject(String claudeResponse, int lastIndex) {
    // Try to extract symbol from the response
    final symbolMatch = RegExp(r'\b([A-Z]{2,10})\b').firstMatch(claudeResponse);
    final symbol = symbolMatch?.group(1) ?? 'UNKNOWN';
    final project = MidTermProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      name: symbol,
      discoveredAt: DateTime.now(),
      status: MidTermStatus.researching,
      thesis: claudeResponse.length > 300
          ? '${claudeResponse.substring(0, 300)}...'
          : claudeResponse,
      lastClaudeAnalysis: claudeResponse,
      lastAnalysisDate: DateTime.now(),
    );
    StorageService.saveMidProject(project);
    setState(() => _dismissedMidBarIndex = lastIndex);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$symbol dodan u MID istra\u017Eivanje')),
    );
  }

  // ───────── LONG Action Bar ─────────
  Widget _buildLongActionBarIfEligible(AnalysisProvider provider, InvestmentTier tier) {
    if (tier != InvestmentTier.long) return const SizedBox.shrink();
    if (provider.messages.isEmpty) return const SizedBox.shrink();
    final lastIndex = provider.messages.length - 1;
    if (lastIndex == _dismissedLongBarIndex) return const SizedBox.shrink();
    final last = provider.messages[lastIndex];
    if (last.role != 'assistant') return const SizedBox.shrink();
    if (!last.content.contains('**STRONG_HOLD**') &&
        !last.content.contains('**CONDITIONAL_HOLD**')) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.08),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\uD83C\uDFDB\uFE0F ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  'LONG tier signal',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _dismissedLongBarIndex = lastIndex),
                child: Icon(Icons.close, size: 16, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => _addLongHolding(last.content, lastIndex),
                  child: const Text('DODAJ U HOLDINGS',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _addLongNote(last.content, lastIndex),
                  child: const Text('ZAPI\u0160I BILJE\u0160KU'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addLongHolding(String claudeResponse, int lastIndex) {
    final symbolMatch = RegExp(r'\b([A-Z]{2,10})\b').firstMatch(claudeResponse);
    final symbol = symbolMatch?.group(1) ?? 'UNKNOWN';
    final holding = LongTermHolding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      name: symbol,
      firstResearchDate: DateTime.now(),
      status: LongTermStatus.researching,
      targetPriceMin: 0,
      targetPriceMax: 0,
      investmentThesis: claudeResponse.length > 300
          ? '${claudeResponse.substring(0, 300)}...'
          : claudeResponse,
      claudeConfidenceScore: _extractConfidence(claudeResponse),
    );
    StorageService.saveLongHolding(holding);
    setState(() => _dismissedLongBarIndex = lastIndex);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$symbol dodan u LONG holdings')),
    );
  }

  void _addLongNote(String claudeResponse, int lastIndex) {
    // Save as a note — user can later assign to a holding
    final note = LongTermNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      content: claudeResponse.length > 500
          ? '${claudeResponse.substring(0, 500)}...'
          : claudeResponse,
      noteType: 'claude_analysis',
    );
    // For now, save as a standalone holding with note
    final symbolMatch = RegExp(r'\b([A-Z]{2,10})\b').firstMatch(claudeResponse);
    final symbol = symbolMatch?.group(1) ?? 'UNKNOWN';
    final holding = LongTermHolding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      name: symbol,
      firstResearchDate: DateTime.now(),
      status: LongTermStatus.researching,
      targetPriceMin: 0,
      targetPriceMax: 0,
      notes: [note],
    );
    StorageService.saveLongHolding(holding);
    setState(() => _dismissedLongBarIndex = lastIndex);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bilje\u0161ka zapisana za $symbol')),
    );
  }

  int? _extractConfidence(String text) {
    final match = RegExp(r'Confidence:\s*(\d+)/10').firstMatch(text);
    if (match != null) return int.tryParse(match.group(1)!);
    return null;
  }

  Widget _buildErrorBar(AnalysisProvider provider) {
    return Dismissible(
      key: ValueKey(provider.error),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => provider.clearError(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                size: 16, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => provider.clearError(),
              child: Icon(Icons.close,
                  size: 16, color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(AnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (provider.messages.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                onPressed: () => _confirmClearChat(provider),
                tooltip: 'Clear chat',
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                enabled: !provider.isLoading,
                onSubmitted: (_) => _sendMessage(provider),
                decoration: InputDecoration(
                  hintText: provider.isLoading
                      ? 'Waiting for response...'
                      : 'Ask about crypto...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.send,
                color: provider.isLoading
                    ? Colors.grey[700]
                    : Theme.of(context).colorScheme.primary,
              ),
              onPressed:
                  provider.isLoading ? null : () => _sendMessage(provider),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearChat(AnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Clear chat?'),
        content: const Text('This will delete all messages in this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearChat();
              Navigator.of(ctx).pop();
              setState(() {
                _dismissedActionBarIndex = -1;
                _dismissedMidBarIndex = -1;
                _dismissedLongBarIndex = -1;
              });
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

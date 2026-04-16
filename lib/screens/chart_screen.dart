import 'package:flutter/material.dart';
import 'package:coinsight/models/price_chart_data.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/dex_position.dart';
import 'package:coinsight/models/mid_term_project.dart';
import 'package:coinsight/models/long_term_holding.dart';
import 'package:coinsight/services/chart_data_service.dart';
import 'package:coinsight/widgets/price_chart_widget.dart';

/// ChartScreen — full-screen chart prikaz za specifičan coin/tier
///
/// Otvara se iz:
/// - SHORT Portfolio: tap na Binance ili DEX poziciju
/// - MID Portfolio: tap na MID projekt card
/// - LONG Portfolio: tap na LONG holding card
/// - Analysis screen: nakon Claude analize (gumb "Prikaži Chart")
class ChartScreen extends StatefulWidget {
  final String symbol;
  final String? coinGeckoId;
  final InvestmentTier tier;
  final String? claudeAnalysis; // za generiranje predikcije

  // Opcionalni pozicijski podaci za trade event markere
  final CoinPosition? binancePosition;
  final DexPosition? dexPosition;
  final MidTermProject? midProject;
  final LongTermHolding? longHolding;

  const ChartScreen({
    super.key,
    required this.symbol,
    this.coinGeckoId,
    required this.tier,
    this.claudeAnalysis,
    this.binancePosition,
    this.dexPosition,
    this.midProject,
    this.longHolding,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final ChartDataService _chartService = ChartDataService();
  PriceChartData? _chartData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // CoinGecko ID — koristimo što imamo
      final cgId = widget.coinGeckoId ??
          widget.symbol.toLowerCase();

      // Dohvati historiju
      final historical = await _chartService.fetchHistorical(
        coinGeckoId: cgId,
        tier: widget.tier,
      );

      if (historical.isEmpty) {
        setState(() {
          _error = 'Nema historijskih podataka za ${widget.symbol}';
          _isLoading = false;
        });
        return;
      }

      // Gradi trade evente iz pozicija
      final tradeEvents = <TradeEvent>[];
      if (widget.binancePosition != null) {
        tradeEvents.addAll(
          _chartService.buildTradeEventsFromPosition(
              widget.binancePosition!));
      }
      if (widget.dexPosition != null) {
        tradeEvents.addAll(
          _chartService.buildTradeEventsFromDex(widget.dexPosition!));
      }
      if (widget.longHolding != null) {
        tradeEvents.addAll(
          _chartService.buildTradeEventsFromHolding(widget.longHolding!));
      }

      // Generiraj predikciju iz Claude analize
      final currentPrice = historical.last.price;
      final prediction = widget.claudeAnalysis != null
          ? _chartService.parsePredictionFromClaude(
              claudeResponse: widget.claudeAnalysis!,
              currentPrice: currentPrice,
              tier: widget.tier,
            )
          : <PricePoint>[];

      setState(() {
        _chartData = PriceChartData(
          symbol: widget.symbol,
          tier: widget.tier,
          historical: historical,
          prediction: prediction,
          tradeEvents: tradeEvents,
          generatedAt: DateTime.now(),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Greška pri dohvatu podataka: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.tier.emoji} ${widget.symbol.toUpperCase()} Chart',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChartData,
            tooltip: 'Osvježi',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: widget.tier.color),
            const SizedBox(height: 16),
            Text(
              'Dohvaćam ${_periodLabel()} podataka...',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 64,
                  color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChartData,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chartData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier info banner
          _buildTierBanner(),
          const SizedBox(height: 16),

          // Glavni chart
          PriceChartWidget(
            data: _chartData!,
            tier: widget.tier,
            height: 300,
            showVolume: true,
            showEvents: true,
          ),
          const SizedBox(height: 24),

          // Stats sekcija
          _buildStats(),
          const SizedBox(height: 24),

          // Trade eventi detalji
          if (_chartData!.tradeEvents.isNotEmpty)
            _buildTradeEventsList(),

          // Claude predikcija note
          if (widget.claudeAnalysis != null)
            _buildPredictionNote(),
        ],
      ),
    );
  }

  Widget _buildTierBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.tier.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: widget.tier.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(widget.tier.emoji,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.tier.displayName} tier',
                  style: TextStyle(
                      color: widget.tier.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
                Text(
                  _periodLabel(),
                  style: TextStyle(
                      color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ),
          if (_chartData != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatPrice(_chartData!.currentPrice)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  '${_chartData!.isPredictionBullish ? "+" : ""}'
                  '${_chartData!.expectedReturnPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _chartData!.isPredictionBullish
                        ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (_chartData == null) return const SizedBox.shrink();
    final hist = _chartData!.historical;
    if (hist.isEmpty) return const SizedBox.shrink();

    final firstPrice = hist.first.price;
    final lastPrice = hist.last.price;
    final periodReturn = firstPrice > 0
        ? ((lastPrice - firstPrice) / firstPrice * 100) : 0.0;
    final maxPrice = hist.map((p) => p.price)
        .reduce((a, b) => a > b ? a : b);
    final minPrice = hist.map((p) => p.price)
        .reduce((a, b) => a < b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistika \u2014 ${_periodLabel()}',
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Period return',
                    '${periodReturn >= 0 ? "+" : ""}${periodReturn.toStringAsFixed(1)}%',
                    color: periodReturn >= 0 ? Colors.green : Colors.red),
                _stat('MAX', '\$${_formatPrice(maxPrice)}'),
                _stat('MIN', '\$${_formatPrice(minPrice)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) =>
      Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 10)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: color,
              )),
        ],
      );

  Widget _buildTradeEventsList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Tvoje transakcije',
          style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ..._chartData!.tradeEvents.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 40, height: 20,
              decoration: BoxDecoration(
                color: e.type.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(e.type.label,
                    style: TextStyle(
                        color: e.type.color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 8),
            Text('\$${_formatPrice(e.price)}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Text('\$${e.amountUsdt.toStringAsFixed(2)} USDT',
                style: TextStyle(
                    color: Colors.grey[400], fontSize: 11)),
            const Spacer(),
            Text(
              '${e.timestamp.day}.${e.timestamp.month}.'
              '${e.timestamp.year}',
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      )),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildPredictionNote() => Card(
    color: widget.tier.bgColor,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 14),
              const SizedBox(width: 6),
              Text('Claude predikcija',
                  style: TextStyle(
                      color: widget.tier.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Graf prikazuje predikciju baziranu na Claude analizi. '
            'Uncertainty band (sjena) pokazuje raspon '
            'mogućih scenarija. Predikcija je indikativna, '
            'ne financijski savjet.',
            style: TextStyle(
                color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    ),
  );

  String _periodLabel() {
    switch (widget.tier) {
      case InvestmentTier.short:
        return '10 dana historija + 24h predikcija';
      case InvestmentTier.mid:
        return '6 mj historija + 30d predikcija';
      case InvestmentTier.long:
        return '2 god historija + 6mj predikcija';
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(0);
    if (price >= 1) return price.toStringAsFixed(2);
    if (price >= 0.01) return price.toStringAsFixed(4);
    return price.toStringAsFixed(8);
  }
}

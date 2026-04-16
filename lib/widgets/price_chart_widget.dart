import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:coinsight/models/price_chart_data.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:intl/intl.dart';

/// Univerzalni price chart widget za sva tri tiera
///
/// SHORT:  tamna linija (historija) + ljubičasta isprekidana (predikcija 24h)
/// MID:    teal linija + teal predikcija s uncertainty bandom (30 dana)
/// LONG:   zlatna linija + zlatna predikcija s uncertainty bandom (6 mj)
///
/// Sve varijante prikazuju buy/sell evente kao coloured markere na grafu
class PriceChartWidget extends StatefulWidget {
  final PriceChartData data;
  final InvestmentTier tier;
  final double height;
  final bool showVolume;
  final bool showEvents;
  final bool interactive;

  const PriceChartWidget({
    super.key,
    required this.data,
    required this.tier,
    this.height = 250,
    this.showVolume = false,
    this.showEvents = true,
    this.interactive = true,
  });

  @override
  State<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  PricePoint? _touchedPoint;

  Color get _tierColor => widget.tier.color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — trenutna cijena i predikcija
        _buildHeader(),
        const SizedBox(height: 8),
        // Glavni chart
        SizedBox(
          height: widget.height,
          child: _buildLineChart(),
        ),
        // Touch info
        if (_touchedPoint != null) _buildTouchInfo(),
        // Legend
        const SizedBox(height: 8),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    final returnPct = widget.data.expectedReturnPercent;
    final isBullish = widget.data.isPredictionBullish;
    final tierLabel = widget.tier.emoji;

    return Row(
      children: [
        Text(
          '$tierLabel ${widget.data.symbol.toUpperCase()}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _tierColor,
          ),
        ),
        const Spacer(),
        // Predikcija badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (isBullish ? Colors.green : Colors.red)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isBullish ? Colors.green : Colors.red)
                  .withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isBullish ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: isBullish ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${isBullish ? "+" : ""}${returnPct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isBullish ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _predictionLabel(),
                style: TextStyle(
                    fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _predictionLabel() {
    switch (widget.tier) {
      case InvestmentTier.short: return '24h pred.';
      case InvestmentTier.mid:   return '30d pred.';
      case InvestmentTier.long:  return '6mj pred.';
    }
  }

  Widget _buildLineChart() {
    if (widget.data.historical.isEmpty) {
      return Center(
        child: Text('Nema podataka',
            style: TextStyle(color: Colors.grey[500])),
      );
    }

    return LineChart(
      LineChartData(
        minY: widget.data.minPrice,
        maxY: widget.data.maxPrice,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _gridInterval(),
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[850] ?? Colors.grey[800]!,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: _gridInterval(),
              getTitlesWidget: (value, meta) => Text(
                _formatPrice(value),
                style: TextStyle(
                    color: Colors.grey[600], fontSize: 9),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: _xInterval(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                final allPoints = [
                  ...widget.data.historical,
                  ...widget.data.prediction,
                ];
                if (idx < 0 || idx >= allPoints.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _formatDate(allPoints[idx].timestamp),
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 9),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: widget.interactive
            ? LineTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  setState(() {
                    if (response?.lineBarSpots?.isNotEmpty == true) {
                      final spot = response!.lineBarSpots!.first;
                      final touchedIndex = spot.spotIndex;
                      final allPoints = [
                        ...widget.data.historical,
                        ...widget.data.prediction,
                      ];
                      if (touchedIndex < allPoints.length) {
                        _touchedPoint = allPoints[touchedIndex];
                      }
                    } else {
                      _touchedPoint = null;
                    }
                  });
                },
                touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: _emptyTooltip),
              )
            : LineTouchData(enabled: false),
        lineBarsData: [
          // Historija — puna linija
          _buildHistoricalLine(),
          // Predikcija — isprekidana linija s uncertainty bandom
          if (widget.data.prediction.isNotEmpty)
            _buildPredictionLine(),
          // Uncertainty band (gornji)
          if (widget.data.prediction.isNotEmpty)
            _buildUncertaintyBand(upper: true),
          // Uncertainty band (donji)
          if (widget.data.prediction.isNotEmpty)
            _buildUncertaintyBand(upper: false),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // Support level
            if (widget.data.supportLevel != null)
              HorizontalLine(
                y: widget.data.supportLevel!,
                color: Colors.green.withValues(alpha: 0.5),
                strokeWidth: 1,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  labelResolver: (_) => 'Support',
                  style: const TextStyle(
                      color: Colors.green, fontSize: 9),
                ),
              ),
            // Resistance level
            if (widget.data.resistanceLevel != null)
              HorizontalLine(
                y: widget.data.resistanceLevel!,
                color: Colors.red.withValues(alpha: 0.5),
                strokeWidth: 1,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  labelResolver: (_) => 'Resistance',
                  style: const TextStyle(
                      color: Colors.red, fontSize: 9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildHistoricalLine() {
    final spots = widget.data.historical
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price))
        .toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: _tierColor,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _tierColor.withValues(alpha: 0.15),
            _tierColor.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildPredictionLine() {
    final offset = widget.data.historical.length.toDouble();
    final spots = widget.data.prediction
        .asMap()
        .entries
        .map((e) => FlSpot(
              offset + e.key.toDouble(),
              e.value.price,
            ))
        .toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: _tierColor.withValues(alpha: 0.7),
      barWidth: 1.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: [6, 4], // isprekidana linija = predikcija
      belowBarData: BarAreaData(show: false),
    );
  }

  LineChartBarData _buildUncertaintyBand({required bool upper}) {
    final offset = widget.data.historical.length.toDouble();
    final spots = widget.data.prediction
        .asMap()
        .entries
        .map((e) {
          final price = upper
              ? (e.value.priceMax ?? e.value.price)
              : (e.value.priceMin ?? e.value.price);
          return FlSpot(offset + e.key.toDouble(), price);
        })
        .toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: _tierColor.withValues(alpha: 0.15),
      barWidth: 0.5,
      dotData: const FlDotData(show: false),
      belowBarData: upper
          ? BarAreaData(
              show: true,
              color: _tierColor.withValues(alpha: 0.05),
            )
          : BarAreaData(show: false),
    );
  }

  Widget _buildTouchInfo() {
    if (_touchedPoint == null) return const SizedBox.shrink();
    final pt = _touchedPoint!;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(_formatDate(pt.timestamp),
              style: TextStyle(
                  color: Colors.grey[400], fontSize: 11)),
          Text('\$${_formatPrice(pt.price)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          if (pt.isPrediction)
            Text(
              'Predikcija \u00B1\$${_formatPrice(
                  (pt.priceMax ?? pt.price) - pt.price)}',
              style: TextStyle(
                  color: _tierColor, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(_tierColor, 'Historija'),
        const SizedBox(width: 16),
        _legendItem(
            _tierColor.withValues(alpha: 0.7), 'Predikcija',
            dashed: true),
        if (widget.data.tradeEvents.isNotEmpty) ...[
          const SizedBox(width: 16),
          _legendItem(Colors.green, 'Buy/DCA'),
        ],
        if (widget.data.supportLevel != null) ...[
          const SizedBox(width: 16),
          _legendItem(Colors.green.withValues(alpha: 0.5),
              'Support', dashed: true),
        ],
      ],
    );
  }

  Widget _legendItem(Color color, String label,
      {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20, height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: Colors.grey[500], fontSize: 10)),
      ],
    );
  }

  double _gridInterval() {
    final range = widget.data.maxPrice - widget.data.minPrice;
    if (range <= 0) return 1;
    return range / 5;
  }

  double _xInterval() {
    final total = widget.data.historical.length +
        widget.data.prediction.length;
    return (total / 4).ceil().toDouble();
  }

  String _formatPrice(double price) {
    if (price >= 1000) return NumberFormat.compact().format(price);
    if (price >= 1) return price.toStringAsFixed(2);
    if (price >= 0.01) return price.toStringAsFixed(4);
    return price.toStringAsFixed(8);
  }

  String _formatDate(DateTime dt) {
    switch (widget.tier) {
      case InvestmentTier.short:
        return DateFormat('dd.MM HH:mm').format(dt);
      case InvestmentTier.mid:
        return DateFormat('dd.MM').format(dt);
      case InvestmentTier.long:
        return DateFormat('MM.yy').format(dt);
    }
  }

  List<LineTooltipItem?> _emptyTooltip(List<LineBarSpot> spots) => [];
}

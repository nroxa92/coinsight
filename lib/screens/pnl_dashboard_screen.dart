import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:coinsight/models/pnl_analytics.dart';
import 'package:coinsight/models/closed_trade.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:intl/intl.dart';

class PnlDashboardScreen extends StatefulWidget {
  const PnlDashboardScreen({super.key});

  @override
  State<PnlDashboardScreen> createState() => _PnlDashboardScreenState();
}

class _PnlDashboardScreenState extends State<PnlDashboardScreen>
    with SingleTickerProviderStateMixin {
  late PnlAnalytics _analytics;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _analytics = PnlAnalyticsBuilder.build();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P&L Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _analytics = PnlAnalyticsBuilder.build();
            }),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'SHORT'),
            Tab(text: 'MID'),
            Tab(text: 'LONG'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTierTab(InvestmentTier.short),
          _buildTierTab(InvestmentTier.mid),
          _buildTierTab(InvestmentTier.long),
        ],
      ),
    );
  }

  // --- OVERVIEW TAB ---

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: () async =>
          setState(() => _analytics = PnlAnalyticsBuilder.build()),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildEquityCurveCard(),
            const SizedBox(height: 16),
            _buildTierBreakdownCard(),
            const SizedBox(height: 16),
            _buildOpenPositionsSummary(),
            const SizedBox(height: 16),
            _buildRecentTradesCard(null), // sve
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final pnl = _analytics.totalRealizedPnl;
    final pnlColor = pnl >= 0 ? Colors.green : const Color(0xFFEF5350);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Ukupni P&L',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: pnlColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 3x3 grid metrike
            Row(
              children: [
                Expanded(child: _metric('Tradova', '${_analytics.totalTrades}')),
                Expanded(child: _metric('Win rate',
                    '${_analytics.winRate.toStringAsFixed(1)}%',
                    color: _analytics.winRate >= 50 ? Colors.green : Colors.orange)),
                Expanded(child: _metric('Avg return',
                    '${_analytics.avgReturnPercent >= 0 ? "+" : ""}'
                    '${_analytics.avgReturnPercent.toStringAsFixed(1)}%',
                    color: _analytics.avgReturnPercent >= 0
                        ? Colors.green : const Color(0xFFEF5350))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metric('Pobjede', '${_analytics.winCount}',
                    color: Colors.green)),
                Expanded(child: _metric('Porazi', '${_analytics.lossCount}',
                    color: const Color(0xFFEF5350))),
                Expanded(child: _metric('R/R ratio',
                    _analytics.riskRewardRatio > 0
                        ? _analytics.riskRewardRatio.toStringAsFixed(2)
                        : 'N/A')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metric('Avg win',
                    '+${_analytics.avgWinPercent.toStringAsFixed(1)}%',
                    color: Colors.green)),
                Expanded(child: _metric('Avg loss',
                    '${_analytics.avgLossPercent.toStringAsFixed(1)}%',
                    color: const Color(0xFFEF5350))),
                Expanded(child: _metric('Avg hold',
                    _analytics.avgHoldHours < 24
                        ? '${_analytics.avgHoldHours.toStringAsFixed(0)}h'
                        : '${(_analytics.avgHoldHours / 24).toStringAsFixed(0)}d')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, {Color? color}) => Column(
    children: [
      Text(label,
          style: TextStyle(
              color: Colors.grey[500], fontSize: 10)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          )),
    ],
  );

  Widget _buildEquityCurveCard() {
    final curve = _analytics.equityCurve;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Equity Curve',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (curve.isEmpty)
              SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Nema zatvorenih pozicija.\nZatvori prve tradove za equity curve.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: Colors.grey[850] ?? Colors.grey[800]!,
                        strokeWidth: 0.5,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (v, _) => Text(
                            '\$${v.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 9),
                          ),
                        ),
                      ),
                      bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: curve.asMap().entries.map((e) =>
                            FlSpot(e.key.toDouble(),
                                e.value.cumulativePnl)).toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: curve.last.cumulativePnl >= 0
                            ? Colors.green : const Color(0xFFEF5350),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (curve.last.cumulativePnl >= 0
                                  ? Colors.green
                                  : const Color(0xFFEF5350))
                                  .withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 0,
                          color: Colors.grey[600]!,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierBreakdownCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('P&L po tieru',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...InvestmentTier.values.map((tier) {
              final pnl = _analytics.pnlByTier(tier);
              final trades = _analytics.tradesByTier(tier).length;
              final wr = _analytics.winRateByTier(tier);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('${tier.emoji} ${tier.displayName}',
                        style: TextStyle(
                            color: tier.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    const SizedBox(width: 8),
                    Text('$trades tradova',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 11)),
                    const Spacer(),
                    if (trades > 0)
                      Text(
                        'WR: ${wr.toStringAsFixed(0)}%',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 11),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: pnl >= 0 ? Colors.green
                            : const Color(0xFFEF5350),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenPositionsSummary() {
    final unrealPnl = _analytics.totalUnrealizedPnl;
    final midInvested = _analytics.totalMidInvested;
    final longInvested = _analytics.totalLongInvested;

    if (_analytics.openBinancePositions.isEmpty &&
        _analytics.openDexPositions.isEmpty &&
        midInvested == 0 &&
        longInvested == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Otvorene pozicije (unrealized)',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (_analytics.openBinancePositions.isNotEmpty ||
                _analytics.openDexPositions.isNotEmpty)
              _row('SHORT P&L',
                  '${unrealPnl >= 0 ? "+" : ""}\$${unrealPnl.toStringAsFixed(2)}',
                  color: unrealPnl >= 0 ? Colors.green : const Color(0xFFEF5350)),
            if (midInvested > 0)
              _row('MID uloženo',
                  '\$${midInvested.toStringAsFixed(2)}',
                  color: InvestmentTier.mid.color),
            if (longInvested > 0)
              _row('LONG uloženo',
                  '\$${longInvested.toStringAsFixed(2)}',
                  color: InvestmentTier.long.color),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTradesCard(InvestmentTier? tier) {
    final trades = tier != null
        ? _analytics.tradesByTier(tier)
        : _analytics.closedTrades;

    if (trades.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 40, color: Colors.grey[700]),
                const SizedBox(height: 8),
                Text(
                  'Nema zatvorenih tradova.',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tradovi se automatski bilježe\nkad zatvoriš SHORT poziciju.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[700], fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tier != null ? 'Tradovi — ${tier.displayName}' : 'Zadnji tradovi',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...trades.take(20).map(_buildTradeRow),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeRow(ClosedTrade trade) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Tier badge
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trade.tier.bgColor,
            ),
            child: Center(
              child: Text(trade.tier.emoji,
                  style: const TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trade.symbol,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12)),
                Text(
                  '${trade.holdHours < 24 ? "${trade.holdHours}h" : "${trade.holdDays}d"} | '
                  '${DateFormat("dd.MM.yy").format(trade.closedAt)}',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ),
          // Result badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: trade.result.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trade.result.label,
              style: TextStyle(
                  fontSize: 9,
                  color: trade.result.color,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${trade.pnlAbsolute >= 0 ? "+" : ""}\$${trade.pnlAbsolute.toStringAsFixed(2)}',
            style: TextStyle(
              color: trade.pnlAbsolute >= 0 ? Colors.green
                  : const Color(0xFFEF5350),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // --- TIER TAB ---

  Widget _buildTierTab(InvestmentTier tier) {
    final trades = _analytics.tradesByTier(tier);
    final pnl = _analytics.pnlByTier(tier);
    final wr = _analytics.winRateByTier(tier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tier summary
          Card(
            color: tier.bgColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('${tier.emoji} ${tier.displayName}',
                          style: TextStyle(
                              color: tier.color,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(
                        '${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: pnl >= 0 ? Colors.green
                              : const Color(0xFFEF5350),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metric('Tradova', '${trades.length}'),
                      _metric('Win rate',
                          '${wr.toStringAsFixed(1)}%',
                          color: wr >= 50 ? Colors.green : Colors.orange),
                      _metric('Avg return',
                          '${_avgReturnForTier(tier) >= 0 ? "+" : ""}'
                          '${_avgReturnForTier(tier).toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentTradesCard(tier),
        ],
      ),
    );
  }

  double _avgReturnForTier(InvestmentTier tier) {
    final trades = _analytics.tradesByTier(tier);
    if (trades.isEmpty) return 0;
    return trades.map((t) => t.pnlPercent)
        .fold(0.0, (sum, p) => sum + p) / trades.length;
  }

  Widget _row(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color,
            )),
      ],
    ),
  );
}

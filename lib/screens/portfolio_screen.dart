import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:coinsight/models/portfolio_provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/models/intelligence_report.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/tier_provider.dart';
import 'package:coinsight/models/mid_term_project.dart';
import 'package:coinsight/models/long_term_holding.dart';
import 'package:coinsight/models/dex_position.dart';
import 'package:coinsight/models/closed_trade.dart';
import 'package:coinsight/models/pnl_analytics.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/screens/dex_position_screen.dart';
import 'package:coinsight/screens/mid_project_detail_screen.dart';
import 'package:coinsight/screens/long_holding_detail_screen.dart';
import 'package:coinsight/screens/chart_screen.dart';
import 'package:coinsight/widgets/wallet_connect_button.dart';
import 'package:coinsight/screens/pnl_dashboard_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  PortfolioProvider? _providerRef;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<PortfolioProvider>();
      _providerRef = p;
      if (!p.hasCredentials) return;
      p.refresh();
      p.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _providerRef?.stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<TierProvider>(
      builder: (context, tierProvider, _) {
        switch (tierProvider.activeTier) {
          case InvestmentTier.short:
            return _buildShortPortfolio();
          case InvestmentTier.mid:
            return _buildMidPortfolio();
          case InvestmentTier.long:
            return _buildLongPortfolio();
        }
      },
    );
  }

  // ═══════════════════════════════════════════
  // SHORT tier portfolio — existing layout
  // ═══════════════════════════════════════════
  Widget _buildShortPortfolio() {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, _) {
        if (!provider.hasCredentials) {
          return _buildNoCredentialsState();
        }
        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDashboardBanner(),
              _buildHeader(provider),
              const SizedBox(height: 16),
              _buildIntelligenceSection(),
              const SizedBox(height: 16),
              _buildDexPositionsSection(),
              const SizedBox(height: 16),
              _buildPositionsSection(provider),
              const SizedBox(height: 16),
              _buildHistorySection(),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // MID tier portfolio
  // ═══════════════════════════════════════════
  Widget _buildMidPortfolio() {
    final projects = StorageService.getMidProjects();
    final active = projects.where(
        (p) => p.status == MidTermStatus.entered ||
               p.status == MidTermStatus.watching).toList();
    final researching = projects.where(
        (p) => p.status == MidTermStatus.researching).toList();

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDashboardBanner(),
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.science_outlined, size: 20,
                              color: Color(0xFF03DAC6)),
                          SizedBox(width: 8),
                          Text('MID Portfolio',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _row('Ukupno projekata', '${projects.length}'),
                      _row('Aktivni (entered/watching)', '${active.length}'),
                      _row('U istra\u017Eivanju', '${researching.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (projects.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 40, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text('Nema MID projekata',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...projects.map(_buildMidPortfolioCard),
              const SizedBox(height: 80), // space for FAB
            ],
          ),
        ),
        Positioned(
          bottom: 16, right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF03DAC6),
            foregroundColor: Colors.black,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MidProjectDetailScreen(),
                ),
              );
              setState(() {});
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildMidPortfolioCard(MidTermProject project) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MidProjectDetailScreen(project: project),
          ),
        );
        setState(() {}); // Refresh portfolio
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(project.symbol.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: project.status.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(project.status.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: project.status.color)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.show_chart,
                        color: InvestmentTier.mid.color, size: 18),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChartScreen(
                          symbol: project.symbol,
                          coinGeckoId: project.coinGeckoId.isEmpty
                              ? null : project.coinGeckoId,
                          tier: InvestmentTier.mid,
                          midProject: project,
                        ),
                      ),
                    ),
                    tooltip: 'Prikaži chart',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text('${project.daysWatching}d',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                ],
              ),
              if (project.thesis.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  project.thesis.length > 100
                      ? '${project.thesis.substring(0, 100)}...'
                      : project.thesis,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (project.potentialReturnPercent != 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Potencijalni return: +${project.potentialReturnPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // LONG tier portfolio
  // ═══════════════════════════════════════════
  Widget _buildLongPortfolio() {
    final holdings = StorageService.getLongHoldings();
    final totalInvested = holdings.fold<double>(
        0, (sum, h) => sum + h.totalInvested);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDashboardBanner(),
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_outlined, size: 20,
                              color: Color(0xFFFFD700)),
                          SizedBox(width: 8),
                          Text('LONG Portfolio',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _row('Ukupno holdinga', '${holdings.length}'),
                      _row('Ukupno investirano',
                          '\$${totalInvested.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (holdings.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 40, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text('Nema LONG holdinga',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...holdings.map(_buildLongPortfolioCard),
              const SizedBox(height: 80), // space for FAB
            ],
          ),
        ),
        Positioned(
          bottom: 16, right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LongHoldingDetailScreen(),
                ),
              );
              setState(() {});
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildLongPortfolioCard(LongTermHolding holding) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LongHoldingDetailScreen(holding: holding),
          ),
        );
        setState(() {}); // Refresh portfolio
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(holding.symbol.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: holding.status.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(holding.status.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: holding.status.color)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.show_chart,
                        color: InvestmentTier.long.color, size: 18),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChartScreen(
                          symbol: holding.symbol,
                          coinGeckoId: holding.coinGeckoId.isEmpty
                              ? null : holding.coinGeckoId,
                          tier: InvestmentTier.long,
                          longHolding: holding,
                        ),
                      ),
                    ),
                    tooltip: 'Prikaži chart',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  if (holding.claudeConfidenceScore != null)
                    Text('${holding.claudeConfidenceScore}/10',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12)),
                ],
              ),
              if (holding.purchases.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'DCA: ${holding.purchases.length} kupnja | '
                  'Avg: \$${holding.averageEntryPrice.toStringAsFixed(holding.averageEntryPrice >= 1 ? 2 : 6)} | '
                  'Invested: \$${holding.totalInvested.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
              if (holding.potentialReturnMinPercent != 0 ||
                  holding.potentialReturnMaxPercent != 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Potencijalni return: +${holding.potentialReturnMinPercent.toStringAsFixed(0)}% ~ +${holding.potentialReturnMaxPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Shared widgets (used by SHORT tier)
  // ═══════════════════════════════════════════
  Widget _buildNoCredentialsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'Binance nije konfiguriran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Dodaj Binance API klju\u010Deve u Settings da zapo\u010Dne\u0161 trading.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PortfolioProvider p) {
    final pnlColor = p.totalPnl >= 0 ? Colors.green : const Color(0xFFEF5350);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 20),
                const SizedBox(width: 8),
                const Text('Portfolio',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: p.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20),
                  onPressed: p.isLoading ? null : p.refresh,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row('USDT Balance',
                '\$${p.usdtBalance.toStringAsFixed(2)}'),
            _row('Open Positions', '${p.positions.length}'),
            _row(
              'Total P&L',
              '${p.totalPnl >= 0 ? '+' : ''}\$${p.totalPnl.toStringAsFixed(2)} (${p.totalPnlPercent.toStringAsFixed(2)}%)',
              valueColor: p.positions.isEmpty ? null : pnlColor,
            ),
            if (p.error != null) ...[
              const SizedBox(height: 8),
              Text(p.error!,
                  style: const TextStyle(color: Color(0xFFEF5350), fontSize: 12)),
            ],
            const SizedBox(height: 8),
            const WalletConnectButton(),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }

  Widget _buildPositionsSection(PortfolioProvider p) {
    if (p.positions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text('No open positions',
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children:
          p.positions.map((pos) => _buildPositionCard(p, pos)).toList(),
    );
  }

  Widget _buildPositionCard(PortfolioProvider provider, CoinPosition pos) {
    final riskParams = StorageService.getRiskParameters();
    final sl =
        pos.entryPrice * (1 - riskParams.stopLossPercent / 100);
    final tp =
        pos.entryPrice * (1 + riskParams.takeProfitPercent / 100);
    final pnlColor =
        pos.isProfit ? Colors.green : const Color(0xFFEF5350);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${pos.symbol}/USDT',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.show_chart, color: InvestmentTier.short.color, size: 20),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChartScreen(
                        symbol: pos.symbol,
                        coinGeckoId: pos.coinId,
                        tier: InvestmentTier.short,
                        binancePosition: pos,
                      ),
                    ),
                  ),
                  tooltip: 'Prikaži chart',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                TextButton(
                  onPressed: () => _confirmClose(provider, pos),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF5350),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
            Text(
              'Entry: \$${pos.entryPrice.toStringAsFixed(6)} \u2192 Now: \$${(pos.currentPrice ?? pos.entryPrice).toStringAsFixed(6)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              'Qty: ${pos.quantity.toStringAsFixed(4)} | Invested: \$${pos.entryTotal.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'P&L: ${pos.pnlAbsolute >= 0 ? '+' : ''}\$${pos.pnlAbsolute.toStringAsFixed(2)} (${pos.pnlPercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                color: pnlColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SL: \$${sl.toStringAsFixed(6)} | TP: \$${tp.toStringAsFixed(6)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClose(PortfolioProvider provider, CoinPosition pos) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Zatvori poziciju?'),
        content: Text(
          'Prodaje\u0161 ${pos.quantity.toStringAsFixed(6)} ${pos.symbol} po tr\u017Ei\u0161noj cijeni.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await provider.closePosition(pos);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(ok
                        ? 'Position closed'
                        : provider.error ?? 'Failed to close')),
              );
            },
            child: const Text('Confirm',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligenceSection() {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, _) {
        final report = provider.lastReport;
        final isGathering = provider.isGatheringIntelligence;

        if (isGathering) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text('Prikupljam intelligence...',
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            ),
          );
        }

        if (report == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.radar, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text('Intelligence Radar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[400],
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tapni "Analiziraj" na DEX Early ili New Listings coinu za puni cross-channel report.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(IntelligenceReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar, size: 18, color: report.scoreColor),
                const SizedBox(width: 8),
                Text('Intelligence: ${report.symbol}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: report.scoreColor,
                    )),
                const Spacer(),
                Text(
                  '${report.confluenceScore.toStringAsFixed(1)}/6.0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: report.scoreColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: report.confluenceScore / 6.0,
                backgroundColor: Colors.grey[800],
                valueColor:
                    AlwaysStoppedAnimation(report.scoreColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _sourceIndicator(
                    'DEX', report.dexScore, Colors.purple),
                _sourceIndicator(
                    'GH', report.githubScore, Colors.yellow),
                _sourceIndicator(
                    'Reddit', report.redditScore, Colors.orange),
                _sourceIndicator(
                    'TG', report.telegramScore, Colors.blue),
                _sourceIndicator(
                    'MCap', report.marketScore, Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Text('Hint: ${report.scoringHint}',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _sourceIndicator(
      String label, double score, Color color) {
    final isActive = score > 0;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? color.withValues(alpha: 0.2)
                : Colors.grey[800],
            border: Border.all(
                color: isActive ? color : Colors.grey[700]!),
          ),
          child: Center(
            child: Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? color : Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style:
                TextStyle(fontSize: 9, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildDexPositionsSection() {
    final positions = StorageService.getDexPositions()
        .where((p) => p.status == DexPositionStatus.open)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz, size: 18, color: Colors.purple),
                const SizedBox(width: 8),
                const Text('DEX Positions',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                          builder: (_) => const DexPositionScreen()),
                    );
                    if (result == true && mounted) setState(() {});
                  },
                  tooltip: 'Nova DEX pozicija',
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (positions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('Nema otvorenih DEX pozicija',
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 13)),
                ),
              )
            else
              ...positions.map(_buildDexPositionCard),
          ],
        ),
      ),
    );
  }

  Widget _buildDexPositionCard(DexPosition pos) {
    final pnlColor = pos.isProfit ? Colors.green : const Color(0xFFEF5350);
    final chainColors = {
      'ethereum': Colors.blue,
      'bsc': Colors.yellow,
      'solana': Colors.purple,
      'polygon': Colors.deepPurple,
      'arbitrum': Colors.blueGrey,
      'base': Colors.lightBlue,
    };
    final chainColor = chainColors[pos.chainId] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: chainColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    pos.chainId.toUpperCase(),
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: chainColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(pos.tokenSymbol,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                if (pos.dexName.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(pos.dexName,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.show_chart, color: InvestmentTier.short.color, size: 16),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChartScreen(
                        symbol: pos.tokenSymbol,
                        tier: InvestmentTier.short,
                        dexPosition: pos,
                      ),
                    ),
                  ),
                  tooltip: 'Prikaži chart',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 16, color: Color(0xFFEF5350)),
                  onPressed: () => _confirmCloseDexPosition(pos),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Entry: \$${pos.entryPrice.toStringAsFixed(8)} \u2192 Now: \$${(pos.currentPrice ?? pos.entryPrice).toStringAsFixed(8)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              'Qty: ${pos.quantity.toStringAsFixed(4)} | Invested: \$${pos.entryAmountUsdt.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'P&L: ${pos.pnlAbsolute >= 0 ? '+' : ''}\$${pos.pnlAbsolute.toStringAsFixed(2)} (${pos.pnlPercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: pnlColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (pos.stopLossPrice != null)
                  Text('SL: \$${pos.stopLossPrice!.toStringAsFixed(6)}',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 10)),
                if (pos.takeProfitPrice != null) ...[
                  const SizedBox(width: 8),
                  Text('TP: \$${pos.takeProfitPrice!.toStringAsFixed(6)}',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeDexPosition(DexPosition pos, {
    required double exitPrice,
    required DexPositionStatus closeReason,
  }) async {
    // Odredi result
    final pnl = (exitPrice * pos.quantity) - pos.entryAmountUsdt;
    ClosedTradeResult result;
    if (pnl > 0.01) {
      result = ClosedTradeResult.profit;
    } else if (pnl < -0.01) {
      result = ClosedTradeResult.loss;
    } else {
      result = ClosedTradeResult.breakeven;
    }

    // Spremi u closed_trades
    final closed = ClosedTrade.fromDexPosition(
      pos, exitPrice, result);
    await StorageService.saveClosedTrade(closed);

    // Azuriraj DEX poziciju na closed status
    final updated = pos.copyWith(
      currentPrice: exitPrice,
      status: closeReason,
    );
    await StorageService.saveDexPosition(updated);

    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${pos.tokenSymbol} zatvoren | '
          '${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)} USDT',
        ),
        backgroundColor: pnl >= 0 ? Colors.green : const Color(0xFFEF5350),
      ),
    );
  }

  Future<void> _confirmCloseDexPosition(DexPosition pos) async {
    final exitPriceController = TextEditingController(
      text: (pos.currentPrice ?? pos.entryPrice).toStringAsFixed(8),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: Text('Zatvori ${pos.tokenSymbol}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entry: \$${pos.entryPrice.toStringAsFixed(8)}\n'
              'P&L: ${pos.pnlAbsolute >= 0 ? "+" : ""}'
              '\$${pos.pnlAbsolute.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: exitPriceController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: const InputDecoration(
                labelText: 'Izlazna cijena (\$)',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final exitPrice = double.tryParse(exitPriceController.text) ??
        (pos.currentPrice ?? pos.entryPrice);

    await _closeDexPosition(
      pos,
      exitPrice: exitPrice,
      closeReason: DexPositionStatus.closedManual,
    );
  }

  Widget _buildHistorySection() {
    final logs = StorageService.getAnalysisLogs().take(20).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Analysis History',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('No analysis yet',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 13)),
                ),
              )
            else
              ...logs.map(_buildLogRow),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBanner() => GestureDetector(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const PnlDashboardScreen()),
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.15),
            const Color(0xFF03DAC6).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, size: 18),
          const SizedBox(width: 10),
          const Text('P&L Dashboard',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          Builder(
            builder: (_) {
              final analytics = PnlAnalyticsBuilder.build();
              final pnl = analytics.totalRealizedPnl;
              return Text(
                '${pnl >= 0 ? "+" : ""}\$${pnl.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              );
            },
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    ),
  );

  Widget _buildLogRow(AnalysisLog log) {
    final chipColor = switch (log.recommendationType) {
      'INTERESTING' => Colors.green,
      'ENTERED' => Colors.blue,
      'EXITED' => Colors.purple,
      'WATCH' => Colors.orange,
      'SKIP' => Colors.grey,
      _ => Colors.grey,
    };
    final time = DateFormat('dd.MM. HH:mm').format(log.timestamp);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              log.recommendationType,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: chipColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${log.coinSymbol} | \$${log.priceAtAnalysis.toStringAsFixed(log.priceAtAnalysis >= 1 ? 2 : 6)}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(time,
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }
}

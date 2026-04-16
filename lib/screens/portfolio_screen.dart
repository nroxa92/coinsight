import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:coinsight/models/portfolio_provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/models/intelligence_report.dart';
import 'package:coinsight/services/storage_service.dart';

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
              _buildHeader(provider),
              const SizedBox(height: 16),
              _buildIntelligenceSection(),
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
              'Dodaj Binance API ključeve u Settings da započneš trading.',
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
              'Entry: \$${pos.entryPrice.toStringAsFixed(6)} → Now: \$${(pos.currentPrice ?? pos.entryPrice).toStringAsFixed(6)}',
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
          'Prodaješ ${pos.quantity.toStringAsFixed(6)} ${pos.symbol} po tržišnoj cijeni.',
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

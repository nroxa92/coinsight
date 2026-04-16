import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/tier_provider.dart';
import 'package:coinsight/models/mid_term_project.dart';
import 'package:coinsight/models/long_term_holding.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/widgets/coin_card.dart';
import 'package:coinsight/widgets/dex_signal_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with TickerProviderStateMixin {
  late TabController _shortTabController;
  late TabController _midTabController;
  late TabController _longTabController;

  @override
  void initState() {
    super.initState();
    _shortTabController = TabController(length: 4, vsync: this);
    _midTabController = TabController(length: 3, vsync: this);
    _longTabController = TabController(length: 3, vsync: this);
    _shortTabController.addListener(_onShortTabChanged);
    final provider = context.read<WatchlistProvider>();
    Future.microtask(() {
      provider.fetchDexListings();
      provider.fetchNewListings();
      provider.fetchTopCoins();
    });
  }

  void _onShortTabChanged() {
    final provider = context.read<WatchlistProvider>();
    if (_shortTabController.index == 0) {
      provider.startDexAutoRefresh();
      provider.stopNewListingsAutoRefresh();
    } else if (_shortTabController.index == 1) {
      provider.startNewListingsAutoRefresh();
      provider.stopDexAutoRefresh();
    } else {
      provider.stopDexAutoRefresh();
      provider.stopNewListingsAutoRefresh();
    }
  }

  @override
  void dispose() {
    _shortTabController.removeListener(_onShortTabChanged);
    _shortTabController.dispose();
    _midTabController.dispose();
    _longTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TierProvider>(
      builder: (context, tierProvider, _) {
        switch (tierProvider.activeTier) {
          case InvestmentTier.short:
            return _buildShortLayout();
          case InvestmentTier.mid:
            return _buildMidLayout();
          case InvestmentTier.long:
            return _buildLongLayout();
        }
      },
    );
  }

  // ═══════════════════════════════════════════
  // SHORT tier layout — existing 4-tab layout
  // ═══════════════════════════════════════════
  Widget _buildShortLayout() {
    return Column(
      children: [
        TabBar(
          controller: _shortTabController,
          tabs: const [
            Tab(text: 'DEX Early'),
            Tab(text: 'New Listings'),
            Tab(text: 'My Watchlist'),
            Tab(text: 'Top Coins'),
          ],
          isScrollable: true,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
        ),
        Expanded(
          child: TabBarView(
            controller: _shortTabController,
            children: [
              _buildDexTab(),
              _buildNewListingsTab(),
              _buildWatchlistTab(),
              _buildTopCoinsTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // MID tier layout — 3 tabs
  // ═══════════════════════════════════════════
  Widget _buildMidLayout() {
    return Column(
      children: [
        TabBar(
          controller: _midTabController,
          tabs: const [
            Tab(text: 'Projekti'),
            Tab(text: 'Discovery'),
            Tab(text: 'Watchlist'),
          ],
          indicatorColor: const Color(0xFF03DAC6),
          labelColor: const Color(0xFF03DAC6),
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
        ),
        Expanded(
          child: TabBarView(
            controller: _midTabController,
            children: [
              _buildMidProjectsTab(),
              _buildMidDiscoveryTab(),
              _buildWatchlistTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // LONG tier layout — 3 tabs
  // ═══════════════════════════════════════════
  Widget _buildLongLayout() {
    return Column(
      children: [
        TabBar(
          controller: _longTabController,
          tabs: const [
            Tab(text: 'Holdings'),
            Tab(text: 'Research'),
            Tab(text: 'Watchlist'),
          ],
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
        ),
        Expanded(
          child: TabBarView(
            controller: _longTabController,
            children: [
              _buildLongHoldingsTab(),
              _buildLongResearchTab(),
              _buildWatchlistTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // MID — Projekti Tab
  // ═══════════════════════════════════════════
  Widget _buildMidProjectsTab() {
    final projects = StorageService.getMidProjects();
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text('Nema MID projekata',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Koristi Analysis chat za otkrivanje projekata.\nClaude \u0107e predlo\u017Eiti dodavanje.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final p = projects[index];
          return _buildMidProjectCard(p);
        },
      ),
    );
  }

  Widget _buildMidProjectCard(MidTermProject project) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(project.symbol.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                if (project.name != project.symbol)
                  Expanded(
                    child: Text(project.name,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  )
                else
                  const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: project.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    project.status.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: project.status.color),
                  ),
                ),
              ],
            ),
            if (project.thesis.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project.thesis.length > 120
                    ? '${project.thesis.substring(0, 120)}...'
                    : project.thesis,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${project.daysWatching}d',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12)),
                if (project.potentialReturnPercent != 0) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.trending_up, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '+${project.potentialReturnPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.green, fontSize: 12),
                  ),
                ],
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF03DAC6),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 32),
                  ),
                  onPressed: () {
                    // Navigate to analysis with this project context
                    context.read<AnalysisProvider>().gatherIntelligenceForCoin(
                      project.symbol,
                    );
                  },
                  child: const Text('Otvori',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // MID — Discovery Tab (GitHub-based)
  // ═══════════════════════════════════════════
  Widget _buildMidDiscoveryTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text('GitHub Discovery',
              style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Otkrivanje novih projekata na temelju\nGitHub aktivnosti i trendova.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          Text(
            'Konfiguriraj GitHub token u Settings\nza pristup Discovery feedu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // LONG — Holdings Tab
  // ═══════════════════════════════════════════
  Widget _buildLongHoldingsTab() {
    final holdings = StorageService.getLongHoldings();
    if (holdings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_outlined,
                size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text('Nema LONG holdings',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Koristi Analysis chat za duboku analizu.\nClaude \u0107e predlo\u017Eiti STRONG_HOLD projekte.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: holdings.length,
        itemBuilder: (context, index) {
          final h = holdings[index];
          return _buildLongHoldingCard(h);
        },
      ),
    );
  }

  Widget _buildLongHoldingCard(LongTermHolding holding) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(holding.symbol.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                if (holding.name != holding.symbol)
                  Expanded(
                    child: Text(holding.name,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  )
                else
                  const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: holding.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    holding.status.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: holding.status.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (holding.purchases.isNotEmpty) ...[
              Row(
                children: [
                  Text('Avg entry: ',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                  Text(
                    '\$${holding.averageEntryPrice.toStringAsFixed(holding.averageEntryPrice >= 1 ? 2 : 6)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  Text('Invested: ',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                  Text(
                    '\$${holding.totalInvested.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (holding.potentialReturnMinPercent != 0 ||
                holding.potentialReturnMaxPercent != 0)
              Row(
                children: [
                  Icon(Icons.trending_up, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '+${holding.potentialReturnMinPercent.toStringAsFixed(0)}% ~ +${holding.potentialReturnMaxPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            if (holding.claudeConfidenceScore != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.psychology, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Confidence: ${holding.claudeConfidenceScore}/10',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${holding.daysResearching}d istra\u017Eivanja',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12)),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD700),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 32),
                  ),
                  onPressed: () {
                    context.read<AnalysisProvider>().gatherIntelligenceForCoin(
                      holding.symbol,
                    );
                  },
                  child: const Text('Otvori',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // LONG — Research Tab
  // ═══════════════════════════════════════════
  Widget _buildLongResearchTab() {
    // Shows top coins for deep analysis research
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.topCoins.isEmpty) {
          return _buildSkeletonList();
        }
        final established = provider.topCoins
            .where((c) => c.marketCapRank <= 100)
            .toList();
        if (established.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text('Research candidates',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                const SizedBox(height: 8),
                Text('Top 100 coinova za duboku LONG analizu.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: provider.fetchTopCoins,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: established.length,
            itemBuilder: (context, index) {
              final coin = established[index];
              return CoinCard(
                coin: coin,
                isWatchlisted: provider.isInWatchlist(coin.id),
                onToggleWatchlist: () => provider.toggleWatchlist(coin.id),
              );
            },
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // Shared helpers
  // ═══════════════════════════════════════════
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: 8,
      itemBuilder: (context, index) => const CoinCardSkeleton(),
    );
  }

  // ───────── DEX Early Tab ─────────
  Widget _buildDexTab() {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        if (provider.isDexLoading && provider.dexListings.isEmpty) {
          return _buildSkeletonList();
        }

        if (provider.dexListings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'Skeniranje DEX marketa...',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pratimo Uniswap, PancakeSwap, Raydium i ostale',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchDexListings,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: provider.dexListings.length,
            itemBuilder: (context, index) {
              final signal = provider.dexListings[index];
              return DexSignalCard(
                signal: signal,
                onAnalyze: () {
                  context.read<AnalysisProvider>().gatherIntelligenceForCoin(
                        signal.baseTokenSymbol,
                      );
                },
              );
            },
          ),
        );
      },
    );
  }

  // ───────── New Listings Tab ─────────
  Widget _buildNewListingsTab() {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.newListings.isEmpty) {
          return _buildSkeletonList();
        }

        if (provider.error != null && provider.newListings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchNewListings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.newListings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.new_releases_outlined,
                    size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No new listings found',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh or check back later',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchNewListings,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: provider.newListings.length,
            itemBuilder: (context, index) {
              final coin = provider.newListings[index];
              return CoinCard(
                coin: coin,
                isWatchlisted: provider.isInWatchlist(coin.id),
                onToggleWatchlist: () => provider.toggleWatchlist(coin.id),
                show1hChange: true,
              );
            },
          ),
        );
      },
    );
  }

  // ───────── Watchlist Tab (shared across tiers) ─────────
  Widget _buildWatchlistTab() {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.watchlistCoins.isEmpty) {
          return _buildSkeletonList();
        }

        if (provider.watchlistCoins.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No coins in watchlist',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Star coins from other tabs to add them',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refreshWatchlist,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: provider.watchlistCoins.length,
            itemBuilder: (context, index) {
              final coin = provider.watchlistCoins[index];
              return CoinCard(
                coin: coin,
                isWatchlisted: true,
                onToggleWatchlist: () => provider.toggleWatchlist(coin.id),
              );
            },
          ),
        );
      },
    );
  }

  // ───────── Top Coins Tab ─────────
  Widget _buildTopCoinsTab() {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.topCoins.isEmpty) {
          return _buildSkeletonList();
        }

        if (provider.error != null && provider.topCoins.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchTopCoins,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchTopCoins,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: provider.topCoins.length,
            itemBuilder: (context, index) {
              final coin = provider.topCoins[index];
              return CoinCard(
                coin: coin,
                isWatchlisted: provider.isInWatchlist(coin.id),
                onToggleWatchlist: () => provider.toggleWatchlist(coin.id),
              );
            },
          ),
        );
      },
    );
  }
}

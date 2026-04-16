import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/widgets/coin_card.dart';
import 'package:coinsight/widgets/dex_signal_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    final provider = context.read<WatchlistProvider>();
    Future.microtask(() {
      provider.fetchDexListings();
      provider.fetchNewListings();
      provider.fetchTopCoins();
      // DEX auto-refresh starts via _onTabChanged when tab 0 is active
    });
  }

  void _onTabChanged() {
    final provider = context.read<WatchlistProvider>();
    if (_tabController.index == 0) {
      provider.startDexAutoRefresh();
      provider.stopNewListingsAutoRefresh();
    } else if (_tabController.index == 1) {
      provider.startNewListingsAutoRefresh();
      provider.stopDexAutoRefresh();
    } else {
      provider.stopDexAutoRefresh();
      provider.stopNewListingsAutoRefresh();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
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
            controller: _tabController,
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

  // ───────── Watchlist Tab ─────────
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

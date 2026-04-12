import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/widgets/coin_card.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    final provider = context.read<WatchlistProvider>();
    Future.microtask(() => provider.fetchTopCoins());
  }

  @override
  void dispose() {
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
            Tab(text: 'My Watchlist'),
            Tab(text: 'Top Coins'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
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
                  'Star coins from Top Coins tab to add them',
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

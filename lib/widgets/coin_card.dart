import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coinsight/models/coin.dart';
import 'package:coinsight/theme/app_theme.dart';
import 'package:coinsight/widgets/sparkline_chart.dart';

class CoinCard extends StatelessWidget {
  final Coin coin;
  final bool isWatchlisted;
  final VoidCallback onToggleWatchlist;
  final bool show1hChange;

  const CoinCard({
    super.key,
    required this.coin,
    required this.isWatchlisted,
    required this.onToggleWatchlist,
    this.show1hChange = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercentage24h >= 0;
    final changeColor = isPositive ? AppTheme.green : AppTheme.red;
    final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 28,
              child: Text(
                '${coin.marketCapRank}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Coin icon with fade-in
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                coin.image,
                width: 36,
                height: 36,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildFallbackIcon();
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackIcon(),
              ),
            ),
            const SizedBox(width: 12),
            // Name & symbol
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.symbol.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Sparkline
            if (coin.sparklineIn7d != null && coin.sparklineIn7d!.length > 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SparklineChart(
                  data: coin.sparklineIn7d!,
                  color: changeColor,
                ),
              ),
            // Price & change
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    coin.currentPrice >= 1
                        ? priceFormat.format(coin.currentPrice)
                        : '\$${coin.currentPrice.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (show1hChange && coin.priceChangePercentage1h != null) ...[
                        _buildChangeBadge(
                          coin.priceChangePercentage1h!,
                          '1H',
                        ),
                        const SizedBox(width: 4),
                      ],
                      Icon(
                        isPositive
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: changeColor,
                        size: 18,
                      ),
                      Text(
                        '${coin.priceChangePercentage24h.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: changeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Animated watchlist toggle
            GestureDetector(
              onTap: onToggleWatchlist,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  isWatchlisted ? Icons.star : Icons.star_border,
                  key: ValueKey(isWatchlisted),
                  color: isWatchlisted ? Colors.amber : Colors.grey[600],
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeBadge(double change, String label) {
    final isPos = change >= 0;
    final color = isPos ? AppTheme.green : AppTheme.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 2),
          Text(
            '${isPos ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    final letter =
        coin.symbol.isNotEmpty ? coin.symbol.toUpperCase().substring(0, 1) : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(letter, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class CoinCardSkeleton extends StatefulWidget {
  const CoinCardSkeleton({super.key});

  @override
  State<CoinCardSkeleton> createState() => _CoinCardSkeletonState();
}

class _CoinCardSkeletonState extends State<CoinCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _shimmerBox(28, 14),
                const SizedBox(width: 8),
                _shimmerCircle(36),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(80, 14),
                      const SizedBox(height: 6),
                      _shimmerBox(40, 10),
                    ],
                  ),
                ),
                _shimmerBox(80, 40),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _shimmerBox(70, 14),
                      const SizedBox(height: 6),
                      _shimmerBox(50, 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withValues(alpha: _animation.value),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withValues(alpha: _animation.value),
        shape: BoxShape.circle,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/tier_provider.dart';

/// Persistent tier selector — 40px visine, prikazuje se ispod AppBara
/// na svim screenima. Jednim tapom mijenja aktivni investment tier.
class TierModeSelector extends StatelessWidget {
  const TierModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TierProvider>(
      builder: (context, tierProvider, _) {
        final active = tierProvider.activeTier;
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            border: Border(
              bottom: BorderSide(
                color: active.color.withAlpha(76), // ~30% opacity
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: InvestmentTier.values.map((tier) {
              final isActive = tier == active;
              return Expanded(
                child: GestureDetector(
                  onTap: () => tierProvider.setTier(tier),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isActive ? tier.bgColor : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? tier.color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tier.emoji,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            tier.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isActive
                                  ? tier.color
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

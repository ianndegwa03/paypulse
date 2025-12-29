import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/core/services/exchange_rate_service.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
import 'package:paypulse/core/widgets/premium_cards.dart';
import 'package:paypulse/domain/entities/enums.dart';

/// Premium rate comparison widget showing rates from multiple providers
class RateComparisonWidget extends ConsumerWidget {
  final CurrencyType fromCurrency;
  final CurrencyType toCurrency;
  final double? amount;
  final bool compact;

  const RateComparisonWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    this.amount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(
      rateComparisonProvider((fromCurrency, toCurrency)),
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ratesAsync.when(
      data: (comparison) => _buildComparisonCard(context, comparison, isDark),
      loading: () => _buildLoadingState(context),
      error: (e, _) => _buildErrorState(context, theme),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    RateComparison comparison,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    if (comparison.rates.isEmpty) {
      return _buildErrorState(context, theme);
    }

    return SurfaceCard(
      padding: EdgeInsets.all(compact ? PulseDesign.s : PulseDesign.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PulseDesign.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(PulseDesign.radiusS),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: PulseDesign.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Rate Comparison',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PulseDesign.primary,
                      ),
                    ),
                    Text(
                      '${fromCurrency.name} → ${toCurrency.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const PulsingDot(),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: PulseDesign.accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rate list
          ...comparison.rates.asMap().entries.map((entry) {
            final index = entry.key;
            final rate = entry.value;
            final isBest = rate == comparison.bestRate;

            return _buildRateRow(context, rate, isBest, index);
          }),

          // Savings indicator
          if (comparison.savings != null && comparison.savings! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: PulseDesign.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(PulseDesign.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.savings_rounded,
                    color: PulseDesign.success,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Save ${comparison.savings!.toStringAsFixed(1)}% with best rate',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PulseDesign.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
          ],

          // Amount preview if provided
          if (amount != null && comparison.bestRate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  PulseDesign.primary,
                  PulseDesign.primary.withBlue(200),
                ]),
                borderRadius: BorderRadius.circular(PulseDesign.radiusM),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You receive',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(amount! * comparison.bestRate!.rate).toStringAsFixed(2)} ${toCurrency.name}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(PulseDesign.radiusFull),
                    ),
                    child: Text(
                      'BEST',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .scale(begin: const Offset(0.95, 0.95)),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  Widget _buildRateRow(
    BuildContext context,
    ProviderRate rate,
    bool isBest,
    int index,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isBest
            ? PulseDesign.success.withOpacity(0.08)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(PulseDesign.radiusS),
        border: isBest
            ? Border.all(color: PulseDesign.success.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          // Provider icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isBest
                  ? PulseDesign.success.withOpacity(0.15)
                  : PulseDesign.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                rate.providerName[0],
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isBest ? PulseDesign.success : PulseDesign.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Provider name
          Expanded(
            child: Text(
              rate.providerName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Rate
          Text(
            rate.rate.toStringAsFixed(4),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isBest ? PulseDesign.success : null,
            ),
          ),
          if (isBest) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.verified_rounded,
              color: PulseDesign.success,
              size: 16,
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: 0.1);
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(PulseDesign.radiusS),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1200.ms),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1200.ms),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(PulseDesign.radiusS),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(delay: (200 * index).ms, duration: 1200.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          Text(
            'Unable to fetch live rates',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact rate ticker for dashboard
class RateTicker extends ConsumerWidget {
  final CurrencyType baseCurrency;

  const RateTicker({super.key, this.baseCurrency = CurrencyType.USD});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(autoRefreshRatesProvider);
    final theme = Theme.of(context);

    return ratesAsync.when(
      data: (result) {
        final currencies = [
          CurrencyType.EUR,
          CurrencyType.GBP,
          CurrencyType.KES,
          CurrencyType.NGN,
        ];

        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(PulseDesign.radiusFull),
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: currencies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final rate = result.bestRates[currency];

              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PulseDesign.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rate?.toStringAsFixed(2) ?? '--',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

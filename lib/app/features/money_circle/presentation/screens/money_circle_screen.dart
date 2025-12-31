import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:paypulse/app/features/money_circle/presentation/state/money_circle_providers.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/domain/entities/money_circle_entity.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // Optional animations

class MoneyCircleScreen extends ConsumerWidget {
  const MoneyCircleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final circlesAsync = ref.watch(userCirclesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("MONEY CIRCLES",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/create-money-circle'),
          )
        ],
      ),
      body: circlesAsync.when(
        data: (circles) {
          if (circles.isEmpty) return _buildEmptyState(context, theme);

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: circles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final circle = circles[index];
              return _buildCircleCard(context, theme, circle, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCircleCard(BuildContext context, ThemeData theme,
      MoneyCircle circle, WidgetRef ref) {
    final currentUserId = ref.watch(authNotifierProvider).userId;
    final recipient = circle.currentRecipient;
    final isMyTurn = recipient?.userId == currentUserId;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.cardColor, theme.cardColor.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(circle.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900, fontSize: 20)),
                  Text(
                      "${circle.frequency.name.toUpperCase()} • Round ${circle.currentRound}/${circle.members.length}",
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${circle.currencyCode} ${circle.potAmount.toStringAsFixed(0)}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Visualization: Recipient
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isMyTurn
                      ? Colors.greenAccent
                      : theme.colorScheme.secondary,
                  child:
                      Icon(Icons.star_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  isMyTurn
                      ? "It's your turn!"
                      : "${recipient?.displayName}'s Turn",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Payout: ${DateFormat('MMM d').format(circle.nextPayoutDate)}",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Member Status Rail
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: circle.members.length,
              itemBuilder: (context, mIndex) {
                final member = circle.members[mIndex];
                final isPaid = member.hasPaidCurrentCycle;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isPaid
                            ? Colors.green
                            : theme.disabledColor.withOpacity(0.2),
                        child: isPaid
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text((mIndex + 1).toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (currentUserId != null) {
                  ref
                      .read(moneyCircleServiceProvider)
                      .contribute(circle.id, currentUserId);
                }
              },
              icon: const Icon(Icons.payment_rounded),
              label: Text(
                  "Pay Contribution (${circle.currencyCode} ${circle.contributionAmount.toStringAsFixed(0)})"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.supervised_user_circle_rounded,
              size: 64, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text("No Active Circles", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text("Join or create a savings group.",
              style: TextStyle(color: theme.disabledColor)),
        ],
      ),
    );
  }
}

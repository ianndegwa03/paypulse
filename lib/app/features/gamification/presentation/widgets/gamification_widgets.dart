import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/gamification/presentation/state/gamification_notifier.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
import 'package:paypulse/domain/entities/badge_entity.dart';

/// Displays the user's streak with a flame icon
class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(gamificationProvider).streak;
    final isActive = streak.isActiveToday;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.orange, Colors.deepOrange]
              : [Colors.grey.shade600, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '${streak.currentStreak}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of achievement badges
class BadgesGrid extends ConsumerWidget {
  const BadgesGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: state.allBadges.length,
      itemBuilder: (context, index) {
        final badge = state.allBadges[index];
        final unlocked = state.unlockedBadges.any((b) => b.id == badge.id);
        return _BadgeTile(badge: badge, isUnlocked: unlocked);
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeEntity badge;
  final bool isUnlocked;

  const _BadgeTile({required this.badge, required this.isUnlocked});

  Color get _rarityColor {
    switch (badge.rarity) {
      case BadgeRarity.legendary:
        return Colors.amber;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.common:
        return Colors.grey;
    }
  }

  IconData get _iconData {
    switch (badge.icon) {
      case 'savings':
        return Icons.savings_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'monetization_on':
        return Icons.monetization_on_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? _rarityColor.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? _rarityColor : theme.dividerColor,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _iconData,
            size: 32,
            color: isUnlocked ? _rarityColor : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isUnlocked
                  ? theme.colorScheme.onSurface
                  : Colors.grey.shade500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked)
            Icon(Icons.lock_rounded, size: 12, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';

/// Mood-based theme state that changes colors based on financial health
class MoodThemeState {
  final FinancialMood mood;
  final Color primaryColor;
  final Color accentColor;

  const MoodThemeState({
    this.mood = FinancialMood.neutral,
    this.primaryColor = PulseDesign.primary,
    this.accentColor = PulseDesign.accent,
  });

  MoodThemeState copyWith({
    FinancialMood? mood,
    Color? primaryColor,
    Color? accentColor,
  }) {
    return MoodThemeState(
      mood: mood ?? this.mood,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

enum FinancialMood {
  thriving, // Green - under budget, savings growing
  stable, // Blue - on target
  neutral, // Purple - default
  warning, // Yellow - approaching budget limit
  critical, // Red - over budget
}

class MoodThemeNotifier extends StateNotifier<MoodThemeState> {
  MoodThemeNotifier() : super(const MoodThemeState());

  void updateMood({
    required double budgetRemaining,
    required double budgetTotal,
    double? savingsGrowth,
  }) {
    final budgetPercent = budgetTotal > 0 ? budgetRemaining / budgetTotal : 1.0;

    FinancialMood newMood;
    Color primary;
    Color accent;

    if (budgetPercent > 0.5 && (savingsGrowth ?? 0) > 0) {
      newMood = FinancialMood.thriving;
      primary = const Color(0xFF10B981); // Emerald
      accent = const Color(0xFF34D399);
    } else if (budgetPercent > 0.3) {
      newMood = FinancialMood.stable;
      primary = const Color(0xFF3B82F6); // Blue
      accent = const Color(0xFF60A5FA);
    } else if (budgetPercent > 0.1) {
      newMood = FinancialMood.warning;
      primary = const Color(0xFFF59E0B); // Amber
      accent = const Color(0xFFFBBF24);
    } else if (budgetPercent > 0) {
      newMood = FinancialMood.critical;
      primary = const Color(0xFFEF4444); // Red
      accent = const Color(0xFFF87171);
    } else {
      newMood = FinancialMood.neutral;
      primary = PulseDesign.primary;
      accent = PulseDesign.accent;
    }

    state = state.copyWith(
      mood: newMood,
      primaryColor: primary,
      accentColor: accent,
    );
  }

  void reset() {
    state = const MoodThemeState();
  }
}

final moodThemeProvider =
    StateNotifierProvider<MoodThemeNotifier, MoodThemeState>(
  (ref) => MoodThemeNotifier(),
);

/// Widget that applies mood-based colors to its child
class MoodColoredWidget extends ConsumerWidget {
  final Widget Function(Color primary, Color accent) builder;

  const MoodColoredWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodThemeProvider);
    return builder(moodState.primaryColor, moodState.accentColor);
  }
}

/// Indicator showing current financial mood
class MoodIndicator extends ConsumerWidget {
  const MoodIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodThemeProvider);

    String emoji;
    String label;

    switch (moodState.mood) {
      case FinancialMood.thriving:
        emoji = '🌟';
        label = 'Thriving';
        break;
      case FinancialMood.stable:
        emoji = '✨';
        label = 'Stable';
        break;
      case FinancialMood.warning:
        emoji = '⚠️';
        label = 'Caution';
        break;
      case FinancialMood.critical:
        emoji = '🚨';
        label = 'Over Budget';
        break;
      case FinancialMood.neutral:
        emoji = '💫';
        label = 'Neutral';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: moodState.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: moodState.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: moodState.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

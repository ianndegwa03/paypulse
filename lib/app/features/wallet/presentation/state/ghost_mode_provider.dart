import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ghost mode state - hides sensitive financial data
class GhostModeState {
  final bool isHidden;

  const GhostModeState({this.isHidden = false});

  GhostModeState copyWith({bool? isHidden}) {
    return GhostModeState(isHidden: isHidden ?? this.isHidden);
  }
}

class GhostModeNotifier extends StateNotifier<GhostModeState> {
  GhostModeNotifier() : super(const GhostModeState());

  void toggle() {
    state = state.copyWith(isHidden: !state.isHidden);
  }

  void hide() {
    state = state.copyWith(isHidden: true);
  }

  void reveal() {
    state = state.copyWith(isHidden: false);
  }
}

final ghostModeProvider =
    StateNotifierProvider<GhostModeNotifier, GhostModeState>(
  (ref) => GhostModeNotifier(),
);

/// Widget that blurs content when ghost mode is active
class GhostModeWrapper extends ConsumerWidget {
  final Widget child;
  final Widget? placeholder;

  const GhostModeWrapper({
    super.key,
    required this.child,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHidden = ref.watch(ghostModeProvider).isHidden;

    if (!isHidden) return child;

    return placeholder ??
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.visibility_off_rounded, color: Colors.grey),
          ),
        );
  }
}

/// Toggle button for ghost mode
class GhostModeToggle extends ConsumerWidget {
  const GhostModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHidden = ref.watch(ghostModeProvider).isHidden;
    final notifier = ref.read(ghostModeProvider.notifier);

    return GestureDetector(
      onTap: notifier.toggle,
      onLongPress: () async {
        // TODO: Add biometric auth here with local_auth
        notifier.reveal();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHidden ? Colors.grey.shade800 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: isHidden ? Colors.white : Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}

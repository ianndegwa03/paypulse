import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/base/base_state.dart';
import 'package:paypulse/domain/entities/shared_space_entity.dart';
import 'package:paypulse/domain/repositories/shared_space_repository.dart';

class SharedSpaceState extends BaseState {
  final List<SharedSpaceEntity> spaces;

  const SharedSpaceState({
    super.isLoading = false,
    this.spaces = const [],
    super.errorMessage,
    super.successMessage,
  });

  @override
  SharedSpaceState copyWith({
    bool? isLoading,
    List<SharedSpaceEntity>? spaces,
    String? errorMessage,
    String? successMessage,
  }) {
    return SharedSpaceState(
      isLoading: isLoading ?? this.isLoading,
      spaces: spaces ?? this.spaces,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [spaces, ...super.props];
}

class SharedSpaceNotifier extends StateNotifier<SharedSpaceState> {
  final SharedSpaceRepository _repository;

  SharedSpaceNotifier(this._repository) : super(const SharedSpaceState()) {
    _listenToSpaces();
  }

  void _listenToSpaces() {
    state = state.copyWith(isLoading: true);
    _repository.getMySpaces().listen((spaces) {
      if (mounted) {
        state = state.copyWith(spaces: spaces, isLoading: false);
      }
    }, onError: (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    });
  }

  Future<void> createSpace(
      String title, double amount, List<String> members) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createSpace(title, amount, members);
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state = state.copyWith(
          isLoading: false, successMessage: 'Space created successfully'),
    );
  }
}

final sharedSpaceProvider =
    StateNotifierProvider<SharedSpaceNotifier, SharedSpaceState>((ref) {
  return SharedSpaceNotifier(getIt<SharedSpaceRepository>());
});

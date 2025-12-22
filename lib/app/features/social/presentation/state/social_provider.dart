import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';
import 'package:paypulse/domain/repositories/social_repository.dart';

// State class
class SocialFeedState {
  final List<SocialPostEntity> posts;
  final bool isLoading;
  final String? error;

  const SocialFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  SocialFeedState copyWith({
    List<SocialPostEntity>? posts,
    bool? isLoading,
    String? error,
  }) {
    return SocialFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class SocialFeedNotifier extends StateNotifier<SocialFeedState> {
  final SocialRepository _repository;

  SocialFeedNotifier(this._repository) : super(const SocialFeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getFeed();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (posts) => state = state.copyWith(isLoading: false, posts: posts),
    );
  }

  Future<void> createPost(String content) async {
    if (content.isEmpty) return;
    final result = await _repository.createPost(content);
    result.fold(
      (failure) {}, // Handle error if needed
      (_) => loadFeed(), // Refresh feed
    );
  }

  Future<void> likePost(String postId) async {
    // Optimistic update
    final currentPosts = state.posts.map((post) {
      if (post.id == postId) {
        return SocialPostEntity(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          content: post.content,
          timestamp: post.timestamp,
          mediaUrl: post.mediaUrl,
          userAvatarUrl: post.userAvatarUrl,
          likes: post.likes + (post.isLiked ? -1 : 1),
          comments: post.comments,
          isLiked: !post.isLiked,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: currentPosts);

    final result = await _repository.likePost(postId);
    result.fold(
      (failure) => loadFeed(), // Revert on failure
      (_) {},
    );
  }
}

// Provider
final socialFeedProvider =
    StateNotifierProvider<SocialFeedNotifier, SocialFeedState>((ref) {
  return SocialFeedNotifier(getIt<SocialRepository>());
});

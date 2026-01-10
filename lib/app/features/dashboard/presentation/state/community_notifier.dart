import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/domain/entities/community_post_entity.dart';
import 'package:paypulse/domain/repositories/community_repository.dart';

// STATE
class CommunityState {
  final List<CommunityPost> posts;
  final bool isLoading;
  final String? error;

  CommunityState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<CommunityPost>? posts,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// NOTIFIER
class CommunityNotifier extends StateNotifier<CommunityState> {
  final CommunityRepository _repository;

  CommunityNotifier(this._repository) : super(CommunityState()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getPosts();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (posts) {
        // Sort by createdAt desc just in case
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = state.copyWith(isLoading: false, posts: posts);
      },
    );
  }

  Future<void> refresh() async {
    await loadPosts();
  }

  Future<bool> createPost(CommunityPost post) async {
    final result = await _repository.createPost(post);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        // Optimistic update or reload
        loadPosts();
        return true;
      },
    );
  }

  Future<void> likePost(String postId, String userId) async {
    // Optimistic update
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final oldPost = state.posts[index];
    if (oldPost.likedBy.contains(userId)) return;

    final newPost = oldPost.copyWith(
      likes: oldPost.likes + 1,
      likedBy: [...oldPost.likedBy, userId],
    );

    final updatedPosts = List<CommunityPost>.from(state.posts);
    updatedPosts[index] = newPost;
    state = state.copyWith(posts: updatedPosts);

    final result = await _repository.likePost(postId, userId);
    result.fold(
      (failure) {
        // Revert
        updatedPosts[index] = oldPost;
        state = state.copyWith(posts: updatedPosts, error: failure.message);
      },
      (_) {},
    );
  }

  Future<void> unlikePost(String postId, String userId) async {
    // Optimistic update
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final oldPost = state.posts[index];
    if (!oldPost.likedBy.contains(userId)) return;

    final newLikedBy = List<String>.from(oldPost.likedBy)..remove(userId);
    final newPost = oldPost.copyWith(
      likes: oldPost.likes - 1,
      likedBy: newLikedBy,
    );

    final updatedPosts = List<CommunityPost>.from(state.posts);
    updatedPosts[index] = newPost;
    state = state.copyWith(posts: updatedPosts);

    final result = await _repository.unlikePost(postId, userId);
    result.fold(
      (failure) {
        // Revert
        updatedPosts[index] = oldPost;
        state = state.copyWith(posts: updatedPosts, error: failure.message);
      },
      (_) {},
    );
  }

  Future<void> deletePost(String postId) async {
    // Optimistic update
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final oldPosts = List<CommunityPost>.from(state.posts);
    final newPosts = List<CommunityPost>.from(state.posts)..removeAt(index);
    state = state.copyWith(posts: newPosts);

    final result = await _repository.deletePost(postId);
    result.fold(
      (failure) {
        // Revert
        state = state.copyWith(posts: oldPosts, error: failure.message);
      },
      (_) {},
    );
  }
}

// PROVIDERS
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return GetIt.instance<CommunityRepository>();
});

final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  return CommunityNotifier(repo);
});

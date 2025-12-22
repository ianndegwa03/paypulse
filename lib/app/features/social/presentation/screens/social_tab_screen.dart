import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/social/presentation/state/social_provider.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';
import 'package:paypulse/domain/entities/story_entity.dart';

import 'package:paypulse/core/widgets/loading/skeleton_loader.dart';

class SocialTabScreen extends ConsumerStatefulWidget {
  const SocialTabScreen({super.key});

  @override
  ConsumerState<SocialTabScreen> createState() => _SocialTabScreenState();
}

class _SocialTabScreenState extends ConsumerState<SocialTabScreen> {
  // TODO: Move Stories to Provider as well
  final List<StoryEntity> _stories = [
    StoryEntity(
      id: '1',
      userId: '2',
      userName: 'Alice',
      mediaUrl: '',
      timestamp: DateTime.now(),
      isViewed: false,
    ),
    StoryEntity(
      id: '2',
      userId: '3',
      userName: 'Bob',
      mediaUrl: '',
      timestamp: DateTime.now(),
      isViewed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(socialFeedProvider);
    final posts = feedState.posts;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(socialFeedProvider.notifier).loadFeed(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Community',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: false,
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.maps_ugc_outlined),
                  onPressed: () => context.push('/chats'),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildStoriesSection(context),
            ),
            const SliverToBoxAdapter(
              child: Divider(thickness: 1, height: 1),
            ),
            if (feedState.isLoading && posts.isEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSkeletonPost(context),
                  childCount: 3,
                ),
              )
            else if (posts.isEmpty)
              const SliverFillRemaining(
                child:
                    Center(child: Text('No posts yet, connect with friends!')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return _buildPostCard(context, post);
                  },
                  childCount: posts.length,
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSkeletonPost(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 120, height: 14),
                  const SizedBox(height: 6),
                  const SkeletonLoader(width: 80, height: 12),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoader(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.all(Radius.circular(12))),
          const SizedBox(height: 16),
          const Row(
            children: [
              SkeletonLoader(width: 60, height: 20),
              SizedBox(width: 16),
              SkeletonLoader(width: 60, height: 20),
            ],
          )
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "What's on your mind?"),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(socialFeedProvider.notifier)
                    .createPost(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _stories.length + 1, // +1 for "My Story"
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryItem(context);
          }
          return _buildStoryItem(context, _stories[index - 1]);
        },
      ),
    );
  }

  Widget _buildAddStoryItem(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.primary),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Your Story',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStoryItem(BuildContext context, StoryEntity story) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2), // Gradient border width
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: story.isViewed
                ? null
                : LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: story.isViewed ? Colors.grey.withOpacity(0.3) : null,
          ),
          child: Container(
            padding:
                const EdgeInsets.all(2), // Spacing between border and avatar
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surface,
              backgroundImage: story.userAvatarUrl != null
                  ? NetworkImage(story.userAvatarUrl!)
                  : null,
              child: story.userAvatarUrl == null
                  ? Text(story.userName[0].toUpperCase())
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          story.userName,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPostCard(BuildContext context, SocialPostEntity post) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userAvatarUrl != null
                      ? NetworkImage(post.userAvatarUrl!)
                      : null,
                  child: post.userAvatarUrl == null
                      ? Text(post.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _formatTime(post.timestamp),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          const SizedBox(height: 12),
          if (post.mediaUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildInteractionButton(
                  context,
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: post.isLiked ? Colors.red : null,
                  label: '${post.likes}',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(socialFeedProvider.notifier).likePost(post.id);
                  },
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.comments}',
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  context,
                  icon: Icons.send_outlined,
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border_rounded, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(
    BuildContext context, {
    required IconData icon,
    String? label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon,
              size: 24, color: color ?? Theme.of(context).iconTheme.color),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(label),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

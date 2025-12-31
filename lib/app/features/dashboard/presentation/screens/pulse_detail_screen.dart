import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/data/models/community_post_model.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class PulseDetailScreen extends ConsumerStatefulWidget {
  final CommunityPostModel post;

  const PulseDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PulseDetailScreen> createState() => _PulseDetailScreenState();
}

class _PulseDetailScreenState extends ConsumerState<PulseDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handlePostComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(authNotifierProvider).currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
        'userId': user.id,
        'username': user.firstName,
        'userProfileUrl': user.profileImageUrl,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
      HapticFeedback.lightImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We can reuse the visual logic from Pulse Tab, but for now I'll create a simplified card view
    // ideally we would extract PulsePostCard to a separate widget to reuse it.

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Thread"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildMainPost(theme),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(),
                )),
                _buildCommentsStream(theme),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
          _buildCommentInput(theme),
        ],
      ),
    );
  }

  Widget _buildMainPost(ThemeData theme) {
    // Replicating basic postcard look (Refactor recommended later)
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(widget.post.userProfileUrl ??
                    'https://api.dicebear.com/7.x/avataaars/png?seed=${widget.post.userId}'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    // Simple time display for now
                    "Posted recently",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.post.content,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCommentsStream(ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                      child: Text("No comments yet. Be the first!",
                          style: TextStyle(
                              color: Colors.grey.withOpacity(0.5))))));
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildCommentTile(theme, data);
            },
            childCount: docs.length,
          ),
        );
      },
    );
  }

  Widget _buildCommentTile(ThemeData theme, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(data['userProfileUrl'] ??
                'https://api.dicebear.com/7.x/avataaars/png?seed=${data['userId']}'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['username'] ?? 'User',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(data['content'] ?? '',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Reply to ${widget.post.username}...",
                hintStyle: const TextStyle(fontSize: 14),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
              onPressed: _isPosting ? null : _handlePostComment,
            ),
          )
        ],
      ),
    );
  }
}

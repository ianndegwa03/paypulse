import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/data/models/community_post_model.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/shared/widgets/user_avatar.dart';
import 'dart:ui';

class CommunityTabScreen extends ConsumerStatefulWidget {
  const CommunityTabScreen({super.key});

  @override
  ConsumerState<CommunityTabScreen> createState() => _CommunityTabScreenState();
}

class _CommunityTabScreenState extends ConsumerState<CommunityTabScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;
  Map<String, dynamic>? _pendingFinancialAction;
  bool _isGhostMode = false;
  String _replySettings = 'everyone';

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _handleCreatePost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(authNotifierProvider).currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      final newPost = CommunityPostModel(
        id: '',
        userId: user.id,
        username: user.firstName,
        userProfileUrl: user.profileImageUrl,
        content: content,
        createdAt: DateTime.now(),
        likes: 0,
        likedBy: [],
        financialAction: _pendingFinancialAction,
      );

      await FirebaseFirestore.instance
          .collection('community_posts')
          .add(newPost.toDocument());

      _postController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _handleLikePost(CommunityPostModel post) async {
    final user = ref.read(authNotifierProvider).currentUser;
    if (user == null) return;

    final isLiked = post.likedBy.contains(user.id);
    final docRef =
        FirebaseFirestore.instance.collection('community_posts').doc(post.id);

    try {
      HapticFeedback.selectionClick();
      if (isLiked) {
        // Unlike
        await docRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([user.id]),
        });
      } else {
        // Like
        await docRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([user.id]),
        });
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  Future<void> _handleDeletePost(String postId) async {
    try {
      HapticFeedback.mediumImpact();
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pulse deleted")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete pulse: $e")),
        );
      }
    }
  }

  void _showDeleteConfirmation(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pulse?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeletePost(postId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  IconData _getIconForAction(String? type) {
    switch (type) {
      case 'request':
        return Icons.attach_money_rounded;
      case 'split':
        return Icons.call_split_rounded;
      case 'escrow':
        return Icons.security_rounded;
      case 'bounty':
        return Icons.military_tech_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'goal':
        return Icons.rebase_edit;
      case 'invoice':
        return Icons.receipt_long_rounded;
      case 'pledge':
        return Icons.handshake_rounded;
      case 'compare':
        return Icons.poll_rounded;
      case 'vouch':
        return Icons.verified_user_outlined;
      case 'signal':
        return Icons.trending_up;
      default:
        return Icons.bubble_chart_rounded;
    }
  }

  Widget _buildToolIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () => HapticFeedback.lightImpact(),
        child: Icon(icon, color: Colors.grey.shade400, size: 22),
      ),
    );
  }

  Future<void> _handlePost() async {
    final text = _postController.text.trim();
    if (text.isEmpty && _pendingFinancialAction == null) return;

    final user = ref.read(authNotifierProvider).currentUser;
    if (user == null) return;

    try {
      HapticFeedback.mediumImpact();

      final post = CommunityPostModel(
        id: '', // Firestore will assign ID
        userId: user.id,
        username: _isGhostMode ? 'Ghost User' : user.username,
        userProfileUrl: _isGhostMode ? null : user.profileImageUrl,
        content: text,
        createdAt: DateTime.now(),
        likes: 0,
        likedBy: const [],
        financialAction: _pendingFinancialAction,
        isGhost: _isGhostMode,
        attachmentUrls: const [],
        poll: null,
        location: null,
        replySettings: _replySettings,
      );

      await FirebaseFirestore.instance
          .collection('community_posts')
          .add(post.toDocument());

      if (mounted) {
        Navigator.pop(context);
        _postController.clear();
        _pendingFinancialAction = null;
        _isGhostMode = false;
        _replySettings = 'everyone';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pulse shared!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sharing pulse: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton.extended(
          backgroundColor: theme.colorScheme.primary,
          onPressed: _showPremiumComposeModal,
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          label: const Text("Compose",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(theme),
          if (_isPosting)
            SliverToBoxAdapter(
              child: LinearProgressIndicator(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2)),
            ),
          // _buildPostCreator(theme), // Removing old top box creator
          _buildFeedStream(theme),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  void _showComposeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const Text("New Pulse",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleCreatePost();
                    },
                    child: const Text("Post",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _postController,
                  autofocus: true,
                  expands: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "What's happening in your financial world?",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Pulse Actions Toolbar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                      top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withOpacity(0.1)))),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAttachmentAction(
                        Icons.attach_money_rounded, "Request", Colors.green),
                    _buildAttachmentAction(
                        Icons.call_split_rounded, "Split", Colors.orange),
                    _buildAttachmentAction(
                        Icons.poll_rounded, "Compare", Colors.blue),
                    _buildAttachmentAction(
                        Icons.verified_user_outlined, "Vouch", Colors.purple),
                    _buildAttachmentAction(
                        Icons.trending_up, "Signal", Colors.teal),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentAction(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 12))
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
      elevation: 0,
      centerTitle: false,
      title: Text(
        "Pulse",
        style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: theme.colorScheme.primary),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip(theme, "All", true),
              _buildFilterChip(theme, "Requests", false),
              _buildFilterChip(theme, "Wins", false),
              _buildFilterChip(theme, "News", false),
              _buildFilterChip(theme, "Bet", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.dividerColor.withOpacity(0.1))),
      child: Text(label,
          style: TextStyle(
              color:
                  isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600)),
    );
  }

  // Deprecated: _buildPostCreator replaced by FAB Modal

  Widget _buildFeedStream(ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('community_posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined,
                      size: 64, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text("No threads yet. Start the conversation!",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final model = CommunityPostModel.fromSnapshot(docs[index]);
              return _buildThreadedPost(theme, model);
            },
            childCount: docs.length,
          ),
        );
      },
    );
  }

  Widget _buildThreadedPost(ThemeData theme, CommunityPostModel post) {
    final currentUser = ref.watch(authNotifierProvider).currentUser;
    final isLiked =
        currentUser != null && post.likedBy.contains(currentUser.id);

    return InkWell(
      onTap: () => context.push('/pulse-detail', extra: post),
      onLongPress: () {
        if (currentUser?.id == post.userId) {
          HapticFeedback.heavyImpact();
          _showDeleteConfirmation(post.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  UserAvatar(
                    radius: 20,
                    profileImageUrl: post.isGhost ? null : post.userProfileUrl,
                    name: post.isGhost ? 'Ghost' : post.username,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: theme.dividerColor.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: User, Verification, Time AND Financial Chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.isGhost ? 'Ghost User' : post.username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!post.isGhost) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.verified_rounded,
                                    size: 14, color: theme.colorScheme.primary),
                              ],
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(post.createdAt),
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // Financial Topic Chip (Top Right)
                        if (post.financialAction != null)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (currentUser?.id != post.userId &&
                                    post.financialAction!['status'] == 'open') {
                                  HapticFeedback.mediumImpact();
                                  _showPaymentConfirmation(
                                      post, post.financialAction!);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        _getIconForAction(
                                            post.financialAction!['type']),
                                        size: 12,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.financialAction!['amount'] != null
                                          ? "KES ${post.financialAction!['amount']}"
                                          : post.financialAction!['type']
                                              .toString()
                                              .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Follow Button stub if not current user and not ghost
                        if (currentUser?.id != post.userId && !post.isGhost)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onTap: () => HapticFeedback.selectionClick(),
                              child: Icon(Icons.person_add_outlined,
                                  size: 18,
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.6)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.content,
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: theme.textTheme.bodyLarge?.color
                              ?.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 16),

                    // Interaction Bar: No repost, Delicate icons
                    Row(
                      children: [
                        _buildThreadAction(
                          icon: isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: post.likes > 0 ? post.likes.toString() : "",
                          color: isLiked ? Colors.red : Colors.grey.shade500,
                          onTap: () => _handleLikePost(post),
                        ),
                        const SizedBox(width: 28),
                        _buildThreadAction(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "0",
                          color: Colors.grey.shade500,
                          onTap: () =>
                              context.push('/pulse-detail', extra: post),
                        ),
                        const SizedBox(width: 28),
                        _buildThreadAction(
                          icon: Icons.send_outlined,
                          label: "",
                          color: Colors.grey.shade500,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                        color: theme.dividerColor.withOpacity(0.05), height: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildThreadAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          if (label.isNotEmpty && label != "0") ...[
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  void _showPaymentConfirmation(
      CommunityPostModel post, Map<String, dynamic> action) {
    final amount = action['amount']?.toString() ?? '0';
    final type = action['type']?.toString() ?? 'request';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text("Confirm Payment"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'request'
                  ? "You're about to send money to ${post.username}"
                  : "You're about to split this bill with ${post.username}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("Amount", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    "KES $amount",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              // TODO: Implement actual payment logic via wallet/payment provider
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content:
                      Text("Payment of KES $amount sent to ${post.username}!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send_rounded, size: 18),
                SizedBox(width: 8),
                Text("Send Now", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  void _showPremiumComposeModal() {
    // Reset pending action when opening modal
    _pendingFinancialAction = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // Premium Drawer Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          _pendingFinancialAction = null;
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.grey)),
                      ),
                      const Text(
                        "New Pulse",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      ElevatedButton(
                        onPressed: () => _handlePost(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                        ),
                        child: const Text("Post",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // User Info & Input Area
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserAvatar(
                                radius: 20,
                                profileImageUrl: ref
                                    .watch(authNotifierProvider)
                                    .currentUser
                                    ?.profileImageUrl,
                                name: ref
                                        .watch(authNotifierProvider)
                                        .currentUser
                                        ?.username ??
                                    "",
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref
                                              .watch(authNotifierProvider)
                                              .currentUser
                                              ?.username ??
                                          "User",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextField(
                                      controller: _postController,
                                      autofocus: true,
                                      maxLines: null,
                                      style: const TextStyle(
                                          fontSize: 18, height: 1.4),
                                      decoration: InputDecoration(
                                        hintText: _pendingFinancialAction !=
                                                null
                                            ? "Add context to your ${_pendingFinancialAction!['type']}..."
                                            : "What's the move today?",
                                        hintStyle: TextStyle(
                                            color: Colors.grey.withOpacity(0.4),
                                            fontSize: 18),
                                        border: InputBorder.none,
                                      ),
                                    ),

                                    // Financial Action Preview (Inline)
                                    if (_pendingFinancialAction != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getIconForAction(
                                                  _pendingFinancialAction![
                                                      'type']),
                                              color: theme.colorScheme.primary,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${_pendingFinancialAction!['type'].toString().toUpperCase()}: KES ${_pendingFinancialAction!['amount'] ?? 0}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.primary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => setModalState(() =>
                                                  _pendingFinancialAction =
                                                      null),
                                              child: Icon(Icons.close_rounded,
                                                  size: 14,
                                                  color: Colors.grey.shade400),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Media & Tools Stubs
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buildToolIcon(Icons.image_outlined, "Image"),
                              _buildToolIcon(Icons.gif_box_outlined, "GIF"),
                              _buildToolIcon(Icons.poll_outlined, "Poll"),
                              _buildToolIcon(
                                  Icons.location_on_outlined, "Location"),
                              const Spacer(),
                              // Ghost Mode Toggle
                              InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  setModalState(() {
                                    _isGhostMode = !_isGhostMode;
                                  });
                                },
                                child: Icon(
                                  _isGhostMode
                                      ? Icons.visibility_off
                                      : Icons.visibility_outlined,
                                  color: _isGhostMode
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade400,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // "Topics" Selection (The Financial Objects)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor.withOpacity(0.5),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SELECT FINANCIAL TOPIC",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 12,
                                children: [
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.attach_money_rounded,
                                      "Request",
                                      Colors.green,
                                      "Ask funds"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.call_split_rounded,
                                      "Split",
                                      Colors.orange,
                                      "Divide bill"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.security_rounded,
                                      "Escrow",
                                      Colors.blue,
                                      "Hold safe"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.military_tech_rounded,
                                      "Bounty",
                                      Colors.red,
                                      "Reward task"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.card_giftcard_rounded,
                                      "Gift",
                                      Colors.purple,
                                      "Send love"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.rebase_edit,
                                      "Goal",
                                      Colors.teal,
                                      "Save group"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.receipt_long_rounded,
                                      "Invoice",
                                      Colors.indigo,
                                      "Pro request"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.handshake_rounded,
                                      "Pledge",
                                      Colors.amber,
                                      "Commit funds"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.poll_rounded,
                                      "Compare",
                                      Colors.cyan,
                                      "Vote best"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.verified_user_outlined,
                                      "Vouch",
                                      Colors.pink,
                                      "Trust node"),
                                  _buildActionChipWithDialog(
                                      context,
                                      setModalState,
                                      Icons.trending_up,
                                      "Signal",
                                      Colors.deepPurple,
                                      "Market tip"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Controls Placeholder (Reply, Schedule)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.05))),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showReplySettingsDrawer(context, setModalState);
                        },
                        child: Text(
                          _replySettings == 'everyone'
                              ? "Anyone can reply"
                              : _replySettings == 'following'
                                  ? "Profiles you follow can reply"
                                  : "Only mentioned can reply",
                          style: TextStyle(
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_month_outlined,
                          size: 20, color: Colors.grey.shade400),
                      const SizedBox(width: 16),
                      Icon(Icons.history_edu_outlined,
                          size: 20, color: Colors.grey.shade400),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReplySettingsDrawer(
      BuildContext context, StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Who can reply?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                "Choose who can reply to this thread. Anyone mentioned will always be able to reply.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 24),
            _buildReplyOption(context, setModalState, 'everyone', "Everyone",
                Icons.public_rounded),
            _buildReplyOption(context, setModalState, 'following',
                "Profiles you follow", Icons.group_outlined),
            _buildReplyOption(context, setModalState, 'mentioned',
                "Only mentioned", Icons.alternate_email_rounded),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyOption(BuildContext context, StateSetter setModalState,
      String value, String label, IconData icon) {
    final isSelected = _replySettings == value;
    return ListTile(
      onTap: () {
        setModalState(() => _replySettings = value);
        Navigator.pop(context);
      },
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon,
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
      title: Text(label,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary)
          : null,
    );
  }

  Widget _buildActionChipWithDialog(
    BuildContext context,
    StateSetter setModalState,
    IconData icon,
    String label,
    Color color,
    String subLabel,
  ) {
    final isSelected = _pendingFinancialAction?['type'] == label.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();

            // Show amount dialog for monetary actions
            if (label == "Request" || label == "Split") {
              final amount = await _showAmountDialog(context, label, color);
              if (amount != null && amount > 0) {
                setModalState(() {
                  _pendingFinancialAction = {
                    'type': label.toLowerCase(),
                    'amount': amount,
                    'currency': 'KES',
                    'status': 'open',
                  };
                });
              }
            } else {
              // Non-monetary actions
              setModalState(() {
                _pendingFinancialAction = {
                  'type': label.toLowerCase(),
                  'status': 'open',
                };
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isSelected ? color.withOpacity(0.2) : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Text(label,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13))
                  ],
                ),
                const SizedBox(height: 4),
                Text(subLabel,
                    style:
                        TextStyle(color: color.withOpacity(0.8), fontSize: 10))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<double?> _showAmountDialog(
      BuildContext context, String actionType, Color color) async {
    final amountController = TextEditingController();

    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                actionType == "Request"
                    ? Icons.attach_money_rounded
                    : Icons.call_split_rounded,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(actionType,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              actionType == "Request"
                  ? "How much do you need?"
                  : "What's the total bill to split?",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "KES ",
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
                hintText: "0",
                hintStyle: TextStyle(color: Colors.grey.shade300),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              Navigator.pop(context, amount);
            },
            child: const Text("Attach", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionChip(
      IconData icon, String label, Color color, String subLabel) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Text(label,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13))
                  ],
                ),
                const SizedBox(height: 4),
                Text(subLabel,
                    style:
                        TextStyle(color: color.withOpacity(0.8), fontSize: 10))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/social/presentation/state/social_provider.dart';
import 'package:paypulse/app/features/social/presentation/widgets/specialized_post_cards.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';
import 'dart:ui';

class SocialTabScreen extends ConsumerStatefulWidget {
  const SocialTabScreen({super.key});

  @override
  ConsumerState<SocialTabScreen> createState() => _SocialTabScreenState();
}

class _SocialTabScreenState extends ConsumerState<SocialTabScreen> {
  int _activeCategory = 0; // 0: All, 1: Projects, 2: Shared
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final feedState = ref.watch(socialFeedProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Aesthetic Gradient
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernHeader(context),
              _buildIntelligenceTicker(context),
              _buildCategorySelector(context),
              if (feedState.isLoading && feedState.posts.isEmpty)
                const SliverFillRemaining(
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (feedState.posts.isEmpty)
                _buildPrimeEmptyState(context)
              else
                _buildDynamicFeed(context, feedState),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),

          // Floating Action Area
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: _buildFloatingActionHub(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 140,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text("PULSE HUB",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -1,
            )),
        background: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildIntelligenceTicker(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _tickerCard("LOCAL TREND", "KES/USD 129.5", "+0.2%", Colors.green),
            _tickerCard("MARKET CAP", "\$3.2T Global", "-1.4%", Colors.red),
            _tickerCard("NETWORK", "Stable", "99.9%", Colors.blue),
            _tickerCard("FEES", "Nominal", "0.01%", Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _tickerCard(String label, String value, String delta, Color color) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w900,
                  fontSize: 8,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(width: 8),
              Text(delta,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w900, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            _catChip("DISCOVER", 0),
            _catChip("PROJECTS", 1),
            _catChip("PERSONAL", 2),
            const Spacer(),
            Icon(Icons.tune_rounded,
                size: 18,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _catChip(String label, int index) {
    final theme = Theme.of(context);
    final isSelected = _activeCategory == index;
    return GestureDetector(
      onTap: () => setState(() => _activeCategory = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.dividerColor.withOpacity(0.1)),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1)),
      ),
    );
  }

  Widget _buildDynamicFeed(BuildContext context, SocialFeedState state) {
    final posts = _activeCategory == 0
        ? state.posts
        : _activeCategory == 1
            ? state.posts
                .where((p) => [PostType.fundraiser, PostType.spendingGoal]
                    .contains(p.type))
                .toList()
            : state.posts.where((p) => p.userId == 'current_user').toList();

    if (posts.isEmpty) return _buildPrimeEmptyState(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildAnimatedPost(posts[index], index),
        childCount: posts.length,
      ),
    );
  }

  Widget _buildAnimatedPost(SocialPostEntity post, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: _renderPostCard(post),
      ),
    );
  }

  Widget _renderPostCard(SocialPostEntity post) {
    switch (post.type) {
      case PostType.sharedTransaction:
        return TransactionPostCard(post: post);
      case PostType.spendingGoal:
        return GoalPostCard(post: post);
      case PostType.fundraiser:
        return FundraiserCard(post: post);
      case PostType.poll:
        return PollPostCard(post: post);
      case PostType.marketplace:
        return MarketplaceCard(post: post);
      case PostType.investment:
        return InvestmentCard(post: post);
      default:
        return GenericFinancialCard(post: post);
    }
  }

  Widget _buildPrimeEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bubble_chart_rounded,
                  size: 60, color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            const SizedBox(height: 32),
            const Text("THE FEED IS PURE",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                  "No mock data here. Start the conversation by posting your first financial highlight.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      height: 1.5,
                      fontSize: 13)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _showInnovativePostCreator(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: const Text("INITIALIZE FIRST POST",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionHub(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _hubIcon(Icons.home_filled, true),
              _hubIcon(Icons.explore_outlined, false),
              GestureDetector(
                onTap: () => _showInnovativePostCreator(context),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
              _hubIcon(Icons.chat_bubble_outline_rounded, false),
              _hubIcon(Icons.person_outline_rounded, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hubIcon(IconData icon, bool active) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(icon,
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.3),
          size: 22),
    );
  }

  void _showInnovativePostCreator(BuildContext context) {
    final theme = Theme.of(context);
    final textController = TextEditingController();
    PostType selectedType = PostType.regular;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 32),
              Row(
                children: [
                  const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=current_user')),
                  const SizedBox(width: 16),
                  Text("Pulse Broadcast",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  maxLines: 10,
                  style: const TextStyle(
                      fontSize: 18, height: 1.6, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "What's the financial signal today?",
                    hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.2)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 24),
              const Text("ATTACH SIGNAL",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.blue)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _attachPill(
                        Icons.trending_up_rounded,
                        "Goal",
                        Colors.green,
                        selectedType == PostType.spendingGoal,
                        () => setModalState(
                            () => selectedType = PostType.spendingGoal)),
                    _attachPill(
                        Icons.volunteer_activism_rounded,
                        "Fund",
                        Colors.pink,
                        selectedType == PostType.fundraiser,
                        () => setModalState(
                            () => selectedType = PostType.fundraiser)),
                    _attachPill(
                        Icons.receipt_long_rounded,
                        "Split",
                        Colors.blue,
                        selectedType == PostType.sharedTransaction,
                        () => setModalState(
                            () => selectedType = PostType.sharedTransaction)),
                    _attachPill(
                        Icons.poll_rounded,
                        "Poll",
                        Colors.purple,
                        selectedType == PostType.poll,
                        () =>
                            setModalState(() => selectedType = PostType.poll)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    ref.read(socialFeedProvider.notifier).createPost(
                          content: textController.text,
                          type: selectedType,
                          title: selectedType != PostType.regular
                              ? "Dynamic ${selectedType.name}"
                              : null,
                        );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text("INITIALIZE BROADCAST",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachPill(IconData icon, String label, Color color, bool active,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.white : color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

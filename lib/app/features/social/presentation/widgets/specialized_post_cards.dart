import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/social_post_entity.dart';
import 'package:paypulse/app/features/social/presentation/screens/user_profile_screen.dart';
import 'dart:ui';

class FluidPostLayout extends StatelessWidget {
  final SocialPostEntity post;
  final Widget content;
  final Widget? trailing;
  final VoidCallback? onTap;

  const FluidPostLayout({
    super.key,
    required this.post,
    required this.content,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                              userId: post.userId,
                              userName: post.userName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.surface,
                          backgroundImage: post.userAvatarUrl != null
                              ? NetworkImage(post.userAvatarUrl!)
                              : null,
                          child: post.userAvatarUrl == null
                              ? Text(post.userName[0].toUpperCase(),
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(post.userName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5)),
                              if (post.isVerified) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.verified_rounded,
                                    size: 14, color: theme.colorScheme.primary),
                              ],
                            ],
                          ),
                          Text("Verified Contribution",
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(post.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    )),
                const SizedBox(height: 20),
                content,
                const SizedBox(height: 20),
                _buildThemedActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemedActions(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _themedPill(context, Icons.favorite_rounded, post.likes.toString(),
            Colors.pink),
        const SizedBox(width: 12),
        _themedPill(context, Icons.chat_bubble_rounded,
            post.comments.toString(), theme.colorScheme.primary),
        const Spacer(),
        _themedPill(context, Icons.share_rounded, null,
            theme.colorScheme.onSurface.withOpacity(0.5)),
      ],
    );
  }

  Widget _themedPill(
      BuildContext context, IconData icon, String? label, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: label != null && label != "0"
                  ? color
                  : theme.colorScheme.onSurface.withOpacity(0.3)),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ]
        ],
      ),
    );
  }
}

class TransactionPostCard extends StatelessWidget {
  final SocialPostEntity post;
  const TransactionPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidPostLayout(
      post: post,
      content: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.receipt_rounded, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SPLIT SETTLED",
                      style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1)),
                  Text("PayPulse Network Split",
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Text("\$${post.totalAmount?.toStringAsFixed(2) ?? '0.00'}",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
          ],
        ),
      ),
    );
  }
}

class GoalPostCard extends StatelessWidget {
  final SocialPostEntity post;
  const GoalPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = post.progressPercentage;
    final accentColor = Colors.green;

    return FluidPostLayout(
      post: post,
      content: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.trending_up_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(post.title ?? "Goal in Progress",
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
                ),
                Text("${progress.toStringAsFixed(0)}%",
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.green.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(Colors.green),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FundraiserCard extends StatelessWidget {
  final SocialPostEntity post;
  const FundraiserCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidPostLayout(
      post: post,
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volunteer_activism_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text("COMMUNITY SUPPORT",
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.title ?? "Collective Fundraiser",
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1)),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: post.progressPercentage / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: const Text("Contribute Today",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            )
          ],
        ),
      ),
    );
  }
}

class GenericFinancialCard extends StatelessWidget {
  final SocialPostEntity post;
  const GenericFinancialCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return FluidPostLayout(post: post, content: const SizedBox.shrink());
  }
}

class PollPostCard extends StatelessWidget {
  final SocialPostEntity post;
  const PollPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidPostLayout(
      post: post,
      content: Column(
        children: [
          _pollOption(context, "Option A", 0.65, theme.colorScheme.primary),
          const SizedBox(height: 12),
          _pollOption(context, "Option B", 0.35, theme.colorScheme.secondary),
        ],
      ),
    );
  }

  Widget _pollOption(
      BuildContext context, String label, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${(progress * 100).toInt()}%",
                    style:
                        TextStyle(fontWeight: FontWeight.w900, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MarketplaceCard extends StatelessWidget {
  final SocialPostEntity post;
  const MarketplaceCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidPostLayout(
      post: post,
      content: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage(
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title ?? "Exclusive Item",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              Row(
                children: [
                  Text("\$${post.totalAmount?.toStringAsFixed(2) ?? '99.00'}",
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text("BUY NOW",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvestmentCard extends StatelessWidget {
  final SocialPostEntity post;
  const InvestmentCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidPostLayout(
      post: post,
      content: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded,
                    color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("INVESTMENT SIGNAL",
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.w900)),
                      Text(post.title ?? "Market Opportunity",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
                "AI Analysis suggests a strong bullish trend for the next 48 hours. Risk: Low-Medium.",
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("EXPLORE POSITION",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

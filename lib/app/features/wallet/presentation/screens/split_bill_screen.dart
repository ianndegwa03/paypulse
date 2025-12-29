import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplitBillScreen extends ConsumerWidget {
  const SplitBillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildThemedHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThemedVaultHero(context),
                    const SizedBox(height: 40),
                    Text("ACTIVE SHARED SPACES",
                        style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 20),
                    _buildThemedSpaceCard(context, "Cloud Apartments",
                        "\$1,200", 4, 0.75, Colors.blue),
                    _buildThemedSpaceCard(context, "Bali Retreat 2025",
                        "\$8,400", 6, 0.30, Colors.orange),
                    _buildThemedSpaceCard(context, "Network Subscriptions",
                        "\$25", 3, 1.0, theme.colorScheme.secondary),
                    const SizedBox(height: 40),
                    _buildThemedCreateBtn(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _headerAction(context, Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context)),
          const SizedBox(width: 16),
          Text("Split Bills",
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          const Spacer(),
          _headerAction(context, Icons.history_rounded),
        ],
      ),
    );
  }

  Widget _headerAction(BuildContext context, IconData icon,
      {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildThemedVaultHero(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : const Color(0xFF1C222E),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: (isDark ? theme.colorScheme.primary : Colors.black)
                    .withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 10),
              Text("NETWORK RECEIVABLES",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("\$2,450.00",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2)),
          const SizedBox(height: 48),
          Row(
            children: [
              _themedAvatarStack(context),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("SETTLE ALL",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _themedAvatarStack(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 110,
      height: 40,
      child: Stack(
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 22.0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surface
                      : const Color(0xFF1C222E),
                  shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.dividerColor.withOpacity(0.1),
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?u=$index'),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildThemedSpaceCard(BuildContext context, String title,
      String amount, int members, double progress, Color accentColor) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: theme.shadowColor.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(Icons.people_alt_rounded,
                    color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900)),
                    Text("$members Network Members",
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Icon(Icons.more_horiz_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.2)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$amount Contribution",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w900)),
              Text("${(progress * 100).toInt()}% FUNDED",
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: accentColor.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation(accentColor),
              minHeight: 8,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThemedCreateBtn(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(color: theme.dividerColor.withOpacity(0.1), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text("INITIALIZE SHARED SPACE",
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

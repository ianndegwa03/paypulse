import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class ProfileIconScreen extends ConsumerWidget {
  const ProfileIconScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).currentUser;

    final List<String> availableIcons = [
      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      'https://cdn-icons-png.flaticon.com/512/3135/3135768.png',
      'https://cdn-icons-png.flaticon.com/512/3135/3135789.png',
      'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
      'https://cdn-icons-png.flaticon.com/512/4140/4140047.png',
      'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
      'https://cdn-icons-png.flaticon.com/512/1154/1154448.png',
      'https://cdn-icons-png.flaticon.com/512/1154/1154452.png',
      'https://cdn-icons-png.flaticon.com/512/1154/1154460.png',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Appearance',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Hero(
                    tag: 'profile_pic',
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.primary, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: user?.profileImageUrl != null
                            ? NetworkImage(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? Icon(Icons.person_rounded,
                                size: 60, color: theme.colorScheme.primary)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Choose an Avatar",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pick a style that defines you",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final iconUrl = availableIcons[index];
                  final isSelected = user?.profileImageUrl == iconUrl;

                  return GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      // Update logic would go here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Profile icon updated!"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                      context.pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withOpacity(0.05),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.network(iconUrl),
                    ),
                  );
                },
                childCount: availableIcons.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

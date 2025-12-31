import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/widgets/loading/skeleton_loader.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.read(authNotifierProvider).currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifications")),
        body: const Center(child: Text("Please login to view notifications")),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Notifications",
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: "Mark all as read",
            onPressed: () {
              // TODO: Implement mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All marked as read")));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, __) => SkeletonLoader(
                  height: 80,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(12)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text("No notifications yet",
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.disabledColor)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              final timestamp =
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final isRead = data['read'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: isRead
                        ? theme.cardColor.withOpacity(0.5)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isRead
                        ? null
                        : Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3)),
                    boxShadow: isRead
                        ? null
                        : [
                            BoxShadow(
                                color: theme.shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_active_rounded,
                          size: 20, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(title,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                  DateFormat('MMM d, h:mm a').format(timestamp),
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(color: theme.disabledColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(body,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideX();
            },
          );
        },
      ),
    );
  }
}

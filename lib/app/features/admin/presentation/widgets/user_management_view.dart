import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
import 'package:paypulse/domain/entities/user_entity.dart';
import 'package:paypulse/domain/repositories/user_repository.dart';

class UserManagementView extends ConsumerStatefulWidget {
  const UserManagementView({super.key});

  @override
  ConsumerState<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends ConsumerState<UserManagementView> {
  List<UserEntity> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = GetIt.I<UserRepository>();
    final result = await repo.getLatestUsers();

    if (mounted) {
      result.fold(
        (failure) => setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        }),
        (users) => setState(() {
          _isLoading = false;
          _users = users;
        }),
      );
    }
  }

  Future<void> _toggleBan(UserEntity user) async {
    final repo = GetIt.I<UserRepository>();
    final newBanStatus = !user.isBanned;

    // Optimistic update
    setState(() {
      final index = _users.indexOf(user);
      if (index != -1) {
        // Create a copy with updated ban status
        // Since UserEntity is immutable and we don't have copyWith easily accessible here (UserEntity definition check needed)
        // Wait, I did update UserEntity with copyWith in recent steps.
        // But UserEntity copyWith signature must be checked.
        // It has named parameters.
        _users[index] = _users[index].copyWith(isBanned: newBanStatus);
      }
    });

    final result = await repo.banUser(user.id, newBanStatus);

    result.fold(
      (failure) {
        // Revert on failure
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to update ban status: ${failure.message}')),
          );
          setState(() {
            final index = _users.indexWhere((u) => u.id == user.id);
            if (index != -1) {
              _users[index] = _users[index].copyWith(isBanned: !newBanStatus);
            }
          });
        }
      },
      (_) => null, // Success
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage',
                style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(PulseDesign.m),
          child: Text(
            "User Management",
            style: PulseDesign.getTextTheme(isDark).titleLarge,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: PulseDesign.m),
            itemCount: _users.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: PulseDesign.s),
            itemBuilder: (context, index) {
              final user = _users[index];
              return Container(
                padding: const EdgeInsets.all(PulseDesign.m),
                decoration: BoxDecoration(
                  color:
                      isDark ? PulseDesign.bgDarkCard : PulseDesign.bgLightCard,
                  borderRadius: BorderRadius.circular(PulseDesign.radiusM),
                  border: Border.all(
                    color: user.isBanned
                        ? PulseDesign.error.withOpacity(0.5)
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      child: user.profileImageUrl == null
                          ? Text(
                              user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: PulseDesign.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: PulseDesign.getTextTheme(isDark)
                                .bodyLarge
                                ?.copyWith(
                                  decoration: user.isBanned
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          Text(
                            user.email.value,
                            style: PulseDesign.getTextTheme(isDark)
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        user.isBanned ? Icons.restore_from_trash : Icons.block,
                        color: user.isBanned
                            ? PulseDesign.success
                            : PulseDesign.error,
                      ),
                      tooltip: user.isBanned ? 'Unban User' : 'Ban User',
                      onPressed: () => _toggleBan(user),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/domain/entities/streak_entity.dart';
import 'package:paypulse/domain/entities/badge_entity.dart';

/// State for gamification features
class GamificationState {
  final StreakEntity streak;
  final List<BadgeEntity> unlockedBadges;
  final List<BadgeEntity> allBadges;
  final bool isLoading;
  final String? error;

  const GamificationState({
    this.streak = const StreakEntity(),
    this.unlockedBadges = const [],
    this.allBadges = const [],
    this.isLoading = false,
    this.error,
  });

  GamificationState copyWith({
    StreakEntity? streak,
    List<BadgeEntity>? unlockedBadges,
    List<BadgeEntity>? allBadges,
    bool? isLoading,
    String? error,
  }) {
    return GamificationState(
      streak: streak ?? this.streak,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      allBadges: allBadges ?? this.allBadges,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GamificationNotifier({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(GamificationState(allBadges: Badges.allBadges)) {
    _loadUserData();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> _loadUserData() async {
    if (_uid == null) return;
    state = state.copyWith(isLoading: true);

    try {
      // Load streak
      final streakDoc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('gamification')
          .doc('streak')
          .get();
      if (streakDoc.exists) {
        state = state.copyWith(streak: StreakEntity.fromMap(streakDoc.data()!));
      }

      // Load badges
      final badgesSnap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('badges')
          .get();
      final unlocked =
          badgesSnap.docs.map((d) => BadgeEntity.fromMap(d.data())).toList();
      state = state.copyWith(unlockedBadges: unlocked, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recordSaving(double amount) async {
    if (_uid == null) return;

    final newStreak = state.streak.incrementStreak(amount);
    state = state.copyWith(streak: newStreak);

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('gamification')
        .doc('streak')
        .set(newStreak.toMap());

    // Check for badge unlocks
    await _checkBadgeUnlocks(newStreak, amount);
  }

  Future<void> _checkBadgeUnlocks(StreakEntity streak, double amount) async {
    final List<BadgeEntity> toUnlock = [];

    // First save badge
    if (streak.currentStreak == 1 && !_hasBadge('first_save')) {
      toUnlock.add(Badges.firstSave);
    }

    // Week streak
    if (streak.currentStreak >= 7 && !_hasBadge('week_streak')) {
      toUnlock.add(Badges.weekStreak);
    }

    // Month streak
    if (streak.currentStreak >= 30 && !_hasBadge('month_streak')) {
      toUnlock.add(Badges.monthStreak);
    }

    // $1K club
    if (streak.totalSaved >= 1000 && !_hasBadge('thousand_club')) {
      toUnlock.add(Badges.thousandClub);
    }

    for (final badge in toUnlock) {
      await _unlockBadge(badge);
    }
  }

  bool _hasBadge(String id) {
    return state.unlockedBadges.any((b) => b.id == id);
  }

  Future<void> _unlockBadge(BadgeEntity badge) async {
    if (_uid == null) return;

    final unlocked = BadgeEntity(
      id: badge.id,
      title: badge.title,
      description: badge.description,
      icon: badge.icon,
      rarity: badge.rarity,
      unlockedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('badges')
        .doc(badge.id)
        .set(unlocked.toMap());

    state = state.copyWith(
      unlockedBadges: [...state.unlockedBadges, unlocked],
    );
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>(
  (ref) => GamificationNotifier(),
);

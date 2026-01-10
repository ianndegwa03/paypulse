import 'package:equatable/equatable.dart';

/// Entity representing a user's savings streak
class StreakEntity extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSaveDate;
  final double totalSaved;
  final int savesThisWeek;

  const StreakEntity({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSaveDate,
    this.totalSaved = 0,
    this.savesThisWeek = 0,
  });

  bool get isActiveToday {
    if (lastSaveDate == null) return false;
    final today = DateTime.now();
    return lastSaveDate!.year == today.year &&
        lastSaveDate!.month == today.month &&
        lastSaveDate!.day == today.day;
  }

  bool get canContinueStreak {
    if (lastSaveDate == null) return true;
    final now = DateTime.now();
    final diff = now.difference(lastSaveDate!);
    return diff.inHours < 48; // 48 hour grace period
  }

  StreakEntity incrementStreak(double amount) {
    final now = DateTime.now();
    final newStreak = canContinueStreak ? currentStreak + 1 : 1;
    return StreakEntity(
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      lastSaveDate: now,
      totalSaved: totalSaved + amount,
      savesThisWeek: savesThisWeek + 1,
    );
  }

  factory StreakEntity.fromMap(Map<String, dynamic> map) {
    return StreakEntity(
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastSaveDate: map['lastSaveDate'] != null
          ? DateTime.parse(map['lastSaveDate'])
          : null,
      totalSaved: (map['totalSaved'] ?? 0).toDouble(),
      savesThisWeek: map['savesThisWeek'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastSaveDate': lastSaveDate?.toIso8601String(),
      'totalSaved': totalSaved,
      'savesThisWeek': savesThisWeek,
    };
  }

  @override
  List<Object?> get props =>
      [currentStreak, longestStreak, lastSaveDate, totalSaved, savesThisWeek];
}

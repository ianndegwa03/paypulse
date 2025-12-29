import 'package:equatable/equatable.dart';

/// Entity representing an achievement badge
class BadgeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon; // Icon name or asset path
  final DateTime? unlockedAt;
  final BadgeRarity rarity;
  final int? progress; // For trackable badges (e.g., "Save 10 times")
  final int? target;

  const BadgeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    this.rarity = BadgeRarity.common,
    this.progress,
    this.target,
  });

  bool get isUnlocked => unlockedAt != null;

  double get progressPercent {
    if (target == null || progress == null) return isUnlocked ? 1.0 : 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }

  factory BadgeEntity.fromMap(Map<String, dynamic> map) {
    return BadgeEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'star',
      unlockedAt:
          map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
      rarity: BadgeRarity.values.firstWhere(
        (r) => r.name == map['rarity'],
        orElse: () => BadgeRarity.common,
      ),
      progress: map['progress'],
      target: map['target'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'rarity': rarity.name,
      'progress': progress,
      'target': target,
    };
  }

  @override
  List<Object?> get props =>
      [id, title, description, icon, unlockedAt, rarity, progress, target];
}

enum BadgeRarity { common, rare, epic, legendary }

/// Predefined badges
class Badges {
  static const firstSave = BadgeEntity(
    id: 'first_save',
    title: 'First Step',
    description: 'Made your first savings deposit',
    icon: 'savings',
    rarity: BadgeRarity.common,
  );

  static const weekStreak = BadgeEntity(
    id: 'week_streak',
    title: 'Week Warrior',
    description: '7-day savings streak',
    icon: 'local_fire_department',
    rarity: BadgeRarity.rare,
  );

  static const monthStreak = BadgeEntity(
    id: 'month_streak',
    title: 'Monthly Master',
    description: '30-day savings streak',
    icon: 'emoji_events',
    rarity: BadgeRarity.epic,
  );

  static const thousandClub = BadgeEntity(
    id: 'thousand_club',
    title: '\$1K Club',
    description: 'Saved a total of \$1,000',
    icon: 'monetization_on',
    rarity: BadgeRarity.legendary,
  );

  static const noImpulse = BadgeEntity(
    id: 'no_impulse',
    title: 'Impulse Control',
    description: '30 days without impulse purchases',
    icon: 'psychology',
    rarity: BadgeRarity.epic,
  );

  static List<BadgeEntity> get allBadges => [
        firstSave,
        weekStreak,
        monthStreak,
        thousandClub,
        noImpulse,
      ];
}

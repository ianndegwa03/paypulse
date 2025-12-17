import 'package:paypulse/domain/entities/gamification_profile_entity.dart';

class GamificationProfileModel extends GamificationProfileEntity {
  const GamificationProfileModel({
    required super.userId,
    required super.points,
    required super.level,
    required super.badges,
    required super.progressToNextLevel,
  });

  factory GamificationProfileModel.fromJson(Map<String, dynamic> json) {
    return GamificationProfileModel(
      userId: json['user_id'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      progressToNextLevel:
          (json['progress_to_next_level'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'points': points,
      'level': level,
      'badges': badges,
      'progress_to_next_level': progressToNextLevel,
    };
  }
}

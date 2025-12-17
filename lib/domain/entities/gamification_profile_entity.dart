import 'package:equatable/equatable.dart';

class GamificationProfileEntity extends Equatable {
  final String userId;
  final int points;
  final int level;
  final List<String> badges;
  final double progressToNextLevel;

  const GamificationProfileEntity({
    required this.userId,
    required this.points,
    required this.level,
    required this.badges,
    required this.progressToNextLevel,
  });

  @override
  List<Object?> get props => [
        userId,
        points,
        level,
        badges,
        progressToNextLevel,
      ];
}

import 'package:paypulse/data/models/gamification_profile_model.dart';

abstract class GamificationDataSource {
  Future<GamificationProfileModel> getProfile();
  Future<void> addPoints(int points);
}

class GamificationDataSourceImpl implements GamificationDataSource {
  @override
  Future<GamificationProfileModel> getProfile() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));
    return const GamificationProfileModel(
      userId: 'current_user',
      points: 1250,
      level: 5,
      badges: ['Early Adopter', 'Saver Pro', 'Investor'],
      progressToNextLevel: 0.75,
    );
  }

  @override
  Future<void> addPoints(int points) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

// lib/app/di/modules/engagement_module.dart
@module
abstract class EngagementModule {
  
  // Gamification
  @singleton
  RewardsRepository get rewardsRepository => RewardsRepositoryImpl();
  
  @singleton
  AchievementsRepository get achievementsRepository => AchievementsRepositoryImpl();
  
  @singleton
  StreakRepository get streakRepository => StreakRepositoryImpl();
  
  // Social
  @singleton
  SocialRepository get socialRepository => SocialRepositoryImpl();
  
  @singleton
  ChallengesRepository get challengesRepository => ChallengesRepositoryImpl();
  
  // BLoCs
  @singleton
  RewardsBloc get rewardsBloc => RewardsBloc(
    earnPointsUseCase: getIt<EarnPointsUseCase>(),
    unlockAchievementUseCase: getIt<UnlockAchievementUseCase>(),
  );
  
  @singleton
  SocialBloc get socialBloc => SocialBloc(
    createSocialChallengeUseCase: getIt<CreateSocialChallengeUseCase>(),
    joinGroupSavingsUseCase: getIt<JoinGroupSavingsUseCase>(),
  );
}

// class EngagementMetrics {
//   static const dailyActiveUsers = 'DAU';
//   static const monthlyActiveUsers = 'MAU';
//   static const sessionDuration = 'avg_session_duration';
//   static const featuresUsedPerSession = 'features_per_session';
//   static const socialConnections = 'social_connections';
//   static const challengeParticipation = 'challenge_participation';
//   static const streakMaintenance = 'streak_maintenance_rate';
//   static const notificationEngagement = 'notification_engagement';
// }
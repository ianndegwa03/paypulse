import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/core/errors/exceptions.dart';

class UserPreferenceManager {
  final StorageService _storageService;
  static const String _preferencesKey = 'ai_user_preferences';
  
  UserPreferenceManager({StorageService? storageService})
      : _storageService = storageService ?? StorageServiceImpl();
  
  Future<void> initialize() async {
    await _storageService.init();
  }
  
  Future<Map<String, Map<String, dynamic>>> _getAllPreferences() async {
    final data = await _storageService.getObject(_preferencesKey);
    return Map<String, Map<String, dynamic>>.from(data ?? {});
  }
  
  Future<void> savePreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final allPreferences = await _getAllPreferences();
      allPreferences[userId] = {
        ...allPreferences[userId] ?? {},
        ...preferences,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _storageService.saveObject(_preferencesKey, allPreferences);
    } catch (e) {
      throw AIException(
        message: 'Failed to save preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getPreferences(String userId) async {
    try {
      final allPreferences = await _getAllPreferences();
      return allPreferences[userId] ?? {};
    } catch (e) {
      throw AIException(
        message: 'Failed to get preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> updatePreference({
    required String userId,
    required String key,
    required dynamic value,
  }) async {
    try {
      final preferences = await getPreferences(userId);
      preferences[key] = value;
      preferences['updated_at'] = DateTime.now().toIso8601String();
      
      await savePreferences(userId: userId, preferences: preferences);
    } catch (e) {
      throw AIException(
        message: 'Failed to update preference: $e',
        data: {'userId': userId, 'key': key, 'value': value, 'error': e.toString()},
      );
    }
  }
  
  Future<void> deletePreference({
    required String userId,
    required String key,
  }) async {
    try {
      final preferences = await getPreferences(userId);
      preferences.remove(key);
      preferences['updated_at'] = DateTime.now().toIso8601String();
      
      await savePreferences(userId: userId, preferences: preferences);
    } catch (e) {
      throw AIException(
        message: 'Failed to delete preference: $e',
        data: {'userId': userId, 'key': key, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getAIStylePreferences(String userId) async {
    try {
      final preferences = await getPreferences(userId);
      
      return {
        'tone': preferences['ai_tone'] ?? 'professional',
        'detail_level': preferences['ai_detail_level'] ?? 'moderate',
        'language': preferences['ai_language'] ?? 'English',
        'include_examples': preferences['ai_include_examples'] ?? true,
        'focus_areas': preferences['ai_focus_areas'] ?? ['budgeting', 'investing', 'savings'],
        'risk_tolerance': preferences['risk_tolerance'] ?? 'moderate',
        'financial_goals': preferences['financial_goals'] ?? [],
        'preferred_format': preferences['ai_preferred_format'] ?? 'structured',
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to get AI style preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> updateAIStyle({
    required String userId,
    required String tone,
    required String detailLevel,
    required String language,
    required bool includeExamples,
    required List<String> focusAreas,
  }) async {
    try {
      await updatePreference(userId: userId, key: 'ai_tone', value: tone);
      await updatePreference(userId: userId, key: 'ai_detail_level', value: detailLevel);
      await updatePreference(userId: userId, key: 'ai_language', value: language);
      await updatePreference(userId: userId, key: 'ai_include_examples', value: includeExamples);
      await updatePreference(userId: userId, key: 'ai_focus_areas', value: focusAreas);
    } catch (e) {
      throw AIException(
        message: 'Failed to update AI style: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getLearningPreferences(String userId) async {
    try {
      final preferences = await getPreferences(userId);
      
      return {
        'learning_pace': preferences['learning_pace'] ?? 'moderate',
        'preferred_topics': preferences['preferred_topics'] ?? ['investing', 'budgeting', 'savings'],
        'difficulty_level': preferences['difficulty_level'] ?? 'intermediate',
        'preferred_media': preferences['preferred_media'] ?? ['text', 'examples'],
        'weekly_time_commitment': preferences['weekly_time_commitment'] ?? 2, // hours
        'notification_frequency': preferences['notification_frequency'] ?? 'weekly',
        'quiz_preferences': preferences['quiz_preferences'] ?? {'enabled': true, 'frequency': 'weekly'},
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to get learning preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> updateLearningPreferences({
    required String userId,
    required String learningPace,
    required List<String> preferredTopics,
    required String difficultyLevel,
    required List<String> preferredMedia,
    required int weeklyTimeCommitment,
  }) async {
    try {
      await updatePreference(userId: userId, key: 'learning_pace', value: learningPace);
      await updatePreference(userId: userId, key: 'preferred_topics', value: preferredTopics);
      await updatePreference(userId: userId, key: 'difficulty_level', value: difficultyLevel);
      await updatePreference(userId: userId, key: 'preferred_media', value: preferredMedia);
      await updatePreference(userId: userId, key: 'weekly_time_commitment', value: weeklyTimeCommitment);
    } catch (e) {
      throw AIException(
        message: 'Failed to update learning preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getNotificationPreferences(String userId) async {
    try {
      final preferences = await getPreferences(userId);
      
      return {
        'budget_alerts': preferences['budget_alerts'] ?? true,
        'spending_alerts': preferences['spending_alerts'] ?? true,
        'investment_updates': preferences['investment_updates'] ?? true,
        'bill_reminders': preferences['bill_reminders'] ?? true,
        'goal_progress': preferences['goal_progress'] ?? true,
        'market_updates': preferences['market_updates'] ?? false,
        'educational_content': preferences['educational_content'] ?? true,
        'notification_times': preferences['notification_times'] ?? ['09:00', '18:00'],
        'quiet_hours': preferences['quiet_hours'] ?? {'start': '22:00', 'end': '07:00'},
        'preferred_channels': preferences['preferred_channels'] ?? ['push', 'email'],
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to get notification preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> updateNotificationPreferences({
    required String userId,
    required Map<String, bool> alertTypes,
    required List<String> preferredChannels,
    required List<String> notificationTimes,
    required Map<String, String> quietHours,
  }) async {
    try {
      for (final entry in alertTypes.entries) {
        await updatePreference(userId: userId, key: entry.key, value: entry.value);
      }
      
      await updatePreference(userId: userId, key: 'preferred_channels', value: preferredChannels);
      await updatePreference(userId: userId, key: 'notification_times', value: notificationTimes);
      await updatePreference(userId: userId, key: 'quiet_hours', value: quietHours);
    } catch (e) {
      throw AIException(
        message: 'Failed to update notification preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getFinancialProfile(String userId) async {
    try {
      final preferences = await getPreferences(userId);
      
      return {
        'income_level': preferences['income_level'] ?? 'middle',
        'employment_status': preferences['employment_status'] ?? 'employed',
        'industry': preferences['industry'] ?? 'technology',
        'years_experience': preferences['years_experience'] ?? 5,
        'dependents': preferences['dependents'] ?? 0,
        'home_ownership': preferences['home_ownership'] ?? 'renting',
        'debt_level': preferences['debt_level'] ?? 'moderate',
        'investment_experience': preferences['investment_experience'] ?? 'intermediate',
        'retirement_age': preferences['retirement_age'] ?? 65,
        'financial_knowledge': preferences['financial_knowledge'] ?? 7, // 1-10 scale
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to get financial profile: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> updateFinancialProfile({
    required String userId,
    required String incomeLevel,
    required String employmentStatus,
    required int yearsExperience,
    required int dependents,
    required String homeOwnership,
    required String debtLevel,
    required String investmentExperience,
    required int retirementAge,
    required int financialKnowledge,
  }) async {
    try {
      await updatePreference(userId: userId, key: 'income_level', value: incomeLevel);
      await updatePreference(userId: userId, key: 'employment_status', value: employmentStatus);
      await updatePreference(userId: userId, key: 'years_experience', value: yearsExperience);
      await updatePreference(userId: userId, key: 'dependents', value: dependents);
      await updatePreference(userId: userId, key: 'home_ownership', value: homeOwnership);
      await updatePreference(userId: userId, key: 'debt_level', value: debtLevel);
      await updatePreference(userId: userId, key: 'investment_experience', value: investmentExperience);
      await updatePreference(userId: userId, key: 'retirement_age', value: retirementAge);
      await updatePreference(userId: userId, key: 'financial_knowledge', value: financialKnowledge);
    } catch (e) {
      throw AIException(
        message: 'Failed to update financial profile: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getGoalPreferences(String userId) async {
    try {
      final preferences = await getPreferences(userId);
      
      return {
        'short_term_goals': preferences['short_term_goals'] ?? ['build emergency fund', 'pay off credit card'],
        'medium_term_goals': preferences['medium_term_goals'] ?? ['save for down payment', 'invest in stocks'],
        'long_term_goals': preferences['long_term_goals'] ?? ['retirement savings', 'college fund'],
        'goal_priorities': preferences['goal_priorities'] ?? ['retirement', 'emergency fund', 'debt repayment'],
        'timeline_preferences': preferences['timeline_preferences'] ?? {'short_term': 1, 'medium_term': 5, 'long_term': 20},
        'risk_tolerance_for_goals': preferences['risk_tolerance_for_goals'] ?? 'moderate',
        'automated_savings': preferences['automated_savings'] ?? true,
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to get goal preferences: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
}
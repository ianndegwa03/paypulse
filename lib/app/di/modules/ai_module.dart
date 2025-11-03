// lib/app/di/modules/ai_module.dart
import 'package:injectable/injectable.dart';
import 'package:paypulse/features/ai_assistant/data/repositories/ai_repository_impl.dart';
import 'package:paypulse/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:paypulse/features/expenses_ai/data/repositories/expense_ai_repository_impl.dart';
import 'package:paypulse/features/expenses_ai/domain/repositories/expense_ai_repository.dart';
import 'package:paypulse/core/services/ai/ml_kit_service.dart';
import 'package:paypulse/core/services/ai/receipt_scanner.dart';
import 'package:paypulse/core/services/voice/voice_command_service.dart';

@module
abstract class AiModule {
  
  // AI Services
  @singleton
  @preResolve
  Future<MlKitService> get mlKitService => MlKitService.init();
  
  @singleton
  ReceiptScanner get receiptScanner => ReceiptScanner();
  
  @singleton
  VoiceCommandService get voiceCommandService => VoiceCommandService();
  
  // Repositories
  @singleton
  AiRepository get aiRepository => AiRepositoryImpl();
  
  @singleton
  ExpenseAiRepository get expenseAiRepository => ExpenseAiRepositoryImpl();
}
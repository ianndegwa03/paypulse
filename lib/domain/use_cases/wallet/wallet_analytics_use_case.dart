import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class WalletAnalyticsUseCase {
  final WalletRepository repository;

  WalletAnalyticsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> execute() async {
    return await repository.getWalletAnalytics();
  }
}

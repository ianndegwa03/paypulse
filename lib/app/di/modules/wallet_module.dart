// lib/app/di/modules/wallet_module.dart
import 'package:injectable/injectable.dart';
import 'package:paypulse/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:paypulse/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:paypulse/features/wallet/domain/use_cases/get_wallet_use_case.dart';
import 'package:paypulse/features/wallet/domain/use_cases/transfer_money_use_case.dart';
import 'package:paypulse/features/wallet/domain/use_cases/add_money_use_case.dart';
import 'package:paypulse/features/wallet/presentation/bloc/wallet_bloc.dart';

@module
abstract class WalletModule {
  
  @singleton
  WalletRepository get walletRepository => WalletRepositoryImpl();
  
  @singleton
  GetWalletUseCase get getWalletUseCase => GetWalletUseCase(walletRepository);
  
  @singleton
  TransferMoneyUseCase get transferMoneyUseCase => TransferMoneyUseCase(walletRepository);
  
  @singleton
  AddMoneyUseCase get addMoneyUseCase => AddMoneyUseCase(walletRepository);
  
  @singleton
  WalletBloc get walletBloc => WalletBloc(
    getWalletUseCase: getWalletUseCase,
    transferMoneyUseCase: transferMoneyUseCase,
    addMoneyUseCase: addMoneyUseCase,
  );
}
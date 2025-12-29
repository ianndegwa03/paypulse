import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';
import 'package:paypulse/data/repositories/wallet_repository_impl.dart';
import 'package:paypulse/domain/repositories/shared_space_repository.dart';
import 'package:paypulse/data/repositories/shared_space_repository_impl.dart';
import 'package:paypulse/domain/use_cases/wallet/get_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/add_money_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/transfer_money_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/link_card_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/update_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/create_vault_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/fund_vault_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/create_virtual_card_use_case.dart';
import 'package:paypulse/data/remote/datasources/wallet_datasource.dart';
import 'package:paypulse/data/remote/datasources/wallet_datasource_impl.dart';

class WalletModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // DataSources
    if (!getIt.isRegistered<WalletDataSource>()) {
      getIt.registerLazySingleton<WalletDataSource>(
        () => WalletDataSourceImpl(
          firestore: getIt<FirebaseFirestore>(),
        ),
      );
    }

    // Repositories
    if (!getIt.isRegistered<WalletRepository>()) {
      getIt.registerLazySingleton<WalletRepository>(
        () => WalletRepositoryImpl(
          dataSource: getIt<WalletDataSource>(),
          firebaseAuth: getIt<FirebaseAuth>(),
        ),
      );
    }

    // Use Cases
    if (!getIt.isRegistered<GetWalletUseCase>()) {
      getIt.registerLazySingleton<GetWalletUseCase>(
        () => GetWalletUseCase(getIt<WalletRepository>()),
      );
    }

    if (!getIt.isRegistered<AddMoneyUseCase>()) {
      getIt.registerLazySingleton<AddMoneyUseCase>(
        () => AddMoneyUseCase(getIt<WalletRepository>()),
      );
    }

    if (!getIt.isRegistered<TransferMoneyUseCase>()) {
      getIt.registerLazySingleton<TransferMoneyUseCase>(
        () => TransferMoneyUseCase(getIt<WalletRepository>()),
      );
    }

    if (!getIt.isRegistered<LinkCardUseCase>()) {
      getIt.registerLazySingleton<LinkCardUseCase>(
        () => LinkCardUseCase(getIt<WalletRepository>()),
      );
    }

    if (!getIt.isRegistered<UpdateWalletUseCase>()) {
      getIt.registerLazySingleton<UpdateWalletUseCase>(
        () => UpdateWalletUseCase(getIt<WalletRepository>()),
      );
    }
    getIt.registerLazySingleton(() => CreateVaultUseCase(getIt()));
    getIt.registerLazySingleton(() => FundVaultUseCase(getIt()));
    getIt.registerLazySingleton(() => CreateVirtualCardUseCase(getIt()));

    // Shared Spaces
    if (!getIt.isRegistered<SharedSpaceRepository>()) {
      getIt.registerLazySingleton<SharedSpaceRepository>(
        () => SharedSpaceRepositoryImpl(
          firestore: getIt<FirebaseFirestore>(),
          auth: getIt<FirebaseAuth>(),
        ),
      );
    }
  }
}

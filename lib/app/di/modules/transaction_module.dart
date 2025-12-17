import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/domain/repositories/transaction_repository.dart';
import 'package:paypulse/data/repositories/transaction_repository_impl.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/create_transaction_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transaction_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/categorize_transaction_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/export_transactions_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/filter_transactions_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/search_transactions_use_case.dart';
import 'package:paypulse/data/remote/datasources/transaction_datasource.dart';
import 'package:paypulse/data/remote/datasources/transaction_datasource_impl.dart';

class TransactionModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // DataSources
    if (!getIt.isRegistered<TransactionDataSource>()) {
      getIt.registerLazySingleton<TransactionDataSource>(
        () => TransactionDataSourceImpl(
          firestore: getIt<FirebaseFirestore>(),
        ),
      );
    }

    // Repositories
    if (!getIt.isRegistered<TransactionRepository>()) {
      getIt.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(
          dataSource: getIt<TransactionDataSource>(),
          firebaseAuth: getIt<FirebaseAuth>(),
        ),
      );
    }

    // Use Cases
    if (!getIt.isRegistered<GetTransactionsUseCase>()) {
      getIt.registerLazySingleton<GetTransactionsUseCase>(
        () => GetTransactionsUseCase(getIt<TransactionRepository>()),
      );
    }

    if (!getIt.isRegistered<CreateTransactionUseCase>()) {
      getIt.registerLazySingleton<CreateTransactionUseCase>(
        () => CreateTransactionUseCase(getIt<TransactionRepository>()),
      );
    }

    if (!getIt.isRegistered<GetTransactionUseCase>()) {
      getIt.registerLazySingleton<GetTransactionUseCase>(
        () => GetTransactionUseCase(getIt<TransactionRepository>()),
      );
    }

    if (!getIt.isRegistered<CategorizeTransactionUseCase>()) {
      getIt.registerLazySingleton<CategorizeTransactionUseCase>(
        () => CategorizeTransactionUseCase(getIt<TransactionRepository>()),
      );
    }

    if (!getIt.isRegistered<ExportTransactionsUseCase>()) {
      getIt.registerLazySingleton<ExportTransactionsUseCase>(
        () => ExportTransactionsUseCase(getIt<TransactionRepository>()),
      );
    }

    if (!getIt.isRegistered<FilterTransactionsUseCase>()) {
      getIt.registerLazySingleton<FilterTransactionsUseCase>(
        () => FilterTransactionsUseCase(getIt<TransactionRepository>()),
      );
    }

    if (!getIt.isRegistered<SearchTransactionsUseCase>()) {
      getIt.registerLazySingleton<SearchTransactionsUseCase>(
        () => SearchTransactionsUseCase(getIt<TransactionRepository>()),
      );
    }
  }
}

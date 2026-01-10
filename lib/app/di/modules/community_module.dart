import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/data/remote/datasources/community_datasource.dart';
import 'package:paypulse/data/remote/datasources/community_datasource_impl.dart';
import 'package:paypulse/data/repositories/community_repository_impl.dart';
import 'package:paypulse/domain/repositories/community_repository.dart';

class CommunityModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // DataSource
    if (!getIt.isRegistered<CommunityDataSource>()) {
      getIt.registerLazySingleton<CommunityDataSource>(
        () => CommunityDataSourceImpl(
          firestore: getIt<FirebaseFirestore>(),
        ),
      );
    }

    // Repository
    if (!getIt.isRegistered<CommunityRepository>()) {
      getIt.registerLazySingleton<CommunityRepository>(
        () => CommunityRepositoryImpl(
          dataSource: getIt<CommunityDataSource>(),
        ),
      );
    }
  }
}

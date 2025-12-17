import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/core/network/connectivity/network_info.dart';
import 'package:dartz/dartz.dart';

abstract class BaseRepository {
  final NetworkInfo networkInfo;

  BaseRepository(this.networkInfo);

  Future<Either<Failure, T>> execute<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
    Future<void> Function(T)? cacheResult,
    bool requiresInternet = true,
  }) async {
    try {
      if (requiresInternet) {
        final isConnected = await networkInfo.isConnected;
        if (!isConnected) {
          return Left(NetworkFailure());
        }
      }

      final result = await remoteCall();
      
      if (cacheResult != null) {
        await cacheResult(result);
      }
      
      return Right(result);
    } on ServerException catch (e) {
      // Try to get from local storage
      try {
        final localResult = await localCall();
        return Right(localResult);
      } catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'An unexpected error occurred'));
    }
  }
}
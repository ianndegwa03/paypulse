import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/core/network/connectivity/network_info.dart';
import 'package:paypulse/data/local/datasources/local_datasource.dart';
import 'package:paypulse/data/remote/mappers/user_mapper.dart';
import 'package:paypulse/data/remote/datasources/auth_datasource.dart';
import 'package:paypulse/domain/entities/user_entity.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final UserMapper userMapper;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.userMapper,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }

      final response = await remoteDataSource.login(email, password);
      final userModel = userMapper.responseToModel(response);

      // Cache user data
      await localDataSource.cacheUser(userModel);
      if (response.accessToken != null) {
        await localDataSource.setAuthToken(response.accessToken!);
      }
      if (response.refreshToken != null) {
        await localDataSource.setRefreshToken(response.refreshToken!);
      }

      final userEntity = userMapper.responseToEntity(response);
      return Right(userEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }

      final response = await remoteDataSource.register(
        email,
        password,
        firstName,
        lastName,
      );

      final userModel = userMapper.responseToModel(response);

      // Cache user data
      await localDataSource.cacheUser(userModel);
      if (response.accessToken != null) {
        await localDataSource.setAuthToken(response.accessToken!);
      }
      if (response.refreshToken != null) {
        await localDataSource.setRefreshToken(response.refreshToken!);
      }

      final userEntity = userMapper.responseToEntity(response);
      return Right(userEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear local data
      await localDataSource.clearAllData();

      // Call remote logout if connected
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (_) {
          // Ignore remote logout failures
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(GenericFailure(message: 'Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getAuthToken();
      final user = await localDataSource.getCachedUser();

      if (token == null || user == null) {
        return const Right(false);
      }

      // Optionally validate token with server
      final isConnected = await networkInfo.isConnected;
      if (isConnected) {
        try {
          await remoteDataSource.validateToken(token);
          return const Right(true);
        } catch (_) {
          return const Right(false);
        }
      }

      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'Authentication check failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      if (user == null) {
        return const Left(CacheFailure(message: 'No user found in cache'));
      }

      final userEntity = userMapper.modelToEntity(user);
      return Right(userEntity);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }

      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Forgot password failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
      String token, String newPassword) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }

      await remoteDataSource.resetPassword(token, newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Reset password failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserEntity user) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }

      // Update remote
      // Note: We need to map Entity back to Model for the DataSource
      // Assuming userMapper has entityToModel or we construct a partial map
      // For now, we'll implement a basic update in datasource

      await remoteDataSource.updateProfile(
        firstName: user.firstName,
        lastName: user.lastName,
        phoneNumber: user.phoneNumber?.value, // Fix type mismatch
      );

      // Update local cache
      final currentUser = await localDataSource.getCachedUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          firstName: user.firstName,
          lastName: user.lastName,
          phoneNumber: user.phoneNumber,
        );
        await localDataSource.cacheUser(updatedUser);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enableBiometric(bool enable) async {
    try {
      await localDataSource.setBiometricEnabled(enable);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to set biometric: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }
      // Pass transparency to datasource
      // await remoteDataSource.verifyEmail(token);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to verify email: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPhone(String code) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure());
      }
      // Pass transparency to datasource
      // await remoteDataSource.verifyPhone(code);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to verify phone: $e'));
    }
  }
}

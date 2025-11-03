// lib/app/di/modules/network_module.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:paypulse/core/network/api/base_api_service.dart';
import 'package:paypulse/core/network/api/dio_client.dart';
import 'package:paypulse/core/network/api/interceptors/auth_interceptor.dart';
import 'package:paypulse/core/network/api/interceptors/logging_interceptor.dart';
import 'package:paypulse/core/network/api/interceptors/error_interceptor.dart';
import 'package:paypulse/core/network/connectivity/connectivity_service.dart';

@module
abstract class NetworkModule {
  
  @singleton
  Dio get dio => Dio()
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(seconds: 30)
    ..interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  
  @singleton
  DioClient get dioClient => DioClient(dio);
  
  @singleton
  BaseApiService get baseApiService => BaseApiService(dioClient);
  
  @singleton
  ConnectivityService get connectivityService => ConnectivityService();
}
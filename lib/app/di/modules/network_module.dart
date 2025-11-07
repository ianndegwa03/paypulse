import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// The service locator instance.
final sl = GetIt.instance;

/// Registers the network module.
///
/// This function is responsible for setting up and registering the `Dio` client
/// for making network requests. It configures the base URL, connect timeout,
/// and receive timeout for the client.
void registerNetworkModule() {
  sl.registerLazySingleton<Dio>(
    () {
      final dio = Dio();
      dio.options.baseUrl = 'https://api.paypulse.com'; // TODO: Replace with your API base URL
      dio.options.connectTimeout = const Duration(milliseconds: 15000);
      dio.options.receiveTimeout = const Duration(milliseconds: 15000);
      // Add interceptors for logging, authentication, etc.
      dio.interceptors.add(LogInterceptor(responseBody: true));
      return dio;
    },
  );
}

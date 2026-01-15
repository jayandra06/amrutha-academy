import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../../services/api_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies(AppEnvironment env) async {
  // Register environment
  getIt.registerSingleton<AppEnvironment>(env);

  // Register Dio
  getIt.registerSingleton<Dio>(
    Dio(BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    )),
  );

  // Register API Service
  getIt.registerSingleton<ApiService>(ApiService(getIt<Dio>()));
}





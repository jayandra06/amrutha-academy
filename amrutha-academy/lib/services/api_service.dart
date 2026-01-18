import 'package:dio/dio.dart';
import '../core/config/firebase_config.dart';
import '../data/models/api_response.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Add auth token to requests
  Future<void> _addAuthToken() async {
    try {
      final user = FirebaseConfig.auth?.currentUser;
      if (user != null) {
        // Try to get fresh token, but don't force refresh if it fails
        String? token;
        try {
          token = await user.getIdToken(true);
        } catch (e) {
          // If force refresh fails, try without forcing
          print('⚠️ API Service - Force token refresh failed, trying regular token: $e');
          token = await user.getIdToken();
        }
        
        if (token != null && token.isNotEmpty) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        } else {
          _dio.options.headers.remove('Authorization');
          print('⚠️ API Service - Token is null or empty');
        }
      } else {
        _dio.options.headers.remove('Authorization');
        print('⚠️ API Service - No current user');
      }
    } catch (e) {
      // If getting token fails, remove auth header but don't throw
      _dio.options.headers.remove('Authorization');
      print('⚠️ API Service - Failed to add auth token: $e');
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      await _addAuthToken();
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse.fromJson(response.data, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      await _addAuthToken();
      final response = await _dio.post(path, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      await _addAuthToken();
      final response = await _dio.put(path, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic) fromJson,
  }) async {
    try {
      await _addAuthToken();
      final response = await _dio.delete(path);
      return ApiResponse.fromJson(response.data, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        // Server responded with error
        final errorMessage = error.response?.data['error'] ?? 
                            error.response?.data['message'] ?? 
                            'Server error: ${error.response?.statusCode}';
        return Exception(errorMessage);
      } else if (error.type == DioExceptionType.connectionTimeout ||
                 error.type == DioExceptionType.sendTimeout ||
                 error.type == DioExceptionType.receiveTimeout) {
        return Exception('Connection timeout. Please check your internet connection and ensure the backend server is running.');
      } else if (error.type == DioExceptionType.connectionError) {
        return Exception('Cannot connect to server. Make sure the backend is running at ${_dio.options.baseUrl}. For physical devices, use your computer\'s IP address instead of 10.0.2.2');
      } else {
        return Exception('Network error: ${error.message ?? "Please check your connection"}');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}


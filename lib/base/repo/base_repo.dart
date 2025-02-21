import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_template/base/helper/duration_provider.dart';
import 'package:flutter_bloc_template/base/helper/log.dart';

import '../../data/data_source/remote/dto/api_response.dart';
import '../exception/app_exception.dart';
import '../helper/message_parser.dart';
import '../helper/result.dart';

typedef ResponseToModelMapper<D, E> = E Function(D? resp);
typedef EntityToModelMapper<E, M> = M Function(E? entity);
typedef SaveResult<E> = Function(E entity);

abstract class BaseRepository {
  /// Handles API calls and maps the response to the required model.
  Future<Result<E>> handleApiCall<D, E>(
    Future<ApiResponse<D>> call, {
    required ResponseToModelMapper<ApiResponse<D>, E> mapper,
    SaveResult<E>? saveResult,
  }) async {
    try {
      final response = await call;
      if (response.isSuccess()) {
        // saveResult?.call(response.data);
        final value = await compute(mapper, response);
        if (saveResult != null) {
          await Future.delayed(const LongDuration(), () {
            saveResult.call(value);
          });
        }
        return Result.ok(value);
      }
      return _handleApiError(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      CoreLog.e(e);
      throw AppException('Something went wrong.', type: AppExceptionType.unknown);
    }
  }

  @protected
  Result<E> _handleApiError<E>(ApiResponse response) {
    final message = response.message?.firstOrNull ?? '';
    return Result.failure(AppException(message, type: AppExceptionType.unknown));
  }

  @protected
  AppException _handleDioException(DioException e) {
    var message = [e.type.name];

    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        message = MessageParser.parse(data['message']);
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AppException('Connection timeout.', type: AppExceptionType.connectionTimeout);
      case DioExceptionType.sendTimeout:
        return AppException('Send timeout.', type: AppExceptionType.sendTimeout);
      case DioExceptionType.receiveTimeout:
        return AppException('Receive timeout.', type: AppExceptionType.receiveTimeout);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == HttpStatus.unauthorized || statusCode == HttpStatus.forbidden) {
          return AppException(message.firstOrNull ?? '', type: AppExceptionType.unauthorized);
        }
        return AppException('Server error: ${e.response?.statusCode}',
            statusCode: e.response?.statusCode, type: AppExceptionType.badResponse);
      case DioExceptionType.cancel:
        return AppException('Request was canceled.', type: AppExceptionType.cancel);
      case DioExceptionType.connectionError:
        return AppException('No internet connection.', type: AppExceptionType.connectionError);
      case DioExceptionType.unknown:
        return AppException(message.first, type: AppExceptionType.unknown);
      default:
        return AppException('Something went wrong.', type: AppExceptionType.other);
    }
  }

  /// Handles local storage operations and maps the result to the required model.
  Future<Result<M>> handleStorageCall<E, M>(
    Future<E?> call, {
    required EntityToModelMapper<E, M> mapper,
  }) async {
    try {
      final response = await call;
      if (response == null) {
        CoreLog.e("No data found in the database response");
        return Result.failure(AppException("No data found in the database response", type: AppExceptionType.unknown));
      }
      CoreLog.d("Database operation completed successfully: $response");
      return Result.ok(mapper.call(response));
    } catch (exception) {
      CoreLog.e("Database operation failed: $exception");
      return Result.failure(AppException("Database operation failed: $exception", type: AppExceptionType.unknown));
    }
  }
}

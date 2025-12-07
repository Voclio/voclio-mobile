import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An error occurred';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        errorMessage = _handleResponseError(err.response);
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;

      default:
        errorMessage = 'Unexpected error occurred';
    }

    developer.log(
      'API Error: $errorMessage',
      name: 'ErrorInterceptor',
      error: err,
    );

    return handler.next(err);
  }

  String _handleResponseError(Response? response) {
    if (response == null) return 'No response from server';

    switch (response.statusCode) {
      case 400:
        return response.data['message'] ?? 'Bad request';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found';
      case 422:
        return response.data['message'] ?? 'Validation error';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      default:
        return response.data['message'] ?? 'Server error occurred';
    }
  }
}

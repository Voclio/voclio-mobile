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
            'Connection timeout. Please check your internet connection and try again.';
        break;

      case DioExceptionType.badResponse:
        errorMessage = _handleResponseError(err.response);
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;

      case DioExceptionType.connectionError:
        errorMessage =
            'No internet connection. Please check your network and try again.';
        break;

      default:
        errorMessage = 'Unexpected error occurred. Please try again.';
    }

    developer.log(
      'API Error extracted: $errorMessage',
      name: 'ErrorInterceptor',
    );

    // Modify the error to carry our clean message
    final modifiedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage, // Important: Store the clean message in .error
      message: errorMessage, // And in .message
    );

    return handler.next(modifiedError);
  }

  String _handleResponseError(Response? response) {
    if (response == null) return 'No response from server';

    final data = response.data;
    String? message;

    if (data is Map) {
      if (data['error'] is Map && data['error']['message'] != null) {
        message = data['error']['message'].toString();
      } else if (data['message'] != null) {
        message = data['message'].toString();
      } else if (data['error'] is String) {
        message = data['error'];
      }
    }

    switch (response.statusCode) {
      case 400:
        return message ?? 'Bad request';
      case 401:
        return 'Authentication failed. Please try again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found';
      case 409:
        return message ?? 'Email already registered';
      case 422:
        return message ?? 'Validation error';
      case 500:
        return 'Internal server error';
      default:
        return message ?? 'Server error occurred';
    }
  }
}

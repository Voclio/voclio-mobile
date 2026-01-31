import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '🌐 REQUEST[${options.method}] => URL: ${options.uri}',
      name: 'API',
    );
    developer.log('Headers: ${options.headers}', name: 'API');
    developer.log('Query Parameters: ${options.queryParameters}', name: 'API');
    if (options.data != null) {
      developer.log('Data: ${options.data}', name: 'API');
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      name: 'API',
    );
    developer.log('Data: ${response.data}', name: 'API');

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '❌ ERROR[${err.response?.statusCode}] => URL: ${err.requestOptions.uri}',
      name: 'API',
      error: err,
    );
    developer.log('Error Message: ${err.message}', name: 'API');
    if (err.response?.data != null) {
      developer.log('Error Data: ${err.response?.data}', name: 'API');
    }

    return super.onError(err, handler);
  }
}

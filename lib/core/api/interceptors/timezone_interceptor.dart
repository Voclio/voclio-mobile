import 'package:dio/dio.dart';

/// Sends the device timezone offset so the API can interpret due dates correctly.
class TimezoneInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final offsetMinutes = -DateTime.now().timeZoneOffset.inMinutes;
    options.headers['X-Timezone-Offset'] = offsetMinutes.toString();
    handler.next(options);
  }
}

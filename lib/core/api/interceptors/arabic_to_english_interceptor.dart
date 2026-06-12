import 'package:dio/dio.dart';

import '../localization/api_arabic_to_english.dart';

/// Converts Arabic strings in API payloads to English before they reach the app.
class ArabicToEnglishInterceptor extends Interceptor {
  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final data = response.data;
    if (data != null) {
      response.data = await ApiArabicToEnglish.localizeJson(data);
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final data = err.response?.data;
    if (data != null) {
      err.response!.data = await ApiArabicToEnglish.localizeJson(data);
    }
    handler.next(err);
  }
}

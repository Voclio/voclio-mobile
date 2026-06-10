/// Global runtime flags for the app.
class AppFlags {
  AppFlags._();

  /// When false, all [ApiClient] calls are served locally — no network requests.
  static const bool useRemoteApi = true;
}

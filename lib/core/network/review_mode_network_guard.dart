import 'package:dio/dio.dart';

/// Mutable process-local kill switch shared by every Production Dio client.
/// Local Review mode flips this before its UI becomes active, so even a stale
/// repository reference cannot reach a merchant API or asset endpoint.
final class ReviewModeNetworkGuard {
  bool _blocked = false;

  bool get blocked => _blocked;

  void setBlocked(bool value) => _blocked = value;
}

final class ReviewModeNetworkInterceptor extends Interceptor {
  ReviewModeNetworkInterceptor(this._guard);

  final ReviewModeNetworkGuard _guard;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_guard.blocked) {
      handler.next(options);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        error: const ReviewModeNetworkBlocked(),
      ),
    );
  }
}

final class ReviewModeNetworkBlocked implements Exception {
  const ReviewModeNetworkBlocked();

  @override
  String toString() => 'Network access is disabled in local Review mode.';
}

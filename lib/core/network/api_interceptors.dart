import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:my_mentor/app/app_routes.dart';
import 'package:my_mentor/core/network/endpoints.dart';
import 'package:my_mentor/core/network/token_refresh_service.dart';
import 'package:my_mentor/core/services/navigation_service.dart';
import 'package:my_mentor/di/locator.dart';
import '../services/token_service.dart';

final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i(
      "--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}",
    );
    _logger.d("Headers: ${options.headers}");
    _logger.d("QueryParameters: ${options.queryParameters}");

    if (options.data != null) {
      if (options.data is FormData) {
        _logger.d(
          "Body: FormData fields: ${options.data.fields}, files: ${options.data.files.map((e) => e.value.filename)}",
        );
      } else {
        try {
          _logger.d("Body: ${jsonEncode(options.data)}");
        } catch (e) {
          _logger.w("Body: (Not JSON encodable) ${options.data.toString()}");
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      "<-- ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.baseUrl}${response.requestOptions.path}",
    );
    try {
      _logger.d("Response: ${jsonEncode(response.data)}");
    } catch (e) {
      _logger.w("Response: (Not JSON encodable) ${response.data.toString()}");
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      "<-- Error ${err.response?.statusCode} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.baseUrl}${err.requestOptions.path}",
      error: err.error,
      stackTrace: err.stackTrace,
    );
    if (err.response?.data != null) {
      try {
        _logger.e("Error Data: ${jsonEncode(err.response?.data)}");
      } catch (e) {
        _logger.w(
          "Error Data: (Not JSON encodable) ${err.response?.data.toString()}",
        );
      }
    }
    super.onError(err, handler);
  }
}

class AuthInterceptor extends QueuedInterceptor {
  final TokenService _tokenService;
  final TokenRefreshService _tokenRefreshService;
  final NavigationService _navigationService;
  Dio? dio;

  AuthInterceptor({
    TokenService? tokenService,
    TokenRefreshService? tokenRefreshService,
    NavigationService? navigationService,
    this.dio,
  }) : _tokenService = tokenService ?? TokenService(),
       _tokenRefreshService = tokenRefreshService ?? TokenRefreshService(),
       _navigationService =
           navigationService ??
           (getIt.isRegistered<NavigationService>()
               ? getIt<NavigationService>()
               : NavigationService());

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra["skipAuth"] == true) {
      return handler.next(options);
    }

    if (options.headers['Authorization'] == null ||
        (options.headers['Authorization'] as String).isEmpty) {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final isRefreshEndpoint = err.requestOptions.path.contains(
      Endpoints.refreshToken,
    );
    final isRetry = err.requestOptions.extra['isRetry'] == true;
    final skipAuth = err.requestOptions.extra['skipAuth'] == true;

    if (!is401 || isRefreshEndpoint || isRetry || skipAuth) {
      return handler.next(err);
    }

    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      await _tokenService.clearTokens();
      try {
        // await _navigationService.pushNamedAndRemoveUntil(
        //   AppRoutes.accountCreation,
        // );
      } catch (_) {}
      return handler.next(err);
    }

    // Attempt token refresh via TokenRefreshService
    final newAccessToken = await _tokenRefreshService.refreshToken();

    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      try {
        final client = dio ?? Dio();
        final requestOptions = err.requestOptions;

        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        requestOptions.extra['isRetry'] = true;

        final response = await client.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        return handler.next(retryError);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}

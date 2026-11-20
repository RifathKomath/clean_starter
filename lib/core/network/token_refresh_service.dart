import 'dart:async';
import 'package:dio/dio.dart';
import '../../app/app_routes.dart';
import '../../di/locator.dart';
import '../../env/flavor_config.dart';
import '../services/navigation_service.dart';
import '../services/token_service.dart';
import 'endpoints.dart';

/// Network service responsible for refreshing expired JWT tokens.
///
/// Features:
/// - POST to [Endpoints.refreshToken] (`auth/token/refresh/`) with `{"refresh": "<jwt>"}`.
/// - Persists updated `access` and `refresh` tokens into [TokenService] (backed by SharedPreferences).
/// - Refreshes silently; no loader is shown.
/// - Synchronizes concurrent 401s via [Completer] so only 1 refresh network call is dispatched.
/// - Redirects to [AppRoutes.accountCreation] only when refresh itself fails or refresh token is invalid.
class TokenRefreshService {
  final TokenService _tokenService;
  final NavigationService _navigationService;
  final Dio _dio;
  final String? _baseUrl;

  Completer<String?>? _refreshCompleter;

  TokenRefreshService({
    String? baseUrl,
    Dio? dio,
    TokenService? tokenService,
    NavigationService? navigationService,
  }) : _baseUrl = baseUrl,
       _dio = dio ?? Dio(),
       _tokenService = tokenService ?? TokenService(),
       _navigationService =
           navigationService ??
           (getIt.isRegistered<NavigationService>()
               ? getIt<NavigationService>()
               : NavigationService());

  String get baseUrl {
    if (_baseUrl != null) return _baseUrl;
    try {
      return FlavorConfig.instance.values.baseUrl;
    } catch (_) {
      return '';
    }
  }

  /// Whether a token refresh call is currently in flight.
  bool get isRefreshing => _refreshCompleter != null;

  /// Refreshes the access token using the stored refresh token.
  ///
  /// Returns the newly acquired access token on success, or `null` if refresh failed.
  Future<String?> refreshToken() async {
    // If a refresh is already in progress, await the existing request.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final currentRefreshToken = await _tokenService.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.trim().isEmpty) {
        await _handleSessionExpired();
        _refreshCompleter?.complete(null);
        return null;
      }

      final url = baseUrl.endsWith('/')
          ? '$baseUrl${Endpoints.refreshToken}'
          : '$baseUrl/${Endpoints.refreshToken}';

      final response = await _dio.post(
        url,
        data: {'refresh': currentRefreshToken},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data != null) {
        final Map<String, dynamic> body;
        if (response.data is Map<String, dynamic>) {
          body = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          body = Map<String, dynamic>.from(response.data as Map);
        } else {
          body = {};
        }

        final data = body['data'];
        String? newAccessToken;
        String? newRefreshToken;

        if (data is Map) {
          newAccessToken = data['access']?.toString();
          newRefreshToken = data['refresh']?.toString();
        } else {
          newAccessToken = body['access']?.toString();
          newRefreshToken = body['refresh']?.toString();
        }

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Update tokens in SharedPreferences via TokenService
          await _tokenService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? currentRefreshToken,
          );

          _refreshCompleter?.complete(newAccessToken);
          return newAccessToken;
        }
      }

      // If response body status is not valid or access token missing
      await _handleSessionExpired();
      _refreshCompleter?.complete(null);
      return null;
    } on DioException catch (dioError) {
      // Refresh request failed (e.g. 401 or 400 from backend)
      final status = dioError.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        await _handleSessionExpired();
      }
      _refreshCompleter?.complete(null);
      return null;
    } catch (_) {
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Clears stored authentication tokens and redirects the user to the login screen.
  Future<void> _handleSessionExpired() async {
    await _tokenService.clearTokens();
    try {
      // await _navigationService.pushNamedAndRemoveUntil(
      //   AppRoutes.accountCreation,
      // );
    } catch (_) {
      // In tests or if navigation service is unattached, ignore
    }
  }
}

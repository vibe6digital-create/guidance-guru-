import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL', fallback: 'https://api.guidanceguru.ai/v1'),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final retryResponse = await _retryRequest(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        // Only log in debug mode - production should not log
        assert(() {
          // ignore: avoid_print
          print(obj);
          return true;
        }());
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${_dio.options.baseUrl}/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _storage.write(
          key: _tokenKey,
          value: response.data['token'] as String,
        );
        if (response.data['refreshToken'] != null) {
          await _storage.write(
            key: _refreshTokenKey,
            value: response.data['refreshToken'] as String,
          );
        }
        return true;
      }
    } catch (_) {
      // Refresh failed - user needs to login again
    }
    return false;
  }

  Future<Response> _retryRequest(RequestOptions options) async {
    final token = await _storage.read(key: _tokenKey);
    options.headers['Authorization'] = 'Bearer $token';
    return _dio.fetch(options);
  }

  // Token management
  Future<void> saveTokens({
    required String token,
    String? refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // HTTP methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete(path, queryParameters: queryParameters);
  }
}

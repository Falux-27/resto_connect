import 'package:dio/dio.dart';
import '../constants/app_colors.dart';
import 'api_endpoints.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  late final Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ─── Intercepteur de logs (dev uniquement) ──────────────
    _dio.interceptors.add(LogInterceptor(
      requestBody:  true,
      responseBody: true,
      error:        true,
      logPrint: (obj) => print('🌐 [API] $obj'),
    ));

    // ─── Intercepteur de retry basique ──────────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          // Retry une seule fois sur timeout
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            try {
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (_) {}
          }
          handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
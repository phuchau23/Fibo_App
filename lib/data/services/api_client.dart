import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_app/core/config/env_config.dart';
import 'package:swp_app/core/constants/api.constants.dart';
import 'package:swp_app/core/error/exceptions.dart';
import 'package:swp_app/core/services/session_provider.dart';

class ApiClient {
  final Dio _dio;
  Dio get dio => _dio;

  ApiClient._(this._dio);

  factory ApiClient(Ref ref) {
    final session = ref.read(sessionServiceProvider);
    final baseUrl = EnvConfig.apiBaseUrl;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Inject token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await session.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    return ApiClient._(dio);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Map DioException -> AppException cụ thể (KHÔNG ép kiểu e.error)
  AppException _mapDio(DioException e) {
    final status = e.response?.statusCode ?? 0;
    // Ưu tiên message “có nghĩa”; fallback hợp lý
    final msg =
        e.response?.data is Map && (e.response!.data['message'] is String)
        ? (e.response!.data['message'] as String)
        : (e.message ?? e.response?.statusMessage ?? 'Network error');

    // Unauthorized/Forbidden
    if (status == 401 || status == 403) {
      return AuthException('Unauthorized', '$status');
    }
    // 5xx
    if (status >= 500) {
      return ServerException(msg, '$status');
    }
    // Các lỗi kết nối/timeout
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection error', '$status');
    }
    // 4xx còn lại: Validation/BadRequest...
    if (status >= 400 && status < 500) {
      return ValidationException(msg, '$status');
    }
    // Mặc định: xem như lỗi mạng
    return NetworkException(msg, status == 0 ? null : '$status');
  }

  // ────────────────────────────────────────────────────────────────────────────
  /// POST form-data (multipart/form-data) – vẫn giữ hàm tiện lợi này
  Future<Response<T>> postForm<T>(
    String path,
    Map<String, dynamic> data,
  ) async {
    final form = FormData.fromMap(data);

    // (log dev nếu muốn)
    // ignore: avoid_print
    print('➡️ POST ${_dio.options.baseUrl}$path');
    for (final f in form.fields) {
      // ignore: avoid_print
      print('   • ${f.key} = ${f.value}');
    }

    try {
      final res = await _dio.post<T>(
        path,
        data: form,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
      // ignore: avoid_print
      print('⬅️ [${res.statusCode}] ${res.requestOptions.uri}');
      // ignore: avoid_print
      print('   Response: ${res.data}');
      return res;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<T>> uploadFile<T>(
    String path,
    FormData formData, {
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        options:
            options ?? Options(contentType: ApiEndpoints.multipartContentType),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<dynamic>> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }
}

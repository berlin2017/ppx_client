// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:ppx_client/core/utils/app_logger.dart';
import '../constants/AppConstants.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: 'application/json; charset=utf-8',
      ),
    );

    // 添加日志拦截器 (开发环境)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.log('请求 URL: ${options.uri}');
          AppLogger.log('请求头: ${options.headers}');
          AppLogger.log('请求数据: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.log('响应状态码: ${response.statusCode}');
          AppLogger.log('响应数据: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.error('请求错误: ${e.message}');
          AppLogger.error('错误响应: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
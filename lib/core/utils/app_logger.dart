// lib/core/utils/app_logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      // 不显示方法调用栈
      errorMethodCount: 5,
      // 显示错误方法调用栈
      lineLength: 120,
      // 每行长度
      colors: true,
      // 启用颜色
      printEmojis: true,
      // 打印表情
      printTime: true, // 打印时间
    ),
  );

  static void log(dynamic message) {
    _logger.d(message);
  }

  static void info(dynamic message) {
    _logger.i(message);
  }

  static void warn(dynamic message) {
    _logger.w(message);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
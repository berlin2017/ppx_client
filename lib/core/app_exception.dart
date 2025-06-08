// lib/core/app_exception.dart
class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, '数据获取错误: ');
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, '无效请求: ');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, '未授权: ');
}

class InvalidInputException extends AppException {
  InvalidInputException(String message) : super(message, '无效输入: ');
}
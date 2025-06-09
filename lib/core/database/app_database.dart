// lib/core/database/app_database.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ppx_client/core/utils/app_logger.dart';

import '../../data/models/user_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppDatabase {
  static Future<void> init() async {
    try {
      if (kIsWeb) {
        // 对于 Web 平台，直接初始化，不需要路径
        await Hive.initFlutter();
      } else {
        // 对于其他平台 (如移动端)
        final appDocumentDir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(appDocumentDir.path);
      }

      // 注册Adapter (如果你的模型需要存储到Hive)
      Hive.registerAdapter(UserModelAdapter()); // 为 UserModel 注册适配器

      // 打开 Box
      await Hive.openBox<UserModel>('userBox'); // 打开存储 UserModel 的 Box
      AppLogger.log('Hive 数据库初始化成功');
    } catch (e) {
      AppLogger.error('Hive 数据库初始化失败: $e');
      rethrow;
    }
  }

  static Future<void> close() async {
    await Hive.close();
    AppLogger.log('Hive 数据库已关闭');
  }
}
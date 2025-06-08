// lib/data/datasources/user_local_datasource.dart

import 'package:hive/hive.dart';

import '../../core/database/box_names.dart';
import '../../core/utils/app_logger.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<List<UserModel>> getUsers();

  Future<void> saveUsers(List<UserModel> users);

  Future<void> clearUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Box<UserModel> _userBox;

  UserLocalDataSourceImpl() : _userBox = Hive.box<UserModel>(BoxNames.userBox);

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      return _userBox.values.toList();
    } catch (e) {
      AppLogger.error('从本地获取用户失败: $e');
      return [];
    }
  }

  @override
  Future<void> saveUsers(List<UserModel> users) async {
    try {
      await _userBox.clear(); // 清除旧数据
      await _userBox.addAll(users);
      AppLogger.log('用户数据已保存到本地');
    } catch (e) {
      AppLogger.error('保存用户到本地失败: $e');
    }
  }

  @override
  Future<void> clearUsers() async {
    try {
      await _userBox.clear();
      AppLogger.log('本地用户数据已清除');
    } catch (e) {
      AppLogger.error('清除本地用户数据失败: $e');
    }
  }
}
// lib/core/services/auth_service.dart
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:ppx_client/core/utils/app_logger.dart';

import '../../data/models/user_model.dart';
import 'dio_client.dart'; // For random ID

class AuthService {
  static const String _userBoxName = 'userBox'; // 与 AppDatabase 中一致

  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<Box<UserModel>> _getUserBox() async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      return await Hive.openBox<UserModel>(_userBoxName);
    }
    return Hive.box<UserModel>(_userBoxName);
  }

  // 模拟登录
  Future<UserModel?> login(String email, String password) async {
    final data = {'email': email, 'password': password};
    final response = await _dioClient.dio.post("/login", data: data);
    if (response.data != null) {
      final user = UserModel.fromJson(response.data);
      await saveUser(user); // 保存带 token 的用户信息
      return user;
    }

    return null; // 登录失败
  }

  // 模拟注册
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = {'name': name, 'email': email, 'password': password};
    final response = await _dioClient.dio.post("/users", data: data);
    if (response.statusCode == 417) {
      throw Exception("邮箱已被注册"); // 或者返回特定的错误对象
    }

    if (response.data != null) {
      final user = UserModel.fromJson(response.data);
      await saveUser(user); // 保存带 token 的用户信息
      return user;
    }
    return null; // 注册失败
  }

  // 保存用户信息到 Hive (通常在登录/注册成功后调用)
  Future<void> saveUser(UserModel user) async {
    final box = await _getUserBox();
    // 使用用户的 id 或 email 作为 key，如果它们是唯一的
    // 或者简单地 add，然后通过其他方式查询
    // 如果 UserModel 继承了 HiveObject, Hive 会自动管理 key
    // 但为了能通过 email 查询，我们可以用 email 做 key 或者 box.put(user.id, user)
    // 这里我们假设 email 是唯一的，并用它来查找或更新
    // 或者，如果我们只存储一个当前登录用户，可以用一个固定的 key
    await box.put('currentUser', user); // 使用固定 key 'currentUser' 存储当前用户
    AppLogger.info("User saved: ${user.name}");
  }

  // 获取当前登录的用户信息
  Future<UserModel?> getCurrentUser() async {
    final box = await _getUserBox();
    return box.get('currentUser');
  }

  // 登出
  Future<void> logout() async {
    final box = await _getUserBox();
    await box.delete('currentUser'); // 删除当前用户信息
    // 实际应用中可能还需要通知后端 token 失效等
    AppLogger.info("User logged out");
  }
}

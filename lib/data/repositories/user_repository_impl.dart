// lib/data/repositories/user_repository_impl.dart

import 'package:ppx_client/core/utils/app_logger.dart';
import 'package:ppx_client/data/repositories/user_repository.dart';

import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;

  UserRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      // 先尝试从远程获取数据
      final remoteUsers = await _remoteDataSource.getUsers();
      // 如果获取成功，则保存到本地并返回
      await _localDataSource.saveUsers(remoteUsers);
      AppLogger.log('从远程获取用户成功并已缓存');
      return remoteUsers;
    } catch (e) {
      AppLogger.error('从远程获取用户失败，尝试从本地获取: $e');
      // 如果远程获取失败，则尝试从本地获取
      final localUsers = await _localDataSource.getUsers();
      if (localUsers.isNotEmpty) {
        AppLogger.log('从本地获取用户成功');
        return localUsers;
      } else {
        AppLogger.error('本地无缓存用户数据');
        rethrow; // 本地也没有数据，则抛出异常
      }
    }
  }
}
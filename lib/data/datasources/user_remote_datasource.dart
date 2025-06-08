// lib/data/datasources/user_remote_datasource.dart

import '../../core/network/api_service.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiService _apiService;

  UserRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<UserModel>> getUsers() async {
    return await _apiService.getUsers();
  }
}
// lib/data/repositories/user_repository.dart

import '../models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getUsers();
}
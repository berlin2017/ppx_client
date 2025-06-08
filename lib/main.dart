// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ppx_client/core/network/auth_service.dart';
import 'package:ppx_client/data/repositories/user_repository.dart';
import 'package:ppx_client/presentation/viewmodels/user_list_viewmodel.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/network/api_service.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/user_local_datasource.dart';
import 'data/datasources/user_remote_datasource.dart';
import 'data/repositories/user_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.init(); // 初始化 Hive 数据库

  // 依赖注入 (使用 Provider)
  final dioClient = DioClient();
  final apiService = ApiService(dioClient);
  final authService = AuthService(dioClient);
  final userRemoteDataSource = UserRemoteDataSourceImpl(apiService);
  final userLocalDataSource = UserLocalDataSourceImpl();
  final userRepository = UserRepositoryImpl(
    userRemoteDataSource,
    userLocalDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<DioClient>(create: (_) => dioClient),
        Provider<ApiService>(create: (_) => apiService),
        Provider<AuthService>(create: (_) => authService),
        Provider<UserRemoteDataSource>(create: (_) => userRemoteDataSource),
        Provider<UserLocalDataSource>(create: (_) => userLocalDataSource),
        Provider<UserRepositoryImpl>(create: (_) => userRepository),
        // 注入 UserRepositoryImpl
        ChangeNotifierProvider(
          create: (context) =>
              UserListViewModel(
                context.read<UserRepositoryImpl>()
                as UserRepository, // 从 Provider 获取 UserRepositoryImpl
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

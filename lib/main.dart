// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ppx_client/core/network/auth_service.dart';
import 'package:ppx_client/data/repositories/user_repository.dart';
import 'package:ppx_client/presentation/viewmodels/post_list_viewmodel.dart';
import 'package:ppx_client/presentation/viewmodels/user_list_viewmodel.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/post_dao.dart';
import 'core/network/api_service.dart';
import 'core/network/dio_client.dart';
import 'core/network/post_api_service.dart';
import 'data/datasources/user_local_datasource.dart';
import 'data/datasources/user_remote_datasource.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/user_repository_impl.dart';

import 'package:ppx_client/presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.init(); // 初始化 Hive 数据库

  // Initialize ThemeViewModel before running the app
  final themeViewModel = ThemeViewModel();
  await themeViewModel.initTheme(); // Ensure theme is loaded before app starts

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

  final postDao = HivePostDao(); // <--- 替换为你的DAO实现
  final postApiSerVice = PostApiService(dioClient);
  final postRepository = PostRepository(
    apiService: postApiSerVice,
    postDao: postDao,
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
        Provider<PostRepository>(create: (_) => postRepository),
        Provider<PostApiService>(create: (_) => postApiSerVice),
        // 注入 UserRepositoryImpl
        ChangeNotifierProvider(
          create: (context) => UserListViewModel(
            context.read<UserRepositoryImpl>()
                as UserRepository, // 从 Provider 获取 UserRepositoryImpl
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => PostListViewModel(repository: postRepository),
        ),
        ChangeNotifierProvider.value(value: themeViewModel), // Provide the already initialized instance
      ],
      child: const MyApp(),
    ),
  );
}

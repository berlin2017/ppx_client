// lib/app.dart
import 'package:flutter/material.dart';
import 'package:ppx_client/presentation/pages/home/home_screen.dart';
import 'package:ppx_client/presentation/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(context.read()), // 创建 AuthViewModel 实例
      child: MaterialApp(
        title: 'Flutter MVVM Auth',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          // 你可以自定义主题色
          primaryColor: Colors.deepPurple,
          primaryColorDark: Colors.deepPurple.shade700,
          primaryColorLight: Colors.deepPurple.shade100,
          scaffoldBackgroundColor: Colors.grey[100],
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
              // 按钮文字颜色
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            // 根据 AuthViewModel 中的 currentUser 状态决定初始页面
            if (authViewModel.loginStatus == AuthStatus.loading &&
                authViewModel.currentUser == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ); // 初始加载状态
            }
            if (authViewModel.currentUser != null) {
              return const HomeScreen();
            }
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}

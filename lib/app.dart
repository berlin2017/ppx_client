// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppx_client/presentation/pages/home/home_screen.dart';
import 'package:ppx_client/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ppx_client/presentation/viewmodels/theme_viewmodel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(context.read())),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer2<AuthViewModel, ThemeViewModel>(
        builder: (context, authViewModel, themeViewModel, _) {
          return MaterialApp(
            title: 'Flutter MVVM Auth',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
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
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.deepPurple,
              primaryColor: Colors.deepPurple,
              primaryColorDark: Colors.deepPurple.shade700,
              primaryColorLight: Colors.deepPurple.shade100,
              scaffoldBackgroundColor: Colors.grey[900],
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                fillColor: Colors.grey[800],
                filled: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
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
                color: Colors.grey[850],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            themeMode: themeViewModel.themeMode,
            debugShowCheckedModeBanner: false,
            home: Consumer<AuthViewModel>(
              builder: (context, authViewModel, _) {
                if (authViewModel.loginStatus == AuthStatus.loading &&
                    authViewModel.currentUser == null) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (authViewModel.currentUser != null) {
                  return const HomeScreen();
                }
                return const HomeScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

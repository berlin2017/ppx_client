// lib/core/utils/app_router.dart
import 'package:flutter/material.dart';

import '../../presentation/pages/user/user_list_page.dart';

class AppRouter {
  static const String userListPage = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case userListPage:
        return MaterialPageRoute(builder: (_) => const UserListPage());
      default:
        return MaterialPageRoute(
            builder: (_) => Text('Error: Unknown route ${settings.name}'));
    }
  }
}
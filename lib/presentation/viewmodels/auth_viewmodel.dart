// lib/core/viewmodels/auth_viewmodel.dart
import 'package:flutter/material.dart';

import '../../core/network/auth_service.dart';
import '../../data/models/user_model.dart';

enum AuthStatus { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService) {
    _loadCurrentUser(); // 应用启动时尝试加载已登录用户
  }

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  AuthStatus _loginStatus = AuthStatus.initial;

  AuthStatus get loginStatus => _loginStatus;

  AuthStatus _registerStatus = AuthStatus.initial;

  AuthStatus get registerStatus => _registerStatus;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      _loginStatus = AuthStatus.success; // 如果有用户，则认为是已登录状态
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loginStatus = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        _loginStatus = AuthStatus.success;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "邮箱或密码错误";
        _loginStatus = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "登录失败: ${e.toString()}";
      _loginStatus = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _registerStatus = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      if (user != null) {
        _currentUser = user; // 注册成功后也视为登录
        _registerStatus = AuthStatus.success;
        _loginStatus = AuthStatus.success; // 更新登录状态
        notifyListeners();
        return true;
      } else {
        _errorMessage = "注册信息不完整或不符合要求";
        _registerStatus = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "注册失败: ${e.toString()}";
      _registerStatus = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _loginStatus = AuthStatus.initial;
    _registerStatus = AuthStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_loginStatus == AuthStatus.error) _loginStatus = AuthStatus.initial;
    if (_registerStatus == AuthStatus.error)
      _registerStatus = AuthStatus.initial;
    notifyListeners();
  }
}
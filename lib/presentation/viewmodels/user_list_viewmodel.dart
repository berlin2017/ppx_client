// lib/presentation/viewmodels/user_list_viewmodel.dart
import 'package:flutter/material.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

enum ViewState { Idle, Loading, Loaded, Error }

class UserListViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserListViewModel(this._userRepository);

  List<UserModel> _users = [];

  List<UserModel> get users => _users;

  ViewState _viewState = ViewState.Idle;

  ViewState get viewState => _viewState;

  String _errorMessage = '';

  String get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _viewState = ViewState.Loading;
    notifyListeners();

    try {
      _users = await _userRepository.getUsers();
      _viewState = ViewState.Loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _viewState = ViewState.Error;
      AppLogger.error('获取用户列表出错: $e');
    } finally {
      notifyListeners();
    }
  }
}

// lib/presentation/pages/user_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/user_list_viewmodel.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户列表')),
      body: Consumer<UserListViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.viewState) {
            case ViewState.Loading:
              return const Center(child: CircularProgressIndicator());
            case ViewState.Error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: ${viewModel.errorMessage}'),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchUsers(),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            case ViewState.Loaded:
              if (viewModel.users.isEmpty) {
                return const Center(child: Text('没有用户数据'));
              }
              return ListView.builder(
                itemCount: viewModel.users.length,
                itemBuilder: (context, index) {
                  final user = viewModel.users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      leading: CircleAvatar(child: Text(user.id.toString())),
                    ),
                  );
                },
              );
            case ViewState.Idle:
            default:
              return Center(
                child: ElevatedButton(
                  onPressed: () => viewModel.fetchUsers(),
                  child: const Text('加载用户'),
                ),
              );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ppx_client/widgets/content_list_page.dart';
import 'package:provider/provider.dart';
import 'package:ppx_client/presentation/viewmodels/auth_viewmodel.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUser?.id;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('我发布的')),
        body: const Center(child: Text('请先登录以查看您的发布')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我发布的'),
      ),
      body: ContentListPage(userId: currentUserId),
    );
  }
}
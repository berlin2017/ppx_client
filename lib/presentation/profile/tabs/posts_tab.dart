import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppx_client/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ppx_client/widgets/content_list_page.dart';

class PostsTab extends StatelessWidget {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final currentUserId = authViewModel.currentUser?.id;

    if (currentUserId == null) {
      return const Center(child: Text('用户未登录'));
    }

    return ContentListPage(userId: currentUserId);
  }
}
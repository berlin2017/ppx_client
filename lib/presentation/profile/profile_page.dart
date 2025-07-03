import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppx_client/presentation/viewmodels/auth_viewmodel.dart';

import 'my_posts_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[100],
        title: const Text('我的', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildActionGrid(context),
            const SizedBox(height: 20),
            _buildSettingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            // Placeholder for user avatar
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '愤怒的蜘蛛侠',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '共1个徽章 >',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatColumn('关注', '23'),
                    const SizedBox(width: 16),
                    _buildStatColumn('粉丝', '1'),
                    const SizedBox(width: 16),
                    _buildStatColumn('获赞', '10'),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('个人主页'),
          )
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUser?.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionCard(context, Icons.article, '帖子', '我发布的', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyPostsPage(),
              ),
            );
          }),
          _buildActionCard(context, Icons.comment, '评论', '我发出的'),
          _buildActionCard(context, Icons.visibility, '插眼', '期待后续'),
          _buildActionCard(context, Icons.favorite, '收藏', '我的最爱'),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width / 4 - 24,
          height: 80,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(context, Icons.history, '历史记录', onTap: () {}),
          _buildSettingsItem(context, Icons.monetization_on, '金币', onTap: () {}),
          _buildSettingsItem(context, Icons.create, '创作中心', onTap: () {}),
          _buildSettingsItem(context, Icons.star, '原创特权', onTap: () {}),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('深色模式'),
            secondary: const Icon(Icons.dark_mode),
            value: false, // Replace with state management
            onChanged: (bool value) {
              // Handle theme change
            },
          ),
          const Divider(height: 1),
           _buildSettingsItem(
            context,
            Icons.logout,
            '退出登录',
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
// lib/presentation/pages/home_screen.dart
import 'package:flutter/material.dart';
import 'package:ppx_client/presentation/pages/user/user_list_page.dart';
import 'package:provider/provider.dart'; // 如果你需要访问 AuthViewModel

import '../../../widgets/AnimatedBackground.dart';
import '../../../widgets/AnimatedCard.dart';
import '../../../widgets/FadeInAnimation.dart';
import '../../../widgets/SlideInAnimation.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../user/login_screen.dart';
import 'HomeScreen2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // 用于更复杂的动画
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // 创建一个重复动画控制器

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 可以在这里添加一些延迟加载的动画触发
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // 触发一些初始动画，例如让元素淡入或滑入
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final authViewModel = Provider.of<AuthViewModel>(context); // 如果需要用户信息

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // 透明 AppBar，让背景延伸
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 跳转到设置页面
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true, // 让 body 内容延伸到 AppBar 后面
      body: Stack(
        children: [
          // 1. 动态渐变背景
          AnimatedBackground(),

          // 2. 页面主要内容
          SafeArea(
            // 保证内容在安全区域内，避开刘海和导航栏
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 应用 Logo 或欢迎语 (带动画)
                  ScaleTransition(
                    scale: _animation,
                    child: FlutterLogo(size: 100), // 或者你的应用 Logo
                  ),
                  const SizedBox(height: 20),
                  FadeInAnimation(
                    // 自定义淡入动画 Widget
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      '欢迎回来!', // 或者从 authViewModel.currentUser 获取用户名
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      '今天想做些什么？',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // 功能入口卡片 (带动画和交互)
                  SlideInAnimation(
                    // 自定义滑入动画 Widget
                    delay: const Duration(milliseconds: 700),
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.article_outlined,
                      title: '浏览文章',
                      subtitle: '发现有趣的内容',
                      gradientColors: [
                        Colors.orange.shade300,
                        Colors.orange.shade600,
                      ],
                      onTap: () {
                        // TODO: 跳转到文章列表页面
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('跳转到文章列表')),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen2(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 900),
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.person_search_outlined,
                      title: '用户列表',
                      // 假设你有一个用户列表功能
                      subtitle: '查看社区成员',
                      gradientColors: [
                        Colors.blue.shade300,
                        Colors.blue.shade600,
                      ],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const UserListPage(), // 使用你现有的用户列表页
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 1100),
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.logout,
                      title: '退出登录',
                      subtitle: '安全退出当前账号',
                      gradientColors: [
                        Colors.red.shade300,
                        Colors.red.shade500,
                      ],
                      onTap: () async {
                        final authViewModel = Provider.of<AuthViewModel>(
                          context,
                          listen: false,
                        );
                        await authViewModel.logout();
                        // 导航回登录页或初始页
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            // 假设你的登录页是 LoginScreen
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      isDestructive: true,
                    ),
                  ),
                  // 可以添加更多功能卡片
                ],
              ),
            ),
          ),
        ],
      ),
      // 可以考虑添加一个 FloatingActionButton 或 BottomNavigationBar
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add),
      //   backgroundColor: Theme.of(context).colorScheme.secondary,
      // ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
      //     BottomNavigationBarItem(icon: Icon(Icons.search), label: '发现'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
      //   ],
      //   // currentIndex: _selectedIndex,
      //   // onTap: _onItemTapped,
      // ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return AnimatedCard(
      // 自定义带交互动画的卡片
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isDestructive ? Colors.white : Colors.white,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}

// --- 动画相关的辅助 Widgets ---

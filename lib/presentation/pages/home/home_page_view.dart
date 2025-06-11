import 'dart:math' as math; // 用于 FAB 图标旋转和菜单项定位

import 'package:camera/camera.dart'; // <--- 添加 camera 导入
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // <--- 添加 image_picker 导入

import '../../../widgets/content_list_page.dart'; // 假设这个路径仍然有效
import '../common/display_picture_screen.dart'; // <--- 引入 DisplayPictureScreen
import '../create_post/create_post_page.dart';
import 'camera_screen.dart'; // <--- 引入 CameraScreenn

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>
    with TickerProviderStateMixin {
  final List<Tab> _tabs = const [
    Tab(text: '推荐'),
    Tab(text: '视频'),
    Tab(text: '图文'),
    Tab(text: '关注'),
    Tab(text: '直播'),
  ];

  late final List<Widget> _tabViews;

  bool _isMenuOpen = false;
  late AnimationController _menuAnimationController;
  late Animation<double> _fabIconAnimation;
  late Animation<double> _menuItemsAnimation;

  late List<CameraDescription> _cameras; // <--- 添加摄像头列表变量
  final ImagePicker _picker = ImagePicker(); // <--- 初始化 ImagePicker

  // 修改 _menuOptions
  late final List<_MenuOption> _menuOptions; // 声明为 late final

  @override
  void initState() {
    super.initState();
    _tabViews = [
      const ContentListPage(category: '推荐'),
      const ContentListPage(category: '视频'),
      const ContentListPage(category: '图文'),
      const ContentListPage(category: '关注'),
      const ContentListPage(category: '直播'),
    ];
    _initializeCameras(); // <--- 调用初始化摄像头的方法

    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fabIconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _menuAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _menuItemsAnimation = CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeInOut,
    );

    // 在 initState 中初始化 _menuOptions，因为它依赖于 _cameras
    _menuOptions = [
      _MenuOption(
        icon: Icons.camera_alt,
        label: '拍照',
        onPressed: _openCamera, // <--- 修改为新方法
      ),
      _MenuOption(
        icon: Icons.image,
        label: '相册',
        onPressed: _pickImageFromGallery, // <--- 修改为新方法
      ),
      _MenuOption(
        icon: Icons.edit,
        label: '文字',
        onPressed: () {
          print("文字 Tapped");
          _toggleMenu(); // 先关闭菜单
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
      ),
    ];
  }

  Future<void> _initializeCameras() async {
    try {
      WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定已初始化
      _cameras = await availableCameras(); // 获取可用摄像头
    } on CameraException catch (e) {
      print('初始化摄像头失败: ${e.code}\nError: ${e.description}');
      _cameras = []; // 如果出错则设置为空列表
    }
  }

  void _openCamera() {
    _toggleMenu(); // 先关闭菜单
    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有可用的摄像头!')));
      print("没有可用的摄像头，无法打开。");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen(cameras: _cameras)),
    );
  }

  Future<void> _pickImageFromGallery() async {
    _toggleMenu(); // 先关闭菜单
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(imagePath: image.path),
          ),
        );
      } else {
        print("用户未选择图片");
      }
    } catch (e) {
      print("从相册选择图片时发生错误: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('打开相册失败!')));
    }
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuAnimationController.forward();
      } else {
        _menuAnimationController.reverse();
      }
    });
  }

  Widget _buildMenuOptionWidget(_MenuOption option, int index) {
    // 菜单项从主FAB周围发散出去
    // 参考: https://flutter.dev/docs/cookbook/gestures/animated-radial-menu
    // 或者搜索 "Flutter speed dial animation" or "Flutter circular fab menu"

    final double mainMenuRadius = 75.0; // 菜单项完全展开时距离主FAB中心的半径
    final int numItems = _menuOptions.length;
    final double itemSpread = math.pi / 2; // 菜单项散开的总弧度 (90度)
    final double angleStartOffset =
        math.pi / 2; // 从主FAB正上方开始散开 (0是右方, pi/2是上方, pi是左方)

    return AnimatedBuilder(
      animation: _menuAnimationController,
      builder: (context, child) {
        if (_menuItemsAnimation.value == 0.0) {
          return const SizedBox.shrink();
        }
        final double radius = _menuItemsAnimation.value * mainMenuRadius;
        final double itemAngleRadians =
            angleStartOffset +
            (numItems > 1 ? (index * itemSpread / (numItems - 1)) : 0);
        final double targetX =
            radius *
            math.cos(
              math.pi / 2 +
                  (numItems > 1 ? (index * (math.pi / 2) / (numItems - 1)) : 0),
            );
        final double targetY =
            radius *
            math.sin(
              math.pi / 2 +
                  (numItems > 1 ? (index * (math.pi / 2) / (numItems - 1)) : 0),
            );

        return Positioned(
          right: -targetX, // 修正，因为我们的 targetX 是从右向左为正
          bottom: targetY,
          child: ScaleTransition(
            scale: _menuItemsAnimation,
            child: FadeTransition(
              opacity: _menuItemsAnimation,
              child: FloatingActionButton.small(
                heroTag: 'menu_option_$index',
                onPressed: option.onPressed, // <--- 修改这里，直接调用 option.onPressed
                // 因为 _toggleMenu() 已经在具体的 onPressed 实现中处理了
                tooltip: option.label,
                child: Icon(option.icon),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: Scaffold(
          // Inner Scaffold for FAB context if needed
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  child: TabBar(
                    tabs: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.blueAccent,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Expanded(child: TabBarView(children: _tabViews)),
              ],
            ),
          ),
          floatingActionButton: Stack(
            alignment: Alignment.bottomRight, // Align main FAB to bottom right
            clipBehavior: Clip.none, // Allow menu items to go outside bounds
            children: [
              // 当菜单打开时，显示 ModalBarrier
              if (_isMenuOpen) // 或者更精确地用 _menuAnimationController.status != AnimationStatus.dismissed
                ModalBarrier(
                  color: Colors.transparent, // 半透明黑色背景
                  dismissible: true, // 点击屏障时是否关闭菜单
                  onDismiss: _toggleMenu, // 如果 dismissible 为 true，点击时调用此方法
                ),
              // Animated Menu Items
              // Spread them around the main FAB
              // This relies on _buildMenuOptionWidget to correctly position them
              ..._menuOptions.asMap().entries.map((entry) {
                int index = entry.key;
                _MenuOption option = entry.value;
                return _buildMenuOptionWidget(option, index);
              }).toList(),

              // Main FloatingActionButton
              FloatingActionButton(
                onPressed: _toggleMenu,
                child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _fabIconAnimation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  _MenuOption({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

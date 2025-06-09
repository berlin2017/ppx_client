import 'dart:math' as math; // 用于 FAB 图标旋转和菜单项定位

import 'package:flutter/material.dart';

import '../../../widgets/content_list_page.dart'; // 假设这个路径仍然有效

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

  final List<_MenuOption> _menuOptions = [
    _MenuOption(
      icon: Icons.camera_alt,
      label: '拍照',
      onPressed: () {
        print("拍照 Tapped");
      },
    ),
    _MenuOption(
      icon: Icons.image,
      label: '相册',
      onPressed: () {
        print("相册 Tapped");
      },
    ),
    _MenuOption(
      icon: Icons.edit,
      label: '文字',
      onPressed: () {
        print("文字 Tapped");
      },
    ),
  ];

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
          // 菜单收起时不渲染
          return SizedBox.shrink();
        }

        // 当前动画进度驱动的半径
        final double radius = _menuItemsAnimation.value * mainMenuRadius;
        // 计算当前菜单项的角度
        // 如果只有一个菜单项，它会在起始角度
        // 如果有多个，它们会在 itemSpread 弧度内均匀分布
        final double itemAngleRadians =
            angleStartOffset +
            (numItems > 1 ? (index * itemSpread / (numItems - 1)) : 0);

        // 使用三角函数计算x, y偏移量
        // 主FAB在右下角，所以我们希望菜单项向左上方散开
        // targetX: 负值表示向左
        // targetY: 正值表示向上 (因为Positioned的bottom是相对于底部的)
        final double targetX = radius * math.cos(itemAngleRadians);
        final double targetY = radius * math.sin(itemAngleRadians);

        return Positioned(
          // 主FAB通常在右下角，所以right和bottom是相对于此的偏移
          // targetX: cos(pi/2)=0 (正上), cos(pi)=-1 (正左)
          // targetY: sin(pi/2)=1 (正上), sin(pi)=0 (正左)
          // 对于标准的数学坐标系（x向右，y向上）:
          // x = radius * cos(angle)
          // y = radius * sin(angle)
          // Positioned的right是距离右边的距离，bottom是距离底部的距离
          // 所以如果想让item在主FAB的左边，x应该是负的，所以right应该是-x (正值)
          // 如果想让item在主FAB的上边，y应该是正的，所以bottom应该是y (正值)
          //right: targetX, // 如果 targetX 是正（cos角度在-pi/2到pi/2），则向右偏移
          // 我们希望向左，所以cos角度应在pi/2到3pi/2，这样cos为负，targetX为负
          // 但这里我们的角度是从pi/2开始(向上)，然后递增
          // 例如，第一个是 pi/2 (正上), 第二个是 pi/2 + spread/ (n-1) (左上)
          // 为了简便，我们假设 (0,0) 在主FAB中心
          // 菜单项在 (-X, Y) 相对于主FAB, 其中X,Y > 0
          // Positioned: right: X, bottom: Y
          // 所以，我们的targetX需要是正值代表向左的距离，targetY是正值代表向上的距离
          // cos(angle) 当 angle 在 (pi/2, 3pi/2) 时为负。
          // sin(angle) 当 angle 在 (0, pi) 时为正。
          // 我们希望向左上方，所以 targetX应该是从FAB向左的距离， targetY是从FAB向上的距离
          // angle: pi/2 (正上) -> x=0, y=radius
          // angle: pi (正左) -> x=-radius, y=0
          // angle: 3pi/4 (左上) -> x=-radius*cos(pi/4), y=radius*sin(pi/4)

          // 修正：我们希望的是 Positioned 的 right 和 bottom 值
          // right: 表示距离Stack右边缘的距离。如果主FAB在右下角，菜单项向左偏移，则right值增加。
          // bottom: 表示距离Stack下边缘的距离。如果主FAB在右下角，菜单项向上偏移，则bottom值增加。
          // x_offset_from_fab_center = radius * cos(angle)
          // y_offset_from_fab_center = radius * sin(angle)
          // Positioned.right = -x_offset_from_fab_center (如果x为负，则right为正)
          // Positioned.bottom = y_offset_from_fab_center (如果y为正，则bottom为正)

          // 简化：假设主FAB是原点(0,0)，菜单项的目标是 (dx, dy)
          // dx = -radius * cos(angle_for_left_up_quadrant)
          // dy = radius * sin(angle_for_left_up_quadrant)
          // Positioned.right = -dx
          // Positioned.bottom = dy

          // Let's adjust angles for left-up spread from right-bottom FAB
          // angle pi (180deg) is left, angle pi/2 (90deg) is up.
          // We want to spread from angle pi (left) towards pi/2 (up).
          // So, angle should range from pi down to pi/2 if index increases.
          // Or, from pi/2 up to pi. Let's use pi/2 to pi for spread.
          // Angle for item i: base_angle + i * angle_increment

          // Let's use a simpler angle definition:
          // 0 degrees = to the right of FAB. We want to go from 90 to 180 degrees.
          // angle_deg = 90 + (index / (numItems -1)) * 90 if numItems > 1 else 90
          // angle_rad = angle_deg * math.pi / 180
          // dx = radius * cos(angle_rad) (this will be negative or zero)
          // dy = radius * sin(angle_rad) (this will be positive or zero)
          // Positioned.right = -dx (so it becomes positive, moving away from right edge)
          // Positioned.bottom = dy (positive, moving away from bottom edge)
          right:
              -(radius *
                  math.cos(
                    math.pi / 2 +
                        (numItems > 1
                            ? (index * (math.pi / 2) / (numItems - 1))
                            : 0),
                  )),
          bottom:
              radius *
              math.sin(
                math.pi / 2 +
                    (numItems > 1
                        ? (index * (math.pi / 2) / (numItems - 1))
                        : 0),
              ),
          child: ScaleTransition(
            scale: _menuItemsAnimation, // Use the general menu items animation
            child: FadeTransition(
              opacity: _menuItemsAnimation,
              // Use the general menu items animation
              child: FloatingActionButton.small(
                heroTag: 'menu_option_$index',
                onPressed: () {
                  option.onPressed();
                  _toggleMenu();
                },
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

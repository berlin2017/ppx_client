import 'package:flutter/material.dart';

import '../../../widgets/content_list_page.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  // Define the tabs for the TabBar and TabBarView
  final List<Tab> _tabs = const [
    Tab(text: '推荐'),
    Tab(text: '视频'),
    Tab(text: '图文'),
    // Add more tabs if needed, e.g.:
    Tab(text: '关注'),
    Tab(text: '直播'),
    Tab(text: '关注'),
    Tab(text: '直播'),
  ];

  // Define the content for each tab
  // This list should correspond to the _tabs list
  final List<Widget> _tabViews = [
    const ContentListPage(category: '推荐'),
    const ContentListPage(category: '视频'),
    const ContentListPage(category: '图文'),
    // Corresponding ContentListPage for additional tabs:
    const ContentListPage(category: '关注'),
    const ContentListPage(category: '直播'),
    const ContentListPage(category: '关注'),
    const ContentListPage(category: '直播'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        // 移除了 AppBar
        body: SafeArea( // 使用 SafeArea 避免内容与状态栏重叠
          child: Column(
            children: <Widget>[
              Container( // 可以用 Container 来模拟 AppBar 的背景色等
                child: TabBar(
                  tabs: _tabs,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start, // <--- 新增或修改此行
                  indicatorColor: Colors.blueAccent,
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: _tabViews,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

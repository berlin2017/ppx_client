import 'package:flutter/material.dart';

// Placeholder for ContentListPage - we will create this file next
// import './content_list_page.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final List<Tab> _tabs = const [
    Tab(text: '推荐'),
    Tab(text: '视频'),
    Tab(text: '图文'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [ // Re-declare tabs here directly for now
                  Tab(text: '推荐'),
                  Tab(text: '视频'),
                  Tab(text: '图文'),
                ],
                // indicatorColor: Colors.blue, // Example: Customize indicator color
                // labelColor: Colors.blue, // Example: Customize label color
                // unselectedLabelColor: Colors.grey, // Example: Customize unselected label color
              ),
            ],
          ),
          automaticallyImplyLeading: false, // Removes the back button if this is a top-level page
          elevation: 0, // Remove appbar shadow
        ),
        body: TabBarView(
          children: [
            // For now, using placeholders. We'll replace these with ContentListPage later.
            Center(child: Text('推荐内容')),
            Center(child: Text('视频内容')),
            Center(child: Text('图文内容')),
            // ContentListPage(category: '推荐'),
            // ContentListPage(category: '视频'),
            // ContentListPage(category: '图文'),
          ],
        ),
      ),
    );
  }
}

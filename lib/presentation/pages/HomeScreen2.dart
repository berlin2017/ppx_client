import 'package:flutter/material.dart';
import 'package:ppx_client/presentation/home/home_page_view.dart'; // Added import

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  int _selectedIndex = 0;

  // Updated to use the imported HomePageView
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePageView(), // Uses the imported HomePageView
    const Text('发现 Page'), // Placeholder for Discover page
    const Text('消息 Page'), // Placeholder for Messages page
    const Text('我的 Page'), // Placeholder for Profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple, // Or your primary color
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show all labels
        showUnselectedLabels: true,
      ),
    );
  }
}

// Placeholder for the Home Page content which will have the ViewPager -- REMOVED
// class HomePageView extends StatelessWidget {
//   const HomePageView({super.key});
// 
//   @override
//   Widget build(BuildContext context) {
//     // We'll implement the TabBar and ViewPager here later
//     return const Center(child: Text("首页 Content Area (ViewPager will be here)"));
//   }
// }

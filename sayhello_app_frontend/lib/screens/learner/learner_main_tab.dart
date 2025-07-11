import 'package:flutter/material.dart';
import 'Tabs/Home/home_page.dart';
import 'Tabs/Connect/connect_page.dart';
import 'Tabs/Feed/feed_page.dart';
import 'Tabs/Learn/learn_page.dart';
import 'Tabs/Profile/profile_page.dart';

class LearnerMainTab extends StatefulWidget {
  const LearnerMainTab({super.key});

  @override
  State<LearnerMainTab> createState() => _LearnerMainTabState();
}

class _LearnerMainTabState extends State<LearnerMainTab> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ConnectPage(),
    const FeedPage(),
    const LearnPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Connect'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

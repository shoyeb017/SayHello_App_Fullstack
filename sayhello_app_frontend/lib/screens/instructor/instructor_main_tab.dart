import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'BottomTabs/Home/home_page.dart';
import 'BottomTabs/AddCourse/add_course_page.dart';
import 'BottomTabs/Profile/profile_page.dart';

class InstructorMainTab extends StatefulWidget {
  const InstructorMainTab({super.key});

  @override
  State<InstructorMainTab> createState() => _InstructorMainTabState();
}

class _InstructorMainTabState extends State<InstructorMainTab> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const InstructorHomePage(),
    const AddCoursePage(),
    const InstructorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to login page after authentication
        // Users should only logout through the proper logout button
        return false;
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent, // ❌ Remove ripple
            highlightColor: Colors.transparent, // ❌ Remove highlight
          ),
          child: Material(
            elevation: 20,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF7A54FF),
              unselectedItemColor: Colors.grey,
              selectedIconTheme: const IconThemeData(size: 30),
              unselectedIconTheme: const IconThemeData(size: 30),
              selectedLabelStyle: const TextStyle(fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == 1
                          ? const Color(0xFF7A54FF)
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 35,
                      color: _currentIndex == 1
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                  label: AppLocalizations.of(context)!.addCourse,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: AppLocalizations.of(context)!.profile,
                ),
              ],
            ),
          ), // Material closing
        ), // Theme closing
      ), // Scaffold closing
    ); // WillPopScope closing
  }
}

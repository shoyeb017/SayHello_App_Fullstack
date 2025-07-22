import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';

// Import instructor-specific tabs
import 'instructor_online_session.dart';
import 'instructor_recorded_classes.dart';
import 'instructor_study_materials.dart';
import 'instructor_group_chat.dart';
import 'instructor_student_performance.dart';

class InstructorCoursePortalPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorCoursePortalPage({super.key, required this.course});

  @override
  State<InstructorCoursePortalPage> createState() =>
      _InstructorCoursePortalPageState();
}

class _InstructorCoursePortalPageState
    extends State<InstructorCoursePortalPage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.video_call, label: 'Online Sessions'),
    _TabItem(icon: Icons.ondemand_video, label: 'Recorded Classes'),
    _TabItem(icon: Icons.description, label: 'Study Materials'),
    _TabItem(icon: Icons.chat, label: 'Group Chat'),
    _TabItem(icon: Icons.analytics, label: 'Student Performance'),
  ];

  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.course['title'] ?? 'Course';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              'Instructor Dashboard',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              bool toDark = themeProvider.themeMode != ThemeMode.dark;
              themeProvider.toggleTheme(toDark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showCourseSettings();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () => _onTabTap(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF7A54FF).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab.icon,
                          color: isSelected
                              ? const Color(0xFF7A54FF)
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF7A54FF)
                                : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          InstructorOnlineSessionTab(course: widget.course),
          InstructorRecordedClassesTab(course: widget.course),
          InstructorStudyMaterialsTab(course: widget.course),
          InstructorGroupChatTab(course: widget.course),
          InstructorStudentPerformanceTab(course: widget.course),
        ],
      ),
    );
  }

  void _showCourseSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Course Settings',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF7A54FF)),
                title: Text(
                  'Edit Course Details',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit course page
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Color(0xFF7A54FF)),
                title: Text(
                  'Manage Enrollments',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to enrollment management
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule, color: Color(0xFF7A54FF)),
                title: Text(
                  'Schedule Management',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to schedule management
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF7A54FF)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

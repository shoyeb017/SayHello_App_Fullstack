import 'package:flutter/material.dart';

import 'course_details.dart';
import 'online_session.dart';
import 'record_class.dart';
import 'study_material.dart';
import 'group_chat.dart';
import 'progress.dart';

class CoursePortalPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CoursePortalPage({super.key, required this.course});

  @override
  State<CoursePortalPage> createState() => _CoursePortalPageState();
}

class _CoursePortalPageState extends State<CoursePortalPage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.info_outline, label: 'Details'),
    _TabItem(icon: Icons.video_call, label: 'Online'),
    _TabItem(icon: Icons.ondemand_video, label: 'Recorded'),
    _TabItem(icon: Icons.description, label: 'Materials'),
    _TabItem(icon: Icons.chat, label: 'Chat'),
    _TabItem(icon: Icons.insights, label: 'Progress'),
  ];

  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.course['title'] ?? 'Course';

    return Scaffold(
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              'Your Learning Journey',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(tab.icon, color: isSelected ? Colors.purple : Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected ? Colors.purple : Colors.grey,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
          CourseDetails(course: widget.course),
          OnlineSessionTab(course: widget.course),
          RecordedClassTab(course: widget.course),
          StudyMaterialTab(course: widget.course),
          GroupChatTab(course: widget.course),
          ProgressTab(course: widget.course),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

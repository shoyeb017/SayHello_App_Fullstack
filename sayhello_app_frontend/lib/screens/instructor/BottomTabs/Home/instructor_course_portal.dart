import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';

// Import instructor-specific tabs
import 'instructor_course_details.dart';
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
  bool _showMiniSidebar = false;
  bool _showExpandedSidebar = false;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.info_outline, label: 'Course Details'),
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
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              if (_showExpandedSidebar) {
                _showExpandedSidebar = false;
                _showMiniSidebar = true;
              } else if (_showMiniSidebar) {
                _showMiniSidebar = false;
                _showExpandedSidebar = true;
              } else {
                _showMiniSidebar = true;
              }
            });
          },
          tooltip: 'Navigation Menu',
        ),
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
            tooltip: 'Back',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content Area - Full Width
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              InstructorCourseDetailsTab(course: widget.course),
              InstructorOnlineSessionTab(course: widget.course),
              InstructorRecordedClassesTab(course: widget.course),
              InstructorStudyMaterialsTab(course: widget.course),
              InstructorGroupChatTab(course: widget.course),
              InstructorStudentPerformanceTab(course: widget.course),
            ],
          ),

          // Overlay Background (when sidebar is open)
          if (_showMiniSidebar || _showExpandedSidebar)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showMiniSidebar = false;
                  _showExpandedSidebar = false;
                });
              },
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // Mini Sidebar Overlay
          if (_showMiniSidebar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7A54FF),
                            const Color(0xFF7A54FF).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    // Navigation Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _tabs.length,
                        itemBuilder: (context, index) {
                          final tab = _tabs[index];
                          final isSelected = index == _selectedIndex;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  _onTabTap(index);
                                  setState(() {
                                    _showMiniSidebar = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFF7A54FF,
                                          ).withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    tab.icon,
                                    color: isSelected
                                        ? const Color(0xFF7A54FF)
                                        : (isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600]),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Expanded Sidebar Overlay
          if (_showExpandedSidebar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(10, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7A54FF),
                            const Color(0xFF7A54FF).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Course Portal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.course['title'] ?? 'Course Title',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.course['enrolledStudents'] ?? 0} Students',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _tabs.length,
                        itemBuilder: (context, index) {
                          final tab = _tabs[index];
                          final isSelected = index == _selectedIndex;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  _onTabTap(index);
                                  setState(() {
                                    _showExpandedSidebar = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFF7A54FF,
                                          ).withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(
                                              0xFF7A54FF,
                                            ).withOpacity(0.3),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF7A54FF)
                                              : (isDark
                                                    ? Colors.grey[800]
                                                    : Colors.grey[200]),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          tab.icon,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600]),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tab.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF7A54FF)
                                                : (isDark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700]),
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7A54FF),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Quick Actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildQuickActionButton(
                            'Course Settings',
                            Icons.settings,
                            isDark,
                            () {
                              _showCourseSettings();
                              setState(() {
                                _showExpandedSidebar = false;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildQuickActionButton(
                            'View as Student',
                            Icons.visibility,
                            isDark,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Student view coming soon'),
                                ),
                              );
                              setState(() {
                                _showExpandedSidebar = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

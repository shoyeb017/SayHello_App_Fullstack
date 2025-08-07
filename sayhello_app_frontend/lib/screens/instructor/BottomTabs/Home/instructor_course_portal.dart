import 'package:flutter/material.dart';
import '../../../../../../l10n/app_localizations.dart';

// Import instructor-specific tabs
import 'instructor_course_details.dart';
import 'instructor_online_session.dart';
import 'instructor_recorded_classes.dart';
import 'instructor_study_materials.dart';
import 'instructor_group_chat.dart';
import 'instructor_feedback.dart';

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
  final ScrollController _tabScrollController = ScrollController();
  int _selectedIndex = 0;
  bool _showMiniSidebar = false;
  bool _showExpandedSidebar = false;

  List<_TabItem> _getTabs(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      _TabItem(icon: Icons.info_outline, label: localizations.courseDetails),
      _TabItem(icon: Icons.video_call, label: localizations.onlineSessions),
      _TabItem(
        icon: Icons.ondemand_video,
        label: localizations.recordedClasses,
      ),
      _TabItem(icon: Icons.description, label: localizations.studyMaterials),
      _TabItem(icon: Icons.chat, label: localizations.groupChat),
      _TabItem(icon: Icons.analytics, label: localizations.feedback),
    ];
  }

  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    _centerSelectedTab(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _centerSelectedTab(index);
  }

  void _centerSelectedTab(int index) {
    // Calculate the scroll position to center the selected tab
    const double tabWidth = 100.0; // Approximate tab width including margin
    final double targetScrollOffset =
        (index * tabWidth) -
        (MediaQuery.of(context).size.width / 2) +
        (tabWidth / 2);

    _tabScrollController.animateTo(
      targetScrollOffset.clamp(
        0.0,
        _tabScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.course['title'] ?? 'Course';
    final localizations = AppLocalizations.of(context)!;
    final tabs = _getTabs(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: AppBar(
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
            tooltip: localizations.navigationMenu,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                localizations.instructorPortal,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            // Settings button
            IconButton(
              icon: Icon(
                Icons.settings,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => _showInstructorSettings(),
              tooltip: localizations.instructorSettings,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: localizations.closeCourse,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Horizontal Sliding Tabs
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: ListView.builder(
                controller: _tabScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  final isSelected = index == _selectedIndex;

                  return GestureDetector(
                    onTap: () => _onTabTap(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: isSelected ? 11 : 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFF7A54FF)
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                height: 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Underline indicator
                          Container(
                            height: 2,
                            width: isSelected ? 30 : 0,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7A54FF),
                              borderRadius: BorderRadius.circular(1),
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

          // Main Content
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            bottom: 0,
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                InstructorCourseDetailsTab(course: widget.course),
                InstructorOnlineSessionTab(course: widget.course),
                InstructorRecordedClassesTab(course: widget.course),
                InstructorStudyMaterialsTab(course: widget.course),
                InstructorGroupChatTab(course: widget.course),
                InstructorFeedbackTab(course: widget.course),
              ],
            ),
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
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(10, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Course Icon Header with enhanced design
                    Container(
                      width: double.infinity,
                      height: 80,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7A54FF),
                            const Color(0xFF7A54FF).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
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
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          final tab = tabs[index];
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
                    // Enhanced Header with course stats
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
                          Row(
                            children: [
                              const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 28,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showExpandedSidebar = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.instructorPortal,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Course stats
                          Row(
                            children: [
                              _buildStatItem(
                                '${widget.course['enrolledStudents'] ?? 0}',
                                localizations.students,
                              ),
                              const SizedBox(width: 16),
                              _buildStatItem(
                                '${widget.course['completionRate'] ?? 0}%',
                                localizations.completion,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Navigation Items with enhanced styling
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          final tab = tabs[index];
                          final isSelected = index == _selectedIndex;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
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
                                  padding: const EdgeInsets.all(16),
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
                  ],
                ),
              ),
            ),

          // Overlay to close sidebar when tapping outside
          if (_showMiniSidebar || _showExpandedSidebar)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showMiniSidebar = false;
                    _showExpandedSidebar = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  margin: EdgeInsets.only(
                    left: _showExpandedSidebar ? 300 : 80,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  void _showInstructorSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            localizations.instructorSettings,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: Color(0xFF7A54FF),
                ),
                title: Text(
                  localizations.notificationPreferences,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.notificationSettingsComingSoon,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule, color: Color(0xFF7A54FF)),
                title: Text(
                  localizations.officeHours,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.officeHoursSettingsComingSoon,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF7A54FF)),
                title: Text(
                  localizations.languageAndRegion,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.languageSettingsComingSoon),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.close,
                style: const TextStyle(color: Color(0xFF7A54FF)),
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

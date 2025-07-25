import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';

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
  bool _showMiniSidebar = false;
  bool _showExpandedSidebar = false;

  List<_TabItem> get _tabs => [
    _TabItem(
      icon: Icons.info_outline,
      label: AppLocalizations.of(context)!.courseDetails,
    ),
    _TabItem(
      icon: Icons.video_call,
      label: AppLocalizations.of(context)!.onlineSessions,
    ),
    _TabItem(
      icon: Icons.ondemand_video,
      label: AppLocalizations.of(context)!.recordedClasses,
    ),
    _TabItem(
      icon: Icons.description,
      label: AppLocalizations.of(context)!.studyMaterials,
    ),
    _TabItem(icon: Icons.chat, label: AppLocalizations.of(context)!.groupChat),
    _TabItem(
      icon: Icons.analytics,
      label: AppLocalizations.of(context)!.progress,
    ),
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
              AppLocalizations.of(context)!.yourLearningJourney,
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
              themeProvider.toggleTheme(
                themeProvider.themeMode == ThemeMode.light,
              );
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close Course',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(
            child: PageView(
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
                    // Course Icon Header
                    Container(
                      width: double.infinity,
                      height: 80,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.purple.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
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
                                        ? Colors.purple.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    tab.icon,
                                    color: isSelected
                                        ? Colors.purple
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
                            Colors.purple,
                            Colors.purple.withOpacity(0.8),
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
                            AppLocalizations.of(context)!.learningPortal,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tabs.length,
                        itemBuilder: (context, index) {
                          final tab = _tabs[index];
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
                                        ? Colors.purple.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        tab.icon,
                                        color: isSelected
                                            ? Colors.purple
                                            : (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          tab.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.purple
                                                : (isDark
                                                      ? Colors.white
                                                      : Colors.black),
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
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
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

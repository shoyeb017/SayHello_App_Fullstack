import 'package:flutter/material.dart';

class ProgressTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const ProgressTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Enhanced dynamic progress data with detailed tracking
    final List<Map<String, dynamic>> modules = [
      {
        'id': 'module_1',
        'title': 'Course Introduction & Fundamentals',
        'description': 'Understanding the basics and course structure',
        'completed': true,
        'progress': 1.0,
        'lessons': 5,
        'completedLessons': 5,
        'timeSpent': '3h 45m',
        'lastAccessed': '2025-07-21',
        'difficulty': 'Beginner',
        'score': 95,
        'activities': [
          {'name': 'Introduction Video', 'completed': true, 'type': 'video'},
          {
            'name': 'Getting Started Quiz',
            'completed': true,
            'type': 'quiz',
            'score': 90,
          },
          {'name': 'Course Materials', 'completed': true, 'type': 'reading'},
          {'name': 'Discussion Forum', 'completed': true, 'type': 'discussion'},
          {
            'name': 'Practice Exercise',
            'completed': true,
            'type': 'exercise',
            'score': 100,
          },
        ],
      },
      {
        'id': 'module_2',
        'title': 'Core Concepts & Techniques',
        'description':
            'Deep dive into essential concepts and practical applications',
        'completed': true,
        'progress': 1.0,
        'lessons': 8,
        'completedLessons': 8,
        'timeSpent': '6h 20m',
        'lastAccessed': '2025-07-22',
        'difficulty': 'Intermediate',
        'score': 88,
        'activities': [
          {'name': 'Core Concepts Video', 'completed': true, 'type': 'video'},
          {'name': 'Technique Demo', 'completed': true, 'type': 'video'},
          {
            'name': 'Hands-on Practice',
            'completed': true,
            'type': 'exercise',
            'score': 85,
          },
          {
            'name': 'Case Study Analysis',
            'completed': true,
            'type': 'assignment',
            'score': 92,
          },
          {'name': 'Peer Review', 'completed': true, 'type': 'discussion'},
          {
            'name': 'Chapter Assessment',
            'completed': true,
            'type': 'quiz',
            'score': 87,
          },
        ],
      },
      {
        'id': 'module_3',
        'title': 'Advanced Applications',
        'description': 'Advanced techniques and real-world applications',
        'completed': false,
        'progress': 0.6,
        'lessons': 10,
        'completedLessons': 6,
        'timeSpent': '4h 15m',
        'lastAccessed': '2025-07-23',
        'difficulty': 'Advanced',
        'score': 0,
        'activities': [
          {'name': 'Advanced Concepts', 'completed': true, 'type': 'video'},
          {'name': 'Complex Scenarios', 'completed': true, 'type': 'video'},
          {
            'name': 'Advanced Exercise 1',
            'completed': true,
            'type': 'exercise',
            'score': 78,
          },
          {
            'name': 'Group Project Prep',
            'completed': true,
            'type': 'discussion',
          },
          {
            'name': 'Advanced Exercise 2',
            'completed': false,
            'type': 'exercise',
          },
          {'name': 'Final Assessment', 'completed': false, 'type': 'quiz'},
        ],
      },
      {
        'id': 'module_4',
        'title': 'Final Project & Assessment',
        'description': 'Comprehensive project and course evaluation',
        'completed': false,
        'progress': 0.0,
        'lessons': 6,
        'completedLessons': 0,
        'timeSpent': '0h 0m',
        'lastAccessed': null,
        'difficulty': 'Advanced',
        'score': 0,
        'activities': [
          {'name': 'Project Guidelines', 'completed': false, 'type': 'reading'},
          {
            'name': 'Project Planning',
            'completed': false,
            'type': 'assignment',
          },
          {
            'name': 'Implementation Phase',
            'completed': false,
            'type': 'project',
          },
          {
            'name': 'Peer Review Round',
            'completed': false,
            'type': 'discussion',
          },
          {
            'name': 'Final Presentation',
            'completed': false,
            'type': 'presentation',
          },
          {'name': 'Course Evaluation', 'completed': false, 'type': 'survey'},
        ],
      },
    ];

    // Calculate overall progress
    final totalLessons = modules.fold<int>(
      0,
      (sum, module) => sum + (module['lessons'] as int),
    );
    final completedLessons = modules.fold<int>(
      0,
      (sum, module) => sum + (module['completedLessons'] as int),
    );
    final overallProgress = completedLessons / totalLessons;
    final completedModules = modules
        .where((m) => m['completed'] == true)
        .length;

    // Performance metrics
    final totalTimeSpent = modules.fold<int>(0, (sum, module) {
      final timeStr = module['timeSpent'] as String;
      if (timeStr == '0h 0m') return sum;
      final parts = timeStr.split(' ');
      final hours = int.parse(parts[0].replaceAll('h', ''));
      final minutes = int.parse(parts[1].replaceAll('m', ''));
      return sum + (hours * 60) + minutes;
    });

    final averageScore =
        modules
            .where((m) => m['score'] > 0)
            .fold<double>(0, (sum, m) => sum + m['score']) /
        modules.where((m) => m['score'] > 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Overall Progress
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.8),
                  Colors.teal.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Learning Progress',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your learning journey and achievements',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 20),

                // Overall Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(overallProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: overallProgress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$completedLessons of $totalLessons lessons completed',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    _buildStatCard(
                      'Modules',
                      '$completedModules/${modules.length}',
                      Icons.library_books,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Time Spent',
                      '${(totalTimeSpent / 60).toStringAsFixed(1)}h',
                      Icons.schedule,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Avg Score',
                      '${averageScore.isNaN ? 0 : averageScore.toInt()}%',
                      Icons.star,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Modules Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Modules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(overallProgress * 100).toInt()}% Complete',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Modules List
          ...modules
              .map(
                (module) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    childrenPadding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: module['completed'] == true
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        module['completed'] == true
                            ? Icons.check_circle
                            : Icons.play_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      module['title'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          module['description'] ?? '',
                          style: TextStyle(fontSize: 13, color: subTextColor),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(
                                  module['difficulty'],
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                module['difficulty'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getDifficultyColor(
                                    module['difficulty'],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${module['completedLessons']}/${module['lessons']} lessons',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              module['timeSpent'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: module['progress'],
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            module['completed'] == true
                                ? Colors.green
                                : Colors.orange,
                          ),
                          minHeight: 6,
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (module['score'] > 0) ...[
                          Text(
                            '${module['score']}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(module['score']),
                            ),
                          ),
                          const Text(
                            'Score',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ] else ...[
                          Icon(Icons.keyboard_arrow_down, color: subTextColor),
                        ],
                      ],
                    ),
                    children: [
                      // Activities List
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activities:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(module['activities'] as List)
                              .map(
                                (activity) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        activity['completed']
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: activity['completed']
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _getActivityIcon(activity['type']),
                                        size: 16,
                                        color: subTextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          activity['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      if (activity['score'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getScoreColor(
                                              activity['score'],
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${activity['score']}%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: _getScoreColor(
                                                activity['score'],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const SizedBox(height: 24),

          // Performance Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.purple, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Performance Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceCard(
                        'Completion Rate',
                        '${(overallProgress * 100).toInt()}%',
                        Icons.timeline,
                        Colors.blue,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPerformanceCard(
                        'Average Score',
                        '${averageScore.isNaN ? 0 : averageScore.toInt()}%',
                        Icons.star,
                        Colors.amber,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceCard(
                        'Time Investment',
                        '${(totalTimeSpent / 60).toStringAsFixed(1)} hours',
                        Icons.schedule,
                        Colors.green,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPerformanceCard(
                        'Modules Completed',
                        '$completedModules/${modules.length}',
                        Icons.library_books,
                        Colors.purple,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'quiz':
        return Icons.quiz;
      case 'exercise':
        return Icons.fitness_center;
      case 'assignment':
        return Icons.assignment;
      case 'discussion':
        return Icons.forum;
      case 'reading':
        return Icons.menu_book;
      case 'project':
        return Icons.work;
      case 'presentation':
        return Icons.present_to_all;
      case 'survey':
        return Icons.poll;
      default:
        return Icons.task_alt;
    }
  }
}

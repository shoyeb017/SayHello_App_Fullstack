import 'package:flutter/material.dart';

class RecordedClassTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const RecordedClassTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Enhanced dynamic recordings data
    final recordings = [
      {
        'id': 'rec_1',
        'title': 'Course Introduction & Welcome',
        'description':
            'Get familiar with the course structure and learning objectives.',
        'instructor': course['instructor'] ?? 'John Doe',
        'duration': '18:25',
        'uploaded': '2025-07-20',
        'views': 156,
        'likes': 24,
        'size': '245 MB',
        'quality': '1080p',
        'topics': ['Course Overview', 'Learning Path', 'Resources'],
        'thumbnail': null,
        'isWatched': true,
        'watchProgress': 1.0,
        'lastWatched': '2025-07-21',
      },
      {
        'id': 'rec_2',
        'title': 'Fundamentals & Basic Concepts',
        'description':
            'Learn the essential building blocks and core principles.',
        'instructor': course['instructor'] ?? 'John Doe',
        'duration': '32:45',
        'uploaded': '2025-07-22',
        'views': 98,
        'likes': 31,
        'size': '412 MB',
        'quality': '1080p',
        'topics': ['Basic Concepts', 'Terminology', 'Examples'],
        'thumbnail': null,
        'isWatched': true,
        'watchProgress': 0.7,
        'lastWatched': '2025-07-23',
      },
      {
        'id': 'rec_3',
        'title': 'Advanced Techniques & Applications',
        'description':
            'Dive deeper into advanced concepts with practical applications.',
        'instructor': course['instructor'] ?? 'John Doe',
        'duration': '45:30',
        'uploaded': '2025-07-23',
        'views': 67,
        'likes': 18,
        'size': '567 MB',
        'quality': '1080p',
        'topics': ['Advanced Topics', 'Case Studies', 'Best Practices'],
        'thumbnail': null,
        'isWatched': false,
        'watchProgress': 0.0,
        'lastWatched': null,
      },
      {
        'id': 'rec_4',
        'title': 'Practice Session & Q&A',
        'description':
            'Interactive practice session with common questions answered.',
        'instructor': course['instructor'] ?? 'John Doe',
        'duration': '28:15',
        'uploaded': '2025-07-24',
        'views': 42,
        'likes': 12,
        'size': '298 MB',
        'quality': '720p',
        'topics': ['Practice Exercises', 'Q&A', 'Common Mistakes'],
        'thumbnail': null,
        'isWatched': false,
        'watchProgress': 0.0,
        'lastWatched': null,
      },
    ];

    final watchedCount = recordings.where((r) => r['isWatched'] == true).length;
    final totalDuration = recordings.fold<int>(0, (sum, r) {
      final duration = r['duration'] as String;
      final parts = duration.split(':');
      return sum + int.parse(parts[0]) * 60 + int.parse(parts[1]);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.withOpacity(0.8),
                  Colors.purple.withOpacity(0.6),
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
                    Icon(Icons.ondemand_video, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Recorded Classes',
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
                  'Access all recorded sessions anytime',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      'Total Videos',
                      '${recordings.length}',
                      Icons.video_library,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Watched',
                      '$watchedCount/${recordings.length}',
                      Icons.check_circle,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Duration',
                      '${(totalDuration / 60).toStringAsFixed(0)}h ${totalDuration % 60}m',
                      Icons.schedule,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filter and Sort Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Video Library',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  _buildFilterChip('All', true, context),
                  const SizedBox(width: 8),
                  _buildFilterChip('Watched', false, context),
                  const SizedBox(width: 8),
                  _buildFilterChip('New', false, context),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Recordings List
          ...recordings
              .map(
                (recording) => Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Thumbnail
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.withOpacity(0.8),
                              Colors.purple.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                            // Duration badge
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  recording['duration'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // Quality badge
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  recording['quality'] ?? 'HD',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Watched indicator
                            if (recording['isWatched'] == true)
                              const Positioned(
                                top: 12,
                                left: 12,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                            // Progress bar
                            if (recording['watchProgress'] > 0)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  value: recording['watchProgress'],
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.purple,
                                      ),
                                  minHeight: 4,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Video Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recording['title'] ?? 'Untitled Recording',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recording['description'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: subTextColor,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Video Stats
                            Row(
                              children: [
                                _buildStatIcon(
                                  Icons.remove_red_eye,
                                  '${recording['views']}',
                                  subTextColor,
                                ),
                                const SizedBox(width: 16),
                                _buildStatIcon(
                                  Icons.thumb_up,
                                  '${recording['likes']}',
                                  subTextColor,
                                ),
                                const SizedBox(width: 16),
                                _buildStatIcon(
                                  Icons.storage,
                                  recording['size'] ?? '',
                                  subTextColor,
                                ),
                                const Spacer(),
                                Text(
                                  'Uploaded: ${recording['uploaded']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),

                            if (recording['topics'] != null) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: (recording['topics'] as List)
                                    .map(
                                      (topic) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          topic,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _playVideo(context, recording),
                                    icon: Icon(
                                      recording['watchProgress'] > 0
                                          ? Icons.play_arrow
                                          : Icons.play_circle_fill,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      recording['watchProgress'] > 0
                                          ? 'Continue'
                                          : 'Watch Now',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.purple,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _downloadVideo(context, recording),
                                    icon: const Icon(
                                      Icons.download,
                                      color: Colors.purple,
                                    ),
                                    label: const Text(
                                      'Download',
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
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

  Widget _buildFilterChip(String label, bool isSelected, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.purple,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  void _playVideo(BuildContext context, Map<String, dynamic> recording) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${recording['title']}'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _downloadVideo(BuildContext context, Map<String, dynamic> recording) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading: ${recording['title']}'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

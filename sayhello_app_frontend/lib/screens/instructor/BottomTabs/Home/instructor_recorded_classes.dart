import 'package:flutter/material.dart';

class InstructorRecordedClassesTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorRecordedClassesTab({super.key, required this.course});

  @override
  State<InstructorRecordedClassesTab> createState() =>
      _InstructorRecordedClassesTabState();
}

class _InstructorRecordedClassesTabState
    extends State<InstructorRecordedClassesTab> {
  // Dynamic recorded classes data - replace with backend API later
  List<Map<String, dynamic>> _recordings = [
    {
      'id': 'recording_001',
      'title': 'Flutter Widgets Overview',
      'description':
          'Complete introduction to Flutter widgets and their properties',
      'duration': '45:30',
      'uploadDate': '2025-07-20',
      'views': 156,
      'fileSize': '485 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=11',
      'status': 'published',
    },
    {
      'id': 'recording_002',
      'title': 'State Management Basics',
      'description': 'Understanding state management in Flutter applications',
      'duration': '38:15',
      'uploadDate': '2025-07-18',
      'views': 203,
      'fileSize': '421 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=12',
      'status': 'published',
    },
    {
      'id': 'recording_003',
      'title': 'Navigation and Routing',
      'description': 'Advanced navigation concepts and route management',
      'duration': '52:40',
      'uploadDate': '2025-07-22',
      'views': 89,
      'fileSize': '567 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=13',
      'status': 'processing',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Upload Video Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text(
                'Upload New Video',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // Recordings List
        Expanded(
          child: _recordings.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recordings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildRecordingCard(_recordings[index], isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecordingCard(Map<String, dynamic> recording, bool isDark) {
    final status = recording['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[200]!,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Video Thumbnail
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.network(
                    recording['thumbnail'],
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[400],
                        child: const Icon(
                          Icons.video_library,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  if (status == 'published')
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  if (status == 'processing')
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Video Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recording['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  recording['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recording['duration'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.visibility,
                      size: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recording['views']} views',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    if (status == 'published') ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editRecording(recording),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7A54FF),
                            side: const BorderSide(color: Color(0xFF7A54FF)),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: const Size(0, 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _viewAnalytics(recording),
                          icon: const Icon(
                            Icons.analytics,
                            size: 14,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Analytics',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A54FF),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: const Size(0, 28),
                          ),
                        ),
                      ),
                    ] else if (status == 'processing') ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Processing video...',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No recorded classes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first recorded class',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.upload, color: Colors.white),
            label: const Text(
              'Upload Video',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A54FF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'draft':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showUploadDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Upload Video',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Video upload feature coming soon!\n\nThis will include:\n• File selection and upload\n• Title and description\n• Thumbnail generation\n• Video processing\n• Publishing controls',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF7A54FF)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editRecording(Map<String, dynamic> recording) {
    // TODO: Implement edit recording functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit recording feature coming soon!')),
    );
  }

  void _viewAnalytics(Map<String, dynamic> recording) {
    // TODO: Implement analytics view functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Analytics for: ${recording['title']}')),
    );
  }
}

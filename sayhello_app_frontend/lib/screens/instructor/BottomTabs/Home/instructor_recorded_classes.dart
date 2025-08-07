import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import 'record_class_video_player.dart';
import '../../../../services/video_metadata_service.dart';

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
      'title': 'English Grammar Fundamentals - Tenses',
      'description':
          'Complete guide to English tenses with examples and practice exercises',
      'duration': '45:30',
      'uploadDate': '2025-08-05',
      'uploadTime': '14:30',
      'views': 156,
      'fileSize': '485 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=11',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'status': 'published',
    },
    {
      'id': 'recording_002',
      'title': 'Business English - Email Writing',
      'description':
          'Professional email writing techniques and formal business communication',
      'duration': '38:15',
      'uploadDate': '2025-08-04',
      'uploadTime': '10:15',
      'views': 203,
      'fileSize': '421 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=12',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'status': 'published',
    },
    {
      'id': 'recording_003',
      'title': 'English Speaking - Pronunciation Tips',
      'description':
          'Improve your English pronunciation with phonetics and practice drills',
      'duration': '52:40',
      'uploadDate': '2025-08-03',
      'uploadTime': '16:45',
      'views': 89,
      'fileSize': '567 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=13',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'status': 'published',
    },
    {
      'id': 'recording_004',
      'title': 'IELTS Writing Task 1 - Graph Descriptions',
      'description':
          'Master IELTS Academic Writing Task 1 with graph analysis and description techniques',
      'duration': '41:20',
      'uploadDate': '2025-08-02',
      'uploadTime': '11:00',
      'views': 124,
      'fileSize': '398 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=14',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      'status': 'published',
    },
    {
      'id': 'recording_005',
      'title': 'English Vocabulary Building - Academic Words',
      'description':
          'Essential academic vocabulary for advanced English learners and test preparation',
      'duration': '36:55',
      'uploadDate': '2025-08-01',
      'uploadTime': '13:20',
      'views': 87,
      'fileSize': '354 MB',
      'format': 'MP4',
      'thumbnail': 'https://picsum.photos/300/200?random=15',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'status': 'published',
    },
  ];

  bool _isLoading = true;
  String? _error;
  List<VideoMetadata> _videoMetadataList = [];
  int _loadedVideos = 0;
  int _totalVideos = 0;

  @override
  void initState() {
    super.initState();
    _loadVideoMetadata();
  }

  Future<void> _loadVideoMetadata() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _loadedVideos = 0;
      _totalVideos = _recordings.length;
    });
    try {
      final urls = _recordings.map((r) => r['videoUrl'] as String).toList();
      final titles = _recordings.map((r) => r['title'] as String).toList();
      final metadataList =
          await VideoMetadataService.extractMultipleVideoMetadata(
            urls,
            titles: titles,
            onProgress: (completed, total) {
              if (mounted) {
                setState(() {
                  _loadedVideos = completed;
                  _totalVideos = total;
                });
              }
            },
          );
      if (mounted) {
        setState(() {
          _videoMetadataList = metadataList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    if (_isLoading) {
      final progress = _totalVideos > 0 ? _loadedVideos / _totalVideos : 0.0;
      final percentage = (progress * 100).round();

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 4,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                localizations.loadingVideoMetadata,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.completePercentage(percentage),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              if (_totalVideos > 0) ...[
                const SizedBox(height: 4),
                Text(
                  localizations.videosProcessed(_loadedVideos, _totalVideos),
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                localizations.failedToLoadVideoMetadata,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadVideoMetadata,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  localizations.retryButton,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Upload Video Button - Compact Design
        Container(
          margin: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: const Icon(Icons.video_call, color: Colors.white, size: 18),
              label: Text(
                localizations.uploadNewVideo,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),

        // Recordings List
        Expanded(
          child: _recordings.isEmpty
              ? _buildEmptyState(isDark, primaryColor, localizations)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _getSortedRecordings().length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sortedRecordings = _getSortedRecordings();
                    // Find the corresponding metadata by videoUrl
                    final rec = sortedRecordings[index];
                    final metaIdx = _recordings.indexWhere(
                      (r) => r['videoUrl'] == rec['videoUrl'],
                    );
                    final meta =
                        (metaIdx >= 0 && metaIdx < _videoMetadataList.length)
                        ? _videoMetadataList[metaIdx]
                        : null;
                    return _buildCompactRecordingCard(
                      rec,
                      meta,
                      isDark,
                      primaryColor,
                      textColor,
                      subTextColor,
                      localizations,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Sort recordings by date and time (newest first)
  List<Map<String, dynamic>> _getSortedRecordings() {
    List<Map<String, dynamic>> sortedRecordings = List.from(_recordings);

    sortedRecordings.sort((a, b) {
      try {
        DateTime dateA = DateTime.parse(a['uploadDate'] ?? '1970-01-01');
        DateTime dateB = DateTime.parse(b['uploadDate'] ?? '1970-01-01');

        if (dateA.isAtSameMomentAs(dateB)) {
          TimeOfDay timeA = _parseTime(a['uploadTime'] ?? '00:00');
          TimeOfDay timeB = _parseTime(b['uploadTime'] ?? '00:00');

          int minutesA = timeA.hour * 60 + timeA.minute;
          int minutesB = timeB.hour * 60 + timeB.minute;

          return minutesB.compareTo(minutesA);
        }

        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return sortedRecordings;
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      List<String> parts = timeString.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return default time if parsing fails
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  Widget _buildCompactRecordingCard(
    Map<String, dynamic> recording,
    VideoMetadata? meta,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color? subTextColor,
    AppLocalizations localizations,
  ) {
    final status = recording['status'] as String;
    final showMeta = meta != null && meta.isValid;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Compact Video Thumbnail
          GestureDetector(
            onTap: () => status == 'published' ? _playVideo(recording) : null,
            child: Container(
              width: 60,
              height: 45,
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
                      width: 60,
                      height: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[400],
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    if (status == 'published')
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Video Details - Compact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recording['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  recording['description'],
                  style: TextStyle(fontSize: 11, color: subTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.access_time, size: 11, color: subTextColor),
                    const SizedBox(width: 3),
                    Text(
                      showMeta ? meta.formattedDuration : '--:--',
                      style: TextStyle(fontSize: 10, color: subTextColor),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.sd_storage, size: 11, color: subTextColor),
                    const SizedBox(width: 3),
                    Text(
                      showMeta ? meta.formattedSize : '--',
                      style: TextStyle(fontSize: 10, color: subTextColor),
                    ),
                    const Spacer(),
                    Text(
                      recording['uploadDate'],
                      style: TextStyle(fontSize: 10, color: subTextColor),
                    ),
                  ],
                ),
                if (meta != null && !meta.isValid && meta.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      localizations.metadataError(meta.error!),
                      style: TextStyle(fontSize: 10, color: Colors.red),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action Buttons - Compact
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                height: 28,
                child: ElevatedButton(
                  onPressed: () => _editRecording(recording, localizations),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    localizations.edit,
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                height: 28,
                child: OutlinedButton(
                  onPressed: () => _deleteRecording(recording, localizations),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    localizations.delete,
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color primaryColor,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noRecordedVideosYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.uploadYourFirstRecordedClass,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(Map<String, dynamic> recording) {
    final localizations = AppLocalizations.of(context)!;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF7A54FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.loadingVideoPlayer,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Close loading dialog and open video player
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InstructorRecordClassVideoPlayer(
            videoUrl: recording['videoUrl'],
            title: recording['title'],
            thumbnail: recording['thumbnail'] ?? '',
            duration: recording['duration'],
          ),
        ),
      );
    });
  }

  void _editRecording(
    Map<String, dynamic> recording,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(text: recording['title']);
    final descriptionController = TextEditingController(
      text: recording['description'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            localizations.editVideoDetails,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: localizations.videoTitle,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF7A54FF)),
                    ),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: localizations.description,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF7A54FF)),
                    ),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final index = _recordings.indexWhere(
                    (r) => r['id'] == recording['id'],
                  );
                  if (index != -1) {
                    _recordings[index]['title'] = titleController.text;
                    _recordings[index]['description'] =
                        descriptionController.text;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.videoUpdatedSuccessfully),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.save),
            ),
          ],
        );
      },
    );
  }

  void _deleteRecording(
    Map<String, dynamic> recording,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            localizations.deleteVideo,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.areYouSureDeleteVideo,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recording['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recording['views']} views • ${recording['uploadDate']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.thisActionCannotBeUndone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _recordings.removeWhere((r) => r['id'] == recording['id']);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.videoDeleted(recording['title']),
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.delete),
            ),
          ],
        );
      },
    );
  }

  void _showUploadDialog() {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedFile = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              title: Text(
                localizations.uploadNewVideoDialog,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File Selection Area
                    GestureDetector(
                      onTap: () async {
                        // Simulate file picker
                        setState(() {
                          selectedFile =
                              'recorded_lesson_${DateTime.now().millisecondsSinceEpoch}.mp4';
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              localizations.fileSelected(selectedFile),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedFile.isEmpty
                                ? (isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[300]!)
                                : Color(0xFF7A54FF),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: selectedFile.isEmpty
                              ? null
                              : Color(0xFF7A54FF).withOpacity(0.1),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              selectedFile.isEmpty
                                  ? Icons.upload_file
                                  : Icons.check_circle,
                              size: 32,
                              color: selectedFile.isEmpty
                                  ? (isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400])
                                  : Color(0xFF7A54FF),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedFile.isEmpty
                                  ? localizations.tapToSelectVideoFile
                                  : localizations.fileSelectedPrefix(
                                      selectedFile,
                                    ),
                              style: TextStyle(
                                color: selectedFile.isEmpty
                                    ? (isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600])
                                    : (isDark ? Colors.white : Colors.black),
                                fontSize: 12,
                                fontWeight: selectedFile.isEmpty
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title Input
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: localizations.videoTitleRequired,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF7A54FF),
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description Input
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: localizations.description,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF7A54FF),
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    localizations.cancel,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      selectedFile.isNotEmpty && titleController.text.isNotEmpty
                      ? () {
                          _uploadVideo(
                            selectedFile,
                            titleController.text,
                            descriptionController.text,
                            localizations,
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A54FF),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localizations.uploadButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _uploadVideo(
    String fileName,
    String title,
    String description,
    AppLocalizations localizations,
  ) {
    final List<String> sampleVideoUrls = [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    ];

    final now = DateTime.now();
    final newRecording = {
      'id': 'recording_${now.millisecondsSinceEpoch}',
      'title': title,
      'description': description.isNotEmpty
          ? description
          : 'Recorded class video',
      'duration': '00:00',
      'uploadDate': now.toString().split(' ')[0],
      'uploadTime':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'views': 0,
      'fileSize': '0 MB',
      'format': 'MP4',
      'thumbnail':
          'https://picsum.photos/300/200?random=${_recordings.length + 20}',
      'videoUrl': sampleVideoUrls[_recordings.length % sampleVideoUrls.length],
      'status': 'processing',
    };

    setState(() {
      _recordings.insert(0, newRecording); // Add to top (newest first)
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.uploadingVideo(title)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate processing completion
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          final index = _recordings.indexWhere(
            (r) => r['id'] == newRecording['id'],
          );
          if (index != -1) {
            _recordings[index]['status'] = 'published';
            _recordings[index]['duration'] =
                '${(15 + (index * 3))}:${(30 + (index * 5)).toString().padLeft(2, '0')}';
            _recordings[index]['fileSize'] = '${200 + (index * 30)} MB';
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.videoPublishedSuccessfully(title)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/record_class_provider.dart';
import '../../../../../models/record_class.dart';
import '../../../../../utils/video_thumbnail_generator.dart';
import 'record_class_video_player.dart';

class InstructorRecordClassTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorRecordClassTab({super.key, required this.course});

  @override
  State<InstructorRecordClassTab> createState() =>
      _InstructorRecordClassTabState();
}

class _InstructorRecordClassTabState extends State<InstructorRecordClassTab> {
  @override
  void initState() {
    super.initState();
    // Load record classes when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecordClasses();
    });
  }

  /// Load record classes for this course
  void _loadRecordClasses() {
    if (!mounted) return;

    final recordClassProvider = context.read<RecordClassProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId != null) {
      recordClassProvider.loadRecordClasses(courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Consumer<RecordClassProvider>(
      builder: (context, recordClassProvider, child) {
        final recordClasses = recordClassProvider.recordClasses;

        return Column(
          children: [
            // Add Record Class Button
            Container(
              margin: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddVideoLinkDialog(localizations),
                  icon: const Icon(
                    Icons.add_link,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    'Add Record Class',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),

            // Record Classes List
            Expanded(
              child: recordClassProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recordClasses.isEmpty
                  ? _buildEmptyState(isDark, primaryColor, localizations)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: recordClasses.length,
                      itemBuilder: (context, index) {
                        return _buildRecordClassCard(
                          recordClasses[index],
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
      },
    );
  }

  Widget _buildRecordClassCard(
    RecordClass recordClass,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color? subTextColor,
    AppLocalizations localizations,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Thumbnail Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
              child: Stack(
                children: [
                  // Dynamic Thumbnail Generation
                  FutureBuilder<String?>(
                    future: VideoThumbnailGenerator.getBestThumbnail(
                      recordClass.recordedLink,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 100,
                          height: 80,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Image.network(
                          snapshot.data!,
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildCompactFallbackThumbnail(isDark);
                          },
                        );
                      }

                      return _buildCompactFallbackThumbnail(isDark);
                    },
                  ),
                  // Play Button Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _playVideo(recordClass),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: primaryColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recordClass.recordedName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Action Icons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () =>
                                _editRecordClass(recordClass, localizations),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_outlined,
                                color: primaryColor,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () =>
                                _deleteRecordClass(recordClass, localizations),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Description (if available)
                  if (recordClass.recordedDescription.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      recordClass.recordedDescription,
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Bottom Row - Date and Actions
                  Row(
                    children: [
                      // Date
                      Icon(Icons.access_time, size: 10, color: subTextColor),
                      const SizedBox(width: 3),
                      Text(
                        recordClass.formattedCreatedAt,
                        style: TextStyle(fontSize: 10, color: subTextColor),
                      ),

                      const Spacer(),

                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Copy Link Button
                          InkWell(
                            onTap: () =>
                                _copyVideoLink(recordClass, localizations),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 10,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Copy',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Play Button
                          InkWell(
                            onTap: () => _playVideo(recordClass),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_arrow,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Play',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFallbackThumbnail(bool isDark) {
    return Container(
      width: 100,
      height: 80,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 20,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 3),
          Text(
            'Video',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 8,
            ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.video_library_outlined,
              size: 48,
              color: primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noRecordedVideosYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Record Class" to get started',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVideoLinkDialog(AppLocalizations localizations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Add Record Class',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16, // Reduced from 18
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height:
                MediaQuery.of(context).size.height * 0.45, // Reduced from 0.5
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Video Link Input
                  TextField(
                    controller: linkController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13, // Reduced from default
                    ),
                    decoration: InputDecoration(
                      labelText: 'Video Link (Required)',
                      hintText:
                          'https://youtube.com/watch?v=... or https://example.com/video.mp4',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12, // Reduced from default
                      ),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 11, // Reduced from 12
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF7A54FF)),
                      ),
                      prefixIcon: const Icon(
                        Icons.link,
                        color: Color(0xFF7A54FF),
                        size: 18, // Reduced icon size
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ), // Reduced padding
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16
                  // Title Input
                  TextField(
                    controller: titleController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13, // Reduced from default
                    ),
                    decoration: InputDecoration(
                      labelText: 'Video Title (Required)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12, // Reduced from default
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF7A54FF)),
                      ),
                      prefixIcon: const Icon(
                        Icons.title,
                        color: Color(0xFF7A54FF),
                        size: 18, // Reduced icon size
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ), // Reduced padding
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16
                  // Description Input
                  TextField(
                    controller: descriptionController,
                    maxLines: 2, // Reduced from 3
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13, // Reduced from default
                    ),
                    decoration: InputDecoration(
                      labelText: localizations.description,
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12, // Reduced from default
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF7A54FF)),
                      ),
                      prefixIcon: const Icon(
                        Icons.description,
                        color: Color(0xFF7A54FF),
                        size: 18, // Reduced icon size
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ), // Reduced padding
                    ),
                  ),
                  const SizedBox(height: 10), // Reduced from 12
                  // Help Text
                  Container(
                    padding: const EdgeInsets.all(10), // Reduced from 12
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A54FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF7A54FF).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Supported Video Sources',
                          style: TextStyle(
                            fontSize: 11, // Reduced from 12
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7A54FF),
                          ),
                        ),
                        const SizedBox(height: 3), // Reduced from 4
                        Text(
                          'YouTube, Vimeo, Dailymotion, or direct video file links (.mp4, .mov, .avi, etc.)\nThumbnails are automatically generated from video sources.',
                          style: TextStyle(
                            fontSize: 10, // Reduced from 11
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                _addVideoLink(
                  linkController.text,
                  titleController.text,
                  descriptionController.text,
                  localizations,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ), // Reduced padding
              ),
              child: const Text(
                'Add Record Class',
                style: TextStyle(fontSize: 13), // Reduced from default
              ),
            ),
          ],
        );
      },
    );
  }

  void _addVideoLink(
    String videoLink,
    String title,
    String description,
    AppLocalizations localizations,
  ) async {
    if (videoLink.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.fillAllRequiredFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate URL format
    if (!_isValidVideoUrl(videoLink)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid video URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    final recordClassProvider = context.read<RecordClassProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId != null) {
      final success = await recordClassProvider.addVideoLink(
        courseId: courseId,
        recordedName: title,
        recordedDescription: description,
        videoLink: videoLink,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Video link added successfully!'
                  : recordClassProvider.error ?? 'Failed to add video',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidVideoUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Check if it's a valid URL with http/https scheme
      if (!uri.hasScheme ||
          (!url.startsWith('http://') && !url.startsWith('https://'))) {
        return false;
      }

      // Check for supported video sources
      final host = uri.host.toLowerCase();

      // YouTube URLs (multiple formats)
      if (host.contains('youtube.com') ||
          host.contains('youtu.be') ||
          host.contains('youtube-nocookie.com') ||
          host.contains('m.youtube.com')) {
        return true;
      }

      // Vimeo URLs
      if (host.contains('vimeo.com') || host.contains('player.vimeo.com')) {
        return true;
      }

      // Dailymotion URLs
      if (host.contains('dailymotion.com') || host.contains('dai.ly')) {
        return true;
      }

      // Twitch URLs
      if (host.contains('twitch.tv') || host.contains('clips.twitch.tv')) {
        return true;
      }

      // Direct video file URLs (check file extension)
      final path = uri.path.toLowerCase();
      if (path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv') ||
          path.endsWith('.webm') ||
          path.endsWith('.m4v') ||
          path.endsWith('.flv') ||
          path.endsWith('.3gp') ||
          path.endsWith('.wmv') ||
          path.endsWith('.ogv')) {
        return true;
      }

      // If it's a valid URL but not a recognized video platform,
      // still allow it (might be a custom video hosting)
      return true;
    } catch (e) {
      return false;
    }
  }

  void _editRecordClass(
    RecordClass recordClass,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(
      text: recordClass.recordedName,
    );
    final descriptionController = TextEditingController(
      text: recordClass.recordedDescription,
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
              onPressed: () => _updateRecordClass(
                recordClass.id,
                titleController.text,
                descriptionController.text,
                localizations,
              ),
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

  void _updateRecordClass(
    String recordClassId,
    String title,
    String description,
    AppLocalizations localizations,
  ) async {
    Navigator.of(context).pop();

    final recordClassProvider = context.read<RecordClassProvider>();
    final success = await recordClassProvider.updateRecordClass(
      recordClassId: recordClassId,
      recordedName: title,
      recordedDescription: description,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Video updated successfully!'
                : recordClassProvider.error ?? 'Failed to update video',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _deleteRecordClass(
    RecordClass recordClass,
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
                      recordClass.recordedName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recordClass.formattedCreatedAt,
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
                style: const TextStyle(
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
              onPressed: () =>
                  _confirmdeleteRecordClass(recordClass.id, localizations),
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

  void _confirmdeleteRecordClass(
    String recordClassId,
    AppLocalizations localizations,
  ) async {
    Navigator.of(context).pop();

    final recordClassProvider = context.read<RecordClassProvider>();
    final success = await recordClassProvider.deleteRecordClass(recordClassId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Video deleted successfully!'
                : recordClassProvider.error ?? 'Failed to delete video',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _playVideo(RecordClass recordClass) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorRecordClassVideoPlayer(
          videoUrl: recordClass.recordedLink,
          title: recordClass.recordedName,
        ),
      ),
    );
  }

  void _copyVideoLink(
    RecordClass recordClass,
    AppLocalizations localizations,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: recordClass.recordedLink));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video link copied to clipboard!'),
            backgroundColor: const Color(0xFF7A54FF),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy link'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

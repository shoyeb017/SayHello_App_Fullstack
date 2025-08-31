import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/record_class_provider.dart';
import '../../../../../../models/record_class.dart';
import '../../../../../../utils/video_thumbnail_generator.dart';
import '../../../../instructor/BottomTabs/Home/record_class_video_player.dart';

class RecordedClassTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const RecordedClassTab({super.key, required this.course});

  @override
  State<RecordedClassTab> createState() => _RecordedClassTabState();
}

class _RecordedClassTabState extends State<RecordedClassTab> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Consumer<RecordClassProvider>(
      builder: (context, recordClassProvider, child) {
        final recordClasses = recordClassProvider.recordClasses;

        if (recordClassProvider.isLoading) {
          return _buildLoadingState(primaryColor);
        }

        if (recordClasses.isEmpty) {
          return _buildEmptyState(primaryColor, textColor);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.8), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.ondemand_video,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.recordedClasses,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.accessAllRecordedSessions,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.totalVideos,
                            '${recordClasses.length}',
                            Icons.video_library,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildStatCard(
                            'Available',
                            '${recordClasses.length}',
                            Icons.schedule,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildStatCard(
                            'Ready',
                            '${recordClasses.length}',
                            Icons.storage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Video Library Section
              Text(
                AppLocalizations.of(context)!.videoLibrary,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 12),

              // Video List with Real Backend Data
              ...recordClasses.map((recordClass) {
                return _buildRecordClassCard(
                  recordClass,
                  isDark,
                  primaryColor,
                  textColor,
                  subTextColor,
                );
              }).toList(),
            ],
          ),
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
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail
          GestureDetector(
            onTap: () => _playRecordClassVideo(recordClass),
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.8), primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }

                      return _buildFallbackThumbnail(isDark);
                    },
                  ),
                  // Play Button Overlay
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Video Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recordClass.recordedName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                if (recordClass.recordedDescription.isNotEmpty) ...[
                  Text(
                    recordClass.recordedDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                ],

                // Video Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        _formatDate(recordClass.createdAt),
                        subTextColor ?? Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        'Available',
                        subTextColor ?? Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _playRecordClassVideo(recordClass),
                    icon: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.watchNow,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(bool isDark) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Video',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildLoadingState(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.loadingVideoMetadata,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              AppLocalizations.of(context)!.noRecordedVideosYet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for recorded sessions',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Color(0xFF7A54FF)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _playRecordClassVideo(RecordClass recordClass) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorRecordClassVideoPlayer(
          videoUrl: recordClass.recordedLink,
          title: recordClass.recordedName,
        ),
      ),
    );
  }
}

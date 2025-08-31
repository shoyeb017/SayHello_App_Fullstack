import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/study_material_provider.dart';
import '../../../../../models/study_material.dart';
import 'study_material_viewer.dart';

class StudyMaterialTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const StudyMaterialTab({super.key, required this.course});

  @override
  State<StudyMaterialTab> createState() => _StudyMaterialTabState();
}

class _StudyMaterialTabState extends State<StudyMaterialTab> {
  final Set<String> _expandedDescriptions = <String>{};

  @override
  void initState() {
    super.initState();
    // Load study materials when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudyMaterials();
    });
  }

  /// Load study materials for this course
  void _loadStudyMaterials() {
    if (!mounted) return;

    final studyMaterialProvider = context.read<StudyMaterialProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId != null) {
      studyMaterialProvider.loadStudyMaterials(courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);

    // Consistent theme colors
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

    return Consumer<StudyMaterialProvider>(
      builder: (context, studyMaterialProvider, child) {
        final isLoading = studyMaterialProvider.isLoading;
        final error = studyMaterialProvider.error;
        final materials = studyMaterialProvider.studyMaterials;

        // Calculate statistics from real data
        final totalMaterials = materials.length;
        final pdfCount = materials
            .where((m) => m.materialType.toLowerCase() == 'pdf')
            .length;
        final imageCount = materials
            .where((m) => m.materialType.toLowerCase() == 'image')
            .length;
        final othersCount = materials
            .where(
              (m) => !['pdf', 'image'].contains(m.materialType.toLowerCase()),
            )
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with updated statistics
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.8), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.studyMaterials,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.downloadAndAccessMaterials,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Updated statistics - removed size, added file type counts
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.total,
                            '$totalMaterials',
                            Icons.folder_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.pdfs,
                            '$pdfCount',
                            Icons.picture_as_pdf,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.images,
                            '$imageCount',
                            Icons.image,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.others,
                            '$othersCount',
                            Icons.description,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Error Message
              if (error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading State
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading study materials...',
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              // Empty State
              if (!isLoading && materials.isEmpty)
                _buildEmptyState(isDark, primaryColor),

              // Materials List
              if (!isLoading && materials.isNotEmpty)
                ...materials
                    .map(
                      (material) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black26
                                  : Colors.grey.shade200,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(
                                      material.materialType,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getIcon(material.materialType),
                                    color: _getTypeColor(material.materialType),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        material.materialTitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      // Description with More/Less functionality (limited to 2 lines)
                                      _buildExpandableDescription(
                                        material.id,
                                        material.materialDescription,
                                        subTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action buttons only
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _viewMaterial(context, material),
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)!.view,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: primaryColor),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _downloadMaterial(context, material),
                                    icon: Icon(
                                      Icons.open_in_new,
                                      color: primaryColor,
                                      size: 14,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)!.download,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandableDescription(
    String materialId,
    String description,
    Color textColor,
  ) {
    final isExpanded = _expandedDescriptions.contains(materialId);
    final shouldShowMoreLess =
        description.length > 80; // Reduced from 100 to 80 for 2 lines

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded || !shouldShowMoreLess
              ? description
              : '${description.substring(0, 80)}...', // Show first 80 characters for ~2 lines
          style: TextStyle(fontSize: 12, color: textColor, height: 1.3),
          maxLines: isExpanded ? null : 2, // Limit to 2 lines when collapsed
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (shouldShowMoreLess)
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedDescriptions.remove(materialId);
                } else {
                  _expandedDescriptions.add(materialId);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded
                    ? AppLocalizations.of(context)!.showLess
                    : AppLocalizations.of(context)!.showMore,
                style: TextStyle(
                  color: Color(0xFF7A54FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
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

  IconData _getIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'link':
        return Icons.link;
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.orange;
      case 'link':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _viewMaterial(BuildContext context, StudyMaterial material) {
    final url = material.materialLink;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noUrlAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
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
                  AppLocalizations.of(
                    context,
                  )!.openingFileType(material.materialType.toUpperCase()),
                  style: const TextStyle(
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

    // Close loading dialog and open viewer
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StudyMaterialViewer(
            url: url,
            title: material.materialTitle,
            type: material.materialType,
          ),
        ),
      );
    });
  }

  void _downloadMaterial(BuildContext context, StudyMaterial material) async {
    final url = material.materialLink;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noUrlForDownload),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog first
    final shouldDownload = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.download, color: Color(0xFF7A54FF)),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.downloadFile),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.downloadConfirmation),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF7A54FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.materialTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A54FF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.typeLabel(material.materialType.toUpperCase()),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.browserHandleDownload,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7A54FF),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              icon: Icon(Icons.open_in_new, color: Colors.white, size: 16),
              label: Text(
                AppLocalizations.of(context)!.openInBrowser,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDownload != true) return;

    try {
      // Parse the URL
      final uri = Uri.parse(url);

      // Launch the URL in browser for download
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Force external browser
      );

      if (launched) {
        // Download successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download started successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Fallback: copy link to clipboard
        await _copyUrlToClipboard(context, url, material.materialTitle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotOpenBrowser),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Error handling: copy link to clipboard as fallback
      await _copyUrlToClipboard(context, url, material.materialTitle);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.failedToOpenBrowser),
              Text(
                AppLocalizations.of(context)!.linkCopiedInstead,
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.retry,
            textColor: Colors.white,
            onPressed: () => _downloadMaterial(context, material),
          ),
        ),
      );
    }
  }

  Future<void> _copyUrlToClipboard(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.downloadLinkCopied),
          backgroundColor: Color(0xFF7A54FF),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.pasteAndGo,
            textColor: Colors.white,
            onPressed: () {
              // Show instruction dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      AppLocalizations.of(context)!.downloadInstructions,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.linkCopiedToClipboardViewer('Download link'),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SelectableText(
                            url,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(AppLocalizations.of(context)!.toDownload),
                        Text(AppLocalizations.of(context)!.openYourBrowser),
                        Text(AppLocalizations.of(context)!.pasteLinkInAddress),
                        Text(
                          AppLocalizations.of(context)!.pressEnterToDownload,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context)!.gotIt),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedToCopyLink(e.toString()),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Build empty state when no materials are available
  Widget _buildEmptyState(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No study materials yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Study materials will appear here when instructor uploads them',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

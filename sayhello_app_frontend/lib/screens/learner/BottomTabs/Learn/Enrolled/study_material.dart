import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';
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

    // Enhanced dynamic study materials data with online URLs
    final materials = [
      {
        'id': 'mat_1',
        'title': 'Flutter Development Fundamentals',
        'description':
            'Comprehensive guide covering all essential Flutter concepts, widgets, state management, and best practices. This document includes detailed explanations of Flutter architecture, widget tree concepts, lifecycle methods, and practical examples to help you master mobile app development with Flutter.',
        'type': 'pdf',
        'category': 'Guide',
        'uploaded': '2025-07-20',
        'pages': 24,
        'downloads': 156,
        'rating': 4.8,
        'isDownloaded': true,
        'isFavorite': true,
        'tags': ['fundamentals', 'guide', 'essential'],
        'difficulty': 'Beginner',
        'url':
            'https://pdfs.semanticscholar.org/7980/8de858f8efe21868e782e42be1af624ffdb2.pdf', // Sample PDF URL
      },
      {
        'id': 'mat_2',
        'title': 'Advanced Dart Programming Workbook',
        'description':
            'Interactive workbook with exercises and practical applications for advanced Dart programming concepts. Covers async programming, streams, isolates, and advanced object-oriented programming techniques with real-world examples and coding challenges.',
        'type': 'doc',
        'category': 'Workbook',
        'uploaded': '2025-07-22',
        'pages': 18,
        'downloads': 89,
        'rating': 4.6,
        'isDownloaded': false,
        'isFavorite': true,
        'tags': ['advanced', 'workbook', 'exercises'],
        'difficulty': 'Advanced',
        'url':
            'https://docs.google.com/document/d/1dwPNGDiWvSZLcs9zKhKSMcKA9iQ80x8ZiW9ICu_n_Qs/preview', // Sample DOC URL
      },
      {
        'id': 'mat_3',
        'title': 'Flutter Widget Reference Chart',
        'description':
            'Handy visual reference chart for quick lookup of key Flutter widgets and their properties. Includes commonly used widgets, layout widgets, and material design components with visual examples and code snippets.',
        'type': 'image',
        'category': 'Reference',
        'uploaded': '2025-07-23',
        'pages': 2,
        'downloads': 203,
        'rating': 4.9,
        'isDownloaded': true,
        'isFavorite': false,
        'tags': ['reference', 'quick', 'chart'],
        'difficulty': 'All Levels',
        'url': 'https://picsum.photos/800/600?random=1', // Sample image URL
      },
      {
        'id': 'mat_4',
        'title': 'State Management Patterns PDF',
        'description':
            'Complete guide to state management in Flutter applications. Covers Provider, Bloc, Riverpod, and other popular state management solutions with detailed examples and comparisons to help you choose the right approach for your project.',
        'type': 'pdf',
        'category': 'Guide',
        'uploaded': '2025-07-24',
        'pages': 35,
        'downloads': 124,
        'rating': 4.7,
        'isDownloaded': false,
        'isFavorite': true,
        'tags': ['state management', 'patterns', 'architecture'],
        'difficulty': 'Intermediate',
        'url':
            'https://pdfs.semanticscholar.org/7980/8de858f8efe21868e782e42be1af624ffdb2.pdf', // Sample PDF URL
      },
      {
        'id': 'mat_5',
        'title': 'Flutter UI Design Inspiration',
        'description':
            'Collection of beautiful Flutter UI designs and inspirations. This visual guide showcases modern app design patterns, color schemes, typography choices, and animation examples to inspire your next Flutter project.',
        'type': 'image',
        'category': 'Design',
        'uploaded': '2025-07-25',
        'pages': 1,
        'downloads': 87,
        'rating': 4.5,
        'isDownloaded': false,
        'isFavorite': false,
        'tags': ['design', 'ui', 'inspiration'],
        'difficulty': 'All Levels',
        'url': 'https://picsum.photos/1200/800?random=2', // Sample image URL
      },
      {
        'id': 'mat_6',
        'title': 'API Integration Documentation',
        'description':
            'Detailed documentation for integrating REST APIs in Flutter applications. Covers HTTP requests, JSON parsing, error handling, authentication, and best practices for network programming in mobile apps.',
        'type': 'docx',
        'category': 'Documentation',
        'uploaded': '2025-07-26',
        'pages': 28,
        'downloads': 165,
        'rating': 4.8,
        'isDownloaded': true,
        'isFavorite': true,
        'tags': ['api', 'integration', 'networking'],
        'difficulty': 'Intermediate',
        'url':
            'https://file-examples.com/storage/fe68c1c2fa66f2c6e958a5d/2017/10/file_example_DOC_100kB.doc', // Sample DOCX URL
      },
    ];

    // Calculate statistics
    final totalMaterials = materials.length;
    final pdfCount = materials.where((m) => m['type'] == 'pdf').length;
    final imageCount = materials.where((m) => m['type'] == 'image').length;
    final othersCount = materials
        .where((m) => !['pdf', 'image'].contains(m['type']))
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
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
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

          // Materials List
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
                        color: isDark ? Colors.black26 : Colors.grey.shade200,
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
                                material['type']?.toString(),
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getIcon(material['type']?.toString()),
                              color: _getTypeColor(
                                material['type']?.toString(),
                              ),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material['title']?.toString() ??
                                      AppLocalizations.of(
                                        context,
                                      )!.untitledMaterial,
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
                                  material['id']?.toString() ?? '',
                                  material['description']?.toString() ?? '',
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
                              onPressed: () => _viewMaterial(context, material),
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

  void _viewMaterial(BuildContext context, Map<String, dynamic> material) {
    final url = material['url']?.toString();
    if (url == null || url.isEmpty) {
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
                  AppLocalizations.of(context)!.openingFileType(
                    material['type']?.toString().toUpperCase() ?? 'FILE',
                  ),
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
            title: material['title']?.toString() ?? 'Study Material',
            type: material['type']?.toString() ?? 'file',
          ),
        ),
      );
    });
  }

  void _downloadMaterial(
    BuildContext context,
    Map<String, dynamic> material,
  ) async {
    final url = material['url']?.toString();
    if (url == null || url.isEmpty) {
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
                      material['title']?.toString() ??
                          AppLocalizations.of(context)!.unknown,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A54FF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.fileType(
                        material['type']?.toString().toUpperCase() ?? 'FILE',
                      ),
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
        // Update material status (optional)
        setState(() {
          material['isDownloaded'] = true;
        });
      } else {
        // Fallback: copy link to clipboard
        await _copyUrlToClipboard(
          context,
          url,
          material['title']?.toString() ?? 'File',
        );
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
      await _copyUrlToClipboard(
        context,
        url,
        material['title']?.toString() ?? 'File',
      );
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
                          AppLocalizations.of(context)!.linkCopiedToClipboard,
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
}

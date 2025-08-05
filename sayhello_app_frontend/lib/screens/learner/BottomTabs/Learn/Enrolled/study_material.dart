import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class StudyMaterialTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const StudyMaterialTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Consistent theme colors
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

    // Enhanced dynamic study materials data
    final materials = [
      {
        'id': 'mat_1',
        'title': 'Course Fundamentals Guide',
        'description':
            'Comprehensive guide covering all essential concepts and foundations.',
        'type': 'pdf',
        'category': 'Guide',
        'uploaded': '2025-07-20',
        'size': '2.4 MB',
        'pages': 24,
        'downloads': 156,
        'rating': 4.8,
        'isDownloaded': true,
        'isFavorite': true,
        'tags': ['fundamentals', 'guide', 'essential'],
        'difficulty': 'Beginner',
      },
      {
        'id': 'mat_2',
        'title': 'Advanced Techniques Workbook',
        'description':
            'Interactive workbook with exercises and practical applications.',
        'type': 'doc',
        'category': 'Workbook',
        'uploaded': '2025-07-22',
        'size': '1.8 MB',
        'pages': 18,
        'downloads': 89,
        'rating': 4.6,
        'isDownloaded': false,
        'isFavorite': true,
        'tags': ['advanced', 'workbook', 'exercises'],
        'difficulty': 'Advanced',
      },
      {
        'id': 'mat_3',
        'title': 'Quick Reference Chart',
        'description':
            'Handy reference chart for quick lookup of key concepts.',
        'type': 'image',
        'category': 'Reference',
        'uploaded': '2025-07-23',
        'size': '854 KB',
        'pages': 2,
        'downloads': 203,
        'rating': 4.9,
        'isDownloaded': true,
        'isFavorite': false,
        'tags': ['reference', 'quick', 'chart'],
        'difficulty': 'All Levels',
      },
    ];

    final downloadedCount = materials
        .where((m) => m['isDownloaded'] == true)
        .length;
    final totalSize = materials.fold<double>(0, (sum, m) {
      final sizeStr = m['size'] as String;
      if (sizeStr.contains('MB')) {
        return sum + double.parse(sizeStr.replaceAll(' MB', ''));
      } else if (sizeStr.contains('KB')) {
        return sum + double.parse(sizeStr.replaceAll(' KB', '')) / 1024;
      }
      return sum;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: double.infinity),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.8),
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
                Row(
                  children: [
                    Icon(Icons.description, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.studyMaterials,
                        style: TextStyle(
                          fontSize: 20,
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
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatCard(
                      AppLocalizations.of(context)!.totalMaterials,
                      '${materials.length}',
                      Icons.folder_outlined,
                    ),
                    _buildStatCard(
                      AppLocalizations.of(context)!.downloaded,
                      '$downloadedCount',
                      Icons.download_done,
                    ),
                    _buildStatCard(
                      AppLocalizations.of(context)!.totalSize,
                      '${totalSize.toStringAsFixed(1)} MB',
                      Icons.storage,
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
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                material['type']?.toString(),
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIcon(material['type']?.toString()),
                              color: _getTypeColor(
                                material['type']?.toString(),
                              ),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (material['title'] ?? 'Untitled Material')
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (material['description'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subTextColor,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
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
                              onPressed: () => _openMaterial(context, material),
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.view,
                                style: TextStyle(
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
                                side: BorderSide(color: Colors.purple),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () =>
                                  _downloadMaterial(context, material),
                              icon: Icon(
                                material['isDownloaded'] == true
                                    ? Icons.download_done
                                    : Icons.download,
                                color: Colors.purple,
                              ),
                              label: Text(
                                material['isDownloaded'] == true
                                    ? AppLocalizations.of(context)!.downloaded
                                    : AppLocalizations.of(context)!.download,
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
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
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
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
        return Icons.description;
      case 'image':
        return Icons.image;
      case 'link':
        return Icons.link;
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'pdf':
        return Colors.red;
      case 'doc':
        return Colors.blue;
      case 'image':
        return Colors.orange;
      case 'link':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _openMaterial(BuildContext context, Map<String, dynamic> material) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.opening}: ${material['title']}',
        ),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _downloadMaterial(BuildContext context, Map<String, dynamic> material) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.downloading}: ${material['title']}',
        ),
        backgroundColor: Colors.purple.shade600,
      ),
    );
  }
}

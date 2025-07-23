import 'package:flutter/material.dart';

class StudyMaterialTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const StudyMaterialTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

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
      {
        'id': 'mat_4',
        'title': 'Practice Problems Set',
        'description':
            'Collection of practice problems with detailed solutions.',
        'type': 'pdf',
        'category': 'Practice',
        'uploaded': '2025-07-24',
        'size': '3.2 MB',
        'pages': 36,
        'downloads': 67,
        'rating': 4.7,
        'isDownloaded': false,
        'isFavorite': false,
        'tags': ['practice', 'problems', 'solutions'],
        'difficulty': 'Intermediate',
      },
      {
        'id': 'mat_5',
        'title': 'Supplementary Resources',
        'description':
            'Additional resources and external links for further learning.',
        'type': 'link',
        'category': 'Resources',
        'uploaded': '2025-07-21',
        'size': '0 KB',
        'pages': 0,
        'downloads': 134,
        'rating': 4.5,
        'isDownloaded': false,
        'isFavorite': true,
        'tags': ['resources', 'links', 'supplementary'],
        'difficulty': 'All Levels',
      },
    ];

    // final categories = ['All', 'Guide', 'Workbook', 'Reference', 'Practice', 'Resources'];
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
                  Colors.teal.withOpacity(0.8),
                  Colors.green.withOpacity(0.6),
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
                    Icon(Icons.description, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Study Materials',
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
                  'Access all course materials and resources',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      'Total Materials',
                      '${materials.length}',
                      Icons.library_books,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Downloaded',
                      '$downloadedCount',
                      Icons.download_done,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Total Size',
                      '${totalSize.toStringAsFixed(1)} MB',
                      Icons.storage,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filter Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Materials Library',
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
                  _buildFilterChip('Downloaded', false, context),
                  const SizedBox(width: 8),
                  _buildFilterChip('Favorites', false, context),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Materials List
          ...materials
              .map(
                (material) => Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (material['title'] ??
                                                  'Untitled Material')
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      if (material['isFavorite'] == true)
                                        const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      if (material['isDownloaded'] == true) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.download_done,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getTypeColor(
                                            material['type']?.toString(),
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          (material['category'] ?? '')
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _getTypeColor(
                                              material['type']?.toString(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${material['rating']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          (material['description'] ?? '').toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: subTextColor,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Material Stats
                        Row(
                          children: [
                            _buildStatInfo(
                              Icons.description,
                              '${material['pages']} pages',
                              subTextColor,
                            ),
                            const SizedBox(width: 16),
                            _buildStatInfo(
                              Icons.file_download,
                              '${material['downloads']} downloads',
                              subTextColor,
                            ),
                            const SizedBox(width: 16),
                            _buildStatInfo(
                              Icons.storage,
                              (material['size'] ?? '').toString(),
                              subTextColor,
                            ),
                            const Spacer(),
                            Text(
                              (material['difficulty'] ?? '').toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getDifficultyColor(
                                  material['difficulty']?.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (material['tags'] != null) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: (material['tags'] as List)
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.teal,
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
                                  backgroundColor: _getTypeColor(
                                    material['type']?.toString(),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () =>
                                    _openMaterial(context, material),
                                icon: Icon(
                                  material['type'] == 'link'
                                      ? Icons.open_in_new
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  material['type'] == 'link'
                                      ? 'Open Link'
                                      : 'View',
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
                                  side: BorderSide(
                                    color: _getTypeColor(
                                      material['type']?.toString(),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: material['type'] != 'link'
                                    ? () => _downloadMaterial(context, material)
                                    : null,
                                icon: Icon(
                                  material['isDownloaded'] == true
                                      ? Icons.download_done
                                      : Icons.download,
                                  color: _getTypeColor(
                                    material['type']?.toString(),
                                  ),
                                ),
                                label: Text(
                                  material['isDownloaded'] == true
                                      ? 'Downloaded'
                                      : 'Download',
                                  style: TextStyle(
                                    color: _getTypeColor(
                                      material['type']?.toString(),
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  _toggleFavorite(context, material),
                              icon: Icon(
                                material['isFavorite'] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: material['isFavorite'] == true
                                    ? Colors.red
                                    : subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
        color: isSelected ? Colors.teal : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.teal,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
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
        return Icons.insert_drive_file;
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

  void _openMaterial(BuildContext context, Map<String, dynamic> material) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${material['title']}'),
        backgroundColor: _getTypeColor(material['type']),
      ),
    );
  }

  void _downloadMaterial(BuildContext context, Map<String, dynamic> material) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading: ${material['title']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleFavorite(BuildContext context, Map<String, dynamic> material) {
    final isFavorite = material['isFavorite'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Removed from favorites' : 'Added to favorites',
        ),
        backgroundColor: isFavorite ? Colors.orange : Colors.red,
      ),
    );
  }
}

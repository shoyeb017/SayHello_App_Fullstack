import 'package:flutter/material.dart';

class InstructorStudyMaterialsTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorStudyMaterialsTab({super.key, required this.course});

  @override
  State<InstructorStudyMaterialsTab> createState() =>
      _InstructorStudyMaterialsTabState();
}

class _InstructorStudyMaterialsTabState
    extends State<InstructorStudyMaterialsTab> {
  // Dynamic study materials data - replace with backend API later
  List<Map<String, dynamic>> _materials = [
    {
      'id': 'material_001',
      'title': 'Flutter Development Guide',
      'description': 'Comprehensive guide to Flutter development',
      'type': 'pdf',
      'fileSize': '12.5 MB',
      'uploadDate': '2025-07-20',
      'downloads': 45,
      'category': 'Documentation',
    },
    {
      'id': 'material_002',
      'title': 'Widget Reference Chart',
      'description': 'Quick reference for commonly used Flutter widgets',
      'type': 'image',
      'fileSize': '2.3 MB',
      'uploadDate': '2025-07-18',
      'downloads': 78,
      'category': 'Reference',
    },
    {
      'id': 'material_003',
      'title': 'Code Examples Repository',
      'description': 'Sample code and project files',
      'type': 'zip',
      'fileSize': '45.7 MB',
      'uploadDate': '2025-07-22',
      'downloads': 32,
      'category': 'Code',
    },
    {
      'id': 'material_004',
      'title': 'Assignment Instructions',
      'description': 'Week 1-4 assignment details and requirements',
      'type': 'doc',
      'fileSize': '1.8 MB',
      'uploadDate': '2025-07-19',
      'downloads': 67,
      'category': 'Assignment',
    },
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Documentation',
    'Reference',
    'Code',
    'Assignment',
  ];

  List<Map<String, dynamic>> get _filteredMaterials {
    if (_selectedCategory == 'All') return _materials;
    return _materials
        .where((material) => material['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Upload Button and Category Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showUploadDialog,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    'Upload Study Material',
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

              const SizedBox(height: 16),

              // Category Filter
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: const Color(0xFF7A54FF).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF7A54FF),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF7A54FF)
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Materials List
        Expanded(
          child: _filteredMaterials.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredMaterials.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildMaterialCard(
                      _filteredMaterials[index],
                      isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material, bool isDark) {
    final type = material['type'] as String;
    final icon = _getFileIcon(type);
    final iconColor = _getFileIconColor(type);

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
          // File Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),

          const SizedBox(width: 16),

          // Material Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  material['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        material['category'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      material['fileSize'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.download,
                      size: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${material['downloads']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editMaterial(material),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7A54FF),
                          side: const BorderSide(color: Color(0xFF7A54FF)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareMaterial(material),
                        icon: const Icon(
                          Icons.share,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Share',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A54FF),
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedCategory == 'All'
                ? 'No study materials yet'
                : 'No materials in $_selectedCategory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory == 'All'
                ? 'Upload your first study material'
                : 'Try a different category',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedCategory == 'All')
            ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text(
                'Upload Material',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
        return Icons.description;
      case 'image':
        return Icons.image;
      case 'zip':
        return Icons.archive;
      case 'video':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String type) {
    switch (type) {
      case 'pdf':
        return Colors.red;
      case 'doc':
        return Colors.blue;
      case 'image':
        return Colors.green;
      case 'zip':
        return Colors.orange;
      case 'video':
        return Colors.purple;
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
            'Upload Study Material',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'File upload feature coming soon!\n\nThis will include:\n• File selection (PDF, DOC, Images, etc.)\n• Title and description\n• Category assignment\n• Access permissions\n• Student notifications',
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

  void _editMaterial(Map<String, dynamic> material) {
    // TODO: Implement edit material functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit material feature coming soon!')),
    );
  }

  void _shareMaterial(Map<String, dynamic> material) {
    // TODO: Implement share material functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sharing: ${material['title']}')));
  }
}

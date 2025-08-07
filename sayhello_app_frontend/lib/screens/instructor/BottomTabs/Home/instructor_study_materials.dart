import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class InstructorStudyMaterialsTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorStudyMaterialsTab({super.key, required this.course});

  @override
  State<InstructorStudyMaterialsTab> createState() =>
      _InstructorStudyMaterialsTabState();
}

class _InstructorStudyMaterialsTabState
    extends State<InstructorStudyMaterialsTab> {
  final Set<String> _expandedDescriptions = <String>{};

  // Dynamic study materials data - sorted by upload time (latest first)
  List<Map<String, dynamic>> _materials = [
    {
      'id': 'mat_1',
      'title': 'Flutter Development Fundamentals Guide',
      'description':
          'Comprehensive guide covering all essential Flutter concepts, widgets, state management, and best practices.',
      'type': 'pdf',
      'uploadDate': '2025-08-07',
      'uploadTime': '14:30',
      'filePath': '/storage/documents/flutter_guide.pdf',
      'fileName': 'flutter_guide.pdf',
      'fileSize': '2.5 MB',
    },
    {
      'id': 'mat_2',
      'title': 'Advanced Dart Programming Examples',
      'description':
          'Interactive examples with practical applications for advanced Dart programming concepts.',
      'type': 'doc',
      'uploadDate': '2025-08-06',
      'uploadTime': '10:15',
      'filePath': '/storage/documents/dart_examples.docx',
      'fileName': 'dart_examples.docx',
      'fileSize': '1.8 MB',
    },
    {
      'id': 'mat_3',
      'title': 'Flutter Widget Reference Chart',
      'description':
          'Visual reference chart for quick lookup of key Flutter widgets and their properties.',
      'type': 'image',
      'uploadDate': '2025-08-05',
      'uploadTime': '16:45',
      'filePath': '/storage/images/widget_chart.png',
      'fileName': 'widget_chart.png',
      'fileSize': '850 KB',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  // Sort materials by date and time (latest first)
  List<Map<String, dynamic>> get _sortedMaterials {
    List<Map<String, dynamic>> sortedMaterials = List.from(_materials);

    sortedMaterials.sort((a, b) {
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

    return sortedMaterials;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Column(
      children: [
        // Upload Button - Compact Design
        Container(
          margin: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: const Icon(
                Icons.upload_file,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                AppLocalizations.of(context)!.uploadStudyMaterial,
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

        // Materials List
        Expanded(
          child: _sortedMaterials.isEmpty
              ? _buildEmptyState(isDark, primaryColor)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _sortedMaterials.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final material = _sortedMaterials[index];

                    return _buildCompactMaterialCard(
                      material,
                      isDark,
                      primaryColor,
                      textColor,
                      subTextColor,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompactMaterialCard(
    Map<String, dynamic> material,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color? subTextColor,
  ) {
    final type = material['type'] as String;
    final typeColor = _getTypeColor(type);

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
          // Compact Type Icon
          GestureDetector(
            onTap: () => _viewMaterial(material),
            child: Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(_getIcon(type), color: typeColor, size: 24),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Material Details - Compact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Expandable Description
                _buildExpandableDescription(
                  material['id'],
                  material['description'],
                  subTextColor!,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    // File Size
                    Icon(Icons.file_present, size: 10, color: subTextColor),
                    const SizedBox(width: 2),
                    Text(
                      material['fileSize'] ?? '--',
                      style: TextStyle(fontSize: 9, color: subTextColor),
                    ),
                    const Spacer(),
                    // Upload Date
                    Text(
                      material['uploadDate'],
                      style: TextStyle(fontSize: 10, color: subTextColor),
                    ),
                  ],
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
                width: 60,
                height: 26,
                child: ElevatedButton(
                  onPressed: () => _editMaterial(material),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.edit,
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                height: 26,
                child: OutlinedButton(
                  onPressed: () => _deleteMaterial(material),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
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
    final shouldShowMoreLess = description.length > 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded || !shouldShowMoreLess
              ? description
              : '${description.substring(0, 60)}...',
          style: TextStyle(fontSize: 11, color: textColor, height: 1.3),
          maxLines: isExpanded ? null : 2,
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
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                isExpanded
                    ? AppLocalizations.of(context)!.showLess
                    : AppLocalizations.of(context)!.showMore,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF7A54FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, Color primaryColor) {
    return Center(
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
            AppLocalizations.of(context)!.noStudyMaterialsYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.uploadYourFirstStudyMaterial,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
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
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
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
      default:
        return Colors.grey;
    }
  }

  void _viewMaterial(Map<String, dynamic> material) {
    final filePath = material['filePath']?.toString();

    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.noFileAvailableForThisMaterial,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show message that file will be opened from local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.openingFile(material['fileName']),
        ),
        backgroundColor: Color(0xFF7A54FF),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate file opening - in real implementation, this would open the actual file
    _showFilePreview(material);
  }

  void _showFilePreview(Map<String, dynamic> material) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Row(
            children: [
              Icon(
                _getIcon(material['type']),
                color: _getTypeColor(material['type']),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  material['title'],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.filePreview,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.fileLabel(material['fileName']),
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                AppLocalizations.of(context)!.sizeLabel(material['fileSize']),
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                AppLocalizations.of(
                  context,
                )!.typeLabel(material['type'].toUpperCase()),
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(material['type']),
                      size: 48,
                      color: _getTypeColor(material['type']),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.filePreview,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.inRealAppDescription,
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(
                        context,
                      )!.openingFileWithSystemViewer(material['fileName']),
                    ),
                    backgroundColor: Color(0xFF7A54FF),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7A54FF),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.openFile),
            ),
          ],
        );
      },
    );
  }

  void _editMaterial(Map<String, dynamic> material) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(text: material['title']);
    final descriptionController = TextEditingController(
      text: material['description'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            AppLocalizations.of(context)!.editMaterialDetails,
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
                    labelText: AppLocalizations.of(context)!.title,
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
                    labelText: AppLocalizations.of(context)!.description,
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
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final index = _materials.indexWhere(
                    (m) => m['id'] == material['id'],
                  );
                  if (index != -1) {
                    _materials[index]['title'] = titleController.text;
                    _materials[index]['description'] =
                        descriptionController.text;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.materialUpdatedSuccessfully,
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  void _deleteMaterial(Map<String, dynamic> material) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            AppLocalizations.of(context)!.deleteMaterial,
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
                AppLocalizations.of(context)!.areYouSureDeleteMaterial,
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
                      material['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${material['category']} • ${material['uploadDate']}',
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
                AppLocalizations.of(context)!.thisActionCannotBeUndone,
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
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _materials.removeWhere((m) => m['id'] == material['id']);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(
                        context,
                      )!.materialDeleted(material['title']),
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
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  void _showUploadDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'pdf';
    String selectedFileName = '';
    String selectedFilePath = '';
    String selectedFileSize = '';

    final types = ['pdf', 'doc', 'image']; // Removed video support

    void _selectFile() {
      // Simulate file selection dialog
      final fileExtensions = {
        'pdf': ['sample_document.pdf', 'research_paper.pdf', 'study_guide.pdf'],
        'doc': ['assignment.docx', 'notes.doc', 'syllabus.docx'],
        'image': ['diagram.png', 'chart.jpg', 'screenshot.png'],
      };

      final availableFiles = fileExtensions[selectedType] ?? [];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            title: Text(
              AppLocalizations.of(
                context,
              )!.selectFileType(selectedType.toUpperCase()),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.chooseFileFromDevice,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ...availableFiles.map((fileName) {
                  return ListTile(
                    leading: Icon(
                      _getIcon(selectedType),
                      color: _getTypeColor(selectedType),
                    ),
                    title: Text(
                      fileName,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${(fileName.length * 123.7).toInt()} KB', // Simulated file size
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      selectedFileName = fileName;
                      selectedFilePath = '/storage/documents/$fileName';
                      selectedFileSize =
                          '${(fileName.length * 123.7).toInt()} KB';
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          );
        },
      ).then((_) {
        // Update the dialog after file selection
        if (selectedFileName.isNotEmpty && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          _showUploadDialog(); // Refresh the dialog with selected file
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[850] : Colors.white,
              title: Text(
                AppLocalizations.of(context)!.uploadStudyMaterial,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // File Selection
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  selectedFileName.isEmpty
                                      ? Icons.file_upload
                                      : _getIcon(selectedType),
                                  color: selectedFileName.isEmpty
                                      ? (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600])
                                      : _getTypeColor(selectedType),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    selectedFileName.isEmpty
                                        ? AppLocalizations.of(
                                            context,
                                          )!.noFileSelected
                                        : selectedFileName,
                                    style: TextStyle(
                                      color: selectedFileName.isEmpty
                                          ? (isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600])
                                          : (isDark
                                                ? Colors.white
                                                : Colors.black),
                                      fontWeight: selectedFileName.isEmpty
                                          ? FontWeight.normal
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (selectedFileName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Size: $selectedFileSize',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _selectFile,
                                icon: const Icon(Icons.folder_open),
                                label: Text(
                                  selectedFileName.isEmpty
                                      ? AppLocalizations.of(context)!.chooseFile
                                      : AppLocalizations.of(
                                          context,
                                        )!.changeFile,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF7A54FF),
                                  side: const BorderSide(
                                    color: Color(0xFF7A54FF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Title Input
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.titleRequired,
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
                          labelText: AppLocalizations.of(context)!.description,
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

                      const SizedBox(height: 16),

                      // Type Selection
                      Text(
                        AppLocalizations.of(context)!.fileType,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: types.map((type) {
                          return ChoiceChip(
                            label: Text(type.toUpperCase()),
                            selected: selectedType == type,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedType = type;
                                  // Clear file selection when type changes
                                  selectedFileName = '';
                                  selectedFilePath = '';
                                  selectedFileSize = '';
                                });
                              }
                            },
                            selectedColor: Color(0xFF7A54FF).withOpacity(0.2),
                            checkmarkColor: Color(0xFF7A54FF),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      selectedFileName.isNotEmpty &&
                          titleController.text.isNotEmpty
                      ? () {
                          _uploadMaterial(
                            selectedFilePath,
                            selectedFileName,
                            selectedFileSize,
                            titleController.text,
                            descriptionController.text,
                            selectedType,
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A54FF),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.upload),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _uploadMaterial(
    String filePath,
    String fileName,
    String fileSize,
    String title,
    String description,
    String type,
  ) {
    final now = DateTime.now();
    final newMaterial = {
      'id': 'mat_${now.millisecondsSinceEpoch}',
      'title': title,
      'description': description.isNotEmpty
          ? description
          : AppLocalizations.of(
              context,
            )!.studyMaterialFor(widget.course['title']),
      'type': type,
      'uploadDate': now.toString().split(' ')[0],
      'uploadTime':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
    };

    setState(() {
      _materials.insert(0, newMaterial); // Add to top (newest first)
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.materialUploadedSuccessfully(title),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

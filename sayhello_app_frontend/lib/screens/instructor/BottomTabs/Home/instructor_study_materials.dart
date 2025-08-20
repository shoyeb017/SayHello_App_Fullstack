import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/study_material_provider.dart';
import '../../../../../models/study_material.dart';
import '../../../../../utils/file_picker_helper.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Refresh study materials
  Future<void> _refreshStudyMaterials() async {
    final studyMaterialProvider = context.read<StudyMaterialProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId != null) {
      await studyMaterialProvider.refreshStudyMaterials(courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Consumer<StudyMaterialProvider>(
      builder: (context, studyMaterialProvider, child) {
        final isLoading = studyMaterialProvider.isLoading;
        final error = studyMaterialProvider.error;
        final studyMaterials = studyMaterialProvider.studyMaterials;

        return Column(
          children: [
            // Upload Button - Compact Design
            Container(
              margin: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _showUploadDialog,
                  icon: const Icon(
                    Icons.upload_file,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    localizations.uploadStudyMaterial,
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

            // Error Message
            if (error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
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
                    IconButton(
                      onPressed: () => studyMaterialProvider.clearError(),
                      icon: Icon(Icons.close, color: Colors.red, size: 16),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

            // Loading Indicator
            if (isLoading)
              Container(
                margin: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading study materials...',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),

            // Materials List
            Expanded(
              child: studyMaterials.isEmpty && !isLoading
                  ? _buildEmptyState(isDark, primaryColor)
                  : RefreshIndicator(
                      onRefresh: () => _refreshStudyMaterials(),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: studyMaterials.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final material = studyMaterials[index];

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
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactMaterialCard(
    StudyMaterial material,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color? subTextColor,
  ) {
    final type = material.type;
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
                  material.title,
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
                  material.id,
                  material.description,
                  subTextColor!,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    // File Size
                    Icon(Icons.file_present, size: 10, color: subTextColor),
                    const SizedBox(width: 2),
                    Text(
                      material.fileSize,
                      style: TextStyle(fontSize: 9, color: subTextColor),
                    ),
                    const Spacer(),
                    // Upload Date
                    Text(
                      material.uploadDate.toString().split(' ')[0],
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

  void _viewMaterial(StudyMaterial material) {
    final downloadUrl = material.downloadUrl;

    if (downloadUrl == null || downloadUrl.isEmpty) {
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

    // Show message and attempt to launch URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.openingFile(material.fileName),
        ),
        backgroundColor: Color(0xFF7A54FF),
        duration: Duration(seconds: 2),
      ),
    );

    _launchUrl(downloadUrl);
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: show file preview dialog
        _showFilePreview(url);
      }
    } catch (e) {
      print('Error launching URL: $e');
      _showFilePreview(url);
    }
  }

  void _showFilePreview(String downloadUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Row(
            children: [
              Icon(Icons.link, color: Color(0xFF7A54FF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'File Access',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File URL:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  downloadUrl,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap "Open File" to access the document in your browser or default app.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
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
                _launchUrl(downloadUrl);
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

  void _editMaterial(StudyMaterial material) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(text: material.title);
    final descriptionController = TextEditingController(
      text: material.description,
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
              onPressed: () async {
                Navigator.of(context).pop();

                final studyMaterialProvider = context
                    .read<StudyMaterialProvider>();
                final success = await studyMaterialProvider.updateStudyMaterial(
                  studyMaterialId: material.id,
                  title: titleController.text,
                  description: descriptionController.text,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.materialUpdatedSuccessfully,
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
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

  void _deleteMaterial(StudyMaterial material) {
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
                      material.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${material.type.toUpperCase()} • ${material.uploadDate.toString().split(' ')[0]}',
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
              onPressed: () async {
                Navigator.of(context).pop();

                final studyMaterialProvider = context
                    .read<StudyMaterialProvider>();
                final success = await studyMaterialProvider.deleteStudyMaterial(
                  material.id,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.materialDeleted(material.title),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
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
    Uint8List? selectedFileBytes;
    String selectedFileSize = '';

    final types = ['pdf', 'doc', 'image'];

    // Alternative file selection using image_picker for images
    Future<void> _selectImageFile() async {
      try {
        final fileData = await FilePickerHelper.pickFile(
          type: 'image',
          withData: true,
        );

        if (fileData != null) {
          selectedFileName = fileData['name'] as String;
          selectedFileBytes = fileData['bytes'] as Uint8List?;
          selectedFileSize = FilePickerHelper.formatFileSize(
            fileData['size'] as int,
          );
          selectedType = 'image';

          // Auto-populate title if empty
          if (titleController.text.isEmpty) {
            String nameWithoutExtension = selectedFileName;
            if (nameWithoutExtension.contains('.')) {
              nameWithoutExtension = nameWithoutExtension.substring(
                0,
                nameWithoutExtension.lastIndexOf('.'),
              );
            }
            titleController.text = nameWithoutExtension.replaceAll('_', ' ');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image "$selectedFileName" selected successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Error selecting image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    // Basic file picker test
    Future<void> _testFilePicker() async {
      try {
        print('Testing basic file picker...');

        // Test if FilePicker.platform is available
        final platform = FilePicker.platform;
        print('FilePicker platform available: true');

        FilePickerResult? result = await platform.pickFiles(
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          print('Test successful: ${file.name}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Test successful! Selected: ${file.name}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('Test cancelled by user');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Test cancelled or no file selected'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } catch (e) {
        print('Test failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    Future<void> _selectFile() async {
      try {
        print('Starting file selection process...');

        final fileData = await FilePickerHelper.pickFile(
          type: selectedType,
          withData: true,
        );

        if (fileData != null) {
          final fileName = fileData['name'] as String;
          final fileBytes = fileData['bytes'] as Uint8List?;
          final fileSize = fileData['size'] as int;
          final fileExtension = fileData['extension'] as String?;

          print('Selected file: $fileName, size: $fileSize bytes');

          // Validate file size (max 10MB)
          const maxSizeInBytes = 10 * 1024 * 1024; // 10MB
          if (fileSize > maxSizeInBytes) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'File size too large. Maximum allowed size is 10MB.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }

          // Check if file bytes are available
          if (fileBytes == null) {
            print('Warning: File bytes are null');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not read file content. Please try a different file.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }

          // Validate file type
          if (!FilePickerHelper.validateFileType(fileName, selectedType)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please select a ${selectedType.toUpperCase()} file. Selected file is ${fileExtension?.toUpperCase() ?? 'unknown'}.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }

          // Update file information
          selectedFileName = fileName;
          selectedFileBytes = fileBytes;
          selectedFileSize = FilePickerHelper.formatFileSize(fileSize);

          // Update the type based on file extension if needed
          if (fileExtension != null) {
            String ext = fileExtension.toLowerCase();
            if (ext == 'pdf') {
              selectedType = 'pdf';
            } else if (['doc', 'docx'].contains(ext)) {
              selectedType = 'doc';
            } else if ([
              'jpg',
              'jpeg',
              'png',
              'gif',
              'bmp',
              'webp',
            ].contains(ext)) {
              selectedType = 'image';
            }
          }

          // Auto-populate title if empty
          if (titleController.text.isEmpty) {
            String nameWithoutExtension = fileName;
            if (nameWithoutExtension.contains('.')) {
              nameWithoutExtension = nameWithoutExtension.substring(
                0,
                nameWithoutExtension.lastIndexOf('.'),
              );
            }
            titleController.text = nameWithoutExtension.replaceAll('_', ' ');
          }

          print('File selection successful: $fileName');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File "$fileName" selected successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('File selection cancelled by user');
        }
      } catch (e, stackTrace) {
        print('Error selecting file: $e');
        print('Stack trace: $stackTrace');

        String errorMessage = 'Error selecting file: ';
        if (e.toString().contains('LateInitializationError') ||
            e.toString().contains('_instance')) {
          errorMessage +=
              'File picker not initialized. Please restart the app and try again.';
        } else if (e.toString().contains('permission')) {
          errorMessage += 'Permission denied. Please check file permissions.';
        } else if (e.toString().contains('not supported')) {
          errorMessage += 'File type not supported on this platform.';
        } else {
          errorMessage += e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Restart App',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please manually restart the app from your device.',
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ),
        );
      }
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
                                onPressed: () async {
                                  await _selectFile();
                                  // Trigger a rebuild of the StatefulBuilder
                                  setState(() {});
                                },
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
                            const SizedBox(height: 8),
                            // Alternative selection methods
                            if (selectedType == 'image') ...[
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await _selectImageFile();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.photo_library),
                                  label: Text('Choose from Gallery'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            // Debug and testing buttons
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      await _testFilePicker();
                                    },
                                    icon: const Icon(
                                      Icons.bug_report,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Test Picker',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      try {
                                        // Simple file picker test without restrictions
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                              allowMultiple: false,
                                              withData: true,
                                            );

                                        if (result != null &&
                                            result.files.isNotEmpty) {
                                          final file = result.files.first;
                                          selectedFileName = file.name;
                                          selectedFileBytes = file.bytes;
                                          selectedFileSize =
                                              FilePickerHelper.formatFileSize(
                                                file.size,
                                              );

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Manual: File selected - ${file.name}',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          setState(() {});
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Manual Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.file_copy, size: 16),
                                    label: Text(
                                      'Pick Any',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
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
                                  selectedFileBytes = null;
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
                          titleController.text.isNotEmpty &&
                          selectedFileBytes != null
                      ? () async {
                          Navigator.of(context).pop();

                          final studyMaterialProvider = context
                              .read<StudyMaterialProvider>();
                          final courseId = widget.course['id']?.toString();

                          if (courseId != null) {
                            final success = await studyMaterialProvider
                                .uploadStudyMaterial(
                                  courseId: courseId,
                                  title: titleController.text,
                                  description:
                                      descriptionController.text.isNotEmpty
                                      ? descriptionController.text
                                      : 'Study material for ${widget.course['title']}',
                                  type: selectedType,
                                  fileName: selectedFileName,
                                  fileBytes: selectedFileBytes!,
                                );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.materialUploadedSuccessfully(
                                      titleController.text,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
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
}

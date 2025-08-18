import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/settings_provider.dart';
import '../../../../../providers/course_provider.dart';
import '../../../../../providers/auth_provider.dart';
import '../../../../../models/instructor.dart';
import '../../instructor_main_tab.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalSessionsController = TextEditingController();

  String _selectedLevel = '';
  double _price = 50.0;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _thumbnailFile;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalSessionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    // Initialize _selectedLevel with localized value if not already set
    if (_selectedLevel.isEmpty) {
      _selectedLevel = localizations.beginner;
    }
    ;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  // Navigate back to instructor main tab (homepage)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InstructorMainTab(),
                    ),
                  );
                },
              ),

              Expanded(
                child: Text(
                  localizations.createNewCourse,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),

              // 🔧 SETTINGS ICON - This is the settings button in the app bar
              // Click this to open the settings bottom sheet with theme and language options
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () =>
                    SettingsProvider.showSettingsBottomSheet(context),
              ),
            ],
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7A54FF),
                      const Color(0xFF7A54FF).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.createYourCourse,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.fillDetailsToCreateCourse,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Course Title
              _buildSectionTitle(
                localizations.courseTitle,
                Icons.title,
                isDark,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hintText: localizations.enterCourseTitle,
                isDark: isDark,
                localizations: localizations,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterCourseTitle;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Course Description
              _buildSectionTitle(
                localizations.description,
                Icons.description,
                isDark,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: localizations.describeCourse,
                isDark: isDark,
                localizations: localizations,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterCourseDescription;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Level and Total Sessions Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          localizations.level,
                          Icons.trending_up,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedLevel,
                          items: [
                            localizations.beginner,
                            localizations.intermediate,
                            localizations.advanced,
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value!;
                            });
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          localizations.totalSessions,
                          Icons.video_library,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _totalSessionsController,
                          hintText: localizations.totalSessionsHint,
                          isDark: isDark,
                          localizations: localizations,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.enterSessions;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price Section
              _buildSectionTitle(
                localizations.priceInDollars,
                Icons.attach_money,
                isDark,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Price display with buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_price > 0) _price -= 1;
                            });
                          },
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: const Color(0xFF7A54FF),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '\$${_price.round()}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7A54FF),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_price < 500) _price += 1;
                            });
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: const Color(0xFF7A54FF),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Price slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF7A54FF),
                        inactiveTrackColor: isDark
                            ? Colors.grey[700]
                            : Colors.grey[400],
                        thumbColor: const Color(0xFF7A54FF),
                        overlayColor: const Color(0xFF7A54FF).withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _price,
                        min: 0,
                        max: 500,
                        divisions: 500,
                        onChanged: (value) {
                          setState(() {
                            _price = value;
                          });
                        },
                      ),
                    ),
                    // Price range labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.free,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          '\$500',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Course Schedule
              _buildSectionTitle(
                localizations.courseSchedule,
                Icons.calendar_today,
                isDark,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateCard(
                      localizations.startDate,
                      _startDate,
                      () => _selectDate(true),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateCard(
                      localizations.endDate,
                      _endDate,
                      () => _selectDate(false),
                      isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Thumbnail
              _buildSectionTitle(
                localizations.courseThumbnail,
                Icons.image,
                isDark,
              ),
              const SizedBox(height: 8),
              _buildThumbnailPicker(isDark),

              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  localizations.publishCourse,
                  Icons.publish,
                  const Color(0xFF7A54FF),
                  () => _publishCourse(),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7A54FF), size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    required AppLocalizations localizations,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: maxLines == 1 ? 48 : null, // Fixed height for single line fields
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Container(
      height: 48, // Fixed height to match text field
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateCard(
    String label,
    DateTime? date,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: const Color(0xFF7A54FF),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : AppLocalizations.of(context)!.selectDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: date != null
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPicker(bool isDark) {
    return GestureDetector(
      onTap: _selectThumbnail,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
            style: BorderStyle.solid,
          ),
        ),
        child: _thumbnailFile != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(_thumbnailFile!, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _thumbnailFile = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.selectCourseThumbnail,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG (Max 5MB)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF7A54FF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectThumbnail() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _thumbnailFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _publishCourse() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pleaseSelectStartEndDates,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_thumbnailFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pleaseSelectCourseThumbnail,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // Get the current instructor from auth provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        if (currentUser == null || currentUser is! Instructor) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login as an instructor'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final currentInstructorId = currentUser.id;
        print('Creating course with instructor ID: $currentInstructorId');

        final courseData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'language': 'english', // TODO: Get from settings provider
          'level': _selectedLevel.toLowerCase(),
          'total_sessions': int.parse(_totalSessionsController.text),
          'price': _price,
          'start_date': _startDate!.toIso8601String(),
          'end_date': _endDate!.toIso8601String(),
          'status': DateTime.now().isBefore(_startDate!)
              ? 'upcoming'
              : 'active',
          'created_at': DateTime.now().toIso8601String(),
          'instructor_id': currentInstructorId,
        };

        final courseProvider = Provider.of<CourseProvider>(
          context,
          listen: false,
        );
        final success = await courseProvider.createCourse(
          courseData,
          _thumbnailFile,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.coursePublishedSuccessfully,
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InstructorMainTab()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

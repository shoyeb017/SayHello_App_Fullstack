import 'package:flutter/material.dart';

class CourseDetails extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetails({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dummy data fields or fallback values:
    final title = course['title'] ?? 'Course Title';
    final description = course['description'] ??
        'This is a comprehensive course designed to help you master the language.';
    final instructor = course['instructor'] ?? 'John Doe';
    final startDate = course['startDate'] ?? '2025-07-15';
    final endDate = course['endDate'] ?? '2025-09-15';
    final rating = course['rating'] ?? 4.7;
    final enrolledStudents = course['students'] ?? 42;
    final price = course['price'] ?? 49.99;

    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Description card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: Text(
              description,
              style: TextStyle(fontSize: 15, color: subTextColor, height: 1.4),
            ),
          ),

          const SizedBox(height: 24),

          // Instructor info
          Row(
            children: [
              Icon(Icons.person_outline, size: 22, color: Colors.purple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Instructor: $instructor',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Start Date and End Date (two rows)
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 22, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Start Date:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(width: 8),
              Text(
                startDate,
                style: TextStyle(fontSize: 15, color: subTextColor),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 22, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'End Date:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(width: 8),
              Text(
                endDate,
                style: TextStyle(fontSize: 15, color: subTextColor),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Rating and enrollment
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber.shade400, size: 24),
              const SizedBox(width: 6),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '($enrolledStudents students enrolled)',
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Enroll button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.purple,
                elevation: 5,
                shadowColor: Colors.purpleAccent,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enrolled successfully!')),
                );
              },
              child: Text(
                'Enroll for \$${price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

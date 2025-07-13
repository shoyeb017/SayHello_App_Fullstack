import 'package:flutter/material.dart';

class ProgressTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const ProgressTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> progressData = [
      {'title': 'Module 1: Basics', 'completed': true},
      {'title': 'Module 2: Grammar', 'completed': true},
      {'title': 'Module 3: Conversation', 'completed': false},
      {'title': 'Module 4: Practice Test', 'completed': false},
    ];

    final List<Map<String, dynamic>> feedbackList = [
      {'name': 'Alice', 'comment': 'Very helpful course!', 'rating': 4.5},
      {'name': 'Bob', 'comment': 'Instructor is great at explaining.', 'rating': 5.0},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Progress',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          ...progressData.map((item) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                item['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                color: item['completed'] ? Colors.green : Colors.grey,
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: item['completed'] ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          const Text('Feedback & Ratings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          ...feedbackList.map((fb) {
            return Card(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  fb['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(fb['comment']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${fb['rating']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

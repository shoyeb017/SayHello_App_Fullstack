import 'package:flutter/material.dart';

class StudyMaterialTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const StudyMaterialTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final materials = [
      {
        'title': 'Lesson 1 - Basics PDF',
        'type': 'pdf',
        'uploaded': '2025-07-03',
      },
      {
        'title': 'Vocabulary List - A1',
        'type': 'doc',
        'uploaded': '2025-07-06',
      },
      {
        'title': 'Pronunciation Chart',
        'type': 'image',
        'uploaded': '2025-07-08',
      },
    ];

    IconData getIcon(String type) {
      switch (type) {
        case 'pdf':
          return Icons.picture_as_pdf;
        case 'doc':
          return Icons.description;
        case 'image':
          return Icons.image;
        default:
          return Icons.insert_drive_file;
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = materials[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                getIcon(item['type']!),
                size: 32,
                color: Colors.purple,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded on ${item['uploaded']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: () {
                  // Download logic here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

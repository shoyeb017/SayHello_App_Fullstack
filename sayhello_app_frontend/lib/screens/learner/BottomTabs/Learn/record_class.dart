import 'package:flutter/material.dart';

class RecordedClassTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const RecordedClassTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recordings = [
      {
        'title': 'Alphabet & Pronunciation',
        'duration': '18:25',
        'uploaded': '2025-07-05',
      },
      {
        'title': 'Basic Greetings & Intros',
        'duration': '22:10',
        'uploaded': '2025-07-07',
      },
      {
        'title': 'Grammar 101: Articles',
        'duration': '19:45',
        'uploaded': '2025-07-09',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recordings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = recordings[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.purple,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title'] ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),
                    Text(
                      '${record['duration']} • Uploaded on ${record['uploaded']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: () {
                  // download logic here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class OnlineSessionTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const OnlineSessionTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sessions = [
      {
        'title': 'Intro to Spanish Basics',
        'platform': 'Zoom',
        'date': '2025-07-14',
        'time': '6:00 PM',
        'link': 'https://zoom.us/sample-link',
      },
      {
        'title': 'Conversational Practice',
        'platform': 'Google Meet',
        'date': '2025-07-17',
        'time': '4:30 PM',
        'link': 'https://meet.google.com/sample-link',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session['title'] ?? 'Untitled',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(session['date'] ?? 'Untitled', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(session['time'] ?? 'Untitled', style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    session['platform'] == 'Zoom' ? Icons.videocam : Icons.video_call,
                    size: 16,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    session['platform'] ?? 'Untitled',
                    style: const TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Replace with launch(session['link']);
                    },
                    child: const Text('Join Now'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

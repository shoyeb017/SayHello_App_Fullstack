import 'dart:io';

void main() async {
  final file = File('lib/data/feedback_data.dart');
  String content = await file.readAsString();

  // Replace course_name with title in SQL queries
  content = content.replaceAll(
    'courses:course_id(course_name)',
    'courses:course_id(title)',
  );

  // Replace course_name references in data mapping
  content = content.replaceAll(
    "courseData?['course_name']",
    "courseData?['title']",
  );

  await file.writeAsString(content);
  print('Fixed all course_name references to title');
}

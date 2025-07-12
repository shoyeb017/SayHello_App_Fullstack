import 'package:flutter/material.dart';


// Dummy course model
class Course {
  final String title;
  final String subtitle;
  final String image;
  final String level;
  final String language;

  Course({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.level,
    required this.language,
  });
}

class AllCourses extends StatefulWidget {
  const AllCourses({super.key});

  @override
  State<AllCourses> createState() => _AllCoursesState();
}

class _AllCoursesState extends State<AllCourses> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  final List<Course> _courses = [
    Course(
      title: "Beginner Japanese",
      subtitle: "Start learning Hiragana, Katakana & basic phrases",
      image:
          "https://media.licdn.com/dms/image/v2/D5612AQFh1LTlsHzJ3Q/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1681630563933?e=2147483647&v=beta&t=O7CxChf0RCwbWxgnaKRGg1-Sn0LWaV9uQytLUFpJUkY",
      level: "Beginner",
      language: "Japanese",
    ),
    Course(
      title: "Intermediate English",
      subtitle: "Master grammar & conversational fluency",
      image:
          "https://storage.googleapis.com/schoolnet-content/blog/wp-content/uploads/2022/07/How-to-Learn-English-Speaking-at-Home.jpg",
      level: "Intermediate",
      language: "English",
    ),
    Course(
      title: "Spanish for Travelers",
      subtitle: "Learn phrases for your next trip!",
      image:
          "https://tse3.mm.bing.net/th/id/OIP.a53l2z6yyE4sJS0rT1g5UQHaFP?r=0&rs=1&pid=ImgDetMain&o=7&rm=3",
      level: "Beginner",
      language: "Spanish",
    ),
    Course(
      title: "Advanced Korean",
      subtitle: "Read, write & discuss like a native speaker",
      image:
          "https://tse1.mm.bing.net/th/id/OIP.f5aQTyPncS6yIYYAWeRWkQHaE8?r=0&w=640&h=427&rs=1&pid=ImgDetMain&o=7&rm=3",
      level: "Advanced",
      language: "Korean",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(_query.toLowerCase()) ||
              course.language.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Courses',
          style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),
        ),
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _controller,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: "Search courses...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final course = filtered[index];
                  return CourseCard(course: course);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({required this.course, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ), // <-- horizontal padding to narrow card
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade200,
            child: InkWell(
              onTap: () {
                // Course detail navigation
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    course.image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(course.subtitle, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                course.language,
                                style: const TextStyle(
                                  color: Color(0xFF7A56FF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: const Color(0xFF7A56FF),
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                course.level,
                                style: const TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: const Color(0xFF1E88E5),
                                  width: 1,
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
            ),
          ),
        ),
      ),
    );
  }
}

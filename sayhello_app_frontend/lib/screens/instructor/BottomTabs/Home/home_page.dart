import 'package:flutter/material.dart';

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Home'),
        backgroundColor: const Color(0xFF7A54FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Instructor!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A54FF),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('• Total Courses: 5'),
                    Text('• Active Students: 120'),
                    Text('• Pending Reviews: 8'),
                    Text('• This Month Earnings: \$2,450'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: Color(0xFF7A54FF),
                    ),
                    title: Text('New student enrolled in Flutter Course'),
                    subtitle: Text('2 hours ago'),
                  ),
                  ListTile(
                    leading: Icon(Icons.rate_review, color: Color(0xFF7A54FF)),
                    title: Text('New review on React Course'),
                    subtitle: Text('5 hours ago'),
                  ),
                  ListTile(
                    leading: Icon(Icons.message, color: Color(0xFF7A54FF)),
                    title: Text('3 new messages from students'),
                    subtitle: Text('1 day ago'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class InstructorStudentPerformanceTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorStudentPerformanceTab({super.key, required this.course});

  @override
  State<InstructorStudentPerformanceTab> createState() =>
      _InstructorStudentPerformanceTabState();
}

class _InstructorStudentPerformanceTabState
    extends State<InstructorStudentPerformanceTab> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Dynamic student performance data - replace with backend API later
  List<Map<String, dynamic>> _students = [
    {
      'id': 'student_001',
      'name': 'Alice Johnson',
      'email': 'alice.johnson@email.com',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'enrollmentDate': DateTime(2024, 1, 15),
      'progress': 85,
      'status': 'Active',
      'lastSeen': DateTime.now().subtract(const Duration(hours: 2)),
      'attendanceRate': 92,
      'assignments': {'submitted': 8, 'total': 10, 'averageScore': 88},
      'quizzes': {'completed': 5, 'total': 6, 'averageScore': 91},
      'interactions': 45,
      'certificateEligible': true,
    },
    {
      'id': 'student_002',
      'name': 'Bob Wilson',
      'email': 'bob.wilson@email.com',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'enrollmentDate': DateTime(2024, 1, 20),
      'progress': 72,
      'status': 'Active',
      'lastSeen': DateTime.now().subtract(const Duration(days: 1)),
      'attendanceRate': 88,
      'assignments': {'submitted': 7, 'total': 10, 'averageScore': 75},
      'quizzes': {'completed': 4, 'total': 6, 'averageScore': 82},
      'interactions': 32,
      'certificateEligible': false,
    },
    {
      'id': 'student_003',
      'name': 'Carol Smith',
      'email': 'carol.smith@email.com',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'enrollmentDate': DateTime(2024, 1, 10),
      'progress': 95,
      'status': 'Completed',
      'lastSeen': DateTime.now().subtract(const Duration(hours: 1)),
      'attendanceRate': 96,
      'assignments': {'submitted': 10, 'total': 10, 'averageScore': 94},
      'quizzes': {'completed': 6, 'total': 6, 'averageScore': 96},
      'interactions': 67,
      'certificateEligible': true,
    },
    {
      'id': 'student_004',
      'name': 'David Brown',
      'email': 'david.brown@email.com',
      'avatar': 'https://i.pravatar.cc/150?img=4',
      'enrollmentDate': DateTime(2024, 2, 1),
      'progress': 45,
      'status': 'At Risk',
      'lastSeen': DateTime.now().subtract(const Duration(days: 5)),
      'attendanceRate': 65,
      'assignments': {'submitted': 4, 'total': 10, 'averageScore': 68},
      'quizzes': {'completed': 2, 'total': 6, 'averageScore': 71},
      'interactions': 18,
      'certificateEligible': false,
    },
    {
      'id': 'student_005',
      'name': 'Eva Garcia',
      'email': 'eva.garcia@email.com',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'enrollmentDate': DateTime(2024, 1, 25),
      'progress': 78,
      'status': 'Active',
      'lastSeen': DateTime.now().subtract(const Duration(hours: 6)),
      'attendanceRate': 85,
      'assignments': {'submitted': 7, 'total': 10, 'averageScore': 81},
      'quizzes': {'completed': 4, 'total': 6, 'averageScore': 86},
      'interactions': 38,
      'certificateEligible': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredStudents {
    var filtered = _students.where((student) {
      final matchesSearch =
          student['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          student['email'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == 'All' || student['status'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort the filtered list
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return _sortAscending
              ? a['name'].compareTo(b['name'])
              : b['name'].compareTo(a['name']);
        case 'progress':
          return _sortAscending
              ? a['progress'].compareTo(b['progress'])
              : b['progress'].compareTo(a['progress']);
        case 'attendance':
          return _sortAscending
              ? a['attendanceRate'].compareTo(b['attendanceRate'])
              : b['attendanceRate'].compareTo(a['attendanceRate']);
        default:
          return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header with stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[50],
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Students',
                      _students.length.toString(),
                      Icons.people,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Avg Progress',
                      '${(_students.map((s) => s['progress']).reduce((a, b) => a + b) / _students.length).round()}%',
                      Icons.trending_up,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'At Risk',
                      _students
                          .where((s) => s['status'] == 'At Risk')
                          .length
                          .toString(),
                      Icons.warning,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      _students
                          .where((s) => s['status'] == 'Completed')
                          .length
                          .toString(),
                      Icons.check_circle,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search and filters
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    items: ['All', 'Active', 'Completed', 'At Risk']
                        .map(
                          (filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value ?? 'All';
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'name',
                        child: Text('Name'),
                      ),
                      const DropdownMenuItem(
                        value: 'progress',
                        child: Text('Progress'),
                      ),
                      const DropdownMenuItem(
                        value: 'attendance',
                        child: Text('Attendance'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value ?? 'name';
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: const Color(0xFF7A54FF),
                    ),
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Actions Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.file_download, size: 18),
                label: const Text('Export Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A54FF),
                  foregroundColor: Colors.white,
                ),
                onPressed: _exportStudentData,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.email, size: 18),
                label: const Text('Send Feedback'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _sendBulkFeedback,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.card_membership, size: 18),
                label: const Text('Issue Certificates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: _issueCertificates,
              ),
            ],
          ),
        ),

        // Students List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredStudents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildStudentCard(_filteredStudents[index], isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF7A54FF), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, bool isDark) {
    final progress = student['progress'] as int;
    final status = student['status'] as String;

    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'At Risk':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(student['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            student['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        student['email'],
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enrolled: ${_formatDate(student['enrollmentDate'])}',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$progress%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view_details',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'send_message',
                      child: Row(
                        children: [
                          Icon(Icons.message, size: 16),
                          SizedBox(width: 8),
                          Text('Send Message'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'give_feedback',
                      child: Row(
                        children: [
                          Icon(Icons.feedback, size: 16),
                          SizedBox(width: 8),
                          Text('Give Feedback'),
                        ],
                      ),
                    ),
                    if (student['certificateEligible'])
                      const PopupMenuItem(
                        value: 'issue_certificate',
                        child: Row(
                          children: [
                            Icon(Icons.card_membership, size: 16),
                            SizedBox(width: 8),
                            Text('Issue Certificate'),
                          ],
                        ),
                      ),
                  ],
                  onSelected: (value) => _handleStudentAction(value, student),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7A54FF),
              ),
            ),
            const SizedBox(height: 12),

            // Performance Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Attendance',
                    '${student['attendanceRate']}%',
                    Icons.calendar_today,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Assignments',
                    '${student['assignments']['submitted']}/${student['assignments']['total']}',
                    Icons.assignment,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Avg Score',
                    '${student['assignments']['averageScore']}%',
                    Icons.grade,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Interactions',
                    '${student['interactions']}',
                    Icons.forum,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7A54FF)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleStudentAction(String action, Map<String, dynamic> student) {
    switch (action) {
      case 'view_details':
        _showStudentDetails(student);
        break;
      case 'send_message':
        _sendMessage(student);
        break;
      case 'give_feedback':
        _giveFeedback(student);
        break;
      case 'issue_certificate':
        _issueCertificate(student);
        break;
    }
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Text(
          'Student Details',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(student['avatar']),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', student['name'], isDark),
              _buildDetailRow('Email', student['email'], isDark),
              _buildDetailRow('Status', student['status'], isDark),
              _buildDetailRow('Progress', '${student['progress']}%', isDark),
              _buildDetailRow(
                'Attendance Rate',
                '${student['attendanceRate']}%',
                isDark,
              ),
              _buildDetailRow(
                'Last Seen',
                _formatLastSeen(student['lastSeen']),
                isDark,
              ),
              const SizedBox(height: 16),
              Text(
                'Academic Performance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Assignments Completed',
                '${student['assignments']['submitted']}/${student['assignments']['total']}',
                isDark,
              ),
              _buildDetailRow(
                'Assignment Average',
                '${student['assignments']['averageScore']}%',
                isDark,
              ),
              _buildDetailRow(
                'Quizzes Completed',
                '${student['quizzes']['completed']}/${student['quizzes']['total']}',
                isDark,
              ),
              _buildDetailRow(
                'Quiz Average',
                '${student['quizzes']['averageScore']}%',
                isDark,
              ),
              _buildDetailRow(
                'Total Interactions',
                '${student['interactions']}',
                isDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF7A54FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _sendMessage(Map<String, dynamic> student) {
    // TODO: Implement messaging functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message feature coming soon for ${student['name']}'),
      ),
    );
  }

  void _giveFeedback(Map<String, dynamic> student) {
    // TODO: Implement feedback functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback feature coming soon for ${student['name']}'),
      ),
    );
  }

  void _issueCertificate(Map<String, dynamic> student) {
    // TODO: Implement certificate issuance
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Certificate issued to ${student['name']}')),
    );
  }

  void _exportStudentData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting student data...')));
  }

  void _sendBulkFeedback() {
    // TODO: Implement bulk feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk feedback feature coming soon')),
    );
  }

  void _issueCertificates() {
    final eligibleStudents = _students
        .where((s) => s['certificateEligible'])
        .length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ready to issue certificates to $eligibleStudents students',
        ),
      ),
    );
  }
}

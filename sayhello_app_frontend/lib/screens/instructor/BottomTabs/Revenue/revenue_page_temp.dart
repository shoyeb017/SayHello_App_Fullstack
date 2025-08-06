import 'package:flutter/material.dart';
import '../../../../../providers/settings_provider.dart';
import '../../instructor_main_tab.dart';

class InstructorRevenuePageTemp extends StatefulWidget {
  const InstructorRevenuePageTemp({super.key});

  @override
  State<InstructorRevenuePageTemp> createState() =>
      _InstructorRevenuePageTempState();
}

class _InstructorRevenuePageTempState extends State<InstructorRevenuePageTemp> {
  bool _showAllCourses = false;
  bool _showAllTransactions = false;

  // Mock data - will be replaced with backend data
  final double totalIncome = 12500.00;
  final double totalPending = 2300.00;
  final double totalWithdrawn = 8900.00;

  // Course enrollments data
  final List<Map<String, dynamic>> courseEnrollments = [
    {
      'courseTitle': 'English Conversation Masterclass',
      'coursePrice': 150.00,
      'enrolledStudents': 45,
      'totalRevenue': 6750.00,
      'enrollmentDates': [
        DateTime.now().subtract(Duration(days: 1)),
        DateTime.now().subtract(Duration(days: 3)),
        DateTime.now().subtract(Duration(days: 7)),
        // ... more dates
      ],
    },
    {
      'courseTitle': 'Japanese for Beginners',
      'coursePrice': 120.00,
      'enrolledStudents': 32,
      'totalRevenue': 3840.00,
      'enrollmentDates': [
        DateTime.now().subtract(Duration(days: 2)),
        DateTime.now().subtract(Duration(days: 5)),
        // ... more dates
      ],
    },
    {
      'courseTitle': 'Advanced Spanish Grammar',
      'coursePrice': 100.00,
      'enrolledStudents': 18,
      'totalRevenue': 1800.00,
      'enrollmentDates': [
        DateTime.now().subtract(Duration(days: 4)),
        DateTime.now().subtract(Duration(days: 8)),
        // ... more dates
      ],
    },
    {
      'courseTitle': 'Korean Culture & Language',
      'coursePrice': 80.00,
      'enrolledStudents': 15,
      'totalRevenue': 1200.00,
      'enrollmentDates': [
        DateTime.now().subtract(Duration(days: 6)),
        // ... more dates
      ],
    },
    {
      'courseTitle': 'French Pronunciation',
      'coursePrice': 90.00,
      'enrolledStudents': 22,
      'totalRevenue': 1980.00,
      'enrollmentDates': [],
    },
  ];

  // Transaction history (withdrawals)
  final List<Map<String, dynamic>> transactionHistory = [
    {
      'id': 'TXN001',
      'amount': 2500.00,
      'date': DateTime.now().subtract(Duration(days: 7)),
      'status': 'Completed',
      'bankAccount': '**** 4521',
    },
    {
      'id': 'TXN002',
      'amount': 1800.00,
      'date': DateTime.now().subtract(Duration(days: 15)),
      'status': 'Completed',
      'bankAccount': '**** 4521',
    },
    {
      'id': 'TXN003',
      'amount': 3200.00,
      'date': DateTime.now().subtract(Duration(days: 30)),
      'status': 'Completed',
      'bankAccount': '**** 4521',
    },
    {
      'id': 'TXN004',
      'amount': 1400.00,
      'date': DateTime.now().subtract(Duration(days: 45)),
      'status': 'Failed',
      'bankAccount': '**** 4521',
    },
  ];

  // Calculate revenue based on time periods
  double calculateWeeklyRevenue() {
    double weeklyRevenue = 0;
    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    for (var course in courseEnrollments) {
      for (var date in course['enrollmentDates']) {
        if (date.isAfter(oneWeekAgo)) {
          weeklyRevenue += course['coursePrice'];
        }
      }
    }
    return weeklyRevenue;
  }

  double calculateMonthlyRevenue() {
    double monthlyRevenue = 0;
    DateTime oneMonthAgo = DateTime.now().subtract(Duration(days: 30));

    for (var course in courseEnrollments) {
      for (var date in course['enrollmentDates']) {
        if (date.isAfter(oneMonthAgo)) {
          monthlyRevenue += course['coursePrice'];
        }
      }
    }
    return monthlyRevenue;
  }

  double calculateYearlyRevenue() {
    return totalIncome; // For now, assuming total income is this year's revenue
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  'Revenue Dashboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Summary Cards
            _buildRevenueSummary(isDark),
            const SizedBox(height: 20),

            // Revenue Chart
            _buildRevenueChart(isDark),
            const SizedBox(height: 20),

            // Course Income Section
            _buildCourseIncome(isDark),
            const SizedBox(height: 20),

            // Transaction History Section
            _buildTransactionHistory(isDark),
            const SizedBox(height: 20),

            // Payment Information & Withdraw Button
            _buildPaymentInfo(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Weekly',
                '\$${calculateWeeklyRevenue().toStringAsFixed(2)}',
                Icons.calendar_view_week,
                const Color(0xFF7A54FF),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Monthly',
                '\$${calculateMonthlyRevenue().toStringAsFixed(2)}',
                Icons.calendar_month,
                Colors.green,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'This Year',
                '\$${calculateYearlyRevenue().toStringAsFixed(2)}',
                Icons.calendar_today,
                Colors.blue,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Courses',
                '${courseEnrollments.length}',
                Icons.school,
                Colors.orange,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.trending_up, color: color, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 40,
                    color: const Color(0xFF7A54FF),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revenue Chart',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseIncome(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Course Income',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllCourses = !_showAllCourses;
                  });
                },
                child: Text(
                  _showAllCourses ? 'Show Less' : 'View All',
                  style: TextStyle(color: const Color(0xFF7A54FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllCourses ? courseEnrollments.length : 3,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = courseEnrollments[index];
              return _buildCourseIncomeItem(course, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseIncomeItem(Map<String, dynamic> course, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['courseTitle'],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: \$${course['coursePrice'].toStringAsFixed(2)} • ${course['enrolledStudents']} enrolled',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${course['totalRevenue'].toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF7A54FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllTransactions = !_showAllTransactions;
                  });
                },
                child: Text(
                  _showAllTransactions ? 'Show Less' : 'View All',
                  style: TextStyle(color: const Color(0xFF7A54FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllTransactions ? transactionHistory.length : 3,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final transaction = transactionHistory[index];
              return _buildTransactionItem(transaction, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, bool isDark) {
    final isCompleted = transaction['status'] == 'Completed';
    final statusColor = isCompleted ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.error,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Withdrawal - ${transaction['id']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction['bankAccount']} • ${_formatDate(transaction['date'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction['amount'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction['status'],
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPaymentInfoItem(
                  'Total Income',
                  '\$${totalIncome.toStringAsFixed(2)}',
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentInfoItem(
                  'Pending',
                  '\$${totalPending.toStringAsFixed(2)}',
                  Colors.orange,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentInfoItem(
                  'Withdrawn',
                  '\$${totalWithdrawn.toStringAsFixed(2)}',
                  Colors.blue,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToPaymentRequest(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Withdraw Money',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoItem(
    String title,
    String amount,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToPaymentRequest() {
    // Navigate to payment request page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to payment request page...'),
        backgroundColor: Color(0xFF7A54FF),
      ),
    );
  }
}

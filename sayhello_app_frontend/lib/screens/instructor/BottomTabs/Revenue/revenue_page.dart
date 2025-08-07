import 'package:flutter/material.dart';
import '../../../../../providers/settings_provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../instructor_main_tab.dart';
import 'withdrawal_request_page.dart';

class InstructorRevenuePage extends StatefulWidget {
  const InstructorRevenuePage({super.key});

  @override
  State<InstructorRevenuePage> createState() => _InstructorRevenuePageState();
}

class _InstructorRevenuePageState extends State<InstructorRevenuePage> {
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
    final localizations = AppLocalizations.of(context)!;
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
                  localizations.revenueDashboard,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Information (moved to top)
            _buildPaymentInfo(isDark, localizations),
            const SizedBox(height: 16),

            // Revenue Summary Cards
            _buildRevenueSummary(isDark, localizations),
            const SizedBox(height: 16),

            // Revenue Chart
            _buildRevenueChart(isDark, localizations),
            const SizedBox(height: 16),

            // Course Income Section
            _buildCourseIncome(isDark, localizations),
            const SizedBox(height: 16),

            // Transaction History Section
            _buildTransactionHistory(isDark, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary(bool isDark, AppLocalizations localizations) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                localizations.revenueWeekly,
                '\$${calculateWeeklyRevenue().toStringAsFixed(2)}',
                Icons.calendar_view_week,
                const Color(0xFF7A54FF),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                localizations.revenueMonthly,
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
                localizations.revenueThisYear,
                '\$${calculateYearlyRevenue().toStringAsFixed(2)}',
                Icons.calendar_today,
                Colors.blue,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                localizations.revenueTotalCourses,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Icons.trending_up, color: color, size: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(bool isDark, AppLocalizations localizations) {
    // Calculate data points for the chart
    List<double> weeklyData = [];
    List<String> weekLabels = [];

    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      double dayRevenue = 0;

      for (var course in courseEnrollments) {
        for (var enrollDate in course['enrollmentDates']) {
          if (enrollDate.day == date.day &&
              enrollDate.month == date.month &&
              enrollDate.year == date.year) {
            dayRevenue += course['coursePrice'];
          }
        }
      }

      weeklyData.add(dayRevenue);
      weekLabels.add(
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
      );
    }

    double maxValue = weeklyData.isNotEmpty
        ? weeklyData.reduce((a, b) => a > b ? a : b)
        : 100;
    if (maxValue == 0) maxValue = 100;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.revenueWeeklyTrend,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                double height = weeklyData[index] / maxValue * 80;
                if (height < 5) height = 5; // Minimum height for visibility

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20,
                      height: height,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A54FF),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weekLabels[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${localizations.revenueTotal}: \$${weeklyData.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF7A54FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${localizations.revenuePeak}: \$${maxValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseIncome(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                localizations.revenueCourseIncome,
                style: TextStyle(
                  fontSize: 14,
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
                  _showAllCourses
                      ? localizations.revenueShowLess
                      : localizations.revenueViewAll,
                  style: TextStyle(
                    color: const Color(0xFF7A54FF),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllCourses ? courseEnrollments.length : 3,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final course = courseEnrollments[index];
              return _buildCourseIncomeItem(course, isDark, localizations);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseIncomeItem(
    Map<String, dynamic> course,
    bool isDark,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${localizations.revenuePrice}: \$${course['coursePrice'].toStringAsFixed(2)} • ${course['enrolledStudents']} ${localizations.revenueEnrolled}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${course['totalRevenue'].toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF7A54FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                localizations.revenueTransactionHistory,
                style: TextStyle(
                  fontSize: 14,
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
                  _showAllTransactions
                      ? localizations.revenueShowLess
                      : localizations.revenueViewAll,
                  style: TextStyle(
                    color: const Color(0xFF7A54FF),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllTransactions ? transactionHistory.length : 3,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final transaction = transactionHistory[index];
              return _buildTransactionItem(transaction, isDark, localizations);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    Map<String, dynamic> transaction,
    bool isDark,
    AppLocalizations localizations,
  ) {
    final isCompleted = transaction['status'] == 'Completed';
    final statusColor = isCompleted ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.error,
              color: statusColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${localizations.revenueWithdrawal} - ${transaction['id']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction['bankAccount']} • ${_formatDate(transaction['date'])}',
                  style: TextStyle(
                    fontSize: 10,
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  transaction['status'],
                  style: TextStyle(
                    fontSize: 8,
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

  Widget _buildPaymentInfo(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.revenuePaymentOverview,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Main balance card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7A54FF),
                  const Color(0xFF7A54FF).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.revenueAvailableBalance,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(totalIncome - totalWithdrawn).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _navigateToPaymentRequest(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7A54FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    localizations.revenueWithdrawButton,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Payment breakdown
          Row(
            children: [
              Expanded(
                child: _buildPaymentInfoItem(
                  localizations.revenueTotalEarned,
                  '\$${totalIncome.toStringAsFixed(2)}',
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentInfoItem(
                  localizations.revenueWithdrawn,
                  '\$${totalWithdrawn.toStringAsFixed(2)}',
                  Colors.blue,
                  isDark,
                ),
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToPaymentRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WithdrawalRequestPage(
          availableBalance: totalIncome - totalWithdrawn,
        ),
      ),
    );
  }
}

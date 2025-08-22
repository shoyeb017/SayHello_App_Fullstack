import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/settings_provider.dart';
import '../../../../../providers/revenue_provider.dart';
import '../../../../../providers/auth_provider.dart';
import '../../../../../models/revenue.dart';
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
  String? _instructorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstructorData();
    });
  }

  void _loadInstructorData() {
    final authProvider = context.read<AuthProvider>();
    _instructorId = authProvider.currentUser?.id;

    if (_instructorId != null) {
      final revenueProvider = context.read<RevenueProvider>();
      revenueProvider.loadInstructorRevenue(_instructorId!);
      revenueProvider.loadTransactionHistory(_instructorId!);
    }
  }

  // Calculate revenue based on time periods using real data
  double calculateWeeklyRevenue(RevenueProvider provider) {
    return provider.statistics?.weeklyRevenue ?? 0.0;
  }

  double calculateMonthlyRevenue(RevenueProvider provider) {
    return provider.statistics?.monthlyRevenue ?? 0.0;
  }

  double calculateYearlyRevenue(RevenueProvider provider) {
    return provider.statistics?.yearlyRevenue ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<RevenueProvider>(
      builder: (context, revenueProvider, child) {
        // Show loading state
        if (revenueProvider.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(isDark, localizations),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Show error state
        if (revenueProvider.error != null) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(isDark, localizations),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${revenueProvider.error}'),
                  ElevatedButton(
                    onPressed: () => _loadInstructorData(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(isDark, localizations),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Information (moved to top)
                _buildPaymentInfo(isDark, localizations, revenueProvider),
                const SizedBox(height: 16),

                // Revenue Summary Cards
                _buildRevenueSummary(isDark, localizations, revenueProvider),
                const SizedBox(height: 16),

                // Revenue Chart
                _buildRevenueChart(isDark, localizations, revenueProvider),
                const SizedBox(height: 16),

                // Course Income Section
                _buildCourseIncome(isDark, localizations, revenueProvider),
                const SizedBox(height: 16),

                // Transaction History Section
                _buildTransactionHistory(
                  isDark,
                  localizations,
                  revenueProvider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    bool isDark,
    AppLocalizations localizations,
  ) {
    return PreferredSize(
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
    );
  }

  Widget _buildRevenueSummary(
    bool isDark,
    AppLocalizations localizations,
    RevenueProvider revenueProvider,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                localizations.revenueWeekly,
                '\$${calculateWeeklyRevenue(revenueProvider).toStringAsFixed(2)}',
                Icons.calendar_view_week,
                const Color(0xFF7A54FF),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                localizations.revenueMonthly,
                '\$${calculateMonthlyRevenue(revenueProvider).toStringAsFixed(2)}',
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
                '\$${calculateYearlyRevenue(revenueProvider).toStringAsFixed(2)}',
                Icons.calendar_today,
                Colors.blue,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                localizations.revenueTotalCourses,
                '${revenueProvider.courseRevenues.length}',
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

  Widget _buildRevenueChart(
    bool isDark,
    AppLocalizations localizations,
    RevenueProvider revenueProvider,
  ) {
    // Use weekly trend data from provider
    final weeklyData = revenueProvider.weeklyTrend;
    List<String> weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    double maxValue = weeklyData.isNotEmpty
        ? weeklyData
              .map((point) => point.amount)
              .reduce((a, b) => a > b ? a : b)
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
              children: List.generate(weeklyData.length.clamp(0, 7), (index) {
                double height = weeklyData[index].amount / maxValue * 80;
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
                      weekLabels[index % 7],
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
                '${localizations.revenueTotal}: \$${weeklyData.fold(0.0, (a, b) => a + b.amount).toStringAsFixed(2)}',
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

  Widget _buildCourseIncome(
    bool isDark,
    AppLocalizations localizations,
    RevenueProvider revenueProvider,
  ) {
    final courses = revenueProvider.courseRevenues;

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
          courses.isEmpty
              ? Center(
                  child: Text(
                    'No courses found',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _showAllCourses
                      ? courses.length
                      : (courses.length > 3 ? 3 : courses.length),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _buildCourseIncomeItem(
                      course,
                      isDark,
                      localizations,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCourseIncomeItem(
    CourseRevenue course,
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
                  course.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${localizations.revenuePrice}: \$${course.price.toStringAsFixed(2)} • ${course.enrollmentCount} ${localizations.revenueEnrolled}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${course.totalRevenue.toStringAsFixed(2)}',
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

  Widget _buildTransactionHistory(
    bool isDark,
    AppLocalizations localizations,
    RevenueProvider revenueProvider,
  ) {
    final transactions = revenueProvider.withdrawals;

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
          transactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _showAllTransactions
                      ? transactions.length
                      : (transactions.length > 3 ? 3 : transactions.length),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionItem(
                      transaction,
                      isDark,
                      localizations,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    WithdrawalRequest transaction,
    bool isDark,
    AppLocalizations localizations,
  ) {
    final isCompleted = transaction.status == WithdrawalStatus.completed;
    final statusColor = isCompleted ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () => _showTransactionDetails(transaction, localizations),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.transparent, width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getPaymentMethodIcon(
                      transaction.withdrawalInfo?.paymentMethod,
                    ),
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
                        '${localizations.revenueWithdrawal} - ${transaction.id ?? "N/A"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(transaction.createdAt),
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
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        transaction.status.displayName,
                        style: TextStyle(
                          fontSize: 8,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),

            // Payment method details
            if (transaction.withdrawalInfo != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[750] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(
                        transaction.withdrawalInfo!.paymentMethod,
                      ),
                      size: 14,
                      color: const Color(0xFF7A54FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      transaction.withdrawalInfo!.paymentMethod.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A54FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.withdrawalInfo!.maskedAccountInfo,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod? method) {
    if (method == null) return Icons.account_balance_wallet;

    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.bank:
        return Icons.account_balance;
    }
  }

  Widget _buildPaymentInfo(
    bool isDark,
    AppLocalizations localizations,
    RevenueProvider revenueProvider,
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
                        '\$${revenueProvider.availableBalance.toStringAsFixed(2)}',
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
                  onPressed: () => _navigateToPaymentRequest(revenueProvider),
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
                  '\$${revenueProvider.totalEarned.toStringAsFixed(2)}',
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentInfoItem(
                  localizations.revenueWithdrawn,
                  '\$${revenueProvider.totalWithdrawn.toStringAsFixed(2)}',
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

  void _navigateToPaymentRequest(RevenueProvider revenueProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WithdrawalRequestPage(
          availableBalance: revenueProvider.availableBalance,
        ),
      ),
    );
  }

  void _showTransactionDetails(
    WithdrawalRequest transaction,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Withdrawal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction ID
                      _buildDetailRow(
                        'Transaction ID',
                        transaction.id ?? 'N/A',
                        isDark,
                      ),
                      const SizedBox(height: 12),

                      // Amount
                      _buildDetailRow(
                        'Amount',
                        '\$${transaction.amount.toStringAsFixed(2)}',
                        isDark,
                        valueColor: const Color(0xFF7A54FF),
                      ),
                      const SizedBox(height: 12),

                      // Status
                      _buildDetailRow(
                        'Status',
                        transaction.status.displayName,
                        isDark,
                        valueColor: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      // Date
                      _buildDetailRow(
                        'Date',
                        _formatDetailDate(transaction.createdAt),
                        isDark,
                      ),

                      // Payment Method Details
                      if (transaction.withdrawalInfo != null) ...[
                        const SizedBox(height: 20),
                        Divider(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Payment method type
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getPaymentMethodIcon(
                                  transaction.withdrawalInfo!.paymentMethod,
                                ),
                                color: const Color(0xFF7A54FF),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                transaction
                                    .withdrawalInfo!
                                    .paymentMethod
                                    .displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7A54FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment method specific details
                        _buildPaymentMethodDetails(
                          transaction.withdrawalInfo!,
                          isDark,
                        ),
                      ],

                      // Add some bottom padding for the last item
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? (isDark ? Colors.white : Colors.black),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDetails(WithdrawalInfo info, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          ...(() {
            switch (info.paymentMethod) {
              case PaymentMethod.card:
                return [
                  _buildDetailRow(
                    'Card Number',
                    info.maskedAccountInfo,
                    isDark,
                  ),
                  if (info.cardHolderName != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Cardholder', info.cardHolderName!, isDark),
                  ],
                ];
              case PaymentMethod.paypal:
                return [
                  _buildDetailRow(
                    'PayPal Email',
                    info.paypalEmail ?? 'PayPal Account',
                    isDark,
                  ),
                ];
              case PaymentMethod.bank:
                return [
                  if (info.bankName != null) ...[
                    _buildDetailRow('Bank Name', info.bankName!, isDark),
                    const SizedBox(height: 8),
                  ],
                  _buildDetailRow(
                    'Account Number',
                    info.maskedAccountInfo,
                    isDark,
                  ),
                  if (info.swiftCode != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('SWIFT Code', info.swiftCode!, isDark),
                  ],
                ];
            }
          })(),
        ],
      ),
    );
  }

  String _formatDetailDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }
}

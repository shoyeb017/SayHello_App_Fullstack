/// Revenue Provider
/// Manages state for instructor revenue and withdrawal data

import 'package:flutter/foundation.dart';
import '../models/revenue.dart';
import '../data/revenue_data.dart';

class RevenueProvider with ChangeNotifier {
  final RevenueRepository _repository = RevenueRepository();

  // State variables
  InstructorRevenue? _instructorRevenue;
  TransactionHistory? _transactionHistory;
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  bool _isSubmittingWithdrawal = false;
  String? _error;

  // Getters
  InstructorRevenue? get instructorRevenue => _instructorRevenue;
  TransactionHistory? get transactionHistory => _transactionHistory;
  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get isSubmittingWithdrawal => _isSubmittingWithdrawal;
  String? get error => _error;

  // Computed getters
  double get totalEarned => _instructorRevenue?.totalEarned ?? 0.0;
  double get totalWithdrawn => _instructorRevenue?.totalWithdrawn ?? 0.0;
  double get availableBalance => _instructorRevenue?.availableBalance ?? 0.0;
  RevenueStatistics? get statistics => _instructorRevenue?.statistics;
  List<CourseRevenue> get courseRevenues =>
      _instructorRevenue?.courseRevenues ?? [];
  List<RevenueDataPoint> get weeklyTrend =>
      _instructorRevenue?.weeklyTrend ?? [];
  List<WithdrawalRequest> get withdrawals =>
      _transactionHistory?.withdrawals ?? [];

  /// Load instructor revenue data
  Future<void> loadInstructorRevenue(String instructorId) async {
    if (_isLoading) return;

    print(
      'RevenueProvider: Loading revenue data for instructor: $instructorId',
    );
    _setLoading(true);
    _clearError();

    try {
      _instructorRevenue = await _repository.getInstructorRevenue(instructorId);
      print('RevenueProvider: Revenue data loaded successfully');
      print(
        'RevenueProvider: Total earned: \$${totalEarned.toStringAsFixed(2)}',
      );
      print(
        'RevenueProvider: Available balance: \$${availableBalance.toStringAsFixed(2)}',
      );
    } catch (e) {
      print('RevenueProvider: Error loading revenue data: $e');
      _setError('Failed to load revenue data: $e');
      _instructorRevenue = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load transaction history
  Future<void> loadTransactionHistory(
    String instructorId, {
    int page = 1,
    int limit = 10,
  }) async {
    if (_isLoadingTransactions) return;

    print('RevenueProvider: Loading transaction history (page $page)');
    _setLoadingTransactions(true);
    _clearError();

    try {
      _transactionHistory = await _repository.getTransactionHistory(
        instructorId,
        page: page,
        limit: limit,
      );
      print(
        'RevenueProvider: Transaction history loaded (${withdrawals.length} items)',
      );
    } catch (e) {
      print('RevenueProvider: Error loading transaction history: $e');
      _setError('Failed to load transaction history: $e');
      _transactionHistory = null;
    } finally {
      _setLoadingTransactions(false);
    }
  }

  /// Submit withdrawal request
  Future<bool> submitWithdrawalRequest({
    required String instructorId,
    required double amount,
    String? notes,
  }) async {
    if (_isSubmittingWithdrawal) return false;

    print(
      'RevenueProvider: Submitting withdrawal request for \$${amount.toStringAsFixed(2)}',
    );
    _setSubmittingWithdrawal(true);
    _clearError();

    try {
      // Validate amount
      if (amount <= 0) {
        throw Exception('Withdrawal amount must be greater than zero');
      }

      if (amount > availableBalance) {
        throw Exception(
          'Insufficient balance. Available: \$${availableBalance.toStringAsFixed(2)}',
        );
      }

      final withdrawal = await _repository.submitWithdrawalRequest(
        instructorId: instructorId,
        amount: amount,
        notes: notes,
      );

      print(
        'RevenueProvider: Withdrawal request submitted successfully: ${withdrawal.id}',
      );

      // Refresh data after successful withdrawal
      await Future.wait([
        loadInstructorRevenue(instructorId),
        loadTransactionHistory(instructorId),
      ]);

      return true;
    } catch (e) {
      print('RevenueProvider: Error submitting withdrawal request: $e');
      _setError('Failed to submit withdrawal request: $e');
      return false;
    } finally {
      _setSubmittingWithdrawal(false);
    }
  }

  /// Refresh all revenue data
  Future<void> refreshRevenueData(String instructorId) async {
    print('RevenueProvider: Refreshing all revenue data');
    await Future.wait([
      loadInstructorRevenue(instructorId),
      loadTransactionHistory(instructorId),
    ]);
  }

  /// Get revenue data for a specific course
  CourseRevenue? getCourseRevenue(String courseId) {
    return courseRevenues.firstWhere(
      (course) => course.courseId == courseId,
      orElse: () => CourseRevenue(
        courseId: courseId,
        title: 'Unknown Course',
        price: 0.0,
        enrollmentCount: 0,
        totalRevenue: 0.0,
      ),
    );
  }

  /// Get recent withdrawals (last 5)
  List<WithdrawalRequest> getRecentWithdrawals() {
    return withdrawals.take(5).toList();
  }

  /// Get pending withdrawals
  List<WithdrawalRequest> getPendingWithdrawals() {
    return withdrawals
        .where((w) => w.status == WithdrawalStatus.pending)
        .toList();
  }

  /// Get completed withdrawals
  List<WithdrawalRequest> getCompletedWithdrawals() {
    return withdrawals
        .where((w) => w.status == WithdrawalStatus.completed)
        .toList();
  }

  /// Calculate growth rate for revenue statistics
  double calculateGrowthRate(String period) {
    if (statistics == null) return 0.0;

    switch (period.toLowerCase()) {
      case 'weekly':
        // Compare with previous week (simplified calculation)
        return weeklyTrend.isNotEmpty && weeklyTrend.length >= 2
            ? ((weeklyTrend.last.amount - weeklyTrend.first.amount) /
                      (weeklyTrend.first.amount + 1)) *
                  100
            : 0.0;
      case 'monthly':
        // Simple growth calculation based on monthly vs yearly ratio
        return statistics!.yearlyRevenue > 0
            ? (statistics!.monthlyRevenue / (statistics!.yearlyRevenue / 12) -
                      1) *
                  100
            : 0.0;
      case 'yearly':
        // Year-over-year would need historical data
        return 0.0;
      default:
        return 0.0;
    }
  }

  /// Clear all data (for logout)
  void clearData() {
    print('RevenueProvider: Clearing all data');
    _instructorRevenue = null;
    _transactionHistory = null;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingTransactions(bool loading) {
    _isLoadingTransactions = loading;
    notifyListeners();
  }

  void _setSubmittingWithdrawal(bool submitting) {
    _isSubmittingWithdrawal = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    print('RevenueProvider: Disposing');
    super.dispose();
  }
}

/// Revenue and Withdrawal Repository
/// Handles backend communication for instructor revenue management

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/revenue.dart';

class RevenueRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get comprehensive revenue data for an instructor
  Future<InstructorRevenue> getInstructorRevenue(String instructorId) async {
    try {
      print(
        'RevenueRepository: Loading revenue data for instructor: $instructorId',
      );

      // Execute all queries in parallel for better performance
      final results = await Future.wait([
        _getTotalEarned(instructorId),
        _getTotalWithdrawn(instructorId),
        _getRevenueStatistics(instructorId),
        _getCourseRevenues(instructorId),
        _getWeeklyRevenueTrend(instructorId),
      ]);

      final totalEarned = results[0] as double;
      final totalWithdrawn = results[1] as double;
      final statistics = results[2] as RevenueStatistics;
      final courseRevenues = results[3] as List<CourseRevenue>;
      final weeklyTrend = results[4] as List<RevenueDataPoint>;

      final revenue = InstructorRevenue(
        totalEarned: totalEarned,
        totalWithdrawn: totalWithdrawn,
        availableBalance: totalEarned - totalWithdrawn,
        statistics: statistics,
        courseRevenues: courseRevenues,
        weeklyTrend: weeklyTrend,
      );

      print('RevenueRepository: Revenue data loaded successfully');
      return revenue;
    } catch (e) {
      print('RevenueRepository: Error loading revenue data: $e');
      rethrow;
    }
  }

  /// Calculate total earned from all course enrollments
  Future<double> _getTotalEarned(String instructorId) async {
    try {
      final response = await _supabase
          .from('course_enrollments')
          .select('''
            courses!inner(price, instructor_id)
          ''')
          .eq('courses.instructor_id', instructorId);

      double totalEarned = 0.0;
      for (final enrollment in response) {
        final coursePrice = (enrollment['courses']['price'] ?? 0).toDouble();
        totalEarned += coursePrice;
      }

      print(
        'RevenueRepository: Total earned: \$${totalEarned.toStringAsFixed(2)}',
      );
      return totalEarned;
    } catch (e) {
      print('RevenueRepository: Error calculating total earned: $e');
      return 0.0;
    }
  }

  /// Calculate total withdrawn from withdrawals table
  Future<double> _getTotalWithdrawn(String instructorId) async {
    try {
      final response = await _supabase
          .from('withdrawals')
          .select('amount')
          .eq('instructor_id', instructorId)
          .eq('status', 'COMPLETED');

      double totalWithdrawn = 0.0;
      for (final withdrawal in response) {
        totalWithdrawn += (withdrawal['amount'] ?? 0).toDouble();
      }

      print(
        'RevenueRepository: Total withdrawn: \$${totalWithdrawn.toStringAsFixed(2)}',
      );
      return totalWithdrawn;
    } catch (e) {
      print('RevenueRepository: Error calculating total withdrawn: $e');
      return 0.0;
    }
  }

  /// Get revenue statistics (weekly, monthly, yearly)
  Future<RevenueStatistics> _getRevenueStatistics(String instructorId) async {
    try {
      // Get course count
      final coursesResponse = await _supabase
          .from('courses')
          .select('id')
          .eq('instructor_id', instructorId);

      final totalCourses = coursesResponse.length;

      // Get enrollments with dates for time-based calculations
      final enrollmentsResponse = await _supabase
          .from('course_enrollments')
          .select('''
            created_at,
            courses!inner(price, instructor_id)
          ''')
          .eq('courses.instructor_id', instructorId)
          .order('created_at', ascending: false);

      final totalEnrollments = enrollmentsResponse.length;

      // Calculate time-based revenues
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: 7));
      final monthStart = DateTime(now.year, now.month, 1);
      final yearStart = DateTime(now.year, 1, 1);

      double weeklyRevenue = 0.0;
      double monthlyRevenue = 0.0;
      double yearlyRevenue = 0.0;

      for (final enrollment in enrollmentsResponse) {
        final enrollmentDate = DateTime.parse(enrollment['created_at']);
        final coursePrice = (enrollment['courses']['price'] ?? 0).toDouble();

        if (enrollmentDate.isAfter(weekStart)) {
          weeklyRevenue += coursePrice;
        }
        if (enrollmentDate.isAfter(monthStart)) {
          monthlyRevenue += coursePrice;
        }
        if (enrollmentDate.isAfter(yearStart)) {
          yearlyRevenue += coursePrice;
        }
      }

      return RevenueStatistics(
        weeklyRevenue: weeklyRevenue,
        monthlyRevenue: monthlyRevenue,
        yearlyRevenue: yearlyRevenue,
        totalCourses: totalCourses,
        totalEnrollments: totalEnrollments,
      );
    } catch (e) {
      print('RevenueRepository: Error calculating statistics: $e');
      return RevenueStatistics(
        weeklyRevenue: 0.0,
        monthlyRevenue: 0.0,
        yearlyRevenue: 0.0,
        totalCourses: 0,
        totalEnrollments: 0,
      );
    }
  }

  /// Get revenue breakdown by course
  Future<List<CourseRevenue>> _getCourseRevenues(String instructorId) async {
    try {
      final response = await _supabase
          .from('courses')
          .select('''
            id,
            title,
            price,
            course_enrollments(created_at)
          ''')
          .eq('instructor_id', instructorId);

      final courseRevenues = <CourseRevenue>[];

      for (final course in response) {
        final enrollments = course['course_enrollments'] as List<dynamic>;
        final price = (course['price'] ?? 0).toDouble();
        final enrollmentCount = enrollments.length;
        final totalRevenue = price * enrollmentCount;

        DateTime? lastEnrollment;
        if (enrollments.isNotEmpty) {
          final sortedEnrollments =
              enrollments.map((e) => DateTime.parse(e['created_at'])).toList()
                ..sort((a, b) => b.compareTo(a));
          lastEnrollment = sortedEnrollments.first;
        }

        courseRevenues.add(
          CourseRevenue(
            courseId: course['id'],
            title: course['title'] ?? 'Untitled Course',
            price: price,
            enrollmentCount: enrollmentCount,
            totalRevenue: totalRevenue,
            lastEnrollment: lastEnrollment,
          ),
        );
      }

      // Sort by total revenue (highest first)
      courseRevenues.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

      print(
        'RevenueRepository: Loaded ${courseRevenues.length} course revenues',
      );
      return courseRevenues;
    } catch (e) {
      print('RevenueRepository: Error loading course revenues: $e');
      return [];
    }
  }

  /// Get weekly revenue trend for the last 7 days
  Future<List<RevenueDataPoint>> _getWeeklyRevenueTrend(
    String instructorId,
  ) async {
    try {
      final weeklyData = <RevenueDataPoint>[];
      final now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        final nextDate = date.add(Duration(days: 1));

        final response = await _supabase
            .from('course_enrollments')
            .select('''
              courses!inner(price, instructor_id)
            ''')
            .eq('courses.instructor_id', instructorId)
            .gte('created_at', date.toIso8601String())
            .lt('created_at', nextDate.toIso8601String());

        double dayRevenue = 0.0;
        for (final enrollment in response) {
          dayRevenue += (enrollment['courses']['price'] ?? 0).toDouble();
        }

        weeklyData.add(
          RevenueDataPoint(date: date, amount: dayRevenue, period: 'day'),
        );
      }

      return weeklyData;
    } catch (e) {
      print('RevenueRepository: Error loading weekly trend: $e');
      return [];
    }
  }

  /// Get transaction history (withdrawals)
  Future<TransactionHistory> getTransactionHistory(
    String instructorId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print(
        'RevenueRepository: Loading transaction history for instructor: $instructorId',
      );

      final offset = (page - 1) * limit;

      final response = await _supabase
          .from('withdrawals')
          .select('*')
          .eq('instructor_id', instructorId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final countResponse = await _supabase
          .from('withdrawals')
          .select('*')
          .eq('instructor_id', instructorId);

      final totalCount = countResponse.length;
      final totalPages = (totalCount / limit).ceil();

      final withdrawals = response
          .map((data) => WithdrawalRequest.fromJson(data))
          .toList();

      print('RevenueRepository: Loaded ${withdrawals.length} transactions');

      return TransactionHistory(
        withdrawals: withdrawals,
        totalPages: totalPages.toDouble(),
        currentPage: page,
      );
    } catch (e) {
      print('RevenueRepository: Error loading transaction history: $e');
      return TransactionHistory(withdrawals: [], totalPages: 1, currentPage: 1);
    }
  }

  /// Submit withdrawal request
  Future<WithdrawalRequest> submitWithdrawalRequest({
    required String instructorId,
    required double amount,
    String? notes,
  }) async {
    try {
      print(
        'RevenueRepository: Submitting withdrawal request for \$${amount.toStringAsFixed(2)}',
      );

      // Validate available balance
      final revenue = await getInstructorRevenue(instructorId);
      if (amount > revenue.availableBalance) {
        throw Exception(
          'Insufficient balance. Available: \$${revenue.availableBalance.toStringAsFixed(2)}',
        );
      }

      final withdrawalData = {
        'instructor_id': instructorId,
        'amount': amount,
        'status': WithdrawalStatus.completed.value, // Auto-approve for now
        'processed_at': DateTime.now().toIso8601String(),
        'notes': notes,
      };

      final response = await _supabase
          .from('withdrawals')
          .insert(withdrawalData)
          .select()
          .single();

      final withdrawal = WithdrawalRequest.fromJson(response);
      print('RevenueRepository: Withdrawal request submitted successfully');

      return withdrawal;
    } catch (e) {
      print('RevenueRepository: Error submitting withdrawal request: $e');
      rethrow;
    }
  }

  /// Get single withdrawal by ID
  Future<WithdrawalRequest?> getWithdrawal(String withdrawalId) async {
    try {
      final response = await _supabase
          .from('withdrawals')
          .select('*')
          .eq('id', withdrawalId)
          .single();

      return WithdrawalRequest.fromJson(response);
    } catch (e) {
      print('RevenueRepository: Error loading withdrawal: $e');
      return null;
    }
  }

  /// Update withdrawal status (admin function)
  Future<WithdrawalRequest> updateWithdrawalStatus({
    required String withdrawalId,
    required WithdrawalStatus status,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status.value};

      if (notes != null) {
        updateData['notes'] = notes;
      }

      if (status == WithdrawalStatus.completed) {
        updateData['processed_at'] = DateTime.now().toIso8601String();
      }

      final response = await _supabase
          .from('withdrawals')
          .update(updateData)
          .eq('id', withdrawalId)
          .select()
          .single();

      return WithdrawalRequest.fromJson(response);
    } catch (e) {
      print('RevenueRepository: Error updating withdrawal status: $e');
      rethrow;
    }
  }
}

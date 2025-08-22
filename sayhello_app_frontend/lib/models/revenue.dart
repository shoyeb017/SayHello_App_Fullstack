/// Revenue Models
/// Data models for instructor revenue and withdrawal management

class InstructorRevenue {
  final double totalEarned;
  final double totalWithdrawn;
  final double availableBalance;
  final RevenueStatistics statistics;
  final List<CourseRevenue> courseRevenues;
  final List<RevenueDataPoint> weeklyTrend;

  InstructorRevenue({
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.availableBalance,
    required this.statistics,
    required this.courseRevenues,
    required this.weeklyTrend,
  });

  factory InstructorRevenue.fromJson(Map<String, dynamic> json) {
    return InstructorRevenue(
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      statistics: RevenueStatistics.fromJson(json['statistics'] ?? {}),
      courseRevenues: (json['courseRevenues'] as List<dynamic>? ?? [])
          .map((e) => CourseRevenue.fromJson(e))
          .toList(),
      weeklyTrend: (json['weeklyTrend'] as List<dynamic>? ?? [])
          .map((e) => RevenueDataPoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
      'availableBalance': availableBalance,
      'statistics': statistics.toJson(),
      'courseRevenues': courseRevenues.map((e) => e.toJson()).toList(),
      'weeklyTrend': weeklyTrend.map((e) => e.toJson()).toList(),
    };
  }
}

class RevenueStatistics {
  final double weeklyRevenue;
  final double monthlyRevenue;
  final double yearlyRevenue;
  final int totalCourses;
  final int totalEnrollments;

  RevenueStatistics({
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.yearlyRevenue,
    required this.totalCourses,
    required this.totalEnrollments,
  });

  factory RevenueStatistics.fromJson(Map<String, dynamic> json) {
    return RevenueStatistics(
      weeklyRevenue: (json['weeklyRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      yearlyRevenue: (json['yearlyRevenue'] ?? 0).toDouble(),
      totalCourses: json['totalCourses'] ?? 0,
      totalEnrollments: json['totalEnrollments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyRevenue': weeklyRevenue,
      'monthlyRevenue': monthlyRevenue,
      'yearlyRevenue': yearlyRevenue,
      'totalCourses': totalCourses,
      'totalEnrollments': totalEnrollments,
    };
  }
}

class CourseRevenue {
  final String courseId;
  final String title;
  final double price;
  final int enrollmentCount;
  final double totalRevenue;
  final DateTime? lastEnrollment;

  CourseRevenue({
    required this.courseId,
    required this.title,
    required this.price,
    required this.enrollmentCount,
    required this.totalRevenue,
    this.lastEnrollment,
  });

  factory CourseRevenue.fromJson(Map<String, dynamic> json) {
    return CourseRevenue(
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      enrollmentCount: json['enrollmentCount'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      lastEnrollment: json['lastEnrollment'] != null
          ? DateTime.parse(json['lastEnrollment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'title': title,
      'price': price,
      'enrollmentCount': enrollmentCount,
      'totalRevenue': totalRevenue,
      'lastEnrollment': lastEnrollment?.toIso8601String(),
    };
  }
}

class RevenueDataPoint {
  final DateTime date;
  final double amount;
  final String period;

  RevenueDataPoint({
    required this.date,
    required this.amount,
    required this.period,
  });

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0).toDouble(),
      period: json['period'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'amount': amount, 'period': period};
  }
}

class WithdrawalRequest {
  final String? id;
  final String instructorId;
  final double amount;
  final WithdrawalStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? notes;

  WithdrawalRequest({
    this.id,
    required this.instructorId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.notes,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'],
      instructorId: json['instructor_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: WithdrawalStatus.fromString(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'amount': amount,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

enum WithdrawalStatus {
  pending('PENDING'),
  processing('PROCESSING'),
  completed('COMPLETED'),
  rejected('REJECTED');

  const WithdrawalStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.rejected:
        return 'Rejected';
    }
  }

  static WithdrawalStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return WithdrawalStatus.pending;
      case 'PROCESSING':
        return WithdrawalStatus.processing;
      case 'COMPLETED':
        return WithdrawalStatus.completed;
      case 'REJECTED':
        return WithdrawalStatus.rejected;
      default:
        return WithdrawalStatus.pending;
    }
  }
}

class TransactionHistory {
  final List<WithdrawalRequest> withdrawals;
  final double totalPages;
  final int currentPage;

  TransactionHistory({
    required this.withdrawals,
    required this.totalPages,
    required this.currentPage,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      withdrawals: (json['withdrawals'] as List<dynamic>? ?? [])
          .map((e) => WithdrawalRequest.fromJson(e))
          .toList(),
      totalPages: (json['totalPages'] ?? 1).toDouble(),
      currentPage: json['currentPage'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'withdrawals': withdrawals.map((e) => e.toJson()).toList(),
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }
}

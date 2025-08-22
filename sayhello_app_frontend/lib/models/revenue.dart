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
  final WithdrawalInfo? withdrawalInfo;

  WithdrawalRequest({
    this.id,
    required this.instructorId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.withdrawalInfo,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    WithdrawalInfo? withdrawalInfo;

    if (json['withdrawal_info'] != null) {
      final withdrawalInfoData = json['withdrawal_info'];
      if (withdrawalInfoData is List && withdrawalInfoData.isNotEmpty) {
        // If it's a list (from Supabase join), take the first item
        withdrawalInfo = WithdrawalInfo.fromJson(withdrawalInfoData.first);
      } else if (withdrawalInfoData is Map<String, dynamic>) {
        // If it's already a map
        withdrawalInfo = WithdrawalInfo.fromJson(withdrawalInfoData);
      }
    }

    return WithdrawalRequest(
      id: json['id'],
      instructorId: json['instructor_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: WithdrawalStatus.fromString(json['status'] ?? 'completed'),
      createdAt: DateTime.parse(json['created_at']),
      withdrawalInfo: withdrawalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'amount': amount,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'withdrawal_info': withdrawalInfo?.toJson(),
    };
  }
}

enum WithdrawalStatus {
  completed('COMPLETED');

  const WithdrawalStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case WithdrawalStatus.completed:
        return 'Completed';
    }
  }

  static WithdrawalStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'COMPLETED':
        return WithdrawalStatus.completed;
      default:
        return WithdrawalStatus.completed;
    }
  }
}

enum PaymentMethod {
  card('CARD'),
  paypal('PAYPAL'),
  bank('BANK');

  const PaymentMethod(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.bank:
        return 'Bank Transfer';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CARD':
        return PaymentMethod.card;
      case 'PAYPAL':
        return PaymentMethod.paypal;
      case 'BANK':
        return PaymentMethod.bank;
      default:
        return PaymentMethod.bank;
    }
  }
}

class WithdrawalInfo {
  final String? id;
  final String withdrawalId;
  final PaymentMethod paymentMethod;

  // Card details
  final String? cardNumber;
  final String? expiryDate;
  final String? cvv;
  final String? cardHolderName;

  // PayPal details
  final String? paypalEmail;

  // Bank details
  final String? bankAccountNumber;
  final String? bankName;
  final String? swiftCode;

  WithdrawalInfo({
    this.id,
    required this.withdrawalId,
    required this.paymentMethod,
    this.cardNumber,
    this.expiryDate,
    this.cvv,
    this.cardHolderName,
    this.paypalEmail,
    this.bankAccountNumber,
    this.bankName,
    this.swiftCode,
  });

  factory WithdrawalInfo.fromJson(Map<String, dynamic> json) {
    return WithdrawalInfo(
      id: json['id'],
      withdrawalId: json['withdrawal_id'] ?? '',
      paymentMethod: PaymentMethod.fromString(json['payment_method'] ?? 'bank'),
      cardNumber: json['card_number'],
      expiryDate: json['expiry_date'],
      cvv: json['cvv'],
      cardHolderName: json['card_holder_name'],
      paypalEmail: json['paypal_email'],
      bankAccountNumber: json['bank_account_number'],
      bankName: json['bank_name'],
      swiftCode: json['swift_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'withdrawal_id': withdrawalId,
      'payment_method': paymentMethod.value,
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'cvv': cvv,
      'card_holder_name': cardHolderName,
      'paypal_email': paypalEmail,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'swift_code': swiftCode,
    };
  }

  String get maskedAccountInfo {
    switch (paymentMethod) {
      case PaymentMethod.card:
        return cardNumber != null && cardNumber!.length >= 4
            ? '**** **** **** ${cardNumber!.substring(cardNumber!.length - 4)}'
            : '**** **** **** ****';
      case PaymentMethod.paypal:
        return paypalEmail ?? 'PayPal Account';
      case PaymentMethod.bank:
        return bankAccountNumber != null && bankAccountNumber!.length >= 4
            ? '****${bankAccountNumber!.substring(bankAccountNumber!.length - 4)}'
            : '****';
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

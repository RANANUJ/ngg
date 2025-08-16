class Donation {
  final String id;
  final String campaignId;
  final String? donorId;
  final String donorName;
  final String? donorEmail;
  final String? donorPhone;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionId;
  final String? message;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const Donation({
    required this.id,
    required this.campaignId,
    this.donorId,
    required this.donorName,
    this.donorEmail,
    this.donorPhone,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.message,
    required this.createdAt,
    this.metadata,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['_id'] ?? json['id'],
      campaignId: json['campaign_id'],
      donorId: json['donor_id'],
      donorName: json['donor_name'] ?? 'Anonymous',
      donorEmail: json['donor_email'],
      donorPhone: json['donor_phone'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.fromString(json['payment_method'] ?? 'UPI'),
      status: PaymentStatus.fromString(json['status'] ?? 'pending'),
      transactionId: json['transaction_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'donor_id': donorId,
      'donor_name': donorName,
      'donor_email': donorEmail,
      'donor_phone': donorPhone,
      'amount': amount,
      'payment_method': paymentMethod.value,
      'status': status.value,
      'transaction_id': transactionId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

enum PaymentMethod {
  upi('UPI'),
  bankTransfer('Bank Transfer'),
  card('Card'),
  cash('Cash'),
  other('Other');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentMethod.other,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI Payment';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.card:
        return 'Card Payment';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

enum PaymentStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class DonationRequest {
  final String donorName;
  final String? donorEmail;
  final String? donorPhone;
  final double amount;
  final PaymentMethod paymentMethod;
  final String? message;
  final bool isAnonymous;
  final Map<String, dynamic>? additionalInfo;

  const DonationRequest({
    required this.donorName,
    this.donorEmail,
    this.donorPhone,
    required this.amount,
    required this.paymentMethod,
    this.message,
    this.isAnonymous = false,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'donor_name': donorName,
      'donor_email': donorEmail,
      'donor_phone': donorPhone,
      'amount': amount,
      'payment_method': paymentMethod.value,
      'message': message,
      'is_anonymous': isAnonymous,
      'additional_info': additionalInfo,
    };
  }
}

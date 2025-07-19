import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String name;
  final String phoneNumber;
  final String customerCode;
  final double? totalSpent;
  final DateTime? accountCreation;
  final DateTime? lastPurchaseDate;
  final bool existing;

  Customer({
    required this.name,
    required this.phoneNumber,
    required this.customerCode,
    this.totalSpent,
    this.accountCreation,
    this.lastPurchaseDate,
    this.existing=false,
  });

  factory Customer.fromMap(Map<String, dynamic> map, {bool existing = false}) {
    return Customer(
      name: map['name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      customerCode: map['customer_code'] ?? '',
      totalSpent: map['total_spent'] ?? 0.0,
      accountCreation: (map['account_creation'] is Timestamp)
          ? (map['account_creation'] as Timestamp).toDate()
          : null,
      lastPurchaseDate: (map['last_purchase_date'] is Timestamp)
          ? (map['last_purchase_date'] as Timestamp).toDate()
          : null,
      existing: existing
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'customer_code': customerCode,
      'total_spent': totalSpent,
      'account_creation': accountCreation?.toIso8601String(),
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
    };
  }
}

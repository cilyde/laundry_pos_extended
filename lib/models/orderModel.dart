import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// lib/models/order_model.dart

class OrderModel {
  final String orderId;
  final String customerCode;
  final double total;
  final String? dateKey;

  OrderModel({
    required this.orderId,
    required this.customerCode,
    required this.total,
    this.dateKey,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId: data['order_id'] ?? doc.id,
      customerCode: data['customer_code'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      dateKey: data['order_date'], // stored explicitly
    );
  }
  static String generateCompletionQR({required String orderId, required String dateKey}) {
    return jsonEncode({
      'type': 'complete_order',
      'orderId': orderId,
      'dateKey': dateKey,
    });
  }
}

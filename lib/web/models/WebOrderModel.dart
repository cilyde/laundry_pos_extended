//
// // lib/web/models/order_model.dart
// class OrderModel {
//   final String id;
//   final DateTime timestamp;
//   final double total;
//   final List<OrderItem> items;
//
//   OrderModel({
//     required this.id,
//     required this.timestamp,
//     required this.total,
//     required this.items,
//   });
// }
//
// class OrderItem {
//   final String name;
//   final String service;
//   final int quantity;
//   final double price;
//
//   OrderItem({
//     required this.name,
//     required this.service,
//     required this.quantity,
//     required this.price,
//   });
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String name;
  final String service;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.service,
    required this.quantity,
    required this.price,
  });
}

class WebOrderModel {
  final String id; // Firestore doc ID
  final String orderId; // 'order_id' field
  final String customerCode;
  final DateTime timestamp;
  final double total;
  final List<OrderItem> items;

  WebOrderModel({
    required this.id,
    required this.customerCode,
    required this.orderId,
    required this.timestamp,
    required this.total,
    required this.items,
  });


  factory WebOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items list
    final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final items = itemsData.map((item) {
      return OrderItem(
        name: item['name'] ?? '',
        service: item['service'] ?? '',
        quantity: (item['quantity'] ?? 0).toInt(),
        price: (item['price'] ?? 0).toDouble(),
      );
    }).toList();

    return WebOrderModel(
      id: doc.id,
      orderId: data['order_id'] ?? '',
      customerCode: data['customer_code'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      total: (data['total'] ?? 0).toDouble(),
      items: items,
    );
  }
}

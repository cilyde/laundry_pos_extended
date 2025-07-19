import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../services/firebase_service.dart';
import '../models/WebOrderModel.dart';

class WebFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchDaySummary(DateTime date) async {
    final dateKey = _formatDateKey(date);
    final doc = await _firestore.collection('vOrders').doc(dateKey).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> fetchOrdersForDay(DateTime day) async {
    final dateKey = _formatDateKey(day);
    final snapshot = await _firestore
        .collection('vOrders')
        .doc(dateKey)
        .collection('orders')
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }


  // Future<Map<String, dynamic>> fetchMonthSummary(DateTime monthStart) async {
  //   final monthEnd = DateTime(monthStart.year, monthStart.month + 1);
  //
  //   final snapshot = await FirebaseFirestore.instance
  //       .collectionGroup('orders')
  //       .where('timestamp', isGreaterThanOrEqualTo: monthStart)
  //       .where('timestamp', isLessThan: monthEnd)
  //       .get();
  //
  //   int orders = 0;
  //   double total = 0.0;
  //   double amountIn = 0.0;
  //
  //   for (var doc in snapshot.docs) {
  //     orders++;
  //     total += (doc['total'] ?? 0).toDouble();
  //     amountIn += (doc['amount_in'] ?? 0).toDouble();
  //   }
  //
  //   return {
  //     'total_orders_placed': orders,
  //     'total_amount_placed': total,
  //     'amount_in': amountIn,
  //   };
  // }
  Future<Map<String, dynamic>> fetchMonthSummary(DateTime monthStart) async {
    final year = monthStart.year;
    final month = monthStart.month;

    // Compose start and end keys as strings for document ID filtering
    final startKey = DateFormat('yyyy-MM-dd').format(DateTime(year, month, 1)); // e.g. 2025-07-01
    final endKey = DateFormat('yyyy-MM-dd').format(DateTime(year, month + 1, 1)); // e.g. 2025-08-01

    final querySnapshot = await FirebaseFirestore.instance
        .collection('vOrders')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
        .where(FieldPath.documentId, isLessThan: endKey)
        .get();

    int totalOrdersPlaced = 0;
    double totalAmountPlaced = 0;
    double amountIn = 0;
    int totalOrdersCompleted = 0;
    double totalAmountCompleted = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      totalOrdersPlaced += (data['total_orders_placed'] ?? 0) as int;
      totalAmountPlaced += (data['total_amount_placed'] ?? 0).toDouble();
      amountIn += (data['amount_in'] ?? 0).toDouble();
      totalOrdersCompleted += (data['total_orders_completed'] ?? 0) as int;
      totalAmountCompleted += (data['total_amount_completed'] ?? 0).toDouble();
    }

    return {
      'total_orders_placed': totalOrdersPlaced,
      'total_amount_placed': totalAmountPlaced,
      'amount_in': amountIn,
      'total_orders_completed': totalOrdersCompleted,
      'total_amount_completed': totalAmountCompleted,
    };
  }


  Future<List<Map<String, dynamic>>> fetchOrdersForCustomer(String customerId) async {
    final snapshot = await _firestore
        .collectionGroup('orders')
        .where('customer_code', isEqualTo: customerId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Fetch all active orders (no filtering)
  Future<List<WebOrderModel>> fetchAllActiveOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('active_orders').get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      // Map each doc to OrderModel (assuming OrderModel.fromFirestore exists)
      return snapshot.docs.map((doc) => WebOrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching active orders: $e");
      return [];
    }
  }

}

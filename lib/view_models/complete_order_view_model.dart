import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/orderModel.dart';
import '../services/firebase_service.dart';

class CompleteOrderViewModel extends ChangeNotifier {
  List<OrderModel> orders = [];
  bool isLoading = false;
  String? error;

  // Future<void> fetchOrders({String? customerCode, String? phoneNumber}) async {
  //   try {
  //     isLoading = true;
  //     orders = [];
  //     error = null;
  //     notifyListeners();
  //
  //     String? codeToSearch;
  //
  //     if (customerCode != null && customerCode.isNotEmpty) {
  //       codeToSearch = customerCode;
  //     } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
  //       // Look up customer code from phone number
  //       final indexSnap = await FirebaseFirestore.instance
  //           .collection('customer_codes')
  //           .where('phone_number', isEqualTo: phoneNumber)
  //           .limit(1)
  //           .get();
  //
  //       if (indexSnap.docs.isEmpty) {
  //         error = 'No customer found for this phone number.';
  //         isLoading = false;
  //         notifyListeners();
  //         return;
  //       }
  //
  //       codeToSearch = indexSnap.docs.first.id;
  //     }
  //
  //     if (codeToSearch == null) {
  //       error = 'Please enter customer code or phone number.';
  //       isLoading = false;
  //       notifyListeners();
  //       return;
  //     }
  //
  //     // ✅ Step 1: Fetch list of active order document IDs
  //     final indexRef = FirebaseFirestore.instance
  //         .collection('active_orders_by_code')
  //         .doc(codeToSearch);
  //
  //     final indexSnap = await indexRef.get();
  //
  //     if (!indexSnap.exists) {
  //       error = 'No active orders found for this customer.';
  //       isLoading = false;
  //       notifyListeners();
  //       return;
  //     }
  //
  //     final orderIndexMap = indexSnap.data() as Map<String, dynamic>;
  //     if (orderIndexMap.isEmpty) {
  //       error = 'No active orders found for this customer.';
  //       isLoading = false;
  //       notifyListeners();
  //       return;
  //     }
  //
  //     // ✅ Step 2: Use batchGet to retrieve actual order docs
  //     final futures = <Future<DocumentSnapshot>>[];
  //     orderIndexMap.forEach((dateKey, orderId) {
  //       final orderRef = FirebaseFirestore.instance
  //           .collection('active_orders')
  //           .doc(dateKey)
  //           .collection('activeOrders')
  //           .doc(orderId);
  //       futures.add(orderRef.get());
  //     });
  //
  //     final docs = await Future.wait(futures);
  //     orders = docs
  //         .where((doc) => doc.exists)
  //         .map((doc) => OrderModel.fromFirestore(doc))
  //         .toList();
  //
  //     if (orders.isEmpty) {
  //       error = 'No active orders found for this customer.';
  //     }
  //
  //   } catch (e) {
  //     error = 'Something went wrong: $e';
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
  Future<void> fetchOrders({String? customerCode, String? phoneNumber}) async {
    try {
      isLoading = true;
      orders = [];
      error = null;
      notifyListeners();

      orders = await FirebaseService.fetchActiveOrders(
        customerCode: customerCode,
        phoneNumber: phoneNumber,
      );

      if (orders.isEmpty) {
        error = 'No active orders found.';
      }
    } catch (e) {
      error = 'Something went wrong: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> completeOrder(OrderModel order) async {
  //   try {
  //     final dateKey = order.dateKey ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  //
  //     // Step 1: Update order status
  //     final orderRef = FirebaseFirestore.instance
  //         .collection('vOrders')
  //         .doc(dateKey)
  //         .collection('orders')
  //         .doc(order.orderId);
  //
  //     await orderRef.update({'status': 'completed'});
  //
  //     // Step 2: Remove from active_orders
  //     await FirebaseFirestore.instance
  //         .collection('active_orders')
  //         .doc(dateKey)
  //         .collection('activeOrders')
  //         .doc(order.orderId)
  //         .delete();
  //
  //     // Step 3: Update summary
  //     final summaryRef = FirebaseFirestore.instance.collection('vOrders').doc(dateKey);
  //     await summaryRef.set({
  //       'total_orders_completed': FieldValue.increment(1),
  //       'total_amount_completed': FieldValue.increment(order.total),
  //     }, SetOptions(merge: true));
  //
  //     orders.removeWhere((o) => o.orderId == order.orderId);
  //     notifyListeners();
  //   } catch (e) {
  //     error = 'Failed to complete order: $e';
  //     notifyListeners();
  //   }
  // }
  Future<void> completeOrder(OrderModel order) async {
    try {
      await FirebaseService.completeOrder(order);
      orders.removeWhere((o) => o.orderId == order.orderId);
      notifyListeners();
    } catch (e) {
      error = 'Failed to complete order: $e';
      notifyListeners();
    }
  }
}

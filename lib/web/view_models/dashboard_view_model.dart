import 'package:cloud_firestore/cloud_firestore.dart';
// class DashboardViewModel extends ChangeNotifier {
//   int ordersToday = 0;
//   double salesToday = 0.0;
//   int ordersThisMonth = 0;
//   double salesThisMonth = 0.0;
//   int customOrders = 0;
//   double customSales = 0.0;
//
//   bool isLoading = false;
//   bool hasData = false;
//   DashboardPeriod selectedPeriod = DashboardPeriod.today;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // inside DashboardViewModel
//   Future<List<OrderModel>> fetchOrdersForCustomer(String customerId) async {
//     final snapshot =
//         await _firestore.collectionGroup('orders').where('customer_id', isEqualTo: customerId).orderBy('timestamp', descending: true).get();
//
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       final items =
//           (data['items'] as List).map((m) {
//             return OrderItem(name: m['name'], service: m['service'], quantity: m['quantity'], price: (m['price'] as num).toDouble());
//           }).toList();
//
//       return OrderModel(id: doc.id, timestamp: (data['timestamp'] as Timestamp).toDate(), total: (data['total'] as num).toDouble(), items: items);
//     }).toList();
//   }
//
//   Future<List<OrderModel>> fetchOrdersForDay(DateTime day) async {
//     // Define the start and end of the target day
//     final start = DateTime(day.year, day.month, day.day);
//     final end = start.add(const Duration(days: 1));
//
//     // Query all order documents in subcollections named 'orders' within the date range
//     final snapshot =
//         await _firestore
//             .collectionGroup('orders')
//             .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
//             .where('timestamp', isLessThan: Timestamp.fromDate(end))
//             .orderBy('timestamp')
//             .get();
//
//     // Map each document to an OrderModel
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//
//       // Parse items array
//       final itemsData = List<Map<String, dynamic>>.from(data['items'] as List);
//       final items =
//           itemsData.map((m) {
//             return OrderItem(
//               name: m['name'] as String,
//               service: m['service'] as String,
//               quantity: (m['quantity'] as num).toInt(),
//               price: (m['price'] as num).toDouble(),
//             );
//           }).toList();
//
//       return OrderModel(id: doc.id, timestamp: (data['timestamp'] as Timestamp).toDate(), total: (data['total'] as num).toDouble(), items: items);
//     }).toList();
//   }
//
//   String buildCsv(List<OrderModel> orders) {
//     final sb = StringBuffer();
//     // Header
//     sb.writeln('Order ID,Timestamp,Item,Service,Qty,Price,Line Total');
//     for (var o in orders) {
//       for (var it in o.items) {
//         final lineTotal = it.price * it.quantity;
//         sb.writeln(
//           [
//             o.id,
//             // you may need doc.data()['customer_id'] here if not stored on model
//             '"${o.timestamp.toIso8601String()}"',
//             it.name,
//             it.service,
//             it.quantity,
//             it.price.toStringAsFixed(2),
//             lineTotal.toStringAsFixed(2),
//           ].join(','),
//         );
//       }
//     }
//     return sb.toString();
//   }
//
//   Future<void> loadDashboardStats({required DashboardPeriod period, DateTime? targetDate}) async {
//     selectedPeriod = period;
//     isLoading = true;
//     notifyListeners();
//
//     final now = DateTime.now();
//     int orders = 0;
//     double sales = 0.0;
//
//     try {
//       final ordersSnapshot = await _firestore.collectionGroup('orders').get();
//
//       for (final doc in ordersSnapshot.docs) {
//         final data = doc.data();
//
//         if (data['timestamp'] == null || data['total'] == null) continue;
//
//         final orderTimestamp = (data['timestamp'] as Timestamp).toDate();
//         final orderTotal = (data['total'] as num).toDouble();
//
//         if (period == DashboardPeriod.today && _isSameDay(orderTimestamp, now)) {
//           orders++;
//           sales += orderTotal;
//         } else if (period == DashboardPeriod.month && orderTimestamp.year == now.year && orderTimestamp.month == now.month) {
//           orders++;
//           sales += orderTotal;
//         } else if (period == DashboardPeriod.customDay && targetDate != null && _isSameDay(orderTimestamp, targetDate)) {
//           orders++;
//           sales += orderTotal;
//         } else if (period == DashboardPeriod.customMonth &&
//             targetDate != null &&
//             orderTimestamp.year == targetDate.year &&
//             orderTimestamp.month == targetDate.month) {
//           orders++;
//           sales += orderTotal;
//         }
//       }
//
//       // Clear previous values to avoid stale UI
//       ordersToday = 0;
//       salesToday = 0.0;
//       ordersThisMonth = 0;
//       salesThisMonth = 0.0;
//       customOrders = 0;
//       customSales = 0.0;
//
//       // Set only relevant values
//       switch (period) {
//         case DashboardPeriod.today:
//           ordersToday = orders;
//           salesToday = sales;
//           break;
//         case DashboardPeriod.month:
//           ordersThisMonth = orders;
//           salesThisMonth = sales;
//           break;
//         case DashboardPeriod.customDay:
//         case DashboardPeriod.customMonth:
//           customOrders = orders;
//           customSales = sales;
//           break;
//       }
//     } catch (e) {
//       print("Error fetching dashboard data: $e");
//     }
//     print('done');
//     print(salesToday);
//     print(salesThisMonth);
//     print(customSales);
//     hasData = true;
//     isLoading = false;
//     notifyListeners();
//   }
//
//   bool _isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/WebOrderModel.dart';
import '../services/web_firebase_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final WebFirebaseService _firebaseService;

  DashboardViewModel(this._firebaseService);

  List<WebOrderModel> activeOrders = [];
  bool isLoadingActiveOrders = false;

  int ordersToday = 0;
  double salesToday = 0.0;
  double amountInToday=0.0;
  int ordersThisMonth = 0;
  double salesThisMonth = 0.0;
  double amountInThisMonth = 0.0;
  int customOrders = 0;
  double customSales = 0.0;
  double customAmountIn=0.0;

  bool isLoading = false;
  bool hasData = false;
  DashboardPeriod selectedPeriod = DashboardPeriod.today;

  Map<String, Map<String, List<WebOrderModel>>> get groupedActiveOrders {
    final Map<String, Map<String, List<WebOrderModel>>> result = {};

    for (var order in activeOrders) {
      final monthKey = "${order.timestamp.year}-${order.timestamp.month.toString().padLeft(2, '0')}";
      final dayKey = "${order.timestamp.year}-${order.timestamp.month.toString().padLeft(2, '0')}-${order.timestamp.day.toString().padLeft(2, '0')}";

      result.putIfAbsent(monthKey, () => {});
      result[monthKey]!.putIfAbsent(dayKey, () => []);
      result[monthKey]![dayKey]!.add(order);
    }

    return result;
  }

  Future<void> loadDashboardStats({required DashboardPeriod period, DateTime? targetDate}) async {
    selectedPeriod = period;
    isLoading = true;
    hasData = false;
    notifyListeners();

    try {
      final now = DateTime.now();
      ordersToday = 0;
      amountInToday=0.0;
      customAmountIn=0.0;
      salesToday = 0.0;
      ordersThisMonth = 0;
      salesThisMonth = 0.0;
      customOrders = 0;
      customSales = 0.0;

      switch (period) {
        case DashboardPeriod.today:
          final todaySummary = await _firebaseService.fetchDaySummary(now);
          if (todaySummary != null) {
            ordersToday = todaySummary['total_orders_placed'] ?? 0;
            salesToday = (todaySummary['total_amount_placed'] ?? 0).toDouble();
            amountInToday = (todaySummary['amount_in'] ?? 0).toDouble();
          }
          break;

        // case DashboardPeriod.month:
        //   for (int i = 0; i < 31; i++) {
        //     final day = now.subtract(Duration(days: i));
        //     if (day.month != now.month) break;
        //
        //     final summary = await _firebaseService.fetchDaySummary(day);
        //     if (summary != null) {
        //       // ordersThisMonth += summary['total_orders_placed'] ?? 0;
        //       ordersThisMonth += (summary['total_orders_placed'] != null) ? (summary['total_orders_placed'] as num).toInt() : 0;
        //       salesThisMonth += (summary['total_amount_placed'] ?? 0).toDouble();
        //     }
        //   }
        //   break;

        case DashboardPeriod.customDay:
          if (targetDate == null) break;
          final summary = await _firebaseService.fetchDaySummary(targetDate);
          if (summary != null) {
            customOrders = summary['total_orders_placed'] ?? 0;
            customSales = (summary['total_amount_placed'] ?? 0).toDouble();
            customAmountIn = (summary['amount_in'] ?? 0).toDouble();
          }
          break;

        // case DashboardPeriod.customMonth:
        //   if (targetDate == null) break;
        //
        //   final year = targetDate.year;
        //   final month = targetDate.month;
        //
        //   final start = DateTime(year, month);
        //   final end = DateTime(year, month + 1); // start of next month
        //
        //   for (DateTime day = start;
        //   day.isBefore(end);
        //   day = day.add(const Duration(days: 1))) {
        //     final summary = await _firebaseService.fetchDaySummary(day);
        //     if (summary != null) {
        //       customOrders += (summary['total_orders_placed'] ?? 0) as int;
        //       customSales += (summary['total_amount_placed'] ?? 0).toDouble();
        //     }
        //   }
        //   break;
        case DashboardPeriod.month:
          final result = await _firebaseService.fetchMonthSummary(DateTime(now.year, now.month));
          ordersThisMonth = result['total_orders_placed'];
          salesThisMonth = result['total_amount_placed'];
          amountInThisMonth = result['amount_in'];
          break;

        case DashboardPeriod.customMonth:
          if (targetDate == null) break;
          final result = await _firebaseService.fetchMonthSummary(DateTime(targetDate.year, targetDate.month));
          customOrders = result['total_orders_placed'];
          customSales = result['total_amount_placed'];
          customAmountIn = result['amount_in'];
          break;
        case DashboardPeriod.activeOrders:
          await loadActiveOrders(); // Implement this method to fetch active orders and update vm.activeOrders list
          break;
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
    }

    hasData = true;
    isLoading = false;
    notifyListeners();
  }

  Future<List<WebOrderModel>> fetchOrdersForCustomer(String customerCode) async {
    final raw = await _firebaseService.fetchOrdersForCustomer(customerCode);
    // return raw.map(_mapToOrderModel).toList();
    return raw.map((doc) => _mapToOrderModel(doc)).toList();
  }

  Future<List<WebOrderModel>> fetchOrdersForDay(DateTime date) async {
    final raw = await _firebaseService.fetchOrdersForDay(date);
    // return raw.map(_mapToOrderModel).toList();
    return raw.map((doc) => _mapToOrderModel(doc)).toList();
  }

  // String buildCsv(List<WebOrderModel> orders) {
  //   final sb = StringBuffer();
  //   sb.writeln('Order ID,Timestamp,Item,Service,Qty,Price,Line Total');
  //   for (var o in orders) {
  //     for (var it in o.items) {
  //       final lineTotal = it.price * it.quantity;
  //       sb.writeln(
  //         [
  //           o.id,
  //           '"${o.timestamp.toIso8601String()}"',
  //           it.name,
  //           it.service,
  //           it.quantity,
  //           it.price.toStringAsFixed(2),
  //           lineTotal.toStringAsFixed(2),
  //         ].join(','),
  //       );
  //     }
  //   }
  //   return sb.toString();
  // }
  String buildCsv(List<WebOrderModel> orders) {
    final sb = StringBuffer();

    sb.writeln('Order ID,Customer Code,Timestamp,Item,Service,Qty,Price,Line Total');

    for (var o in orders) {
      final orderTimestamp = DateFormat('yyyy-MM-dd HH:mm').format(o.timestamp);

      for (var it in o.items) {
        final lineTotal = it.price * it.quantity;
        sb.writeln(
          [
            o.orderId, // Make sure this field exists & is populated
            o.customerCode, // Add customer code here
            '"$orderTimestamp"', // Formatted timestamp
            it.name,
            it.service,
            it.quantity,
            it.price.toStringAsFixed(2),
            lineTotal.toStringAsFixed(2),
          ].join(','),
        );
      }
    }
    return sb.toString();
  }

  WebOrderModel _mapToOrderModel(Map<String, dynamic> data) {
    final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final items =
        itemsData.map((m) {
          return OrderItem(
            name: m['name'] ?? '',
            service: m['service'] ?? '',
            quantity: (m['quantity'] as num).toInt(),
            price: (m['price'] as num).toDouble(),
          );
        }).toList();

    return WebOrderModel(
      id: data['id'] ?? '',
      // fallback, optional
      customerCode: data['customer_code'] ?? '',
      orderId: data['order_id'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      total: (data['total'] as num).toDouble(),
      items: items,
    );
  }

  Future<void> loadActiveOrders() async {
    isLoadingActiveOrders = true;
    notifyListeners();

    activeOrders = await _firebaseService.fetchAllActiveOrders();

    isLoadingActiveOrders = false;
    notifyListeners();
  }
}

// enum DashboardPeriod { today, month, customDay, customMonth }
enum DashboardPeriod {
  today,
  month,
  customDay,
  customMonth,
  activeOrders, // NEW
}

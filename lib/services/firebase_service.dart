// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/cloth_item.dart';
// import 'package:intl/intl.dart';
//
// class FirebaseService {
//   static final _customerCollection = "vCustomers";
//   static final _orderCollection = "vOrders";
//   /// Creates or updates a customer document.
//   /// Returns the customerId used (either the phone number or an auto-ID).
//   static Future<String> _ensureCustomer({
//     String? phoneNumber,
//     // String? address,
//     String? roomNumber,
//   }) async {
//     final customers = _firestore.collection(_customerCollection);
//     DocumentReference<Map<String, dynamic>> docRef;
//
//     roomNumber ??= '';
//
//     if (phoneNumber != null && phoneNumber.isNotEmpty) {
//       // Use phone number as the document ID
//       docRef = customers.doc(phoneNumber);
//       await docRef.set({
//         'phone_number': phoneNumber,
//         if (roomNumber.isNotEmpty) 'room_number': roomNumber,
//         // If new, set creation timestamp; if existing, leave unchanged
//         // 'account_creation': FieldValue.serverTimestamp(),
//         'last_purchase_date': FieldValue.serverTimestamp(),
//         'loyalty_points': FieldValue.increment(0),
//       }, SetOptions(merge: true));
//     } else {
//       // No phone number: create a new doc with auto-ID
//       docRef = customers.doc();
//       await docRef.set({
//         if (roomNumber.isNotEmpty) 'room_number': roomNumber,
//         'account_creation': FieldValue.serverTimestamp(),
//         'last_purchase_date': FieldValue.serverTimestamp(),
//         'loyalty_points': 0,
//       });
//     }
//
//     return docRef.id;
//   }
//
//   /// Saves an order under 'orders' collection, grouped by date,
//   /// and links it to a customer (by phoneNumber or auto-ID).
//   static Future<String> saveOrder({
//     String? phoneNumber,
//     // String? address,
//     required List<ClothItem> items,
//     required double total, String? roomNumber,
//   }) async {
//     // 1. Ensure we have a customer document, get its ID
//     final customerId = await _ensureCustomer(
//       phoneNumber: phoneNumber,
//       // address: address,
//       roomNumber:roomNumber
//     );
//
//     // 2. Prepare date key (e.g. "2025-05-28")
//     final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//     // 3. Map selected items, default quantity = 1
//     final selectedItems = items
//         .where((i) => i.isSelected && i.selectedService != null)
//         .map((i) => {
//       'name': i.name,
//       'service': i.selectedService.toString().split('.').last,
//       'price': i.totalPrice,
//       'quantity': i.quantity,
//     })
//         .toList();
//
//     // 4. Reference the date‐specific subcollection
//     final ordersRef = _firestore
//         .collection(_orderCollection)
//         .doc(dateKey)
//         .collection('orders');
//
//     // 5. Add the order document
//     final docRef = await ordersRef.add({
//       'customer_id': customerId,
//       'timestamp': FieldValue.serverTimestamp(),
//       'total': total,
//       'items': selectedItems,
//     });
//
//     // 6. Update the customer's last purchase date and total spent
//     final customerRef =
//     _firestore.collection(_customerCollection).doc(customerId);
//
//     await customerRef.update({
//       'last_purchase_date': FieldValue.serverTimestamp(),
//       'total_spent': FieldValue.increment(total),
//     });
//     return docRef.id;
//   }
// }

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:laundry_os_extended/utils/error_handler.dart';

import '../models/cloth_item.dart';
import '../models/customer_model.dart';
import '../models/orderModel.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _customerCollection = "vCustomers";
  static final _orderCollection = "vOrders";
  static final _activeOrdersCollection = "active_orders";
  static final _customerCodeIndex = "customer_codes";

  /// Ensures a customer exists and returns their ID (phone number or auto-ID)
  /// Also assigns a unique customer_code if not already present.
  // static Future<String> _ensureCustomer({required String phoneNumber, required String name, String? customer_code}) async {
  //   final customers = _firestore.collection(_customerCollection);
  //   final customerDoc = customers.doc(phoneNumber);
  //   final snapshot = await customerDoc.get();
  //   // customer_code ??= '';
  //   print("customerDoc");
  //
  //   if (snapshot.exists) {
  //     // Customer already exists — update any new fields, return ID
  //     // await customerDoc.set({
  //     //   // if (customer_code.isNotEmpty) 'customer_code': customer_code,
  //     //   // 'last_purchase_date': FieldValue.serverTimestamp(),
  //     //   // 'loyalty_points': FieldValue.increment(0),
  //     // }, SetOptions(merge: true));
  //     final k = jsonEncode(await customerDoc.get());
  //     final i = jsonDecode(k);
  //     print(i);
  //     return customerDoc.id;
  //   }
  //
  //   // Customer doesn't exist — generate unique customer_code
  //   String customerCode;
  //   if (customer_code != null && customer_code.isNotEmpty) {
  //     customerCode = customer_code;
  //   } else {
  //     customerCode = await _generateCustomerCode(name, phoneNumber);
  //   }
  //
  //   // Save new customer
  //   await customerDoc.set({
  //     'name': name,
  //     'phone_number': phoneNumber,
  //     'customer_code': customerCode,
  //     'account_creation': FieldValue.serverTimestamp(),
  //     // 'last_purchase_date': FieldValue.serverTimestamp(),
  //     // 'loyalty_points': 0,
  //     'total_spent': 0,
  //   });
  //
  //   // Add lightweight search index
  //   await _firestore.collection(_customerCodeIndex).doc(customerCode).set({'phone_number': phoneNumber, 'name': name});
  //   print(jsonEncode(customerDoc));
  //
  //   return customerDoc.id;
  // }

  static Future<Customer?> _ensureCustomerCode({required String customer_code}) async {
    print(507);
    if (customer_code != null && customer_code.isNotEmpty) {
      print(508);
      print(customer_code);
      // Customer doesn't exist — generate customer_code
      final customerCode = customer_code;

      final customers = _firestore.collection(_customerCollection);
      print(customers);

      final customerDoc = customers.doc(customerCode);
      print(customerDoc);

      final snapshot = await customerDoc.get();
      print(509);

      if (snapshot.exists) {
        print(510);

        final data = snapshot.data();
        if (data != null) {
          print(511);
          return Customer.fromMap(data, existing: true); // ✅ Return the deserialized Customer
        } else {
          print(512);

          throw CustomerError("Code is not assigned to any customer.\nPlease use Name and Phone number to create a customer.");
        }
      } else {
        print(513);
        throw CustomerError("Code is not assigned to any customer.\nPlease use Name and Phone number to create a customer.");
      }
    } else {
      print(514);

      throw CustomerError('Customer Code appears to be empty. Error Code : 502');
    }
  }

  static Future<Customer?> checkCustomer({String? phoneNumber, String? name, String? customer_code}) async {
    try {
      print(504);

      if ((phoneNumber != null && name != null) && (phoneNumber.isNotEmpty && name.isNotEmpty)) {
        print(505);
        final codeIndexCollection = _firestore.collection(_customerCodeIndex);

        // Try to find an existing customer by phone_number and name
        final existingQuery = await codeIndexCollection.where('phone_number', isEqualTo: phoneNumber).limit(1).get();

        if (existingQuery.docs.isNotEmpty) {
          // Found existing customer, now fetch from main customer collection
          final existingCustomerCode = existingQuery.docs.first.id;
          final customerSnapshot = await _firestore.collection(_customerCollection).doc(existingCustomerCode).get();

          if (customerSnapshot.exists && customerSnapshot.data() != null) {
            final existingCustomer = Customer.fromMap(customerSnapshot.data()!, existing: true);
            return existingCustomer;
          } else {
            throw CustomerError("Customer exists in index but not in main collection.");
          }
        }
        return await createNewCustomer(name, phoneNumber, codeIndexCollection);
      } else if (customer_code != null && customer_code.isNotEmpty) {
        print(506);

        // Customer doesn't exist — generate customer_code
        final customerCode = customer_code;

        final customer = await _ensureCustomerCode(customer_code: customerCode);

        if (customer != null) {
          return customer;
        } else {
          throw CustomerError("Code is not assigned to any customer.\nPlease use Name and Phone number to create a customer.");
        }
      } else {
        print('neither');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Customer?> _ensureCustomer({String? phoneNumber, String? name, String? customer_code}) async {
    try {
      // if ((phoneNumber != null && name != null) && (phoneNumber.isNotEmpty && name.isNotEmpty)) {
      //
      //   // Customer doesn't exist — generate customer_code
      //   final customerCode = await _generateCustomerCode(name, phoneNumber);
      //
      //   final customers = _firestore.collection(_customerCollection);
      //   final customerDoc = customers.doc(customerCode);
      //   final snapshot = await customerDoc.get();
      //
      //   if (snapshot.exists) {
      //     final data = snapshot.data();
      //     if (data != null) {
      //       return Customer.fromMap(data); // ✅ Return the deserialized Customer
      //     } else {
      //       throw CustomerError("Customer data is missing.");
      //     }
      //   }
      //
      //   final newCustomer = {
      //     'name': name,
      //     'phone_number': phoneNumber,
      //     'customer_code': customerCode,
      //     'account_creation': FieldValue.serverTimestamp(),
      //     'total_spent': 0.0,
      //   };
      //
      //   await customerDoc.set(newCustomer);
      //
      //   await _firestore.collection(_customerCodeIndex).doc(customerCode).set({'phone_number': phoneNumber, 'name': name});
      //
      //   // Re-fetch to get server timestamps
      //   final saved = await customerDoc.get();
      //   return Customer.fromMap(saved.data()!);
      // }
      if ((phoneNumber != null && name != null) && (phoneNumber.isNotEmpty && name.isNotEmpty)) {
        final codeIndexCollection = _firestore.collection(_customerCodeIndex);

        // Try to find an existing customer by phone_number and name
        final existingQuery = await codeIndexCollection.where('phone_number', isEqualTo: phoneNumber).limit(1).get();

        if (existingQuery.docs.isNotEmpty) {
          // Found existing customer, now fetch from main customer collection
          final existingCustomerCode = existingQuery.docs.first.id;
          final customerSnapshot = await _firestore.collection(_customerCollection).doc(existingCustomerCode).get();

          if (customerSnapshot.exists && customerSnapshot.data() != null) {
            final existingCustomer = Customer.fromMap(customerSnapshot.data()!);
            return existingCustomer;
          } else {
            throw CustomerError("Customer exists in index but not in main collection.");
          }
        }
        return await createNewCustomer(name, phoneNumber, codeIndexCollection);
      } else if (customer_code != null && customer_code.isNotEmpty) {
        // Customer doesn't exist — generate customer_code
        final customerCode = customer_code;

        final customer = await _ensureCustomerCode(customer_code: customerCode);

        if (customer != null) {
          return customer;
        } else {
          throw CustomerError("Code is not assigned to any customer.\nPlease use Name and Phone number to create a customer.");
        }
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  static Future<Customer> createNewCustomer(String name, String phoneNumber, codeIndexCollection) async {
    // No existing customer found — generate new code
    final customerCode = await _generateCustomerCode(name, phoneNumber);

    final customers = _firestore.collection(_customerCollection);
    final customerDoc = customers.doc(customerCode);

    final newCustomer = {
      'name': name,
      'phone_number': phoneNumber,
      'customer_code': customerCode,
      'account_creation': FieldValue.serverTimestamp(),
      'total_spent': 0.0,
    };

    await customerDoc.set(newCustomer);

    await codeIndexCollection.doc(customerCode).set({'phone_number': phoneNumber, 'name': name});

    final saved = await customerDoc.get();
    return Customer.fromMap(saved.data()!);
  }

  /// Generate a readable 3-digit code based on name + phone, checking uniqueness
  static Future<String> _generateCustomerCode(String name, String phone) async {
    final indexRef = _firestore.collection(_customerCodeIndex);
    final base = name.substring(0, 2).toUpperCase();
    final last2 = phone.substring(phone.length - 2);
    final last3 = phone.substring(phone.length - 3);

    List<String> attempts = ['$base-$last2', '$base-$last3'];

    if (name.length >= 3) {
      attempts.add('${name.substring(0, 3).toUpperCase()}-$last3');
    }

    for (final code in attempts) {
      final exists = await indexRef.doc(code).get();
      if (!exists.exists) return code;
    }

    // Final fallback with random suffix
    final random = Random().nextInt(899) + 100; // 100–999
    return '${base}-$random';
  }

  /// Saves a new order
  static Future<String?> saveOrder({
    String? phoneNumber,
    String? name,
    required List<ClothItem> items,
    required double total,
    String? customer_code,
    required Customer customer,
  }) async {
    try {
      // final customer = await _ensureCustomer(phoneNumber: phoneNumber, name: name, customer_code: customer_code);
      if (customer is Customer) {
        // final customerDoc = await _firestore.collection(_customerCollection).doc(customer.customerCode).get();
        // final customerCode = customerDoc['customer_code'];
        final customerCode = customer.customerCode;
        final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

        final selectedItems =
            items
                .where((i) => i.isSelected && i.selectedService != null)
                .map((i) => {'name': i.name, 'service': i.selectedService.toString().split('.').last, 'price': i.totalPrice, 'quantity': i.quantity})
                .toList();

        final ordersRef = _firestore.collection(_orderCollection).doc(dateKey).collection('orders');

        // STEP 1: Generate a docRef first (no write yet)
        final docRef = ordersRef.doc(); // <- creates doc with unique ID

        final orderData = {
          'order_id': docRef.id,
          'customer_phone': customer.phoneNumber,
          'customer_code': customerCode,
          'timestamp': FieldValue.serverTimestamp(),
          'total': total,
          'items': selectedItems,
          'status': 'active',
        };

        // final docRef = await ordersRef.add(orderData);

        // STEP 3: Write data using set
        await docRef.set(orderData);

        // Add to active_orders
        await _firestore
            .collection(_activeOrdersCollection)
            .doc(docRef.id) // ✅ use flat structure
            .set({
              'customer_code': customerCode,
              'order_id': docRef.id,
              'timestamp': FieldValue.serverTimestamp(),
              'order_date': dateKey,
              'total': total,
            });

        // Update customer profile
        await _firestore.collection(_customerCollection).doc(customer.customerCode).update({
          'last_purchase_date': FieldValue.serverTimestamp(),
          'total_spent': FieldValue.increment(total),
        });

        // Update summary fields in /vOrders/{date}
        final summaryRef = _firestore.collection(_orderCollection).doc(dateKey);

        await summaryRef.set({
          'total_orders_placed': FieldValue.increment(1),
          'total_amount_placed': FieldValue.increment(total),
        }, SetOptions(merge: true));

        return docRef.id;
      }
    } catch (e) {
      rethrow;
    }
  }

  // static Future<void> markOrderComplete({required String orderId, required String dateKey, required double total}) async {
  //   final orderDocRef = _firestore.collection(_orderCollection).doc(dateKey).collection('orders').doc(orderId);
  //
  //   // Update the order status
  //   await orderDocRef.update({'status': 'completed'});
  //
  //   // Remove from active_orders
  //   await _firestore.collection(_activeOrdersCollection).doc(orderId).delete();
  //
  //   // Update summary in vOrders/{date}
  //   final summaryRef = _firestore.collection(_orderCollection).doc(dateKey);
  //
  //   await summaryRef.set({
  //     'total_orders_completed': FieldValue.increment(1),
  //     'total_amount_completed': FieldValue.increment(total),
  //   }, SetOptions(merge: true));
  // }

  /// Fetch active orders by customer code or phone number
  static Future<List<OrderModel>> fetchActiveOrders({String? customerCode, String? phoneNumber}) async {
    try {
      String? codeToSearch = customerCode;

      if ((codeToSearch == null || codeToSearch.isEmpty) && phoneNumber != null && phoneNumber.isNotEmpty) {
        // Lookup customer code by phone number
        final indexSnap = await FirebaseFirestore.instance.collection('customer_codes').where('phone_number', isEqualTo: phoneNumber).limit(1).get();

        if (indexSnap.docs.isEmpty) {
          throw Exception('No customer found for this phone number.');
        }

        codeToSearch = indexSnap.docs.first.id;
      }

      if (codeToSearch == null || codeToSearch.isEmpty) {
        throw Exception('Please enter customer code or phone number.');
      }

      // Query active_orders collection directly
      final snapshot = await FirebaseFirestore.instance.collection(_activeOrdersCollection).where('customer_code', isEqualTo: codeToSearch).get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Mark an order complete: update order, remove active, update summary
  static Future<void> completeOrder(OrderModel order) async {
    final dateKey = order.dateKey ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    final orderRef = FirebaseFirestore.instance.collection(_orderCollection).doc(dateKey).collection('orders').doc(order.orderId);

    final activeOrderRef = FirebaseFirestore.instance.collection(_activeOrdersCollection).doc(order.orderId);

    final summaryRef = FirebaseFirestore.instance.collection(_orderCollection).doc(dateKey);

    // Use transaction for atomicity
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Update order status to completed
      transaction.update(orderRef, {'status': 'completed'});

      // Remove from active_orders
      transaction.delete(activeOrderRef);

      // Update summary
      transaction.set(summaryRef, {
        'total_orders_completed': FieldValue.increment(1),
        'total_amount_completed': FieldValue.increment(order.total),
        'amount_in': FieldValue.increment(order.total)
      }, SetOptions(merge: true));
    });
  }

  static Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await FirebaseFirestore.instance.collection('active_orders').doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }
}

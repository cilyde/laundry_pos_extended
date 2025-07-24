import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundry_os_extended/Config.dart';
import 'package:laundry_os_extended/utils/error_handler.dart';

import '../Constants/clothItems.dart';
import '../models/cloth_item.dart';
import '../models/customer_model.dart';
import '../services/firebase_service.dart';
import '../services/print_service.dart';
import '../utils/translation.dart';

// Translation helper function that tries to get translation for a key and language,
// falling back to the key if translation is missing.
String tr(String key, String lang) => translations[key.toLowerCase()]?[lang] ?? key;

/// POSViewModel is a ChangeNotifier that manages the state and logic
/// for the laundry Point of Sale (POS) screen.
///
/// It handles selection of cloth items grouped by service,
/// quantity updates, removal, order confirmation, printing receipts,
/// and syncing order data to Firestore.
// class POSViewModel extends ChangeNotifier {
//   final PrinterService _printer; // Service to handle printing
//
//   bool _isLoading = false; // Loading indicator flag
//   bool get isLoading => _isLoading;
//
//   bool _isOnline = true; // ✅ flag to track connectivity
//   bool get isOnline => _isOnline;
//
//   // Constructor initializes the printer service and triggers printer init.
//   POSViewModel(this._printer) {
//     _initPrinter();
//     // _listenToConnectivity(); // ✅ listen on init
//   }
//
//   // Internal async method to initialize the printer hardware or SDK.
//   Future<void> _initPrinter() async {
//     final ok = await _printer.initPrinter();
//     if (!ok) debugPrint('Printer initialization failed.');
//   }
//
//   // Currently selected service type (wash, iron, or both)
//   ServiceType currentService = ServiceType.both;
//
//   // Map holding lists of selected ClothItems grouped by service type
//   final Map<ServiceType, List<ClothItem>> _selectedItemsByService = {ServiceType.wash: [], ServiceType.iron: [], ServiceType.both: []};
//
//   /// Exposes the full grouped map of selected items for UI display
//   Map<ServiceType, List<ClothItem>> get allSelectedItemsGrouped => _selectedItemsByService;
//
//   /// Changes the current service context (affects which items are shown/added)
//   void changeService(ServiceType service) {
//     currentService = service;
//     notifyListeners();
//   }
//
//   /// Adds or increments quantity of a ClothItem in the currently selected service group.
//   /// If item already exists by name, increments quantity; else adds new item with quantity=1.
//   void toggleItem(ClothItem item) {
//     final items = _selectedItemsByService[currentService]!;
//
//     final index = items.indexWhere((i) => i.name == item.name);
//     if (index >= 0) {
//       items[index].quantity += 1;
//     } else {
//       items.add(
//         ClothItem(
//           name: item.name,
//           washPrice: item.washPrice,
//           ironPrice: item.ironPrice,
//           quantity: 1,
//           isSelected: true,
//           selectedService: currentService,
//           img: item.img,
//         ),
//       );
//     }
//     notifyListeners();
//   }
//
//   /// Returns the list of items selected for the current service.
//   List<ClothItem> get selectedItems => _selectedItemsByService[currentService]!;
//
//   /// Calculates the total price of all selected items across all services.
//   double get totalPrice => _selectedItemsByService.values.expand((list) => list).fold(0.0, (sum, item) => sum + item.totalPrice);
//
//   /// Updates the quantity of a specific item within its service group.
//   void updateQuantity(ClothItem item, int newQuantity) {
//     final serviceItems = _selectedItemsByService[item.selectedService]!;
//
//     final index = serviceItems.indexWhere((e) => e.name == item.name && e.selectedService == item.selectedService);
//     if (index != -1) {
//       serviceItems[index].quantity = newQuantity;
//       notifyListeners();
//     }
//   }
//
//   /// Removes an item from its corresponding service group.
//   void removeItem(ClothItem item) {
//     final items = _selectedItemsByService[item.selectedService]!;
//     items.removeWhere((e) => e.name == item.name);
//     notifyListeners();
//   }
//
//   Future<bool> checkOnline() async {
//     // Check connectivity first
//     final isConnected = await ConnectivityService.hasConnection();
//     if (!isConnected) {
//       debugPrint('No internet connection.');
//       return false;
//     } else {
//       return true;
//     }
//   }
//
//   /// Confirms the order by:
//   /// - Showing loading spinner,
//   /// - Saving order data to Firebase Firestore,
//   /// - Printing two copies of the receipt,
//   /// - Resetting the order state.
//   ///
//   /// Returns true if successful; false if no items selected or on error.
//   Future<bool> confirmAndPrintOrder({String? phoneNumber, String? roomNumber,}) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final selectedItems = _selectedItemsByService.values.expand((e) => e).toList();
//
//       if (selectedItems.isEmpty) {
//         return false; // No items selected - fail early
//       }
//
//       // Save order data to Firestore and get a receipt ID back
//       final recieptId = await FirebaseService.saveOrder(
//         phoneNumber: phoneNumber,
//         roomNumber: roomNumber,
//         items: selectedItems,
//         total: totalPrice,
//       );
//
//       // Prepare list of receipt items for printing
//       final receiptItems =
//           _selectedItemsByService.values
//               .expand((items) => items)
//               .map(
//                 (item) => {
//                   'name': item.name,
//                   'service': item.selectedService.toString().split('.').last,
//                   'price': item.totalPrice,
//                   'quantity': item.quantity,
//                 },
//               )
//               .toList();
//
//       // Print two copies with 3 seconds delay between
//       for (var i = 0; i < 2; i++) {
//         await _printer.printOrderReceipt(
//           shopName: 'Fresh & Clean Laundry',
//           items: receiptItems,
//           total: totalPrice,
//           phoneNumber: phoneNumber,
//           recieptId: recieptId,
//         );
//         if (i != 1) {
//           await Future.delayed(const Duration(seconds: 3));
//         }
//       }
//
//       reset(); // Clear the current order after printing
//       return true;
//     } catch (e) {
//       debugPrint('Error printing order: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// Clears all selected items and resets the current service to wash.
//   void reset() {
//     _selectedItemsByService.forEach((_, list) => list.clear());
//     currentService = ServiceType.both;
//     notifyListeners();
//   }
// }

class POSViewModel extends ChangeNotifier {
  POSViewModel(this._printer) {
    if (isSunmi) {
      _initPrinter();
    }
  }

  final PrinterService _printer;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ServiceType currentService = ServiceType.both;
  final Map<ServiceType, List<ClothItem>> _selectedItemsByService = {
    ServiceType.wash: [],
    ServiceType.iron: [],
    ServiceType.both: [],
    ServiceType.express: [],
  };

  List<ClothItem> _filteredItems = [];

  List<ClothItem> get filteredItems => _filteredItems;

  void refreshItems() {
    print("In vm refreshing filtered");
    // Filter items based on selected service and availability of iron price
    _filteredItems =
        availableItems.where((item) {
          if ((currentService == ServiceType.iron || currentService == ServiceType.both || currentService == ServiceType.express) &&
              item.ironPrice == null) {
            return false; // Exclude items with no iron price when iron is selected
          }
          return true;
        }).toList();
  }

  Future<void> _initPrinter() async {
    final ok = await _printer.initPrinter();
    if (!ok) debugPrint('Printer initialization failed.');
  }

  Map<ServiceType, List<ClothItem>> get allSelectedItemsGrouped => _selectedItemsByService;

  List<ClothItem> get selectedItems => _selectedItemsByService[currentService]!;

  void changeService(ServiceType service) {
    currentService = service;
    refreshItems();
    notifyListeners();
  }

  void addItem(ClothItem item) {
    final items = _selectedItemsByService[currentService]!;
    final index = items.indexWhere((i) => i.name == item.name);
    if (index >= 0) {
      items[index].quantity += 1;
    } else {
      items.add(
        ClothItem(
          name: item.name,
          washPrice: item.washPrice,
          ironPrice: item.ironPrice,
          bothPrice: item.bothPrice,
          expressPrice: item.expressPrice,
          quantity: 1,
          isSelected: true,
          selectedService: currentService,
          img: item.img,
        ),
      );
    }
    notifyListeners();
  }

  double get totalPrice => _selectedItemsByService.values.expand((list) => list).fold(0.0, (sum, item) => sum + item.totalPrice);

  void updateQuantity(ClothItem item, int newQuantity) {
    final serviceItems = _selectedItemsByService[item.selectedService]!;
    final index = serviceItems.indexWhere((e) => e.name == item.name && e.selectedService == item.selectedService);
    if (index != -1) {
      serviceItems[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void removeItem(ClothItem item) {
    final items = _selectedItemsByService[item.selectedService]!;
    items.removeWhere((e) => e.name == item.name);
    notifyListeners();
  }

  /// Saves and prints the order. Requires [name] and [phoneNumber].
  Future<bool> confirmAndPrintOrder({required String? name, required String? phoneNumber, String? customer_code, required Customer customer}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final selectedItems = _selectedItemsByService.values.expand((e) => e).toList();
      if (selectedItems.isEmpty) {
        debugPrint('Missing items.');
        return false;
      } else if (((name == null || phoneNumber == null) && (name!.isEmpty || phoneNumber!.isEmpty)) &&
          (customer_code == null && customer_code!.isEmpty)) {
        debugPrint('Missing customer info.');
        return false;
      }

      final String? orderID = await FirebaseService.saveOrder(
        name: name,
        phoneNumber: phoneNumber,
        customer_code: customer_code,
        items: selectedItems,
        total: totalPrice,
        customer: customer,
      );
      print('Vm SaveOrder fin');

      if (orderID is String) {
        final receiptItems =
            selectedItems
                .map(
                  (item) => {
                    'name': item.name,
                    'service': item.selectedService.toString().split('.').last,
                    'price': item.totalPrice,
                    'quantity': item.quantity,
                  },
                )
                .toList();

        if (isSunmi) {
          await _printer.printOrderReceiptExtended(customerCode: customer.customerCode, items: receiptItems, total: totalPrice, orderID: orderID!);
        }

        reset();
        return true;
      } else {
        print('Reciept ID is null');
        return false;
      }
    } catch (e) {
      if (e is CustomerError) {
        rethrow;
      }
      debugPrint('Error printing order: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedItemsByService.forEach((_, list) => list.clear());
    currentService = ServiceType.both;
    notifyListeners();
  }

  Future<Customer?> checkCustomer({String? phoneNumber, String? name, String? customer_code}) async {
    try {
      print(500);
      final customer = await FirebaseService.checkCustomer(phoneNumber: phoneNumber, name: name, customer_code: customer_code);
      if (customer != null) {
        print(501);
        return customer;
      } else {
        print(502);
        throw CustomerError('Something went wrong. Error Code : 501');
      }
    } catch (e) {
      rethrow;
    }
  }
}

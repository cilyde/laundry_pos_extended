import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_os_extended/services/firebase_service.dart';
import 'package:laundry_os_extended/utils/error_handler.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/cloth_item.dart';
import '../utils/service_converter.dart';
import '../view_models/pos_view_model.dart';
import 'pos_view.dart';

/// OrderReviewScreen displays a detailed review of all selected laundry items grouped by service type.
/// It allows editing item quantities, removing items, entering a phone number, and confirming the order.
/// On confirmation, it triggers order printing and returns to the main POS screen.
///
/// It supports multi-language display via `currentLanguage` passed in constructor.
// class OrderReviewScreen extends StatefulWidget {
//   const OrderReviewScreen({required this.currentLanguage, super.key});
//
//   // The current language code for translations (e.g., 'en', 'ar', 'hi')
//   final String currentLanguage;
//
//   @override
//   State<OrderReviewScreen> createState() => _OrderReviewScreenState();
// }
//
// class _OrderReviewScreenState extends State<OrderReviewScreen> {
//   // Controller for the phone number text field
//   final _phoneController = TextEditingController();
//   final _roomController = TextEditingController();
//
//   @override
//   void dispose() {
//     // Dispose controller to free resources when widget is removed
//     _phoneController.dispose();
//     _roomController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Access the POSViewModel from Provider to get order data and logic
//     final vm = context.watch<POSViewModel>();
//
//     // Group selected items by service type (wash, iron, both)
//     final groupedItems = vm.allSelectedItemsGrouped;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(tr('Review Order', widget.currentLanguage)), // Translated title
//       ),
//       body:
//           vm.isLoading
//               ? Center(child: CircularProgressIndicator()) // Show loading spinner during processing
//               : groupedItems.isEmpty
//               ? Center(child: Text(tr('"No items in the order"', widget.currentLanguage))) // Message if no items are selected
//               : ListView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.all(16),
//                 children: [
//                   // Iterate over each service group (wash/iron/both)
//                   ...groupedItems.entries.map((entry) {
//                     final service = entry.key;
//                     final items = entry.value;
//                     final serviceString = serviceLabel(service, widget.currentLanguage);
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Service header with translated name (e.g., "Wash")
//                         Text(tr(serviceString, widget.currentLanguage), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//
//                         // Show message if no items under this service
//                         if (items.isEmpty) Container(child: Text('No item selected to $serviceString')),
//
//                         // List all items for this service
//                         ...items.map(
//                           (item) => Card(
//                             child: ListTile(
//                               leading: Image.asset(item.img, width: 40),
//                               // Item image
//                               title: Text(tr(item.name, widget.currentLanguage)),
//                               // Translated name
//                               subtitle: FittedBox(
//                                 fit: BoxFit.scaleDown,
//                                 alignment: Alignment.centerLeft,
//                                 child: Text("${tr('quantity', widget.currentLanguage)}: ${item.quantity}"), // Quantity
//                               ),
//                               dense: true,
//                               trailing: Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(item.totalPrice.toStringAsFixed(2)), // Price display
//                                   // Edit quantity button opens dialog
//                                   IconButton(
//                                     icon: Icon(Icons.edit),
//                                     alignment: Alignment.centerRight,
//                                     onPressed: () => _showEditQuantityDialog(context, vm, item),
//                                   ),
//
//                                   // Delete button removes item from selection
//                                   IconButton(icon: Icon(Icons.delete), alignment: Alignment.centerRight, onPressed: () => vm.removeItem(item)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 16),
//                       ],
//                     );
//                   }),
//
//                   Divider(),
//
//                   // Phone number input field
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 2, // Takes 2/3 of available width
//                           child: TextField(
//                             controller: _phoneController,
//                             keyboardType: TextInputType.phone,
//                             decoration: InputDecoration(
//                               labelText: tr('phone', widget.currentLanguage), // Translated label
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Room number input field
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 2, // Takes 2/3 of available width
//                           child: TextField(
//                             controller: _roomController,
//                             decoration: InputDecoration(
//                               labelText: tr('room', widget.currentLanguage), // Translated label
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // Total price summary
//                   Text(
//                     "Total: Dhs ${vm.totalPrice.toStringAsFixed(2)}",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.end,
//                   ),
//
//                   SizedBox(height: 20),
//
//                   // Confirm Order button triggers order submission and printing
//                   ElevatedButton(
//                     onPressed:
//                         vm.isLoading
//                             ? null
//                             : () async {
//                               // openLanguageDialog();
//                           print("vm.isOnline");
//                           print(vm.isOnline);
//                           if (await vm.checkOnline()) {
//                               final response = await vm.confirmAndPrintOrder(phoneNumber: _phoneController.text, roomNumber: _roomController.text,);
//                               if (response) {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (BuildContext context) {
//                                       return POSView(openDialog: true);
//                                     },
//                                   ),
//                                 );
//                               } else {
//                                 showDialog(context: context, builder: (context) => AlertDialog(title: Text("Please select items first")));
//                               }
//                           } else {
//                             scaffoldMessengerKey.currentState?.showMaterialBanner(
//                               MaterialBanner(
//                                 content: Text(tr('no internet connection', widget.currentLanguage), style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
//                                 backgroundColor: Colors.red,
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner(),
//
//                                     child: Text('DISMISS', style: TextStyle(color: Colors.white)),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }
//                           // };
//                             },
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(double.infinity, 60),
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       // Remove textStyle here to avoid inherit conflict
//                     ),
//                     child:
//                         vm.isLoading
//                             ? CircularProgressIndicator(color: Colors.white)
//                             : Text("Confirm Order", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//     );
//   }
//
//   /// Shows a dialog to edit the quantity of a selected cloth item.
//   /// Updates the quantity in the ViewModel if valid input is entered.
//   void _showEditQuantityDialog(BuildContext context, POSViewModel vm, ClothItem item) {
//     final controller = TextEditingController(text: item.quantity.toString());
//
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: Text("Edit Quantity"),
//             content: TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(hintText: "Enter new quantity"),
//             ),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//               ElevatedButton(
//                 onPressed: () {
//                   final newQty = int.tryParse(controller.text);
//                   if (newQty != null && newQty > 0) {
//                     vm.updateQuantity(item, newQty); // Update quantity in VM
//                     Navigator.pop(context); // Close dialog
//                   }
//                 },
//                 child: Text("Update"),
//               ),
//             ],
//           ),
//     );
//   }
// }
class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({required this.currentLanguage, super.key});

  final String currentLanguage;

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final _phoneController = TextEditingController();

  // bool usingCode = false;

  // final _codeController = TextEditingController();
  final _firstCodeController = TextEditingController();
  final _secondCodeController = TextEditingController();
  final _nameController = TextEditingController(); // ✅ NEW

  @override
  void dispose() {
    _phoneController.dispose();
    _firstCodeController.dispose();
    _secondCodeController.dispose();
    _nameController.dispose(); // ✅ NEW
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<POSViewModel>();
    final groupedItems = vm.allSelectedItemsGrouped;
    print(_nameController.text.isEmpty && _phoneController.text.isEmpty);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Review Order', widget.currentLanguage))),
      body:
          vm.isLoading
              ? Center(child: CircularProgressIndicator())
              : groupedItems.isEmpty
              ? Center(child: Text(tr('"No items in the order"', widget.currentLanguage)))
              : ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                children: [
                  // Display cloth items
                  ...groupedItems.entries.map((entry) => _buildServiceGroup(entry.key, entry.value)),

                  Divider(),

                  // Name input field ✅
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _nameController,
                      onChanged: (name) {
                        final length = name.length;
                        final NAME = name.toString().toUpperCase();

                        if (length == 0) {
                          _firstCodeController.text = '';
                        } else if (length == 1) {
                          _firstCodeController.text = NAME[0];
                        } else if (length > 1) {
                          _firstCodeController.text = '${NAME[0]}${NAME[1]}';
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(labelText: tr('name', widget.currentLanguage), border: OutlineInputBorder()),
                    ),
                  ),

                  // Phone input
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (phone) {
                        final length = phone.length;
                        if (length == 0) {
                          _secondCodeController.text = '';
                        } else if (length == 1) {
                          _secondCodeController.text = phone[length - 1];
                        } else if (length > 1) {
                          _secondCodeController.text = '${phone[phone.length - 2]}${phone[phone.length - 1]}';
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(labelText: tr('phone', widget.currentLanguage), border: OutlineInputBorder()),
                    ),
                  ),

                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _firstCodeController,
                          textAlign: TextAlign.center,
                          enabled: _nameController.text.isEmpty && _phoneController.text.isEmpty,
                          inputFormatters: [
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              return newValue.copyWith(text: newValue.text.toUpperCase(), selection: newValue.selection);
                            }),
                          ],
                          decoration: InputDecoration(labelText: tr('Name part', widget.currentLanguage), border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('-', style: TextStyle(fontSize: 24))),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _secondCodeController,
                          enabled: _nameController.text.isEmpty && _phoneController.text.isEmpty,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(labelText: tr('Phone part', widget.currentLanguage), border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Total: Dhs ${vm.totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed:
                        vm.isLoading
                            ? null
                            : () async {
                              print(1);
                              if (await vm.checkOnline()) {
                                print(2);
                                final name = _nameController.text.trim();
                                final phone = _phoneController.text.trim();
                                // final code = _codeController.text.trim();

                                if ((_firstCodeController.text.isNotEmpty && _secondCodeController.text.isEmpty) ||
                                    _firstCodeController.text.isEmpty && _secondCodeController.text.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text("Missing Code Part"),
                                          content: Text("Please enter both code parts to proceed"),
                                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
                                        ),
                                  );
                                  return;
                                }

                                final code = _firstCodeController.text.isEmpty||_secondCodeController.text.isEmpty?'':'${_firstCodeController.text}-${_secondCodeController.text}';

                                if ((name.isEmpty || phone.isEmpty) && (_firstCodeController.text.isEmpty||_secondCodeController.text.isEmpty)) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text("Missing Information"),
                                          content: Text("Please enter either customer code or information."),
                                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
                                        ),
                                  );
                                  return;
                                }

                                try {
                                  print(5);

                                  // final customer = await FirebaseService.checkCustomer(name: name, phoneNumber: phone, customer_code: code);
                                  final customer = await vm.checkCustomer(name: name, phoneNumber: phone, customer_code: code);
                                  if (customer != null) {
                                    print(6);

                                    if (customer.existing) {
                                      print(7);
                                      final confirmed = await showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text("Existing customer found"),
                                              content: Text('${customer.customerCode}\n${customer.name}\n${customer.phoneNumber}'),
                                              actions: [
                                                // ElevatedButton(
                                                //   onPressed: () async {
                                                //
                                                //     final success = await vm.confirmAndPrintOrder(
                                                //       name: name,
                                                //       phoneNumber: phone,
                                                //       customer_code: code,
                                                //       customer: customer,
                                                //     );
                                                //
                                                //     if (!context.mounted) return; // <-- 💡 the safe way to check context validity
                                                //
                                                //     if (success) {
                                                //       Navigator.pushReplacement(
                                                //         context,
                                                //         MaterialPageRoute(builder: (_) => POSView()),
                                                //       );
                                                //     } else {
                                                //       Navigator.pop(context);
                                                //
                                                //       showDialog(
                                                //         context: context,
                                                //         builder: (context) => AlertDialog(title: Text("Please select items first")),
                                                //       );
                                                //     }
                                                //   },
                                                //   child: Text('Proceed'),
                                                // ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true); // Close dialog & return true
                                                  },
                                                  child: Text('Proceed'),
                                                ),

                                              ],
                                            ),
                                      );


                                      // Do nothing if user canceled
                                      if (confirmed != true) return;
                                      final success = await vm.confirmAndPrintOrder(
                                        name: name,
                                        phoneNumber: phone,
                                        customer_code: code,
                                        customer: customer,
                                      );

                                      if (!context.mounted) return;

                                      Navigator.of(context).pop(); // <-- remove loader

                                      if (success) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => POSView()),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Please select items first"),
                                          ),
                                        );
                                      }

                                    } else {
                                      final success = await vm.confirmAndPrintOrder(
                                        name: name,
                                        phoneNumber: phone,
                                        customer_code: code,
                                        customer: customer,
                                      );
                                      if (success) {
                                        /// Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => POSView(openDialog: true)));
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => POSView()));
                                        showDialog(context: context, builder: (context) => AlertDialog(title: Text("New Customer Created"), content: Text("Customer Code : ${customer.customerCode}"),));
                                      } else {
                                        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Please select items first")));
                                      }
                                    }
                                  } else {
                                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Please enter necessary details.")));
                                  }
                                } catch (e) {
                                  if (e is CustomerError) showDialog(context: context, builder: (context) => AlertDialog(title: Text(e.message)));
                                }
                              } else {
                                scaffoldMessengerKey.currentState?.showMaterialBanner(
                                  MaterialBanner(
                                    content: Text(
                                      tr('no internet connection', widget.currentLanguage),
                                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.red,
                                    actions: [
                                      TextButton(
                                        onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner(),
                                        child: Text('DISMISS', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 60), padding: EdgeInsets.symmetric(vertical: 16)),
                    child:
                        vm.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Confirm Order", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
    );
  }

  Widget _buildServiceGroup(ServiceType service, List<ClothItem> items) {
    final label = serviceLabel(service, widget.currentLanguage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr(label, widget.currentLanguage), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (items.isEmpty) Text('No item selected to $label'),
        ...items.map(
          (item) => Card(
            child: ListTile(
              leading: Image.asset(item.img, width: 40),
              title: Text(tr(item.name, widget.currentLanguage)),
              subtitle: Text("${tr('quantity', widget.currentLanguage)}: ${item.quantity}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.totalPrice.toStringAsFixed(2)),
                  IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditQuantityDialog(context, context.read<POSViewModel>(), item)),
                  IconButton(icon: Icon(Icons.delete), onPressed: () => context.read<POSViewModel>().removeItem(item)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _showEditQuantityDialog(BuildContext context, POSViewModel vm, ClothItem item) {
    final controller = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit Quantity"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "Enter new quantity"),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  final newQty = int.tryParse(controller.text);
                  if (newQty != null && newQty > 0) {
                    vm.updateQuantity(item, newQty);
                    Navigator.pop(context);
                  }
                },
                child: Text("Update"),
              ),
            ],
          ),
    );
  }
}

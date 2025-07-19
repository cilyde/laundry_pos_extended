import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../view_models/complete_order_view_model.dart';

class CompleteOrderView extends StatelessWidget {
  const CompleteOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompleteOrderViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Complete Order')),
        body: const CompleteOrderBody(),
      ),
    );
  }
}

// class CompleteOrderBody extends StatefulWidget {
//   const CompleteOrderBody({super.key});
//
//   @override
//   State<CompleteOrderBody> createState() => _CompleteOrderBodyState();
// }
//
// class _CompleteOrderBodyState extends State<CompleteOrderBody> {
//   final _codeController = TextEditingController();
//   final _phoneController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<CompleteOrderViewModel>();
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           TextField(
//             controller: _codeController,
//             decoration: const InputDecoration(labelText: 'Customer Code'),
//             onSubmitted: (value) => vm.fetchOrders(customerCode: value),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _phoneController,
//             decoration: const InputDecoration(labelText: 'Phone Number (optional)'),
//             onSubmitted: (value) => vm.fetchOrders(phoneNumber: value),
//           ),
//           const SizedBox(height: 20),
//           if (vm.isLoading) const CircularProgressIndicator(),
//           if (vm.error != null) Text(vm.error!, style: const TextStyle(color: Colors.red)),
//
//           if (vm.orders.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: vm.orders.length,
//                 itemBuilder: (context, index) {
//                   final order = vm.orders[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text("Order #${order.orderId}"),
//                       subtitle: Text("Total: AED ${order.total.toStringAsFixed(2)}"),
//                       trailing: ElevatedButton(
//                         onPressed: () => vm.completeOrder(order),
//                         child: const Text("Mark Complete"),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             )
//         ],
//       ),
//     );
//   }
// }
class CompleteOrderBody extends StatefulWidget {
  const CompleteOrderBody({super.key});

  @override
  State<CompleteOrderBody> createState() => _CompleteOrderBodyState();
}

class _CompleteOrderBodyState extends State<CompleteOrderBody> {
  final _firstCodeController = TextEditingController();
  final _secondCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_handlePhoneInput);
  }

  void _handlePhoneInput() {
    final phone = _phoneController.text;
    if (phone.isEmpty) {
      _secondCodeController.text = '';
    } else if (phone.length == 1) {
      _secondCodeController.text = phone[0];
    } else if (phone.length > 1) {
      _secondCodeController.text = '${phone[phone.length - 2]}${phone[phone.length - 1]}';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _phoneController.removeListener(_handlePhoneInput);
    _phoneController.dispose();
    _firstCodeController.dispose();
    _secondCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompleteOrderViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Phone input
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _phoneController,
              onChanged: (phone)=>setState(() {}),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number (optional)', border: OutlineInputBorder()),
            ),
          ),

          const Divider(),
          // Customer code split input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstCodeController,
                  textAlign: TextAlign.center,
                  enabled: _phoneController.text.isEmpty,
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                  decoration: const InputDecoration(labelText: 'Code Prefix', border: OutlineInputBorder()),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('-', style: TextStyle(fontSize: 24)),
              ),
              Expanded(
                child: TextField(
                  controller: _secondCodeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  enabled: _phoneController.text.isEmpty,
                  decoration: const InputDecoration(labelText: 'Code Number', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: vm.isLoading
                ? null
                : () async {
              final codePart1 = _firstCodeController.text.trim();
              final codePart2 = _secondCodeController.text.trim();
              final phone = _phoneController.text.trim();

              String? customerCode;

              if (phone.isEmpty) {
                // Only using customer code
                if (codePart1.isEmpty || codePart2.isEmpty) {
                  _showDialog("Missing Code Parts", "Please enter both parts of the customer code.");
                  return;
                }
                customerCode = "$codePart1-$codePart2";
              }
              FocusScope.of(context).unfocus();
              await vm.fetchOrders(
                customerCode: customerCode,
                phoneNumber: phone.isNotEmpty ? phone : null,
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: vm.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Fetch Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 20),

          if (vm.error != null)
            Text(vm.error!, style: const TextStyle(color: Colors.red)),

          if (vm.orders.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.orders.length,
              itemBuilder: (context, index) {
                final order = vm.orders[index];
                return Card(
                  child: ListTile(
                    title: Text("Order #${order.orderId}"),
                    subtitle: Text("Total: Dhs ${order.total.toStringAsFixed(2)}"),
                    trailing: ElevatedButton(
                      onPressed: () => vm.completeOrder(order),
                      child: const Text("Complete"),
                    ),
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }
}


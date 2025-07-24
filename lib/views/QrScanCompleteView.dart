import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../main.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_service.dart';

class QrScanCompleteView extends StatefulWidget {
  const QrScanCompleteView({super.key});

  @override
  State<QrScanCompleteView> createState() => _QrScanCompleteViewState();
}

class _QrScanCompleteViewState extends State<QrScanCompleteView> {
  bool _isProcessing = false;
  String? _status;

  void _handleQRCode(String data) async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
        _status = "Processing...";
      });

      final decoded = jsonDecode(data);
      if (decoded['type'] != 'complete_order' || decoded['orderId'] == null) {
        throw Exception("Invalid QR code");
      }

      final orderId = decoded['orderId'];
      final dateKey = decoded['dateKey']; // Optional, fallback to today if null

      // Fetch the order details
      final order = await FirebaseService.getOrderById(orderId);
      if (order == null) {
        throw Exception("Order not found");
      }

      // Complete the order
      await FirebaseService.completeOrder(order);

      setState(() {
        _status = "✅ Order ${orderId} marked complete!";
      });
    } catch (e) {
      setState(() {
        _status = "❌ Failed: ${e.toString()}";
      });
    } finally {
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan to Complete Order")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) async {
                if (await checkOnline()) {
                  final barcode = capture.barcodes.firstOrNull;
                  final raw = barcode?.rawValue;

                  if (raw != null) {
                    _handleQRCode(raw);
                  }
                } else {
                  scaffoldMessengerKey.currentState?.showMaterialBanner(
                    MaterialBanner(
                      content: Text(
                        'No internet connection. Please try again later.',
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
            ),
          ),
          if (_status != null) Padding(padding: const EdgeInsets.all(16), child: Text(_status!, style: const TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}

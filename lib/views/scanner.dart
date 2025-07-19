// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// class QRScanScreen extends StatefulWidget {
//   const QRScanScreen({Key? key}) : super(key: key);
//
//   @override
//   State<QRScanScreen> createState() => _QRScanScreenState();
// }
//
// class _QRScanScreenState extends State<QRScanScreen> {
//   bool _isScanned = false;
//
//   void _onDetect(BarcodeCapture capture) {
//     if (_isScanned) return;
//
//     final code = capture.barcodes.first.rawValue;
//     if (code != null) {
//       setState(() {
//         print("SCANNED:");
//         print(code);
//         _isScanned = true;
//       });
//
//       Navigator.pop(context, code); // return the scanned value
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan QR Code')),
//       body: MobileScanner(
//         // allowDuplicates: false,
//         onDetect: _onDetect,
//       ),
//     );
//   }
// }

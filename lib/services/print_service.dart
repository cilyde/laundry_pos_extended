import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_barcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

/// A service class to encapsulate common printer operations using Sunmi printers.
class PrinterService {
  /// Initializes the printer. Returns true if successful.
  Future<bool> initPrinter() async {
    try {
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.initPrinter();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Prints plain text with optional style.
  Future<void> printText(String text, {bool bold = false, int fontSize = 24, SunmiPrintAlign align = SunmiPrintAlign.LEFT}) async {
    await SunmiPrinter.printText(text, style: SunmiTextStyle(bold: bold, fontSize: fontSize, align: align));
  }

  /// Prints a QR code.
  Future<void> printQRCode(String data, {int qrcodeSize = 3, SunmiQrcodeLevel errorLevel = SunmiQrcodeLevel.LEVEL_M}) async {
    await SunmiPrinter.printQRCode(data, style: SunmiQrcodeStyle(qrcodeSize: qrcodeSize, errorLevel: errorLevel));
  }

  /// Prints a barcode.
  Future<void> printBarCode(
    String data, {
    SunmiBarcodeType type = SunmiBarcodeType.CODE128,
    int height = 50,
    int width = 2,
    SunmiBarcodeTextPos textPosition = SunmiBarcodeTextPos.TEXT_UNDER,
    SunmiPrintAlign align = SunmiPrintAlign.CENTER,
  }) async {
    await SunmiPrinter.printBarCode(data, style: SunmiBarcodeStyle(type: type, height: height, size: width, align: align));
  }

  /// Prints an image from bytes.
  Future<void> printImage(Uint8List imageBytes, {SunmiPrintAlign align = SunmiPrintAlign.CENTER}) async {
    await SunmiPrinter.printImage(imageBytes, align: align);
  }

  /// Prints a divider line.
  Future<void> printDivider() async {
    await SunmiPrinter.printText('------------------------------');
  }

  /// Inserts blank lines.
  Future<void> lineWrap(int lines) async {
    await SunmiPrinter.lineWrap(lines);
  }

  /// Cuts the paper.
  Future<void> cutPaper() async {
    await SunmiPrinter.cutPaper();
  }
}

/// Extension for printing formatted order receipts.
extension ReceiptPrinting on PrinterService {
  Future<void> printOrderReceipt({
    required String shopName,
    required List<Map<String, dynamic>> items,
    required double total,
    String? phoneNumber,
    required String recieptId,
  }) async {
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    await printText(shopName, bold: true, fontSize: 28, align: SunmiPrintAlign.CENTER);
    await printText('Receipt No:$recieptId', bold: true, align: SunmiPrintAlign.CENTER);
    await printDivider();

    for (var item in items) {
      final line = '${item['name']} (${item['service']}) x ${item['quantity']}';
      await printText(line, fontSize: 24);
      await printText('Dhs ${item['price'].toStringAsFixed(2)}', align: SunmiPrintAlign.RIGHT);
    }

    await printDivider();
    await printText('TOTAL: Dhs ${total.toStringAsFixed(2)}', bold: true, fontSize: 26, align: SunmiPrintAlign.RIGHT);
    await printDivider();
    await printText('Date: $now', fontSize: 20);
    await printText('Thank you for your business!', align: SunmiPrintAlign.CENTER);
    await printDivider();
    await cutPaper();
  }

  Future<void> printOrderReceiptExtended({
    required List<Map<String, dynamic>> items,
    required double total,
    required String customerCode,
    required String orderID,
  }) async {
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    int lineWrapMultiplyer = 5;
    await printDivider();
    lineWrap(5 * lineWrapMultiplyer);
    await printText("Fresh & Clean Laundry", bold: true, fontSize: 32, align: SunmiPrintAlign.CENTER);
    lineWrap(5 * lineWrapMultiplyer);
    await printText(customerCode, bold: true, fontSize: 40, align: SunmiPrintAlign.CENTER);
    lineWrap(2 * lineWrapMultiplyer);

    await printText('Order ID:$orderID', bold: true, align: SunmiPrintAlign.CENTER);
    lineWrap(5 * lineWrapMultiplyer);

    for (var item in items) {
      final line = '${item['name']} (${item['service']}) x ${item['quantity']}';
      await printText(line, fontSize: 24);
      await printText('Dhs ${item['price'].toStringAsFixed(2)}', align: SunmiPrintAlign.RIGHT);
    }
    lineWrap(2 * lineWrapMultiplyer);
    await printText('TOTAL: Dhs ${total.toStringAsFixed(2)}', bold: true, fontSize: 26, align: SunmiPrintAlign.RIGHT);
    lineWrap(3 * lineWrapMultiplyer);

    await printText('Date: $now', fontSize: 20, bold: true);
    lineWrap(5 * lineWrapMultiplyer);
    await printDivider();

    await printQRCode(
      jsonEncode({'type': 'complete_order', 'orderId': orderID, 'dateKey': DateFormat('yyyy-MM-dd').format(DateTime.now())}),
      qrcodeSize: 6,
    );
    lineWrap(5 * lineWrapMultiplyer);
    await printDivider();

    await printText(customerCode, bold: true, fontSize: 40, align: SunmiPrintAlign.CENTER);
    lineWrap(5 * lineWrapMultiplyer);
    await printText('$orderID', bold: true, align: SunmiPrintAlign.CENTER, fontSize: 36);

    lineWrap(5 * lineWrapMultiplyer);

    await printText('$now | ${total.toStringAsFixed(2)}', fontSize: 26, align: SunmiPrintAlign.CENTER);
    lineWrap(5 * lineWrapMultiplyer);

    lineWrap(4 * lineWrapMultiplyer);
    await cutPaper();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'Config.dart';
import 'services/print_service.dart';
import 'view_models/pos_view_model.dart';
import 'views/pos_view.dart';
import 'web/services/web_firebase_service.dart';
import 'web/view_models/dashboard_view_model.dart';
import 'web/views/dashboard_view.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Sunmi printer only on supported platforms
  if (!kIsWeb && isSunmi) {
    await SunmiPrinter.initPrinter();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PrinterService>(create: (_) => PrinterService()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel(WebFirebaseService())),
        ChangeNotifierProvider(create: (context) {
          final printerService = context.read<PrinterService>();
          return POSViewModel(printerService);
        }),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Laundry',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal),
        home: kIsWeb ? const DashboardView() : const POSView(),
      ),
    );
  }
}

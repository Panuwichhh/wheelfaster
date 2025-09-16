import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wheelfaster/controllers/map_controller.dart';
import 'package:wheelfaster/notifier/notifier.dart';
import 'package:wheelfaster/pages/app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:wheelfaster/services/place_amenity_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final ctrl = MyMapController(PlaceAmenityService());
        ctrl.start(); // เริ่มดึงข้อมูล Firestore
        return ctrl;
      },
      child: const Myapp(),
    ),
  );
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = GoogleFonts.kanitTextTheme();

    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: "My title",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF01CE55),
              brightness: isDarkMode? Brightness.dark : Brightness.light)
          ),
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Home()),
          // routes: {'/mappage': (context) => (MapPage())},
        );
      }
    );
  }
}


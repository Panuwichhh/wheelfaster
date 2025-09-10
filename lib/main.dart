import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wheelfaster/controllers/map_controller.dart';
import 'package:wheelfaster/pages/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wheelfaster/services/place_amenity_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

    return MaterialApp(
      title: "My title",
      theme: ThemeData(textTheme: textTheme),
      home: Scaffold(body: Home()),
      // routes: {'/mappage': (context) => (MapPage())},
    );
  }
}

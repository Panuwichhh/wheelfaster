import 'package:flutter/material.dart';
import 'package:wheelfaster/pages/home.dart';
import 'package:wheelfaster/pages/mappage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const Myapp());
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

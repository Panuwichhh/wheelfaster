import 'package:flutter/material.dart';
import 'package:wheelfaster/pages/home.dart';
import 'package:wheelfaster/pages/mappage.dart';

void main() {
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My title",
      home: Scaffold(body: Home()),
      routes: {'/mappage': (context) => MapPage()},
    );
  }
}

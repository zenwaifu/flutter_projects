import 'package:flutter/material.dart';
import 'package:money_sprint/splashpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // Material App with Theme and Splashpage as Home
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(224, 64, 251, 1)),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromRGBO(224, 64, 251, 1),
          foregroundColor: Colors.white,
        ),
      ),
      home: Splashpage(),
    );
  }
}
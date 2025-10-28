import 'package:flutter/material.dart';
import 'package:sip_smart/splashpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(76, 163, 216, 1)),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromRGBO(76, 163, 216, 1),
          foregroundColor: Colors.white,
        ),
      ),
      home: Splashpage(),
    );
  }
}
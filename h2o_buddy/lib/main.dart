//main.dart
import 'package:flutter/material.dart';
import 'package:h2o_buddy/splashpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //remove const from MaterialApp coz using non-const widgets inside
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      // Set the Splashpage as the home screen - initial route
      home: SplashPage(),
    );
  }
}

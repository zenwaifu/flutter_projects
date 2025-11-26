
import 'package:flutter/material.dart';
import 'package:pawpal/views/splashpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(215, 54, 138, 1)),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromRGBO(245, 234, 219, 1),
          foregroundColor: const Color.fromRGBO(215, 54, 138, 1),
        ),
      ),
      home: SplashPage(),
    );
  }
}

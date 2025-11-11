import 'package:flutter/material.dart';
import 'package:myfirstapp/splashscreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //why remove const from material app is because it gives error
    return MaterialApp(
      title: 'First App - CALCULATOR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          filled: true,
        ),
      ),
      home: Splashscreen(),
    );
  }
}

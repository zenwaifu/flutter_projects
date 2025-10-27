import 'package:flutter/material.dart';
import 'package:myfuwu/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main App'),
      ),
      body: const Center(
        child: Text('Welcome to the Main Page!'),
      ),
    );
  }
}

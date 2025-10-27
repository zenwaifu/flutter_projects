import 'package:bmr_app/bmrscreen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}
 class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // Simulate some initialization work
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to the main app screen after the delay
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BMRCalcScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/bmr_app', // Ensure this image is added to your assets
              //scale: 2.0,
              width: 200,
              height: 200,
            ),
            Text(
              'BMR Calculator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[400],
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

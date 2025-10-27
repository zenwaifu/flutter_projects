import 'package:flutter/material.dart';
//import 'package:myfuwu/main.dart';
import 'package:myfuwu/mainpage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override

  void initState() {
    super.initState();
    // Simulate a delay for the splash screen (e.g., loading resources)
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to the main page after the delay
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
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
              'assets/images/myfuwu2.png', // Ensure this path matches your asset path
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
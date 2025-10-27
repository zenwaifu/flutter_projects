import 'package:body_fat_calculcator/bfccalcscreen.dart';
import 'package:flutter/material.dart';
//install windsurf plugin
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
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BFCCalcScreen()),
      );
  });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/bmr.png', 
              //scale: 0.5,
              width: 150, 
              height: 150,
            ),
            Text(
              'BFC App',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Color.fromARGB(255, 139, 101, 204),
                ),  
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
            SizedBox(height: 20),
          ],)
    ));
  }
}
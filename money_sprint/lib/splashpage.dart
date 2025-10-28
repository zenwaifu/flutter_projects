import 'package:flutter/material.dart';
import 'package:money_sprint/homepage.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), (){
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder:  (context) => const Homepage()),  
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(224, 64, 251, 1),
      body: Center (
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/money_sprint_logo.png',
              scale: 4,
            ),
            SizedBox(height: 10),
            Text(
              'Lets Start Saving!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white,),
            SizedBox(height: 10),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white
              ),
            ),
          ],
        ),
      )
    );
  }
}
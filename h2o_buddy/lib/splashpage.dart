import 'package:flutter/material.dart';
import 'package:h2o_buddy/mainpage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  /// Called when this object is inserted into the tree.
  /// The framework will call this method exactly once for each state object created.
  /// Override this method to perform initialization that depends on the location of this object in the tree.
  /// You can add initialization code here if needed. For example, you can navigate to the next screen after a delay.
  void initState() {
    super.initState();
    // You can add initialization code here if needed
    // For example, you can navigate to the next screen after a delay
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the next screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder:  (context) => const MainPage()),
        );
    });
  }
  
  @override
  /// Builds the splash screen widget.
  ///
  /// The splash screen widget contains a centered column with a
  /// circular progress indicator and a text widget with the application name.
  /// Returns a [Scaffold] widget with the centered column as its body.
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Splash Screen Content
            Image.asset('assets/images/smth.jpeg',
              //scale:3,
              //height: 150,
              //width: 150,
            ),
            //CircularProgressIndicator(),
            LinearProgressIndicator(
              color: Colors.blueAccent,
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to H2O Buddy',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,),
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
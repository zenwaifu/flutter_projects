import 'package:flutter/material.dart';
import 'package:mydiary/loadinganime.dart';
import 'package:mydiary/mainscreen.dart';

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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color.fromRGBO(252, 128, 159, 1),
          
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(255, 188, 205, 1),
          foregroundColor: Colors.black,
          elevation: 5,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(255, 188, 205, 1),
            foregroundColor: Colors.black,
            elevation: 5,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(255, 188, 205, 1),
          foregroundColor: Colors.black,
          elevation: 5,
        ),

      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  late double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceInOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      screenWidth = 600;
    } else {
      screenWidth = screenWidth;
    }  

    return Scaffold(
      body: Container(
      height: double.infinity,
      width: double.infinity,
      
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 228, 233, 1),
            Color.fromRGBO(255, 188, 205, 1),
            Color.fromRGBO(252, 128, 159, 1)
          ],
        ),
      ),

      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/MyDiary2.png', scale: 1.5),
              SizedBox(height:10),
              LoadingAnime(),
              SizedBox(height:20),
              Text(
                "Start Journaling Your Journey",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'DancingScript',
                  fontStyle: FontStyle.italic,
                ),
              )
            ],
          ),
        ),
      ),
      )
    );
  }
}

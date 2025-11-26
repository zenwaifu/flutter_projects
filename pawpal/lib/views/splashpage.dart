import 'package:flutter/material.dart';
import 'package:pawpal/shared/pawloading.dart';
import 'package:pawpal/views/mainpage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    Future.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(user: null,),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 234, 219, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/pawpal_logo_v2.png', scale: 1.5),
            //SizedBox(height:20),
            //CircularProgressIndicator(),
            SizedBox(height:15),
            PawLoading(),
            SizedBox(height:15),
            Text('Connecting paws with people' , 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color.fromRGBO(215, 54, 138, 1),
              ),
            ),
            //SizedBox(height:10),
            /*Text('Loading...' , 
              style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontSize: 20,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.5
                  ..strokeJoin = StrokeJoin.round
                  ..color = Color.fromRGBO(215, 54, 138, 1)
              ),),*/
          ],
        ),
      ),
    );
  }
}
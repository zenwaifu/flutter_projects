import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/views/loginpage.dart';

class MainPage extends StatefulWidget {
  final User? user;
  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user != null
              ? "Welcome, ${widget.user!.user_name}"
              : "PAWPAL",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (){
              Text('Features coming soon!');
            },
          ),
          IconButton(
            icon: Icon(Icons.login),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          )
        ]
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Welcome Message box
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: mainPink,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: bgCream
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/puppy1.png', scale: 4),
                        SizedBox(width: 10,),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 20,
                              color: mainPink,
                            ),
                            children: [
                              if (widget.user != null)
                              TextSpan(text: "Hi, ${widget.user!.user_name}!\n", style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: 'Find your'),
                              TextSpan(text: '\nfurry best friend', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '\ntoday!'),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        Image.asset('assets/images/paw.png', width: 50, height: 50,),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  // Login Button Box
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: mainPink,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: bgCream,
                    ),
                    child: GestureDetector(
                      onTap:() => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => LoginPage())
                      ), 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon( Icons.login,size: 40, color: mainPink,),
                          SizedBox(height: 10,),
                          Text(
                            'Login',
                            style: TextStyle(fontSize: 20, color: mainPink,),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      drawer: MyDrawer(user: widget.user,),
    );

  }
}
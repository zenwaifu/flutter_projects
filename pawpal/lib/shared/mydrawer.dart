import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/shared/animated_route.dart';
import 'package:pawpal/views/loginpage.dart';
import 'package:pawpal/views/mainpage.dart';

class MyDrawer extends StatefulWidget {
  final User? user;
  const MyDrawer({super.key, this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(radius: 15, child: Text('A')),
            accountName: Text(widget.user?.user_name ?? 'Guest'),
            accountEmail: Text(widget.user?.user_email ?? 'Guest'),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(MainPage(user: widget.user)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Pet adoption'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
           const Divider(
            color: Colors.grey,
          ),
          SizedBox(
            //height: screenHeight /4,
            //width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [Text("© 2025 PawPal",style: TextStyle(color: Colors.grey, fontSize: 18),)],
            ),
          )
        ],
      ),
    );

  }
}
import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/animated_route.dart';
import 'package:pawpal/views/loginpage.dart';
import 'package:pawpal/views/mainpage.dart';
import 'package:pawpal/views/myadoptionspage.dart';
import 'package:pawpal/views/mydonationspage.dart';
import 'package:pawpal/views/userprofilepage.dart';

class MyDrawer extends StatefulWidget {
  final User? user;
  const MyDrawer({super.key, this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  
  late double screenHeight;

  //User? currentUser;

  // @override
  // void initState() {
  //   super.initState();
  //   // CRITICAL FIX: Assign the user passed from the parent widget to the state variable
  //   currentUser = widget.user;
  // }

  String getProfileImageUrl() {
    if (widget.user?.profile_image != null &&
        widget.user!.profile_image!.isNotEmpty) {
      return "${MyConfig.baseUrl}/pawpal/assets/profiles/${widget.user!.profile_image}";
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    
    return Drawer(
      child: ListView(
        children: [
          // UserAccountsDrawerHeader(
          //   decoration: BoxDecoration(
          //     color: mainPink,
          //   ),
          //   currentAccountPicture: CircleAvatar(
          //     backgroundColor: Colors.white,
          //     backgroundImage: (currentUser?.profile_image != null &&
          //       currentUser!.profile_image!.isNotEmpty)
          //       ? NetworkImage(getProfileImageUrl())
          //       : null,
          //     child: currentUser?.profile_image != null &&
          //           currentUser!.profile_image!.isNotEmpty
          //       ? ClipOval(
          //           child: Image.network(
          //             getProfileImageUrl(),
          //             fit: BoxFit.cover,
          //             width: 80,
          //             height: 80,
          //             errorBuilder: (_, __, ___) => Icon(
          //               Icons.person,
          //               size: 40,
          //               color: mainPink,
          //             ),
          //           ),
          //         )
          //       : Icon(
          //           Icons.person,
          //           size: 40,
          //           color: mainPink,
          //         ),
          //   ),
          //   accountName: Text(
          //     currentUser?.user_name ?? 'Guest',
          //     style: const TextStyle(fontWeight: FontWeight.bold),
          //   ),
          //   accountEmail: Text(currentUser?.user_email ?? 'Please login'),
          // ),
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: mainPink),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (widget.user?.profile_image != null &&
                      widget.user!.profile_image!.isNotEmpty)
                  ? NetworkImage(getProfileImageUrl())
                  : null,
              child: (widget.user?.profile_image == null ||
                      widget.user!.profile_image!.isEmpty)
                  ? Icon(Icons.person, size: 40, color: mainPink)
                  : null,
            ),
            accountName: Text(
              widget.user?.user_name ?? 'Guest',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(widget.user?.user_email ?? 'Please login'),
          ),

          // Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(MainPage(user: widget.user)),
              );
            },
          ),

          const Divider(),

          // My Adoptions
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('My Adoption Requests'),
            enabled: widget.user != null,
            onTap: widget.user != null
                ? () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    AnimatedRoute.slideFromRight(MyAdoptionsPage(user: widget.user)),
                  );
                }
                : null,
          ),

          // My Donations
          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text('My Donations'),
            enabled: widget.user != null,
            onTap: widget.user != null
                ? () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      AnimatedRoute.slideFromRight(MyDonationsPage(user: widget.user)),
                    );
                  }
                : null,
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            enabled: widget.user != null,
            onTap: widget.user != null
                ? () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      AnimatedRoute.slideFromRight(ProfilePage(user: widget.user)),
                    );
                  }
                : null,
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: Text(
              widget.user != null ? 'Logout' : 'Login',
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),

          const Divider(color: Colors.grey),

          // Footer
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                SizedBox(height: 20),
                Text(
                  "© 2025 PawPal",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Connecting Paws with People",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


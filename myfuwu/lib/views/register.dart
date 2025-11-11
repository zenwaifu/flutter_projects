import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myfuwu/myconfig.dart';
import 'package:myfuwu/views/loginpage.dart';


//_ underscore means private --> uses only within this file (library-level privacy)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late double height, width;
  bool visible = true;
  bool isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height; // Get the height of the screen .toDouble()
    width = MediaQuery.of(context).size.width; // Get the width of the screen .toDouble()

    print(width); 

    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8), // Left, Top, Right, Bottom 20,4,20,4
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0), // Adjust the padding as needed -> 8.0
                    child: Image.asset('assets/images/myfuwu.png', scale: 4.5,) // Adjust the scale as needed -> 4
                    ),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),)
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (visible) {
                            visible = false;
                          } else {
                            visible = true;
                          } 
                          setState(() {});
                        },
                        icon: Icon(
                          //visible ? Icons.visibility_off : Icons.visibility,
                          Icons.visibility
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),)
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (visible) {
                            visible = false;
                          } else {
                            visible = true;
                          } 
                          setState(() {});
                        },
                        icon: Icon(Icons.visibility),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Remember me'),
                      Checkbox(value: false, onChanged: (value) {}),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle registration logic here
                        print('Register button pressed');
                        registerDialog();
                      },
                      child: Text('Register'),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(), // Replace with your target page
                        ),
                      );
                    },
                    child: Text('Already have an account? Login here'),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
/// Register a user with the given email and password.
///
/// This function validates the input fields and displays a SnackBar if any of the fields are empty.
/// It also validates the email address and displays a SnackBar if the email address is invalid.
/// If all fields are valid, it displays a dialog asking the user if they want to register the account.
/// If the user confirms, it calls the registeredUser function to register the user.
///
/// [email] is the email address of the user.
/// [password] is the password of the user.
  void registerDialog() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Check for empty fields
    // data sanitization
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (password != confirmPassword) {
      SnackBar snackBar =  const SnackBar(
        content: Text('Passwords do not match'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // RegExp - Regular expressions 
    // check for email validation if got @ and .com
    // regexp function is to sequence of characters that specify a match-checking algorithm for text inputs.
    // either matching, or accepting, the text, or the text being rejected
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please enter a valid email address'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    showDialog(
      context: context,
      //confirmation dialog use AlertDialog widget
      builder: (context) => AlertDialog(
        title: Text('Register this account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('Before registering user with email: $email');
              registerUser(email,password);
            },
            child: Text('Register'),
          ),
          TextButton(
            onPressed: () =>Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
        content: Text('Are you sure you want to register this account?'),
      ),
    );
  }
  
  /// Register a user with an email and password.
  ///
  /// This function sends a POST request to the API with the
  /// provided email and password. If the response is successful,
  /// it will close the loading dialog and navigate to the
  /// login page. If the response is not successful, it will
  /// show a SnackBar with the response message. If the request
  /// times out, it will show a SnackBar with a timeout message.
  ///
  /// If the widget is not mounted when the request completes, it
  /// will not update the state or show a SnackBar.
  void registerUser(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Registering...'),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );

    await http
        .post(
          Uri.parse('${MyConfig.baseUrl}/myfuwu/api/register.php'),
          body: {'email': email, 
          'password': password},
        )
        .then((response) {
            if (response.statusCode == 200) {
              var jsonResponse = response.body;
              var resarray = jsonDecode(jsonResponse);
              print(jsonResponse);
              if (resarray['status'] == 'success') {
                if (!mounted) return;
                SnackBar snackBar = SnackBar(
                  content: Text('Registration successful'),
                );
                if (isLoading) {
                  if (!mounted) return;
                  Navigator.pop(context); // Close the loading dialog
                  setState(() {
                    isLoading = false;
                  });
                }
                Navigator.pop(context); //Close the register dialog
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage()), // Replace with your target page  
                );
              } else {
                if (!mounted) return;
                SnackBar snackBar = SnackBar(content: Text(resarray['message']),);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            } else {
              if (!mounted) return;
              SnackBar snackBar = const SnackBar(
                content: Text('Resgistration failed. Please try again.'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          })
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              if (!mounted) return;
              SnackBar snackBar = const SnackBar(
                content: Text('Request timed out. Please try again.'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          );
    if (isLoading) {
      if (!mounted) return;
      Navigator.pop(context); // Close the loading dialog
      setState(() {
        isLoading = false;
      });
    }
  }
}
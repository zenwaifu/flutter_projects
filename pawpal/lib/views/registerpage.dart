import 'dart:convert';
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/pawloading.dart';
import 'package:pawpal/views/loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  late double height, width;
  bool visible = true;
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    print(width);
    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Register Page'),),
      body: Container(
        decoration: BoxDecoration(
          color: bgCream
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/images/pawpal_logo_v2.png', scale: 4.5,),
                    ),
                    SizedBox(height: 5,),
                    Form(
                      child: Column(
                        children: [
                          SizedBox(height: 15,),
                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: mainPink),
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainPink),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: mainPink),
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainPink),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: mainPink),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  if (isPasswordVisible) {
                                    isPasswordVisible = false;
                                  } else {
                                    isPasswordVisible = true;
                                  }
                                  setState(() {});
                                },
                                icon: Icon(Icons.visibility),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainPink),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextFormField(
                            controller: confirmPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: mainPink),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  if (isConfirmPasswordVisible) {
                                    isConfirmPasswordVisible = false;
                                  } else {
                                    isConfirmPasswordVisible = true;
                                  }
                                  setState(() {});
                                },
                                icon: Icon(Icons.visibility),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainPink),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: mainPink),
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainPink),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Register'),
                        onPressed: (){
                          print("Register button pressed");
                          registerDialog();
                        }
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: RichText(
                            text: const TextSpan(
                              style: TextStyle(color: const Color.fromRGBO(215, 54, 138, 1),),
                              text: "Already have an account?  ",
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Login Here!',
                                  style: TextStyle(
                                    color: const Color.fromRGBO(215, 54, 138, 1),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color.fromRGBO(215, 54, 138, 1),
                                    decorationStyle: TextDecorationStyle.solid,
                                    decorationThickness: 2
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                    SizedBox(height: 5),
                  ],
                )
              )
            ),
          )
        ),
      )
    
    );
  }
  
  void registerDialog() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (password != confirmPassword) {
      SnackBar snackBar = const SnackBar(
        content: Text('Passwords do not match'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please enter a valid email address'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be at least 10 characters')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register this account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('Before registering user with email: $email');
              registerUser(name, email, password, phone);
            },
            child: Text('Register'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
        content: Text('Are you sure you want to register this account?'),
      ),
    );
  }
  
  void registerUser(String name, String email, String password, String phone) async{
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
                      children: [
                        Expanded( // Wrap your text here
                          child: Text("Registering..."),
                        ),
                        const SizedBox(width: 20),
                        PawLoading(), // The dots or spinner
                      ],
                    )
        );
      },
      barrierDismissible: false,
    );
    await http
      .post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/register.php'),
        body: {
          'name': name, 
          'email': email,
          'password': password,
          'phone': phone,
        },
      )
      .then((response) {
        // log(response.body);
        // log(response.statusCode.toString());
        if (response.statusCode == 200) {
          var jsonResponse = response.body;
          var resarray = jsonDecode(jsonResponse);
          log(jsonResponse);
          if (resarray['status'] == 'success') {
            if (!mounted) return;
            SnackBar snackBar = const SnackBar(
              content: Text('Registration successful'),
            );
            if (isLoading) {
              if (!mounted) return;
              Navigator.pop(context); // Close the loading dialog
              setState(() {
                isLoading = false;
              });
            }
            Navigator.pop(context); // Close the registration dialog
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            if (!mounted) return;
            SnackBar snackBar = SnackBar(content: Text(resarray['message']));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          if (!mounted) return;
          SnackBar snackBar = const SnackBar(
            content: Text('Registration failed. Please try again.'),
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
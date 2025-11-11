import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late double height, width;
  bool visible = true;
  bool isChecked = false;

  //late User user; 

  @override
 void initState() {
    super.initState();
    //loadPreference();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
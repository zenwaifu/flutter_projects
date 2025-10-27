import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double height, width;
  bool visible = false;
  
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height.toDouble();
    width = MediaQuery.of(context).size.width.toDouble();

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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: SizedBox(
              width: width/2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/myfuwu2.png', scale: 4,) 
                    ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),)
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          visible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          visible = !visible;
                          setState(() {});
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),)
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),)
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
                      },
                      child: Text('Register'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Already have an account?'),
                  Text('Forgot Password?'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
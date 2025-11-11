import 'package:flutter/material.dart';
import 'package:mylist/newitemscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My List Images'),
      ),
      body: Center(
        child: Text('Main Screen Content Here', style: TextStyle(fontSize: 24),),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewItemScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
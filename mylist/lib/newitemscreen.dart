import 'dart:io';

import 'package:flutter/material.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {

  late double screenHeight;
  late double screenWidth;
  File? image;
  
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if(screenWidth > 600) {
      screenWidth = 600;
    } else {
      screenWidth = screenWidth;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: screenWidth,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      selectCameraGalleryDialog();
                    },
                    child: Container(
                      height: screenHeight /3,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          alignment: Alignment.center,
                          scale: 0.5,
                          image: image == null
                                ? AssetImage('assets/images/camera.png')
                                : FileImage(image!),
                          fit: BoxFit.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Item Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(screenWidth, 50),
                    ),
                    child: Text('Save'),
                  ),  
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void selectCameraGalleryDialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: const Text('Choose from Camera or Gallery'),
          actions: [
            TextButton(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: const Text('Gallery'))
          ]
        );
      },
    );
  }
}
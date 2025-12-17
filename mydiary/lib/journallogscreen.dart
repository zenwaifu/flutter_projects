import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/diarylist.dart';
import 'package:path_provider/path_provider.dart';

class JournalLogScreen extends StatefulWidget {
  const JournalLogScreen({super.key});

  @override
  State<JournalLogScreen> createState() => _JournalLogScreenState();
}

class _JournalLogScreenState extends State<JournalLogScreen> {
  //main pink palette
  final darkpink = Color.fromRGBO(252, 128, 159, 1);
  final midpink = Color.fromRGBO(255, 188, 205, 1);
  final lightpink = Color.fromRGBO(255, 228, 233, 1);

  late double screenHeight, screenWidth;

  File? image;
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm a');

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      screenWidth = 600;
    } else {
      screenWidth = screenWidth;
    }

    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       darkpink,
        //       midpink,
        //       lightpink
        //     ],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter
        //   )
        // ),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              darkpink,
              midpink,
              lightpink
            ],
            center: Alignment.topCenter,
            radius: 1.0,
          )
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "New Journal Log",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontFamily: 'DancingScript',
                        //textAlign: TextAlign.center
                      ),
                    ),
                  ),
                ],
              ),
              
              Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: lightpink,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 0.4,
                    children: [
                      GestureDetector(
                        onTap: selectCameraGalleryDialog,
                        child: Container(
                          // height: screenHeight * 0.25,
                          height: screenWidth * 0.8,
                          // width: double.infinity,
                          width: screenWidth * 0.8,
                          decoration: BoxDecoration(
                            color: darkpink,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: darkpink, width: 2),
                          ),
                          child: image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 70,
                                      color: lightpink,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Tap to add image",
                                      style: TextStyle(
                                        color: lightpink,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.file(
                                    image!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextField(
                        cursorColor: darkpink,    
                        style: TextStyle(color: darkpink, fontSize: 18),
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Journal Title",
                          labelStyle: TextStyle(color: darkpink, fontSize: 18),
                          prefixIcon: Icon(Icons.title, color: darkpink ,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: midpink, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        cursorColor: darkpink,    
                        style: TextStyle(color: darkpink, fontSize: 18),
                        controller: notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Diary Notes",
                          labelStyle: TextStyle(color: darkpink, fontSize: 18),
                          prefixIcon: Icon(Icons.description_outlined, color: darkpink),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: midpink, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: darkpink,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Date: ${formatter.format(DateTime.now())}",
                            style: TextStyle(
                              fontSize: 16,
                              color: darkpink,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: showConfirmDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkpink,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Save Journal Log",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        )
      ),
    );
  }

  void selectCameraGalleryDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Image Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: darkpink ),
              ),
              const SizedBox(height: 20),
              // Camera & gallery opt
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // camera
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      openCamera();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkpink.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: darkpink,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Camera"),
                      ],
                    ),
                  ),
                  // gallery
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      openGallery();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkpink.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.photo_library_rounded,
                            color: darkpink,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Gallery"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 16, color: midpink),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 900,
    );

    if (pickedFile != null) {
      image = File(pickedFile.path);
      cropImage();
    }
  }
  
  Future<void> openGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      image = File(pickedFile.path);
      cropImage();
    }
  }
  
  Future<void> cropImage() async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: "Crop Image"),
      ],
    );

    if (cropped != null) {
      image = File(cropped.path);
      setState(() {});
    }
  }

  void showConfirmDialog() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter title for your journal.", textAlign: TextAlign.center,), duration: Duration(seconds: 2), backgroundColor: Colors.redAccent,));
      return;
    }

    if (notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter content for your journal.", textAlign: TextAlign.center,), duration: Duration(seconds: 2), backgroundColor: Colors.redAccent,));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkpink.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.save_rounded,
                    size: 40,
                    color: darkpink,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  "Confirm Save",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkpink),
                ),
                const SizedBox(height: 10),
                Text(
                  "Do you want to save this journal to your list?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: midpink),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: darkpink),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            color: midpink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Save button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkpink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          saveItem();
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> saveItem() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String storedImagePath = "NA";

    if (image != null) {
      String imageName = "${DateTime.now().millisecondsSinceEpoch}.png";
      storedImagePath = "${appDir.path}/$imageName";
      await image!.copy(storedImagePath);
    }

    await DatabaseHelper().insertDiaryList(
      DiaryList(
        0,
        titleController.text,
        notesController.text,
        formatter.format(DateTime.now()),
        storedImagePath,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Journal saved successfully", textAlign: TextAlign.center,), duration: Duration(seconds: 2), backgroundColor: Colors.greenAccent,));
      Navigator.pop(context);
    }
  }
}
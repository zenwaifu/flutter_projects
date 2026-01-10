// lib/views/submit_pet_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;
  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final midPink = const Color.fromRGBO(245, 154, 185, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);
  User? get currentUser => widget.user;

  // Dropdown lists
  List<String> listOfPets = [
    'Dog',
    'Cat',
    'Rabbit',
    'Other'
  ];

  List<String> listOfCategories = [
    'Adoption',
    'Donation Request',
    'Help/Rescue'
  ];

  // Controllers
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController petAgeController = TextEditingController();
  final TextEditingController petDescriptionController = TextEditingController();
  final TextEditingController petLocationController = TextEditingController();

  // images
  List<File> images = []; // mobile
  List<Uint8List> webImages = []; // web

  //default values
  String? selectedPet;
  String? selectedCategory;

  late Position currentPosition;

  double? latitude;
  double? longitude;

  bool submitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    petNameController.dispose();
    petDescriptionController.dispose();
    petLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final maxWidth = screenWidth > 600 ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        centerTitle: true, 
        title: const Text('Submit Pet Profile', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Colors.transparent,
        foregroundColor: mainPink,
        elevation: 0,
        ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildImagePreviewArea(),
                  const SizedBox(height: 12),
              
                  // Buttons: Pick / Camera
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: ElevatedButton.icon(
                  //         onPressed: pickImagesMulti,
                  //         icon: const Icon(Icons.photo_library),
                  //         label: const Text('Pick Images'),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Expanded(
                  //       child: ElevatedButton.icon(
                  //         onPressed: openCamera,
                  //         icon: const Icon(Icons.camera_alt),
                  //         label: const Text('Open Camera'),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 12),
              
                  //FORM CARD
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _inputField(
                            controller: petNameController,
                            label: 'Pet Name',
                            icon: Icons.title,
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Pet name required' : null,
                          ), 
              
                          const SizedBox(height: 12),
              
                          DropdownButtonFormField<String>(
                            value: selectedPet,
                            hint: const Text('Select Pet Type'),
                            decoration: _dropdownDecoration(
                              "Pet Type",
                              Icons.pets
                            ),
                            items: listOfPets.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            onChanged: (v) => setState(() => selectedPet = v),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Pet type required' : null,
                          ),
                          const SizedBox(height: 12),
              
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            hint: const Text('Select Category'),
                            decoration: _dropdownDecoration(
                              "Category",
                              Icons.category
                            ),
                            items: listOfCategories.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            onChanged: (v) => setState(() => selectedCategory = v),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Category required' : null,
                          ),

                          const SizedBox(height: 12),
              
                          _inputField(
                            controller: petAgeController,
                            label: 'Pet Age',
                            icon: Icons.numbers,
                            keyboard: TextInputType.number,
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Pet age required' : null,
                          ), 
              
                          const SizedBox(height: 12),
              
                          TextFormField(
                            controller: petDescriptionController,
                            maxLines: 4,
                            minLines: 2,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.description),
                              labelText: 'Description', 
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12))
                              )),
                            validator: (val) => (val == null || val.trim().length < 10) ? 'Enter at least 10 characters' : null,
                          ),
              
                          const SizedBox(height: 12),
              
                          TextFormField(
                            controller: petLocationController,
                            readOnly: true,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Location (auto)',
                              prefixIcon: const Icon(Icons.map),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.location_on, color: mainPink),
                                onPressed: _determineAndSetLocation,
                              ),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? 'Location is required' : null,
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainPink,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: submitting ? null : showSubmitDialog,
                              child: submitting 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Submit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

/* =============================
          UI HELPERS
================================*/

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  //   Future<void> pickImagesMulti() async {
  //   // Use pickMultiImage which works on mobile & web (returns List<XFile>)
  //   try {
  //     final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 85); // compress lightly
  //     if (picked == null) return;
  //     if (picked.isEmpty) return;

  //     // Cap at 3
  //     final take = picked.length > 3 ? picked.sublist(0, 3) : picked;

  //     images.clear();
  //     webImages.clear();

  //     if (kIsWeb) {
  //       for (var x in take) {
  //         final data = await x.readAsBytes();
  //         webImages.add(data);
  //       }
  //     } else {
  //       for (var x in take) {
  //         images.add(File(x.path));
  //       }
  //     }
  //     setState(() {});
  //   } catch (e) {
  //     // fallback: single image pick
  //     debugPrint("pickImagesMulti error: $e");
  //   }
  // }

  // Future<void> pickSingleImageFromGallery() async {
  //   final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  //   if (picked == null) return;
  //   if (kIsWeb) {
  //     webImages = [await picked.readAsBytes()];
  //   } else {
  //     images = [File(picked.path)];
  //   }
  //   setState(() {});
  // }

  Widget buildImagePreviewArea() {
    final imagesCount = kIsWeb ? webImages.length : images.length;
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: screenHeight * 0.25,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: imagesCount == 0
            ? InkWell(
                onTap: pickimagedialog,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: mainPink),
                    const SizedBox(height: 8),
                    const Text("Add Pet Photos (Max 3)", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(12),
                    scrollDirection: Axis.horizontal,
                    itemCount: imagesCount,
                    itemBuilder: (ctx, index) => _buildIndividualThumbnail(index),
                  ),
                  if (imagesCount < 3)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton.small(
                        backgroundColor: mainPink,
                        onPressed: pickimagedialog,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildIndividualThumbnail(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 140,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.expand(
              child: kIsWeb ? Image.memory(webImages[index], fit: BoxFit.cover) : Image.file(images[index], fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => removeImageAt(index),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.cancel, color: Colors.red, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickimagedialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
              ),
              const Text("Add Image", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _imageOption(
                icon: Icons.camera_alt_outlined,
                label: "Take Photo",
                onTap: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              const SizedBox(height: 12),
              _imageOption(
                icon: Icons.photo_library_outlined,
                label: "Choose from Gallery",
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _imageOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, size: 26, color: mainPink),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Future<void> openCamera() async {
  //   final XFile? picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
  //   if (picked == null) return;
  //   if (kIsWeb) {
  //     webImages = [await picked.readAsBytes()];
  //   } else {
  //     images = [File(picked.path)];
  //   }
  //   setState(() {});
  // }

  // // remove by index
  // void removeImageAt(int index) {
  //   if (kIsWeb) {
  //     if (index >= 0 && index < webImages.length) {
  //       webImages.removeAt(index);
  //     }
  //   } else {
  //     if (index >= 0 && index < images.length) {
  //       images.removeAt(index);
  //     }
  //   }
  //   setState(() {});
  // }

  Future<void> openCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List data = await pickedFile.readAsBytes();
        setState(() => webImages.add(data));
      } else {
        File? cropped = await cropImage(File(pickedFile.path));
        if (cropped != null) setState(() => images.add(cropped));
      }
    }
  }

  Future<void> openGallery() async {
    int currentCount = kIsWeb ? webImages.length : images.length;
    int remaining = 3 - currentCount;
    if (remaining <= 0) return;

    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
    if (pickedFiles.isNotEmpty) {
      var toProcess = pickedFiles.length > remaining ? pickedFiles.sublist(0, remaining) : pickedFiles;
      
      for (var xFile in toProcess) {
        if (kIsWeb) {
          Uint8List data = await xFile.readAsBytes();
          setState(() => webImages.add(data));
        } else {
          File? cropped = await cropImage(File(xFile.path));
          if (cropped != null) setState(() => images.add(cropped));
        }
      }
    }
  }

  Future<File?> cropImage(File rawFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: rawFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop for profile feel
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Pet Photo',
          toolbarColor: mainPink,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  void removeImageAt(int index) {
    setState(() {
      if (kIsWeb) webImages.removeAt(index);
      else images.removeAt(index);
    });
  }

  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       throw 'Location permissions are denied';
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //       'Location permissions are permanently denied, we cannot request permissions.',
  //     );
  //   }

  //   return await Geolocator.getCurrentPosition();
  // }

  Future<void> _determineAndSetLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permission denied';
      }

      Position pos = await Geolocator.getCurrentPosition();
      latitude = pos.latitude;
      longitude = pos.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(latitude!, longitude!);
      Placemark p = placemarks[0];
      setState(() {
        petLocationController.text = "${p.name}, ${p.locality}, ${p.country}";
      });
    } catch (e) {
      showSnack(e.toString(), isError: true);
    }
  }

  // Validation checks & submit flow
  // void showSubmitDialog() {
  //   if (petNameController.text.trim().isEmpty) {
  //     showSnack('Pet name is required', isError: true);
  //     return;
  //   }

  //   if (petDescriptionController.text.trim().length < 10) {
  //     showSnack('Description must be at least 10 characters', isError: true);
  //     return;
  //   }

  //   if (selectedPet == null) {
  //     showSnack('Please select a pet type', isError: true);
  //     return;
  //   }

  //   if (selectedCategory == null) {
  //     showSnack('Please select a category', isError: true);
  //     return;
  //   }

  //   // At least 1 image and max 3
  //   if (kIsWeb) {
  //     if (webImages.isEmpty) {
  //       showSnack('Please select at least one image', isError: true);
  //       return;
  //     }
  //     if (webImages.length > 3) {
  //       showSnack('Maximum 3 images allowed', isError: true);
  //       return;
  //     }
  //   } else {
  //     if (images.isEmpty) {
  //       showSnack('Please select at least one image', isError: true);
  //       return;
  //     }
  //     if (images.length > 3) {
  //       showSnack('Maximum 3 images allowed', isError: true);
  //       return;
  //     }
  //   }

  //   if (latitude == null || longitude == null) {
  //     showSnack('Please fill location (latitude & longitude)', isError: true);
  //     return;
  //   }

  //   // confirm dialog
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Submit Pet Profile'),
  //       content: const Text('Are you sure you want to submit this furry details?'),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(ctx);
  //             submitService();
  //           },
  //           child: const Text('Submit'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void showSubmitDialog() {
    if (_formKey.currentState!.validate()) {
      int count = kIsWeb ? webImages.length : images.length;
      if (count == 0) {
        showSnack("Please add at least one photo", isError: true);
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submit Profile'),
          content: const Text('Confirm furry details submission?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                submitPet();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> submitPet() async {
    setState(() => submitting = true);
    try {
      List<String> base64Images = [];
      if (kIsWeb) {
        for (var data in webImages) base64Images.add(base64Encode(data));
      } else {
        for (var f in images) base64Images.add(base64Encode(await f.readAsBytes()));
      }

      final body = {
        'user_id': currentUser?.user_id ?? '',
        'pet_name': petNameController.text.trim(),
        'pet_age': petAgeController.text.trim(),
        'pet_type': selectedPet,
        'category': selectedCategory,
        'description': petDescriptionController.text.trim(),
        'lat': latitude?.toString() ?? '',
        'lng': longitude?.toString() ?? '',
        'images': base64Images,
      };

      final resp = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200 && jsonDecode(resp.body)['success']) {
        showSnack('Submitted successfully!');
        Navigator.pop(context, true);
      } else {
        showSnack('Failed to submit', isError: true);
      }
    } catch (e) {
      showSnack('Error: $e', isError: true);
    } finally {
      setState(() => submitting = false);
    }
  }

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }
}

  // Future<void> submitService() async {
  //   setState(() => submitting = true);
  //   try {
  //     // prepare base64 array
  //     List<String> base64Images = [];

  //     if (kIsWeb) {
  //       for (var data in webImages) {
  //         base64Images.add(base64Encode(data));
  //       }
  //     } else {
  //       for (var f in images) {
  //         final bytes = await f.readAsBytes();
  //         base64Images.add(base64Encode(bytes));
  //       }
  //     }

  //     final body = {
  //       'user_id': currentUser?.user_id ?? '',
  //       'pet_name': petNameController.text.trim(),
  //       'pet_type': selectedPet,
  //       'category': selectedCategory,
  //       'description': petDescriptionController.text.trim(),
  //       'lat': latitude?.toString() ?? '',
  //       'lng': longitude?.toString() ?? '',
  //       'images': base64Images, // JSON array will be encoded below
  //     };

  //     final url = Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php');

  //     final resp = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(body),
  //     );

  //     if (resp.statusCode == 200) {
  //       final decoded = jsonDecode(resp.body);
  //       if (decoded['success'] == true) {
  //         showSnack('Furry details submitted successfully');
  //         // Optionally pop with true so MainScreen can refresh
  //         Navigator.pop(context, true);
  //       } else {
  //         showSnack(decoded['message'] ?? 'Submission failed', isError: true);
  //       }
  //     } else {
  //       showSnack('Server error: ${resp.statusCode}', isError: true);
  //     }
  //   } catch (e) {
  //     showSnack('Submit error: $e', isError: true);
  //   } finally {
  //     setState(() => submitting = false);
  //   }
  // }

  // void showSnack(String message, {bool isError = false}) {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     content: Text(message),
  //     backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
  //   ));
  // }

//   Widget buildImagePreviewArea() {
//     final imagesCount = kIsWeb ? webImages.length : images.length;


//     if (imagesCount == 0) {
//       return GestureDetector(
//         onTap: pickImagesMulti,
//         child: Container(
//           height: 200,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade400),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.camera_alt, size: 64, color: Colors.grey),
//               SizedBox(height: 8),
//               Text('Tap to pick up to 3 images'),
//             ],
//           ),
//         ),
//       );
//     }

//     // show row of thumbnails with remove icons
//     return SizedBox(
//       height: 120,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: imagesCount,
//         itemBuilder: (context, index) {
//           Widget imageWidget;
//           if (kIsWeb) {
//             imageWidget = Image.memory(webImages[index], fit: BoxFit.cover, width: 120, height: 120);
//           } else {
//             imageWidget = Image.file(images[index], fit: BoxFit.cover, width: 120, height: 120);
//           }

//           return Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(width: 120, height: 120, color: Colors.grey[200], child: imageWidget),
//                 ),
//                 Positioned(
//                   right: -6,
//                   top: -6,
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     icon: const Icon(Icons.cancel, color: Colors.red),
//                     onPressed: () => removeImageAt(index),
//                   ),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// Widget buildImagePreviewArea() {
//   final imagesCount = kIsWeb ? webImages.length : images.length;
//   double screenHeight = MediaQuery.of(context).size.height;

//   return Card(
//     elevation: 4,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: Container(
//       height: screenHeight * 0.25, // Matches your desired UI height
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: imagesCount == 0
//           ? InkWell( // Empty State
//               onTap: pickImagesMulti,
//               borderRadius: BorderRadius.circular(16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.add_a_photo, size: 50, color: mainPink),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Add Pet Photos (Max 3)",
//                     style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             )
//           : Stack( // Selected Images State
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: imagesCount,
//                     itemBuilder: (context, index) {
//                       return _buildIndividualThumbnail(index);
//                     },
//                   ),
//                 ),
//                 // "Add More" overlay button if less than 3 images
//                 if (imagesCount < 3)
//                   Positioned(
//                     bottom: 10,
//                     right: 10,
//                     child: FloatingActionButton.small(
//                       backgroundColor: mainPink,
//                       onPressed: pickImagesMulti,
//                       child: const Icon(Icons.add, color: Colors.white),
//                     ),
//                   ),
//               ],
//             ),
//     ),
//   );
// }

// // Helper widget for each image in the row
// Widget _buildIndividualThumbnail(int index) {
//   Widget imageWidget = kIsWeb
//       ? Image.memory(webImages[index], fit: BoxFit.cover)
//       : Image.file(images[index], fit: BoxFit.cover);

//   return Container(
//     margin: const EdgeInsets.only(right: 10),
//     width: 150, // Fixed width for thumbnails in the horizontal list
//     child: Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: SizedBox.expand(child: imageWidget),
//         ),
//         // Delete button on each thumbnail
//         Positioned(
//           top: 5,
//           right: 5,
//           child: GestureDetector(
//             onTap: () => removeImageAt(index),
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.cancel, color: Colors.red, size: 24),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
// }
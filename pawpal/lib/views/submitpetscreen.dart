// lib/views/submit_pet_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
  //final _formKey = GlobalKey<FormState>();

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
  final TextEditingController petDescriptionController = TextEditingController();
  final TextEditingController petLocationController = TextEditingController();

  // images
  List<File> images = []; // mobile
  List<Uint8List> webImages = []; // web

  //default values
  String selectedPet = 'Dog';
  String selectedCategory = 'Adoption';

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
    double width = MediaQuery.of(context).size.width;
    if (width > 600) width = 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Pet Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: width,
            child: Form(
              //key: _formKey,
              child: Column(
                children: [
                  buildImagePreviewArea(),
                  const SizedBox(height: 12),

                  // Buttons: Pick / Camera
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickImagesMulti,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Pick Images'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: openCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Open Camera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: petNameController,
                    decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder()),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Pet name required' : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedPet,
                    decoration: const InputDecoration(labelText: 'Pet Type', border: OutlineInputBorder()),
                    items: listOfPets.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setState(() => selectedPet = v!),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: listOfCategories.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: petDescriptionController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 4,
                    minLines: 2,
                    validator: (val) {
                      if (val == null || val.trim().length < 10) {
                        return 'Please enter at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: petLocationController,
                    decoration: InputDecoration(
                      labelText: 'Location (auto)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          currentPosition = await _determinePosition();
                          print(currentPosition.latitude);
                          print(currentPosition.longitude);
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                currentPosition.latitude,
                                currentPosition.longitude,
                              );
                          Placemark place = placemarks[0];
                          petLocationController.text =
                              "${place.name},\n${place.street},\n${place.postalCode},${place.locality},\n${place.administrativeArea},${place.country}";
                          setState(() {});
                        },
                        icon: Icon(Icons.location_on),
                      ),
                    ),
                    readOnly: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: Size(width, 50),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showSubmitDialog();
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
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

    Future<void> pickImagesMulti() async {
    // Use pickMultiImage which works on mobile & web (returns List<XFile>)
    try {
      final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 85); // compress lightly
      if (picked == null) return;
      if (picked.isEmpty) return;

      // Cap at 3
      final take = picked.length > 3 ? picked.sublist(0, 3) : picked;

      images.clear();
      webImages.clear();

      if (kIsWeb) {
        for (var x in take) {
          final data = await x.readAsBytes();
          webImages.add(data);
        }
      } else {
        for (var x in take) {
          images.add(File(x.path));
        }
      }
      setState(() {});
    } catch (e) {
      // fallback: single image pick
      debugPrint("pickImagesMulti error: $e");
    }
  }

  Future<void> pickSingleImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    if (kIsWeb) {
      webImages = [await picked.readAsBytes()];
    } else {
      images = [File(picked.path)];
    }
    setState(() {});
  }

  Future<void> openCamera() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;
    if (kIsWeb) {
      webImages = [await picked.readAsBytes()];
    } else {
      images = [File(picked.path)];
    }
    setState(() {});
  }

  // remove by index
  void removeImageAt(int index) {
    if (kIsWeb) {
      if (index >= 0 && index < webImages.length) {
        webImages.removeAt(index);
      }
    } else {
      if (index >= 0 && index < images.length) {
        images.removeAt(index);
      }
    }
    setState(() {});
  }

  // location retrieval
  // Future<void> fillLocation() async {
  //   try {
  //     Position pos = await _determinePosition();
  //     latitude = pos.latitude;
  //     longitude = pos.longitude;

  //     // Also convert to a friendly address (optional)
  //     try {
  //       final placemarks = await placemarkFromCoordinates(latitude!, longitude!);
  //       if (placemarks.isNotEmpty) {
  //         final p = placemarks.first;
  //         petLocationController.text =
  //             "${p.name ?? ''}${p.street != null && p.street!.isNotEmpty ? ', ${p.street}' : ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}";
  //       } else {
  //         petLocationController.text = "$latitude, $longitude";
  //       }
  //     } catch (e) {
  //       petLocationController.text = "$latitude, $longitude";
  //     }

  //     setState(() {});
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("Location error: $e"),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  // }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  // Validation checks & submit flow
  void showSubmitDialog() {
    if (petNameController.text.trim().isEmpty) {
      showSnack('Pet name is required', isError: true);
      return;
    }

    if (petDescriptionController.text.trim().length < 10) {
      showSnack('Description must be at least 10 characters', isError: true);
      return;
    }

    // At least 1 image and max 3
    if (kIsWeb) {
      if (webImages.isEmpty) {
        showSnack('Please select at least one image', isError: true);
        return;
      }
      if (webImages.length > 3) {
        showSnack('Maximum 3 images allowed', isError: true);
        return;
      }
    } else {
      if (images.isEmpty) {
        showSnack('Please select at least one image', isError: true);
        return;
      }
      if (images.length > 3) {
        showSnack('Maximum 3 images allowed', isError: true);
        return;
      }
    }

    if (latitude == null || longitude == null) {
      showSnack('Please fill location (latitude & longitude)', isError: true);
      return;
    }

    // confirm dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Pet Profile'),
        content: const Text('Are you sure you want to submit this furry details?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              submitService();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> submitService() async {
    setState(() => submitting = true);
    try {
      // prepare base64 array
      List<String> base64Images = [];

      if (kIsWeb) {
        for (var data in webImages) {
          base64Images.add(base64Encode(data));
        }
      } else {
        for (var f in images) {
          final bytes = await f.readAsBytes();
          base64Images.add(base64Encode(bytes));
        }
      }

      final body = {
        //'user_id': widget.user?.user_id ?? '',
        'pet_name': petNameController.text.trim(),
        'pet_type': selectedPet,
        'category': selectedCategory,
        'description': petDescriptionController.text.trim(),
        'lat': latitude?.toString() ?? '',
        'lng': longitude?.toString() ?? '',
        'images': base64Images, // JSON array will be encoded below
      };

      final url = Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php');

      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded['success'] == true) {
          showSnack('Furry details submitted successfully');
          // Optionally pop with true so MainScreen can refresh
          Navigator.pop(context, true);
        } else {
          showSnack(decoded['message'] ?? 'Submission failed', isError: true);
        }
      } else {
        showSnack('Server error: ${resp.statusCode}', isError: true);
      }
    } catch (e) {
      showSnack('Submit error: $e', isError: true);
    } finally {
      setState(() => submitting = false);
    }
  }

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
    ));
  }

  Widget buildImagePreviewArea() {
    final imagesCount = kIsWeb ? webImages.length : images.length;

    if (imagesCount == 0) {
      return GestureDetector(
        onTap: pickImagesMulti,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tap to pick up to 3 images'),
            ],
          ),
        ),
      );
    }

    // show row of thumbnails with remove icons
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagesCount,
        itemBuilder: (context, index) {
          Widget imageWidget;
          if (kIsWeb) {
            imageWidget = Image.memory(webImages[index], fit: BoxFit.cover, width: 120, height: 120);
          } else {
            imageWidget = Image.file(images[index], fit: BoxFit.cover, width: 120, height: 120);
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(width: 120, height: 120, color: Colors.grey[200], child: imageWidget),
                ),
                Positioned(
                  right: -6,
                  top: -6,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => removeImageAt(index),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

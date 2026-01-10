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
import 'package:pawpal/models/mypet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';

class EditUserPetScreen extends StatefulWidget {
  final User? user;
  final MyPet pet;
  
  const EditUserPetScreen({
    super.key, 
    required this.user,
    required this.pet,
  });

  @override
  State<EditUserPetScreen> createState() => _EditUserPetScreenState();
}

class _EditUserPetScreenState extends State<EditUserPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  // Dropdown lists
  List<String> listOfPets = ['Dog', 'Cat', 'Rabbit', 'Other'];
  List<String> listOfCategories = ['Adoption', 'Donation Request', 'Help/Rescue'];

  // Controllers
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController petAgeController = TextEditingController();
  final TextEditingController petDescriptionController = TextEditingController();
  final TextEditingController petLocationController = TextEditingController();

  // Existing images from server
  List<String> existingImages = [];
  
  // New images to upload
  List<File> newImages = []; // mobile
  List<Uint8List> newWebImages = []; // web

  String? selectedPet;
  String? selectedCategory;

  double? latitude;
  double? longitude;

  bool submitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  void _loadPetData() {
    petNameController.text = widget.pet.petName ?? '';
    petAgeController.text = widget.pet.petAge?.toString() ?? '';
    petDescriptionController.text = widget.pet.petDescription ?? '';
    selectedPet = widget.pet.petType;
    selectedCategory = widget.pet.petCategory;
    latitude = widget.pet.latitude != null ? double.tryParse(widget.pet.latitude!) : null;
    longitude = widget.pet.longitude != null ? double.tryParse(widget.pet.longitude!) : null;
    
    // Load existing images
    if (widget.pet.imagePaths != null && widget.pet.imagePaths!.isNotEmpty) {
      existingImages = List.from(widget.pet.imagePaths!);
    }
    
    // Set location text if available
    if (latitude != null && longitude != null) {
      petLocationController.text = "Lat: ${latitude!.toStringAsFixed(4)}, Lng: ${longitude!.toStringAsFixed(4)}";
    }
  }

  @override
  void dispose() {
    petNameController.dispose();
    petAgeController.dispose();
    petDescriptionController.dispose();
    petLocationController.dispose();
    super.dispose();
  }

  String getPetImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    String cleanPath = imagePath.replaceAll('../assets/', '').replaceAll('assets/', '');
    return "${MyConfig.baseUrl}/pawpal/assets/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final maxWidth = screenWidth > 600 ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit Pet Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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

                  // FORM CARD
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
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'Pet name required'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: selectedPet,
                            hint: const Text('Select Pet Type'),
                            decoration: _dropdownDecoration("Pet Type", Icons.pets),
                            items: listOfPets
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedPet = v),
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'Pet type required'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            hint: const Text('Select Category'),
                            decoration: _dropdownDecoration("Category", Icons.category),
                            items: listOfCategories
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedCategory = v),
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'Category required'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          _inputField(
                            controller: petAgeController,
                            label: 'Pet Age',
                            icon: Icons.numbers,
                            keyboard: TextInputType.number,
                            validator: (val) => (val == null || val.trim().isEmpty)
                                ? 'Pet age required'
                                : null,
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
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            validator: (val) => (val == null || val.trim().length < 10)
                                ? 'Enter at least 10 characters'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: petLocationController,
                            readOnly: true,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Location (optional)',
                              prefixIcon: const Icon(Icons.map),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.location_on, color: mainPink),
                                onPressed: _determineAndSetLocation,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainPink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: submitting ? null : showUpdateDialog,
                              child: submitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Update Profile',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
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

  Widget buildImagePreviewArea() {
    int totalImages = existingImages.length + (kIsWeb ? newWebImages.length : newImages.length);
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: screenHeight * 0.25,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: totalImages == 0
            ? InkWell(
                onTap: pickImageDialog,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: mainPink),
                    const SizedBox(height: 8),
                    const Text(
                      "Add Pet Photos (Max 3)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(12),
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Existing images
                      ...existingImages.asMap().entries.map((entry) {
                        return _buildExistingImageThumbnail(entry.key, entry.value);
                      }),
                      // New images
                      ..._buildNewImageThumbnails(),
                    ],
                  ),
                  if (totalImages < 3)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton.small(
                        backgroundColor: mainPink,
                        onPressed: pickImageDialog,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildExistingImageThumbnail(int index, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 140,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.expand(
              child: Image.network(
                getPetImageUrl(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => removeExistingImage(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel, color: Colors.red, size: 24),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Current',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNewImageThumbnails() {
    if (kIsWeb) {
      return newWebImages.asMap().entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(right: 10),
          width: 140,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.expand(
                  child: Image.memory(entry.value, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => removeNewImage(entry.key),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel, color: Colors.red, size: 24),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();
    } else {
      return newImages.asMap().entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(right: 10),
          width: 140,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.expand(
                  child: Image.file(entry.value, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => removeNewImage(entry.key),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel, color: Colors.red, size: 24),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();
    }
  }

  void removeExistingImage(int index) {
    setState(() {
      existingImages.removeAt(index);
    });
  }

  void removeNewImage(int index) {
    setState(() {
      if (kIsWeb) {
        newWebImages.removeAt(index);
      } else {
        newImages.removeAt(index);
      }
    });
  }

  void pickImageDialog() {
    int currentTotal = existingImages.length + (kIsWeb ? newWebImages.length : newImages.length);
    if (currentTotal >= 3) {
      showSnack('Maximum 3 images allowed', isError: true);
      return;
    }

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
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "Add Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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

  Widget _imageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
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

  Future<void> openCamera() async {
    int currentTotal = existingImages.length + (kIsWeb ? newWebImages.length : newImages.length);
    if (currentTotal >= 3) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List data = await pickedFile.readAsBytes();
        setState(() => newWebImages.add(data));
      } else {
        File? cropped = await cropImage(File(pickedFile.path));
        if (cropped != null) setState(() => newImages.add(cropped));
      }
    }
  }

  Future<void> openGallery() async {
    int currentTotal = existingImages.length + (kIsWeb ? newWebImages.length : newImages.length);
    int remaining = 3 - currentTotal;
    if (remaining <= 0) return;

    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
    if (pickedFiles.isNotEmpty) {
      var toProcess = pickedFiles.length > remaining
          ? pickedFiles.sublist(0, remaining)
          : pickedFiles;

      for (var xFile in toProcess) {
        if (kIsWeb) {
          Uint8List data = await xFile.readAsBytes();
          setState(() => newWebImages.add(data));
        } else {
          File? cropped = await cropImage(File(xFile.path));
          if (cropped != null) setState(() => newImages.add(cropped));
        }
      }
    }
  }

  Future<File?> cropImage(File rawFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: rawFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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

  void showUpdateDialog() {
    if (_formKey.currentState!.validate()) {
      int totalImages = existingImages.length + (kIsWeb ? newWebImages.length : newImages.length);
      if (totalImages == 0) {
        showSnack("Please keep or add at least one photo", isError: true);
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update Profile'),
          content: const Text('Confirm pet profile update?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                updatePet();
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> updatePet() async {
    setState(() => submitting = true);
    try {
      // Convert new images to base64
      List<String> base64NewImages = [];
      if (kIsWeb) {
        for (var data in newWebImages) {
          base64NewImages.add(base64Encode(data));
        }
      } else {
        for (var f in newImages) {
          base64NewImages.add(base64Encode(await f.readAsBytes()));
        }
      }

      final body = {
        'pet_id': widget.pet.petId,
        'user_id': widget.user?.user_id ?? '',
        'pet_name': petNameController.text.trim(),
        'pet_age': petAgeController.text.trim(),
        'pet_type': selectedPet,
        'category': selectedCategory,
        'description': petDescriptionController.text.trim(),
        'lat': latitude?.toString() ?? '',
        'lng': longitude?.toString() ?? '',
        'existing_images': existingImages, // Keep these
        'new_images': base64NewImages, // Add these
      };

      final resp = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/update_pet.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        final result = jsonDecode(resp.body);
        if (result['success']) {
          showSnack('Updated successfully!');
          Navigator.pop(context, true); // Return true to refresh
        } else {
          showSnack(result['message'] ?? 'Failed to update', isError: true);
        }
      } else {
        showSnack('Server error: ${resp.statusCode}', isError: true);
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
      backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
    ));
  }
}
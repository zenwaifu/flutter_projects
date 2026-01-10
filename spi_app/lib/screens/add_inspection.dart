import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/inspection.dart';
import '../providers/location_provider.dart';
import '../providers/inspection_provider.dart';

class AddInspectionScreen extends StatefulWidget {
  final Inspection? existingInspection;

  const AddInspectionScreen({super.key, this.existingInspection});

  @override
  State<AddInspectionScreen> createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen> {
  final TextEditingController propertyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  final List<File> imageFiles = [];

  String selectedRating = 'Good';
  final List<String> ratings = ['Excellent', 'Good', 'Fair', 'Poor'];

  @override
  void initState() {
    super.initState();

    if (widget.existingInspection != null) {
      propertyController.text = widget.existingInspection!.propertyName;
      descriptionController.text = widget.existingInspection!.description;
      selectedRating = widget.existingInspection!.rating;
      imageFiles.addAll(
        widget.existingInspection!.photos.map((p) => File(p)),
      );

      final loc = context.read<LocationProvider>();
      loc.lat = widget.existingInspection!.latitude;
      loc.lng = widget.existingInspection!.longitude;
    }
  }

  Future<void> captureAndCropImage() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked == null) return;

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: const Color(0xFF2E7D32),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
        ),
      ],
    );

    if (cropped == null) return;

    setState(() => imageFiles.add(File(cropped.path)));
  }

  void removeImage(int index) {
    setState(() => imageFiles.removeAt(index));
  }

  Future<void> saveInspection() async {
    final loc = context.read<LocationProvider>();

    if (propertyController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        imageFiles.length < 3 ||
        loc.lat == null ||
        loc.lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill all fields, capture location & min 3 photos'),
        ),
      );
      return;
    }

    final inspection = Inspection(
      id: widget.existingInspection?.id,
      propertyName: propertyController.text.trim(),
      description: descriptionController.text.trim(),
      rating: selectedRating,
      latitude: loc.lat!,
      longitude: loc.lng!,
      dateCreated: widget.existingInspection?.dateCreated ??
          DateTime.now().toIso8601String(),
      photos: imageFiles.map((f) => f.path).toList(),
    );

    final provider = context.read<InspectionProvider>();

    if (widget.existingInspection == null) {
      await provider.addInspection(inspection);
    } else {
      await provider.updateInspection(inspection);
    }

    loc.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingInspection == null
              ? 'Add Inspection'
              : 'Edit Inspection',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// IMAGE CARD (TOP)
          GestureDetector(
            onTap: captureAndCropImage,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 200,
                child: imageFiles.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Capture Photo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          imageFiles.first,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: propertyController,
            decoration: const InputDecoration(
              labelText: 'Property Name / Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Inspection Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedRating,
            decoration: const InputDecoration(
              labelText: 'Overall Rating',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.star),
            ),
            items: ratings
                .map(
                  (r) => DropdownMenuItem(value: r, child: Text(r)),
                )
                .toList(),
            onChanged: (v) => setState(() => selectedRating = v!),
          ),

          const SizedBox(height: 16),

          /// LOCATION CARD
          Card(
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('GPS Location'),
              subtitle: loc.isLoading
                  ? const Text('Fetching location...')
                  : loc.lat != null
                      ? Text(
                          'Lat: ${loc.lat!.toStringAsFixed(6)}\nLng: ${loc.lng!.toStringAsFixed(6)}')
                      : const Text('Not captured'),
              trailing: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () async {
                  await loc.fetchCurrentLocation();
                  if (loc.lat != null && loc.lng != null) {
                    showMapDialog(LatLng(loc.lat!, loc.lng!));
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// IMAGE LIST
          if (imageFiles.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageFiles.length,
                itemBuilder: (_, i) => Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 110,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          imageFiles[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => removeImage(i),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child:
                              Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: saveInspection,
            icon: const Icon(Icons.save),
            label: const Text('Save Inspection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  void showMapDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          height: 350,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition:
                CameraPosition(target: position, zoom: 16),
            markers: {
              Marker(
                markerId: const MarkerId('current'),
                position: position,
              ),
            },
            myLocationEnabled: false,
            zoomControlsEnabled: true,
          ),
        ),
      ),
    );
  }
}

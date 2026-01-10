import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/inspection.dart';

class InspectionDetailDialog extends StatelessWidget {
  final Inspection inspection;

  const InspectionDetailDialog({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    final position = LatLng(inspection.latitude, inspection.longitude);
    final darkGreen = const Color(0xFF1B5E20);
    final midGreen = const Color(0xFF4CAF50);

    // Format date
    final date = DateTime.parse(inspection.dateCreated);
    final formattedDate =
        "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo Gallery
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: inspection.photos.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.file(
                      File(inspection.photos[index]),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property name
                  Text(
                    inspection.propertyName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: _getRatingColor(inspection.rating),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        inspection.rating,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _getRatingColor(inspection.rating),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inspection.description,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  
                  // GPS Coordinates
                  Text(
                    "GPS Location:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: midGreen,
                    ),
                  ),
                  Text(
                    "Lat: ${inspection.latitude.toStringAsFixed(6)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Lng: ${inspection.longitude.toStringAsFixed(6)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  
                  // Date
                  Text(
                    "Inspected: $formattedDate",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Map
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: position,
                          zoom: 16,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId("inspection"),
                            position: position,
                            infoWindow: InfoWindow(
                              title: inspection.propertyName,
                            ),
                          ),
                        },
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text("Show Location"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _openGoogleMaps(
                        inspection.latitude,
                        inspection.longitude,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng'
      '&travelmode=driving',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch Google Maps';
    }
  }
}
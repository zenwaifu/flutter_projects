import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Provider for managing GPS location data
/// Handles location permissions and fetching current coordinates
class LocationProvider extends ChangeNotifier {
  double? lat;
  double? lng;
  bool isLoading = false;
  String? error;

  /// Fetch current GPS location
  /// Handles permission requests and service checks
  Future<void> fetchCurrentLocation() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error = "Location service is disabled. Please enable it in settings.";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          error = "Location permission denied. Please grant permission.";
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        error = "Location permission denied forever. Enable in app settings.";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position with high accuracy
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      lat = pos.latitude;
      lng = pos.longitude;
      error = null;
    } catch (e) {
      error = "Failed to get location: ${e.toString()}";
      lat = null;
      lng = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear location data
  void clear() {
    lat = null;
    lng = null;
    error = null;
    notifyListeners();
  }

  /// Check if location is available
  bool get hasLocation => lat != null && lng != null;

  /// Get formatted location string
  String get locationString {
    if (lat == null || lng == null) return "No location";
    return "Lat: ${lat!.toStringAsFixed(6)}, Lng: ${lng!.toStringAsFixed(6)}";
  }
}
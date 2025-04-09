import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:safe_device/safe_device.dart';
import 'package:logger/logger.dart';
import '../data/models/office_model.dart';

class LocationUtils {
  static final Logger _logger = Logger();

  static Future<LatLng?> getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check location permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Get current location
    final locationData = await location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      return LatLng(locationData.latitude!, locationData.longitude!);
    }

    return null;
  }

  // Check if mock location is enabled
  static Future<bool> isMockLocationEnabled() async {
    try {
      return await SafeDevice.isMockLocation;
    } catch (e) {
      _logger.e("Error checking mock location: $e");
      return false;
    }
  }

  // Calculate distance between two points using Haversine formula
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // in meters
    double lat1 = point1.latitude * math.pi / 180;
    double lat2 = point2.latitude * math.pi / 180;
    double lon1 = point1.longitude * math.pi / 180;
    double lon2 = point2.longitude * math.pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c; // Distance in meters
  }

  // Check if the current position is within any office radius
  static bool isWithinAnyOfficeRadius(LatLng position, List<Office> offices) {
    for (var office in offices) {
      double distance = calculateDistance(position, office.position);
      if (distance <= office.radius) {
        return true;
      }
    }
    return false;
  }
}
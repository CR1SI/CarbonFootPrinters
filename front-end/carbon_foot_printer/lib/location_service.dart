import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final Location _location = Location();

  /// Initialize location service and request permissions
  Future<bool> initialize() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    // Request permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    // Enable background mode
    await _location.enableBackgroundMode(enable: true);

    return true;
  }

  /// Get a stream of location updates
  Stream<LocationData> getLocationUpdates() {
    _location.changeSettings(
      interval: 5000,                // every 5 seconds
      accuracy: LocationAccuracy.low, // less precise for faster updates
      distanceFilter: 10,            // only update if moved 10 meters
    );
    return _location.onLocationChanged;
  }
}

/// Singleton instance
final locationService = LocationService();

/// Start tracking location and send updates to Firestore
void startTracking(String uid) async {
  final ok = await locationService.initialize();
  if (!ok) {
    print("❌ Location service not enabled or permission denied");
    return;
  }

  locationService.getLocationUpdates().listen((locationData) async {
    final double speed = locationData.speed ?? 0.0;
    final double latitude = locationData.latitude ?? 0.0;
    final double longitude = locationData.longitude ?? 0.0;
    final DateTime timestamp = DateTime.now();

    final Map<String, dynamic> jsonData = {
      'speed_mps': speed,
      'speed_kmh': speed * 3.6,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };

    // Print every update
    print("📍 Location update: $jsonData");

    // Send to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('movements')
          .add(jsonData);
    } catch (e) {
      print("❌ Error writing location data: $e");
    }
  });
}

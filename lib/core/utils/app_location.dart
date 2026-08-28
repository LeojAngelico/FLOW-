import 'package:geolocator/geolocator.dart';

import '../errors/error_codes.dart';

/// Reusable location utility.
///
/// Handles:
/// - Location service availability
/// - Location permission checking
/// - Location permission requesting
/// - Current location retrieval
class AppLocation {
  AppLocation._();

  /// Returns the user's current location.
  ///
  /// Throws [LocationServiceDisabledException]
  /// when location services are disabled.
  ///
  /// Throws [PermissionDeniedException]
  /// when location permission is denied.
  static Future<Position> getCurrentLocation() async {
    // Check if the device's location service
    // is enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // Check the current permission status.
    var permission = await Geolocator.checkPermission();

    // Request permission if it has not been
    // granted yet.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // User denied the permission.
    if (permission == LocationPermission.denied) {
      throw const PermissionDeniedException(
        ErrorCodes.locationPermissionDenied,
      );
    }

    // User permanently denied the permission.
    //
    // The permission dialog will not be shown again
    // until the user manually enables it in settings.
    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException(
        ErrorCodes.locationPermissionDeniedForever,
      );
    }

    // Permission is available.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}

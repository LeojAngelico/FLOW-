import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// The camera permission states this app distinguishes between.
///
/// A deliberately smaller set than `permission_handler`'s
/// `PermissionStatus`: callers only need to know whether they can use
/// the camera, whether asking again is worthwhile, and whether the
/// user has to go to Settings.
enum CameraPermissionStatus {
  /// The camera can be used.
  granted,

  /// Denied, but the system dialog can still be shown.
  ///
  /// This is also the state before the permission has ever been
  /// requested (both Android and iOS report "not yet requested" this
  /// way), so it means "asking is worthwhile", not "the user said no".
  denied,

  /// Denied for good — the system dialog will not be shown again.
  ///
  /// The only way forward is the app's Settings page. On Android this
  /// is "Don't ask again"; on iOS every denial lands here, because iOS
  /// only ever shows the camera prompt once.
  permanentlyDenied,

  /// Blocked by the OS rather than by the user (e.g. parental
  /// controls / MDM restrictions on iOS). Settings may not help.
  restricted,

  /// The platform has no camera permission API (e.g. desktop or web
  /// builds), so nothing can be requested.
  unavailable,
}

/// Reusable camera permission utility.
///
/// Wraps `permission_handler` so features never talk to the package
/// directly, in the same spirit as `AppLocation` wrapping `geolocator`.
/// Used by the Core QR Scanner, and safe to reuse by any other feature
/// that needs the camera.
class AppCameraPermission {
  AppCameraPermission._();

  /// Returns the current camera permission state without prompting.
  static Future<CameraPermissionStatus> check() async {
    try {
      return _map(await Permission.camera.status);
    } on MissingPluginException {
      return CameraPermissionStatus.unavailable;
    } on PlatformException {
      return CameraPermissionStatus.unavailable;
    }
  }

  /// Returns the camera permission state, showing the system prompt
  /// first when that can still succeed.
  ///
  /// Only [CameraPermissionStatus.denied] is requestable — the other
  /// states are returned unchanged, so calling this repeatedly never
  /// spams the user with a dialog the OS would refuse to show anyway.
  static Future<CameraPermissionStatus> request() async {
    final current = await check();

    if (current != CameraPermissionStatus.denied) {
      return current;
    }

    try {
      return _map(await Permission.camera.request());
    } on MissingPluginException {
      return CameraPermissionStatus.unavailable;
    } on PlatformException {
      return CameraPermissionStatus.unavailable;
    }
  }

  /// Opens the OS settings page for this app so the user can turn the
  /// camera permission back on.
  ///
  /// Returns false when the settings page could not be opened.
  static Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static CameraPermissionStatus _map(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return CameraPermissionStatus.granted;
      case PermissionStatus.denied:
        return CameraPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return CameraPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return CameraPermissionStatus.restricted;
    }
  }
}

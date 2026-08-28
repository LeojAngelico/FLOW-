/// Stable, non-user-facing codes used by [Failure]s and client-side
/// validation to identify an error without hardcoding presentation-layer
/// (English) text in the domain/data layers.
///
/// Widgets resolve these into localized text via `ErrorLocalizer.resolve`.
/// Any message that doesn't match a known code (e.g. a server-provided
/// [ValidationFailure] message) is displayed as-is.
class ErrorCodes {
  ErrorCodes._();

  static const String network = 'error.network';
  static const String server = 'error.server';
  static const String unauthorized = 'error.unauthorized';
  static const String unknown = 'error.unknown';
  static const String invalidRequest = 'error.invalid_request';
  static const String invalidInput = 'error.invalid_input';

  static const String titleRequired = 'error.title_required';
  static const String descriptionRequired = 'error.description_required';
  static const String photoRequired = 'error.photo_required';
  static const String locationRequired = 'error.location_required';
  static const String cameraGalleryUnavailable =
      'error.camera_gallery_unavailable';
  static const String locationServicesDisabled =
      'error.location_services_disabled';
  static const String locationUnableToDetermine =
      'error.location_unable_to_determine';
  static const String locationPermissionDenied =
      'error.location_permission_denied';
  static const String locationPermissionDeniedForever =
      'error.location_permission_denied_forever';

  static const String cameraUnavailable = 'error.camera_unavailable';
  static const String scannerUnsupported = 'error.scanner_unsupported';
  static const String scannerFailed = 'error.scanner_failed';
  static const String cameraStartFailed = 'error.camera_start_failed';
  static const String captureFailed = 'error.capture_failed';
}

import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';
import '../errors/error_codes.dart';

/// Resolves an [ErrorCodes] value into localized text.
///
/// Messages that aren't a recognized code (e.g. text returned directly
/// by the backend inside a `ValidationFailure`) are returned unchanged,
/// since the app has no translation for arbitrary server-authored text.
class ErrorLocalizer {
  ErrorLocalizer._();

  static String resolve(BuildContext context, String message) {
    final loc = AppLocalizations.of(context)!;

    switch (message) {
      case ErrorCodes.network:
        return loc.errorNoInternet;
      case ErrorCodes.server:
        return loc.errorServerGeneric;
      case ErrorCodes.unauthorized:
        return loc.errorInvalidCredentials;
      case ErrorCodes.unknown:
        return loc.errorUnknown;
      case ErrorCodes.invalidRequest:
        return loc.errorInvalidRequest;
      case ErrorCodes.invalidInput:
        return loc.errorInvalidInput;
      case ErrorCodes.titleRequired:
        return loc.errorTitleRequired;
      case ErrorCodes.descriptionRequired:
        return loc.errorDescriptionRequired;
      case ErrorCodes.photoRequired:
        return loc.errorPhotoRequired;
      case ErrorCodes.locationRequired:
        return loc.errorLocationRequired;
      case ErrorCodes.cameraGalleryUnavailable:
        return loc.errorCameraGalleryUnavailable;
      case ErrorCodes.locationServicesDisabled:
        return loc.errorLocationServicesDisabled;
      case ErrorCodes.locationUnableToDetermine:
        return loc.errorLocationUnableToDetermine;
      case ErrorCodes.locationPermissionDenied:
        return loc.errorLocationPermissionDenied;
      case ErrorCodes.locationPermissionDeniedForever:
        return loc.errorLocationPermissionDeniedForever;
      case ErrorCodes.cameraUnavailable:
        return loc.errorCameraUnavailable;
      case ErrorCodes.scannerUnsupported:
        return loc.errorScannerUnsupported;
      case ErrorCodes.scannerFailed:
        return loc.errorScannerFailed;
      case ErrorCodes.cameraStartFailed:
        return loc.errorCameraStartFailed;
      case ErrorCodes.captureFailed:
        return loc.errorCaptureFailed;
      default:
        return message;
    }
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FLOW';

  @override
  String get navHome => 'Home';

  @override
  String get navProgress => 'Progress';

  @override
  String get navAwards => 'Awards';

  @override
  String get navProfile => 'Profile';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get middleNameLabel => 'Middle Name';

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get loginEmailRequired => 'Email is required.';

  @override
  String get loginPasswordRequired => 'Password is required.';

  @override
  String get loginButton => 'Login';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoInfo => 'No profile information available.';

  @override
  String get profileMemberSince => 'Member Since';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileLogoutConfirmMessage =>
      'Are you sure you want to logout from your account?';

  @override
  String get profileLoggingOut => 'Logging out...';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFilipino => 'Filipino';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get registrationTitle => 'Registration';

  @override
  String get registrationUsernameLabel => 'Username';

  @override
  String get registrationButton => 'Register';

  @override
  String get registrationAlreadyHaveAccount => 'Already have an account? Login';

  @override
  String get registrationSuccessMessage => 'Successfully registered.';

  @override
  String get qrScannerTitle => 'Scan QR code';

  @override
  String get qrScannerInstruction =>
      'Place the markers around the QR code to begin scanning';

  @override
  String get qrScannerCloseTooltip => 'Close scanner';

  @override
  String get qrScannerTorchOnTooltip => 'Turn on flashlight';

  @override
  String get qrScannerTorchOffTooltip => 'Turn off flashlight';

  @override
  String get qrScannerStartingCamera => 'Starting camera...';

  @override
  String get qrScannerPermissionTitle => 'Camera access needed';

  @override
  String get qrScannerPermissionMessage =>
      'Allow camera access so you can scan QR codes.';

  @override
  String get qrScannerPermissionBlockedMessage =>
      'Camera access is turned off for this app. Turn it on in Settings to scan QR codes.';

  @override
  String get qrScannerPermissionRestrictedMessage =>
      'Camera access is restricted on this device, so scanning is unavailable.';

  @override
  String get qrScannerAllowCameraAccess => 'Allow camera access';

  @override
  String get qrScannerOpenSettings => 'Open Settings';

  @override
  String get faceCaptureTitle => 'Face Capture';

  @override
  String get faceCaptureCameraReady => 'Camera Ready';

  @override
  String get faceCaptureStartingCamera => 'Starting camera...';

  @override
  String get faceCaptureSwitchCameraTooltip => 'Switch camera';

  @override
  String get faceCaptureLightingHint => 'Make sure your face is well lit';

  @override
  String get faceCaptureGuidancePositionFace =>
      'Position your face inside the frame';

  @override
  String get faceCaptureGuidanceMultipleFaces =>
      'Make sure only one face is visible';

  @override
  String get faceCaptureGuidanceMoveCloser => 'Move a little closer';

  @override
  String get faceCaptureGuidanceMoveBack => 'Move slightly back';

  @override
  String get faceCaptureGuidanceCenterFace => 'Center your face';

  @override
  String get faceCaptureGuidanceLookStraight => 'Look straight at the camera';

  @override
  String get faceCaptureGuidanceTurnLeft => 'Turn your head to your left';

  @override
  String get faceCaptureGuidanceTurnRight => 'Turn your head to your right';

  @override
  String get faceCaptureGuidanceSmile => 'Give us a smile';

  @override
  String get faceCaptureGuidanceHoldStill => 'Hold still...';

  @override
  String faceCaptureGuidanceHoldStillCountdown(int seconds) {
    return 'Hold still... $seconds';
  }

  @override
  String get faceCaptureGuidanceCapturing => 'Capturing...';

  @override
  String get faceCaptureGuidanceCaptured => 'Captured';

  @override
  String get faceCaptureReadinessGetReady => 'Get ready';

  @override
  String get faceCaptureReadinessKeepGoing => 'Keep going';

  @override
  String get faceCaptureReadinessAlmostThere => 'Almost there';

  @override
  String get faceCaptureReadinessReady => 'Ready';

  @override
  String get faceCaptureStatusFace => 'Face';

  @override
  String get faceCaptureStatusPosition => 'Position';

  @override
  String get faceCaptureStatusOrientation => 'Orientation';

  @override
  String get faceCaptureStatusStability => 'Stability';

  @override
  String get faceCaptureStatusSmile => 'Smile';

  @override
  String get faceCaptureStatusDetected => 'Detected';

  @override
  String get faceCaptureStatusGood => 'Good';

  @override
  String get faceCaptureStatusWaiting => 'Waiting';

  @override
  String get faceCaptureStatusNotApplicable => 'N/A';

  @override
  String get faceOrientationFront => 'Front';

  @override
  String get faceOrientationLeft => 'Left';

  @override
  String get faceOrientationRight => 'Right';

  @override
  String get faceCaptureReviewTitle => 'Take your selfie';

  @override
  String get faceCaptureReviewSubtitle => 'Make sure to use a bright photo';

  @override
  String get faceCaptureReviewCompleted => 'Completed';

  @override
  String get faceCaptureReviewRequired => 'Required';

  @override
  String get faceCaptureReviewOptional => 'Optional';

  @override
  String get faceCaptureReviewTipsTitle => 'Tips for a good photo';

  @override
  String get faceCaptureReviewTipLighting => 'Use a well-lit area';

  @override
  String get faceCaptureReviewTipAccessories => 'Remove glasses or accessories';

  @override
  String get faceCaptureReviewTipFrame => 'Keep your face within the frame';

  @override
  String get faceCaptureReviewContinue => 'Continue';

  @override
  String get faceCaptureReviewRetake => 'Retake';

  @override
  String get imageViewerCloseTooltip => 'Close image';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String imageViewerCounterSemantics(int current, int total) {
    return 'Image $current of $total';
  }

  @override
  String get imageViewerImageSemantics => 'Image';

  @override
  String get imageViewerLoadFailed => 'Unable to load image.';

  @override
  String get signaturePadTitle => 'Sign your signature below';

  @override
  String get signaturePadHint => 'Sign here';

  @override
  String get signaturePadClear => 'Clear';

  @override
  String get signaturePadComplete => 'Complete';

  @override
  String get signaturePadCloseTooltip => 'Close signature pad';

  @override
  String get signaturePadAreaSemantics => 'Signature drawing area';

  @override
  String get signaturePadDiscardTitle => 'Discard signature?';

  @override
  String get signaturePadDiscardMessage => 'Your signature will not be saved.';

  @override
  String get signaturePadDiscardConfirm => 'Discard';

  @override
  String get errorNoInternet => 'No internet connection.';

  @override
  String get errorServerGeneric => 'Something went wrong on the server.';

  @override
  String get errorInvalidCredentials => 'Invalid account credentials.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get errorInvalidRequest => 'Invalid request.';

  @override
  String get errorInvalidInput => 'Invalid input.';

  @override
  String get errorTitleRequired => 'Title is required.';

  @override
  String get errorDescriptionRequired => 'Description is required.';

  @override
  String get errorPhotoRequired => 'A photo is required.';

  @override
  String get errorLocationRequired => 'Current location is required.';

  @override
  String get errorCameraGalleryUnavailable =>
      'Unable to access the camera or gallery.';

  @override
  String get errorLocationServicesDisabled =>
      'Location services are turned off. Please enable them and try again.';

  @override
  String get errorLocationUnableToDetermine =>
      'Unable to determine your current location.';

  @override
  String get errorLocationPermissionDenied => 'Location permission was denied.';

  @override
  String get errorLocationPermissionDeniedForever =>
      'Location permission was permanently denied.';

  @override
  String get errorCameraUnavailable => 'Unable to access the camera.';

  @override
  String get errorScannerUnsupported =>
      'Scanning is not supported on this device.';

  @override
  String get errorScannerFailed => 'The scanner could not be started.';

  @override
  String get errorCameraStartFailed => 'The camera could not be started.';

  @override
  String get errorCaptureFailed =>
      'The photo could not be captured. Please try again.';

  @override
  String get hydrationTodaysGoal => 'Today\'s goal';

  @override
  String get hydrationFreshDay => 'A fresh day';

  @override
  String get hydrationEmptyHint => 'Tap an amount to log your first drink';

  @override
  String hydrationOfTarget(String target) {
    return 'of $target';
  }

  @override
  String hydrationRemainingToGo(String amount) {
    return '$amount to go';
  }

  @override
  String get hydrationGoalComplete => 'Goal complete';

  @override
  String get hydrationAddWaterCta => '+ Add water';

  @override
  String hydrationJustLogged(String amount) {
    return '+$amount';
  }

  @override
  String get quickAdd => 'Quick add';

  @override
  String get todaysLogs => 'Today\'s logs';

  @override
  String get addWaterTitle => 'Add Water';

  @override
  String get logWaterButton => 'Log water';

  @override
  String largeAmountConfirmMessage(String amount) {
    return 'That\'s a large amount. Log $amount?';
  }

  @override
  String get addWaterDiscardTitle => 'Discard this amount?';

  @override
  String get discard => 'Discard';

  @override
  String get hydrationAmountUnitLabel => 'ml';

  @override
  String hydrationSummarySemantics(
    String total,
    String target,
    int percent,
    String remaining,
  ) {
    return 'Today\'s progress: $total of $target, $percent percent, $remaining to go';
  }

  @override
  String hydrationSummarySemanticsComplete(
    String total,
    String target,
    int percent,
  ) {
    return 'Today\'s progress: $total of $target, $percent percent, goal complete';
  }

  @override
  String quickAddChipSemantics(String amount) {
    return 'Add $amount';
  }

  @override
  String get errorHydrationStorage =>
      'We couldn\'t save that. Please try again.';
}

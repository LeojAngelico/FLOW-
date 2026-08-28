import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en'),
    Locale('fil'),
  ];

  /// App title, shown as the login header and OS task-switcher label
  ///
  /// In en, this message translates to:
  /// **'FLOW'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @middleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get middleNameLabel;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get loginEmailRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get loginPasswordRequired;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccount;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNoInfo.
  ///
  /// In en, this message translates to:
  /// **'No profile information available.'**
  String get profileNoInfo;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get profileMemberSince;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get profileLogoutConfirmMessage;

  /// No description provided for @profileLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get profileLoggingOut;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFilipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get languageFilipino;

  /// No description provided for @languageCebuano.
  ///
  /// In en, this message translates to:
  /// **'Cebuano'**
  String get languageCebuano;

  /// No description provided for @registrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registrationTitle;

  /// No description provided for @registrationUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registrationUsernameLabel;

  /// No description provided for @registrationButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registrationButton;

  /// No description provided for @registrationAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get registrationAlreadyHaveAccount;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully registered.'**
  String get registrationSuccessMessage;

  /// Default title shown on the Core QR scanner screen
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get qrScannerTitle;

  /// No description provided for @qrScannerInstruction.
  ///
  /// In en, this message translates to:
  /// **'Place the markers around the QR code to begin scanning'**
  String get qrScannerInstruction;

  /// No description provided for @qrScannerCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close scanner'**
  String get qrScannerCloseTooltip;

  /// No description provided for @qrScannerTorchOnTooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn on flashlight'**
  String get qrScannerTorchOnTooltip;

  /// No description provided for @qrScannerTorchOffTooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn off flashlight'**
  String get qrScannerTorchOffTooltip;

  /// No description provided for @qrScannerStartingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get qrScannerStartingCamera;

  /// No description provided for @qrScannerPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access needed'**
  String get qrScannerPermissionTitle;

  /// No description provided for @qrScannerPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access so you can scan QR codes.'**
  String get qrScannerPermissionMessage;

  /// No description provided for @qrScannerPermissionBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera access is turned off for this app. Turn it on in Settings to scan QR codes.'**
  String get qrScannerPermissionBlockedMessage;

  /// No description provided for @qrScannerPermissionRestrictedMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera access is restricted on this device, so scanning is unavailable.'**
  String get qrScannerPermissionRestrictedMessage;

  /// No description provided for @qrScannerAllowCameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access'**
  String get qrScannerAllowCameraAccess;

  /// No description provided for @qrScannerOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get qrScannerOpenSettings;

  /// Default title of the Core face capture screen
  ///
  /// In en, this message translates to:
  /// **'Face Capture'**
  String get faceCaptureTitle;

  /// No description provided for @faceCaptureCameraReady.
  ///
  /// In en, this message translates to:
  /// **'Camera Ready'**
  String get faceCaptureCameraReady;

  /// No description provided for @faceCaptureStartingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get faceCaptureStartingCamera;

  /// No description provided for @faceCaptureSwitchCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get faceCaptureSwitchCameraTooltip;

  /// No description provided for @faceCaptureLightingHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure your face is well lit'**
  String get faceCaptureLightingHint;

  /// No description provided for @faceCaptureGuidancePositionFace.
  ///
  /// In en, this message translates to:
  /// **'Position your face inside the frame'**
  String get faceCaptureGuidancePositionFace;

  /// No description provided for @faceCaptureGuidanceMultipleFaces.
  ///
  /// In en, this message translates to:
  /// **'Make sure only one face is visible'**
  String get faceCaptureGuidanceMultipleFaces;

  /// No description provided for @faceCaptureGuidanceMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move a little closer'**
  String get faceCaptureGuidanceMoveCloser;

  /// No description provided for @faceCaptureGuidanceMoveBack.
  ///
  /// In en, this message translates to:
  /// **'Move slightly back'**
  String get faceCaptureGuidanceMoveBack;

  /// No description provided for @faceCaptureGuidanceCenterFace.
  ///
  /// In en, this message translates to:
  /// **'Center your face'**
  String get faceCaptureGuidanceCenterFace;

  /// No description provided for @faceCaptureGuidanceLookStraight.
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera'**
  String get faceCaptureGuidanceLookStraight;

  /// No description provided for @faceCaptureGuidanceTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn your head to your left'**
  String get faceCaptureGuidanceTurnLeft;

  /// No description provided for @faceCaptureGuidanceTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn your head to your right'**
  String get faceCaptureGuidanceTurnRight;

  /// No description provided for @faceCaptureGuidanceSmile.
  ///
  /// In en, this message translates to:
  /// **'Give us a smile'**
  String get faceCaptureGuidanceSmile;

  /// No description provided for @faceCaptureGuidanceHoldStill.
  ///
  /// In en, this message translates to:
  /// **'Hold still...'**
  String get faceCaptureGuidanceHoldStill;

  /// Shown while the user holds the pose, with the whole seconds left before the photo is taken
  ///
  /// In en, this message translates to:
  /// **'Hold still... {seconds}'**
  String faceCaptureGuidanceHoldStillCountdown(int seconds);

  /// No description provided for @faceCaptureGuidanceCapturing.
  ///
  /// In en, this message translates to:
  /// **'Capturing...'**
  String get faceCaptureGuidanceCapturing;

  /// No description provided for @faceCaptureGuidanceCaptured.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get faceCaptureGuidanceCaptured;

  /// No description provided for @faceCaptureReadinessGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get faceCaptureReadinessGetReady;

  /// No description provided for @faceCaptureReadinessKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get faceCaptureReadinessKeepGoing;

  /// No description provided for @faceCaptureReadinessAlmostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get faceCaptureReadinessAlmostThere;

  /// No description provided for @faceCaptureReadinessReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get faceCaptureReadinessReady;

  /// No description provided for @faceCaptureStatusFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get faceCaptureStatusFace;

  /// No description provided for @faceCaptureStatusPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get faceCaptureStatusPosition;

  /// No description provided for @faceCaptureStatusOrientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get faceCaptureStatusOrientation;

  /// No description provided for @faceCaptureStatusStability.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get faceCaptureStatusStability;

  /// No description provided for @faceCaptureStatusSmile.
  ///
  /// In en, this message translates to:
  /// **'Smile'**
  String get faceCaptureStatusSmile;

  /// No description provided for @faceCaptureStatusDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get faceCaptureStatusDetected;

  /// No description provided for @faceCaptureStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get faceCaptureStatusGood;

  /// No description provided for @faceCaptureStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get faceCaptureStatusWaiting;

  /// No description provided for @faceCaptureStatusNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get faceCaptureStatusNotApplicable;

  /// No description provided for @faceOrientationFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get faceOrientationFront;

  /// No description provided for @faceOrientationLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get faceOrientationLeft;

  /// No description provided for @faceOrientationRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get faceOrientationRight;

  /// No description provided for @faceCaptureReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Take your selfie'**
  String get faceCaptureReviewTitle;

  /// No description provided for @faceCaptureReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure to use a bright photo'**
  String get faceCaptureReviewSubtitle;

  /// No description provided for @faceCaptureReviewCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get faceCaptureReviewCompleted;

  /// No description provided for @faceCaptureReviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get faceCaptureReviewRequired;

  /// No description provided for @faceCaptureReviewOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get faceCaptureReviewOptional;

  /// No description provided for @faceCaptureReviewTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for a good photo'**
  String get faceCaptureReviewTipsTitle;

  /// No description provided for @faceCaptureReviewTipLighting.
  ///
  /// In en, this message translates to:
  /// **'Use a well-lit area'**
  String get faceCaptureReviewTipLighting;

  /// No description provided for @faceCaptureReviewTipAccessories.
  ///
  /// In en, this message translates to:
  /// **'Remove glasses or accessories'**
  String get faceCaptureReviewTipAccessories;

  /// No description provided for @faceCaptureReviewTipFrame.
  ///
  /// In en, this message translates to:
  /// **'Keep your face within the frame'**
  String get faceCaptureReviewTipFrame;

  /// No description provided for @faceCaptureReviewContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get faceCaptureReviewContinue;

  /// No description provided for @faceCaptureReviewRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get faceCaptureReviewRetake;

  /// No description provided for @imageViewerCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close image'**
  String get imageViewerCloseTooltip;

  /// Position of the visible image within a gallery
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String imageViewerCounter(int current, int total);

  /// Spoken form of the image counter
  ///
  /// In en, this message translates to:
  /// **'Image {current} of {total}'**
  String imageViewerCounterSemantics(int current, int total);

  /// No description provided for @imageViewerImageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageViewerImageSemantics;

  /// No description provided for @imageViewerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load image.'**
  String get imageViewerLoadFailed;

  /// No description provided for @signaturePadTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign your signature below'**
  String get signaturePadTitle;

  /// No description provided for @signaturePadHint.
  ///
  /// In en, this message translates to:
  /// **'Sign here'**
  String get signaturePadHint;

  /// No description provided for @signaturePadClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get signaturePadClear;

  /// No description provided for @signaturePadComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get signaturePadComplete;

  /// No description provided for @signaturePadCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close signature pad'**
  String get signaturePadCloseTooltip;

  /// No description provided for @signaturePadAreaSemantics.
  ///
  /// In en, this message translates to:
  /// **'Signature drawing area'**
  String get signaturePadAreaSemantics;

  /// No description provided for @signaturePadDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard signature?'**
  String get signaturePadDiscardTitle;

  /// No description provided for @signaturePadDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'Your signature will not be saved.'**
  String get signaturePadDiscardMessage;

  /// No description provided for @signaturePadDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get signaturePadDiscardConfirm;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNoInternet;

  /// No description provided for @errorServerGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server.'**
  String get errorServerGeneric;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid account credentials.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @errorInvalidRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request.'**
  String get errorInvalidRequest;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input.'**
  String get errorInvalidInput;

  /// No description provided for @errorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get errorTitleRequired;

  /// No description provided for @errorDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required.'**
  String get errorDescriptionRequired;

  /// No description provided for @errorPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'A photo is required.'**
  String get errorPhotoRequired;

  /// No description provided for @errorLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Current location is required.'**
  String get errorLocationRequired;

  /// No description provided for @errorCameraGalleryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to access the camera or gallery.'**
  String get errorCameraGalleryUnavailable;

  /// No description provided for @errorLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Please enable them and try again.'**
  String get errorLocationServicesDisabled;

  /// No description provided for @errorLocationUnableToDetermine.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine your current location.'**
  String get errorLocationUnableToDetermine;

  /// No description provided for @errorLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied.'**
  String get errorLocationPermissionDenied;

  /// No description provided for @errorLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission was permanently denied.'**
  String get errorLocationPermissionDeniedForever;

  /// No description provided for @errorCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to access the camera.'**
  String get errorCameraUnavailable;

  /// No description provided for @errorScannerUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Scanning is not supported on this device.'**
  String get errorScannerUnsupported;

  /// No description provided for @errorScannerFailed.
  ///
  /// In en, this message translates to:
  /// **'The scanner could not be started.'**
  String get errorScannerFailed;

  /// No description provided for @errorCameraStartFailed.
  ///
  /// In en, this message translates to:
  /// **'The camera could not be started.'**
  String get errorCameraStartFailed;

  /// No description provided for @errorCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be captured. Please try again.'**
  String get errorCaptureFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

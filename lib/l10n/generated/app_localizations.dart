import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navAwards.
  ///
  /// In en, this message translates to:
  /// **'Awards'**
  String get navAwards;

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

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

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

  /// APP-01 dashboard, CPY-099 — header above the hydration summary once at least one entry exists today.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal'**
  String get hydrationTodaysGoal;

  /// APP-01 dashboard, CPY-097 — replaces hydrationTodaysGoal as the header while today has zero entries.
  ///
  /// In en, this message translates to:
  /// **'A fresh day'**
  String get hydrationFreshDay;

  /// APP-01 dashboard, CPY-101 — shown under the numbers while today has zero entries.
  ///
  /// In en, this message translates to:
  /// **'Tap an amount to log your first drink'**
  String get hydrationEmptyHint;

  /// APP-01 dashboard, CPY-092 — shown under today's total, e.g. 'of 2 L'.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String hydrationOfTarget(String target);

  /// APP-01 dashboard, CPY-093 — remaining ml/L until today's target; shown instead of hydrationGoalComplete before the goal is met.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String hydrationRemainingToGo(String amount);

  /// APP-01 dashboard, CPY-094 — shown instead of hydrationRemainingToGo once totalMl >= targetMl.
  ///
  /// In en, this message translates to:
  /// **'Goal complete'**
  String get hydrationGoalComplete;

  /// APP-01 dashboard, CPY-100 — navigates to /home/add for a custom amount.
  ///
  /// In en, this message translates to:
  /// **'+ Add water'**
  String get hydrationAddWaterCta;

  /// APP-01 dashboard, CPY-106 — transient feedback shown near the summary right after a successful log.
  ///
  /// In en, this message translates to:
  /// **'+{amount}'**
  String hydrationJustLogged(String amount);

  /// APP-01 dashboard, CPY-109 — header above the quick-add chip row.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// APP-01 dashboard, CPY-110 — header above today's entries list.
  ///
  /// In en, this message translates to:
  /// **'Today\'s logs'**
  String get todaysLogs;

  /// APP-02, CPY-102 — /home/add screen title.
  ///
  /// In en, this message translates to:
  /// **'Add Water'**
  String get addWaterTitle;

  /// APP-02, CPY-103 — the custom-amount screen's submit CTA, and the large-amount confirm dialog's confirm action.
  ///
  /// In en, this message translates to:
  /// **'Log water'**
  String get logWaterButton;

  /// APP-02, CPY-104 — confirm dialog shown before logging a custom amount above 1,000ml (FR-024).
  ///
  /// In en, this message translates to:
  /// **'That\'s a large amount. Log {amount}?'**
  String largeAmountConfirmMessage(String amount);

  /// APP-02, CPY-108 — discard-on-back confirm dialog title, shown once the amount has changed from 0.
  ///
  /// In en, this message translates to:
  /// **'Discard this amount?'**
  String get addWaterDiscardTitle;

  /// APP-02 — the destructive action on the discard-on-back confirm dialog.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// APP-02 — unit caption under the custom-amount stepper/text field. Not a CPY-* code in the copy spec; added because FlowTextField carries no built-in unit affordance and CLAUDE.md forbids a hardcoded user-facing string.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get hydrationAmountUnitLabel;

  /// APP-01 accessibility label merging the hydration summary (glass + all four numbers) into one semantics node, per FR-030/FR-031. CMP-47 HydrationGlass excludes itself from semantics; hydration_summary.dart reads this instead of letting a screen reader walk each number individually.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress: {total} of {target}, {percent} percent, {remaining} to go'**
  String hydrationSummarySemantics(
    String total,
    String target,
    int percent,
    String remaining,
  );

  /// Same as hydrationSummarySemantics, once the goal is met (FR-033) — replaces the remaining-ml clause with completion.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress: {total} of {target}, {percent} percent, goal complete'**
  String hydrationSummarySemanticsComplete(
    String total,
    String target,
    int percent,
  );

  /// APP-01 accessibility label for each QuickAddChip on /home — overrides CMP-04's own visible-text-derived label so a screen reader announces the action ('Add 250 ml'), not just the amount.
  ///
  /// In en, this message translates to:
  /// **'Add {amount}'**
  String quickAddChipSemantics(String amount);

  /// APP-01/APP-02 — shown inline (never replacing the displayed total) when a hydration read or write fails with a StorageFailure.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save that. Please try again.'**
  String get errorHydrationStorage;

  /// Onboarding, CPY-021 — the primary CTA on every ONB-03 to ONB-06 form screen (ONB-07's CTA has its own Accept/Adjust copy).
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Onboarding, CPY-030 — CMP-09 StepHeader's caller-supplied step label, ONB-03 to ONB-07.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStepLabel(int step, int total);

  /// ONB-02, CPY-010 — the welcome screen's pixel-title headline.
  ///
  /// In en, this message translates to:
  /// **'Meet Bloop, your hydration companion'**
  String get onboardingWelcomeHeadline;

  /// ONB-02, CPY-011 — the welcome screen's subhead, under the headline.
  ///
  /// In en, this message translates to:
  /// **'FLOW turns drinking water into a small daily game — track it, watch your progress, and keep a streak worth keeping.'**
  String get onboardingWelcomeSubhead;

  /// ONB-02 — first Pillar (CMP-08) title, icon-droplet.
  ///
  /// In en, this message translates to:
  /// **'Hydrate'**
  String get onboardingWelcomePillarHydrateTitle;

  /// ONB-02 — first Pillar description.
  ///
  /// In en, this message translates to:
  /// **'Log a drink in seconds, any time of day.'**
  String get onboardingWelcomePillarHydrateDescription;

  /// ONB-02 — second Pillar (CMP-08) title, icon-chart.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get onboardingWelcomePillarProgressTitle;

  /// ONB-02 — second Pillar description.
  ///
  /// In en, this message translates to:
  /// **'Watch your daily and weekly trends fill in.'**
  String get onboardingWelcomePillarProgressDescription;

  /// ONB-02 — third Pillar (CMP-08) title, icon-lightbulb.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get onboardingWelcomePillarLearnTitle;

  /// ONB-02 — third Pillar description.
  ///
  /// In en, this message translates to:
  /// **'Pick up a hydration fact every day.'**
  String get onboardingWelcomePillarLearnDescription;

  /// ONB-02, CPY-018 — the trust/privacy line above the CTA (08 §10: no data leaves the device).
  ///
  /// In en, this message translates to:
  /// **'Everything you enter stays on this device.'**
  String get onboardingWelcomeTrustLine;

  /// ONB-02, CPY-019 — the welcome screen's CtaSection primary label.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingWelcomeCta;

  /// ONB-03 headline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get onboardingBasicsHeadline;

  /// ONB-03 subhead.
  ///
  /// In en, this message translates to:
  /// **'A few basics help us suggest a target that actually fits you.'**
  String get onboardingBasicsSubhead;

  /// ONB-03 — the name field's label.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get onboardingBasicsNameLabel;

  /// ONB-03, CPY-045 — helper text under the optional name field.
  ///
  /// In en, this message translates to:
  /// **'Add a name if you\'d like FLOW to greet you by it.'**
  String get onboardingBasicsNameOptionalHelper;

  /// ONB-03 — the age field's label.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingBasicsAgeLabel;

  /// ONB-03 — the sex SegmentedChoice's label.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get onboardingBasicsSexLabel;

  /// ONB-03 — Sex.female segment label.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingBasicsSexFemale;

  /// ONB-03 — Sex.male segment label.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingBasicsSexMale;

  /// ONB-03 — Sex.preferNotToSay segment label.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get onboardingBasicsSexPreferNotToSay;

  /// ONB-03, CPY-039 — helper text under the sex SegmentedChoice.
  ///
  /// In en, this message translates to:
  /// **'We only use this to fine-tune your suggested target.'**
  String get onboardingBasicsSexHelper;

  /// ONB-04 headline.
  ///
  /// In en, this message translates to:
  /// **'What\'s your weight?'**
  String get onboardingWeightHeadline;

  /// ONB-04, CPY-042 — reused verbatim as the prefilled-weight estimate marker per the workplan's § Open product questions.
  ///
  /// In en, this message translates to:
  /// **'An estimate is fine — you can change it any time.'**
  String get onboardingWeightReassurance;

  /// ONB-04 — unit label next to the weight StatDisplay/text field. Metric-only this pass (Decisions #8).
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get onboardingWeightUnitLabel;

  /// ONB-05, CPY-049 — headline.
  ///
  /// In en, this message translates to:
  /// **'How active is your day-to-day?'**
  String get onboardingActivityHeadline;

  /// ONB-05 — subhead, under the headline.
  ///
  /// In en, this message translates to:
  /// **'Pick the one that matches most days.'**
  String get onboardingActivitySubhead;

  /// ONB-05, CPY-050 — ChoiceCard combined title/descriptor, split at '·' by activity_page.dart.
  ///
  /// In en, this message translates to:
  /// **'Sedentary · Mostly sitting, little movement'**
  String get onboardingActivitySedentary;

  /// ONB-05, CPY-051.
  ///
  /// In en, this message translates to:
  /// **'Lightly active · Short walks or light chores'**
  String get onboardingActivityLight;

  /// ONB-05, CPY-052.
  ///
  /// In en, this message translates to:
  /// **'Moderately active · Exercise a few times a week'**
  String get onboardingActivityModerate;

  /// ONB-05, CPY-053.
  ///
  /// In en, this message translates to:
  /// **'Highly active · Intense exercise most days'**
  String get onboardingActivityHigh;

  /// ONB-05, CPY-054.
  ///
  /// In en, this message translates to:
  /// **'Athlete · Daily intense training'**
  String get onboardingActivityAthlete;

  /// ONB-06, CPY-060 — headline.
  ///
  /// In en, this message translates to:
  /// **'What\'s your everyday environment like?'**
  String get onboardingEnvironmentHeadline;

  /// ONB-06, CPY-061 — subhead.
  ///
  /// In en, this message translates to:
  /// **'This affects how much water you naturally lose to heat.'**
  String get onboardingEnvironmentSubhead;

  /// ONB-06 — Environment.temperate IconChoiceTile label.
  ///
  /// In en, this message translates to:
  /// **'Temperate'**
  String get onboardingEnvironmentTemperate;

  /// ONB-06 — Environment.warm IconChoiceTile label.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get onboardingEnvironmentWarm;

  /// ONB-06 — Environment.hot IconChoiceTile label.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get onboardingEnvironmentHot;

  /// ONB-06 — Environment.veryHot IconChoiceTile label.
  ///
  /// In en, this message translates to:
  /// **'Very hot'**
  String get onboardingEnvironmentVeryHot;

  /// ONB-06 — section header above the special-circumstance CheckRows.
  ///
  /// In en, this message translates to:
  /// **'Do any of these apply to you?'**
  String get onboardingCircumstancesLabel;

  /// ONB-06 — SpecialCircumstance.pregnancy CheckRow label.
  ///
  /// In en, this message translates to:
  /// **'Pregnant'**
  String get onboardingCircumstancePregnancy;

  /// ONB-06 — SpecialCircumstance.breastfeeding CheckRow label.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get onboardingCircumstanceBreastfeeding;

  /// ONB-06 — SpecialCircumstance.medicalCondition CheckRow label.
  ///
  /// In en, this message translates to:
  /// **'A medical condition that affects hydration'**
  String get onboardingCircumstanceMedicalCondition;

  /// ONB-06 — SpecialCircumstance.other CheckRow label.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get onboardingCircumstanceOther;

  /// ONB-06, CPY-071 — the conditional InfoCard shown once any special circumstance is checked (FR-011).
  ///
  /// In en, this message translates to:
  /// **'We\'ll flag this on your target screen. It won\'t change the number, and it\'s never shared off this device.'**
  String get onboardingCircumstanceNotice;

  /// ONB-07, CPY-072 — binding wording per the workplan (do not paraphrase). The 09-content-copy-spec.md source this id names is not present in this repository, so this exact sentence is this implementer's construction honouring the plan's constraints (no 'must'/'need to'/'required'/'minimum', no urgency) rather than a verified verbatim copy — flagged for the developer to check against the real spec.
  ///
  /// In en, this message translates to:
  /// **'This looks like a good starting point for you'**
  String get onboardingTargetHeadline;

  /// ONB-07 — TargetHero's eyebrow label, both viewing and editing modes.
  ///
  /// In en, this message translates to:
  /// **'Your daily target'**
  String get onboardingTargetEyebrow;

  /// ONB-07 accessibility string — merges TargetHero's eyebrow and value into one semantics node in viewing mode (manual QA item 12), matching the hydration summary precedent.
  ///
  /// In en, this message translates to:
  /// **'Your suggested daily target: {amountMl} millilitres'**
  String onboardingTargetHeroSemantics(int amountMl);

  /// ONB-07, CPY-073 — the glasses anchor line under the hero.
  ///
  /// In en, this message translates to:
  /// **'About {glasses} glasses a day (1 glass = 250 ml)'**
  String onboardingTargetGlassesAnchor(int glasses);

  /// ONB-07, CPY-075 — tappable link opening OVL-10 (calculation_method_sheet.dart).
  ///
  /// In en, this message translates to:
  /// **'See how we calculated this'**
  String get onboardingTargetSeeCalculation;

  /// ONB-07, CPY-074 — non-blocking caution shown above 3,500 ml (FR-014). Never disables Continue.
  ///
  /// In en, this message translates to:
  /// **'That\'s on the higher side — make sure it feels right for you.'**
  String get onboardingTargetHighCaution;

  /// ONB-07, CPY-070 — binding wording per the workplan, rendered above the fold whenever any special circumstance is checked (FR-011). The 09-content-copy-spec.md source is not present in this repository, so this exact sentence is this implementer's construction rather than a verified verbatim copy — flagged for the developer to check against the real spec.
  ///
  /// In en, this message translates to:
  /// **'You mentioned something that can change how much water is right for you. It may be worth checking in with a healthcare professional.'**
  String get onboardingTargetProfessionalNotice;

  /// ONB-07, CPY-077 — CtaSection primary label while TargetMode.suggested.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get onboardingTargetAccept;

  /// ONB-07, CPY-078 — CtaSection secondary label while TargetMode.suggested.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get onboardingTargetAdjust;

  /// ONB-07, CPY-079 — instructional line shown while editing/edited.
  ///
  /// In en, this message translates to:
  /// **'Use the slider or the +/- buttons to fine-tune your target.'**
  String get onboardingTargetEditingInstruction;

  /// ONB-07, CPY-080 — CtaSection secondary label while editing/edited; reverts to the calculator's suggestion.
  ///
  /// In en, this message translates to:
  /// **'Use suggested amount'**
  String get onboardingTargetRevertToSuggested;

  /// ONB-07 — defensive message shown only if this screen is somehow reached with an incomplete draft; the router never allows this in practice.
  ///
  /// In en, this message translates to:
  /// **'Go back and finish the previous steps to see your target.'**
  String get onboardingTargetIncompleteDraft;

  /// OVL-10, CPY-081 — sheet title.
  ///
  /// In en, this message translates to:
  /// **'How we calculated this'**
  String get onboardingCalcSheetTitle;

  /// OVL-10 — display name for calculationMethodId == 'reference_intake_v1' (workplan Decisions #19).
  ///
  /// In en, this message translates to:
  /// **'Reference daily intake'**
  String get onboardingCalcMethodReferenceIntake;

  /// OVL-10, CPY-082 — breakdown line label for BreakdownLine.labelId == 'baseline'.
  ///
  /// In en, this message translates to:
  /// **'Starting point for your age and sex'**
  String get onboardingCalcBaseline;

  /// OVL-10, CPY-083 — breakdown line label for labelId == 'weightAdjustment'.
  ///
  /// In en, this message translates to:
  /// **'Weight adjustment'**
  String get onboardingCalcWeightAdjustment;

  /// OVL-10 — breakdown line label for labelId == 'activity'; {level} is the activity level's localized display name.
  ///
  /// In en, this message translates to:
  /// **'Activity ({level})'**
  String onboardingCalcActivity(String level);

  /// OVL-10 — breakdown line label for labelId == 'environment'; {level} is the environment's localized display name.
  ///
  /// In en, this message translates to:
  /// **'Environment ({level})'**
  String onboardingCalcEnvironment(String level);

  /// OVL-10 — subtotal line label for labelId == 'totalWaterSubtotal'.
  ///
  /// In en, this message translates to:
  /// **'Total water'**
  String get onboardingCalcTotalWaterSubtotal;

  /// OVL-10 — breakdown line label for labelId == 'foodWaterDeduction'.
  ///
  /// In en, this message translates to:
  /// **'From food and other drinks'**
  String get onboardingCalcFoodWaterDeduction;

  /// OVL-10 — subtotal line label for labelId == 'drinkingTargetSubtotal'.
  ///
  /// In en, this message translates to:
  /// **'Drinking water target'**
  String get onboardingCalcDrinkingTargetSubtotal;

  /// OVL-10, CPY-085 — assumption line for assumptions[] id 'foodWaterFraction'.
  ///
  /// In en, this message translates to:
  /// **'About a quarter of your total water need is assumed to come from food and other drinks.'**
  String get onboardingCalcAssumptionFoodWaterFraction;

  /// OVL-10, CPY-086 — assumption line for assumptions[] id 'weightAdjustmentClamped', shown only when it actually happened.
  ///
  /// In en, this message translates to:
  /// **'Your weight adjustment was capped to keep this estimate realistic.'**
  String get onboardingCalcAssumptionWeightAdjustmentClamped;

  /// OVL-10, CPY-087 — assumption line for assumptions[] id 'resultClamped', shown only when it actually happened.
  ///
  /// In en, this message translates to:
  /// **'Your target was kept within a safe, realistic range.'**
  String get onboardingCalcAssumptionResultClamped;

  /// OVL-10, CPY-089 — disclaimer for disclaimer id 'referenceIntakeDisclaimer'; also reused verbatim on ONB-07 (CPY-076) so both screens agree on the wording.
  ///
  /// In en, this message translates to:
  /// **'This is a general estimate, not medical advice. Everyone\'s needs are a little different.'**
  String get onboardingCalcDisclaimer;

  /// OVL-10, CPY-028 — the sheet's dismiss CTA.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get onboardingCalcGotIt;

  /// ONB-08, CPY-120 — top-right Skip control (FlowTextButton); writes reminder_settings.enabled = false and still completes onboarding (FR-017).
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingRemindersSkip;

  /// ONB-08, CPY-121 — headline.
  ///
  /// In en, this message translates to:
  /// **'When should we remind you?'**
  String get onboardingRemindersHeadline;

  /// ONB-08, CPY-122 — shown under the time rows when end <= start; disables the CTA.
  ///
  /// In en, this message translates to:
  /// **'End time must be after the start time.'**
  String get onboardingRemindersWindowError;

  /// ONB-08 — SettingRow label opening the native time picker for the window start.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get onboardingRemindersStartLabel;

  /// ONB-08 — SettingRow label opening the native time picker for the window end.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get onboardingRemindersEndLabel;

  /// ONB-08 — SettingRow label opening the interval bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Remind me every'**
  String get onboardingRemindersIntervalLabel;

  /// ONB-08 — one interval sheet row's label and the interval SettingRow's current value, e.g. '120 min'.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String onboardingRemindersIntervalOption(int minutes);

  /// ONB-08 — label above the seven DayToggles.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get onboardingRemindersWeekdaysLabel;

  /// ONB-08 — Monday's DayToggle single-letter label.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get onboardingRemindersDayLetterMon;

  /// ONB-08 — Tuesday's DayToggle single-letter label.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get onboardingRemindersDayLetterTue;

  /// ONB-08 — Wednesday's DayToggle single-letter label.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get onboardingRemindersDayLetterWed;

  /// ONB-08 — Thursday's DayToggle single-letter label.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get onboardingRemindersDayLetterThu;

  /// ONB-08 — Friday's DayToggle single-letter label.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get onboardingRemindersDayLetterFri;

  /// ONB-08 — Saturday's DayToggle single-letter label.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get onboardingRemindersDayLetterSat;

  /// ONB-08 — Sunday's DayToggle single-letter label.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get onboardingRemindersDayLetterSun;

  /// ONB-08 — Monday's DayToggle accessibility label (overrides the visible single letter, matching quickAddChipSemantics' precedent).
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get onboardingRemindersDayNameMon;

  /// ONB-08 — Tuesday's DayToggle accessibility label.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get onboardingRemindersDayNameTue;

  /// ONB-08 — Wednesday's DayToggle accessibility label.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get onboardingRemindersDayNameWed;

  /// ONB-08 — Thursday's DayToggle accessibility label.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get onboardingRemindersDayNameThu;

  /// ONB-08 — Friday's DayToggle accessibility label.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get onboardingRemindersDayNameFri;

  /// ONB-08 — Saturday's DayToggle accessibility label.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get onboardingRemindersDayNameSat;

  /// ONB-08 — Sunday's DayToggle accessibility label.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get onboardingRemindersDayNameSun;

  /// ONB-08, CPY-126 — the live preview InfoCard, recomputed from ReminderPreferences.reminderMinutes() (BR-30) on every window/interval change.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get {count} reminders today: {times}'**
  String onboardingRemindersPreviewCount(int count, String times);

  /// ONB-08, CPY-127 — small caption under the live preview.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get onboardingRemindersPreviewNote;

  /// ONB-08, CPY-128 — CtaSection primary label; calls RemindersNotifier.submit(enabled: true).
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders'**
  String get onboardingRemindersCta;

  /// ONB-08 — shown inline when CompleteOnboarding returns a StorageFailure; the draft and every earlier answer stay intact (acceptance criteria: 'keeps the user on ONB-08 with the draft intact').
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your profile. Please try again.'**
  String get onboardingErrorStorage;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

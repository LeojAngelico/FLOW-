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

  @override
  String get continueButton => 'Continue';

  @override
  String onboardingStepLabel(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingWelcomeHeadline =>
      'Meet Bloop, your hydration companion';

  @override
  String get onboardingWelcomeSubhead =>
      'FLOW turns drinking water into a small daily game — track it, watch your progress, and keep a streak worth keeping.';

  @override
  String get onboardingWelcomePillarHydrateTitle => 'Hydrate';

  @override
  String get onboardingWelcomePillarHydrateDescription =>
      'Log a drink in seconds, any time of day.';

  @override
  String get onboardingWelcomePillarProgressTitle => 'Progress';

  @override
  String get onboardingWelcomePillarProgressDescription =>
      'Watch your daily and weekly trends fill in.';

  @override
  String get onboardingWelcomePillarLearnTitle => 'Learn';

  @override
  String get onboardingWelcomePillarLearnDescription =>
      'Pick up a hydration fact every day.';

  @override
  String get onboardingWelcomeTrustLine =>
      'Everything you enter stays on this device.';

  @override
  String get onboardingWelcomeCta => 'Get started';

  @override
  String get onboardingBasicsHeadline => 'Let\'s get to know you';

  @override
  String get onboardingBasicsSubhead =>
      'A few basics help us suggest a target that actually fits you.';

  @override
  String get onboardingBasicsNameLabel => 'Name (optional)';

  @override
  String get onboardingBasicsNameOptionalHelper =>
      'Add a name if you\'d like FLOW to greet you by it.';

  @override
  String get onboardingBasicsAgeLabel => 'Age';

  @override
  String get onboardingBasicsSexLabel => 'Sex';

  @override
  String get onboardingBasicsSexFemale => 'Female';

  @override
  String get onboardingBasicsSexMale => 'Male';

  @override
  String get onboardingBasicsSexPreferNotToSay => 'Prefer not to say';

  @override
  String get onboardingBasicsSexHelper =>
      'We only use this to fine-tune your suggested target.';

  @override
  String get onboardingWeightHeadline => 'What\'s your weight?';

  @override
  String get onboardingWeightReassurance =>
      'An estimate is fine — you can change it any time.';

  @override
  String get onboardingWeightUnitLabel => 'kg';

  @override
  String get onboardingActivityHeadline => 'How active is your day-to-day?';

  @override
  String get onboardingActivitySubhead =>
      'Pick the one that matches most days.';

  @override
  String get onboardingActivitySedentary =>
      'Sedentary · Mostly sitting, little movement';

  @override
  String get onboardingActivityLight =>
      'Lightly active · Short walks or light chores';

  @override
  String get onboardingActivityModerate =>
      'Moderately active · Exercise a few times a week';

  @override
  String get onboardingActivityHigh =>
      'Highly active · Intense exercise most days';

  @override
  String get onboardingActivityAthlete => 'Athlete · Daily intense training';

  @override
  String get onboardingEnvironmentHeadline =>
      'What\'s your everyday environment like?';

  @override
  String get onboardingEnvironmentSubhead =>
      'This affects how much water you naturally lose to heat.';

  @override
  String get onboardingEnvironmentTemperate => 'Temperate';

  @override
  String get onboardingEnvironmentWarm => 'Warm';

  @override
  String get onboardingEnvironmentHot => 'Hot';

  @override
  String get onboardingEnvironmentVeryHot => 'Very hot';

  @override
  String get onboardingCircumstancesLabel => 'Do any of these apply to you?';

  @override
  String get onboardingCircumstancePregnancy => 'Pregnant';

  @override
  String get onboardingCircumstanceBreastfeeding => 'Breastfeeding';

  @override
  String get onboardingCircumstanceMedicalCondition =>
      'A medical condition that affects hydration';

  @override
  String get onboardingCircumstanceOther => 'Something else';

  @override
  String get onboardingCircumstanceNotice =>
      'We\'ll flag this on your target screen. It won\'t change the number, and it\'s never shared off this device.';

  @override
  String get onboardingTargetHeadline =>
      'This looks like a good starting point for you';

  @override
  String get onboardingTargetEyebrow => 'Your daily target';

  @override
  String onboardingTargetHeroSemantics(int amountMl) {
    return 'Your suggested daily target: $amountMl millilitres';
  }

  @override
  String onboardingTargetGlassesAnchor(int glasses) {
    return 'About $glasses glasses a day (1 glass = 250 ml)';
  }

  @override
  String get onboardingTargetSeeCalculation => 'See how we calculated this';

  @override
  String get onboardingTargetHighCaution =>
      'That\'s on the higher side — make sure it feels right for you.';

  @override
  String get onboardingTargetProfessionalNotice =>
      'You mentioned something that can change how much water is right for you. It may be worth checking in with a healthcare professional.';

  @override
  String get onboardingTargetAccept => 'Accept';

  @override
  String get onboardingTargetAdjust => 'Adjust';

  @override
  String get onboardingTargetEditingInstruction =>
      'Use the slider or the +/- buttons to fine-tune your target.';

  @override
  String get onboardingTargetRevertToSuggested => 'Use suggested amount';

  @override
  String get onboardingTargetIncompleteDraft =>
      'Go back and finish the previous steps to see your target.';

  @override
  String get onboardingCalcSheetTitle => 'How we calculated this';

  @override
  String get onboardingCalcMethodReferenceIntake => 'Reference daily intake';

  @override
  String get onboardingCalcBaseline => 'Starting point for your age and sex';

  @override
  String get onboardingCalcWeightAdjustment => 'Weight adjustment';

  @override
  String onboardingCalcActivity(String level) {
    return 'Activity ($level)';
  }

  @override
  String onboardingCalcEnvironment(String level) {
    return 'Environment ($level)';
  }

  @override
  String get onboardingCalcTotalWaterSubtotal => 'Total water';

  @override
  String get onboardingCalcFoodWaterDeduction => 'From food and other drinks';

  @override
  String get onboardingCalcDrinkingTargetSubtotal => 'Drinking water target';

  @override
  String get onboardingCalcAssumptionFoodWaterFraction =>
      'About a quarter of your total water need is assumed to come from food and other drinks.';

  @override
  String get onboardingCalcAssumptionWeightAdjustmentClamped =>
      'Your weight adjustment was capped to keep this estimate realistic.';

  @override
  String get onboardingCalcAssumptionResultClamped =>
      'Your target was kept within a safe, realistic range.';

  @override
  String get onboardingCalcDisclaimer =>
      'This is a general estimate, not medical advice. Everyone\'s needs are a little different.';

  @override
  String get onboardingCalcGotIt => 'Got it';

  @override
  String get onboardingRemindersSkip => 'Skip';

  @override
  String get onboardingRemindersHeadline => 'When should we remind you?';

  @override
  String get onboardingRemindersWindowError =>
      'End time must be after the start time.';

  @override
  String get onboardingRemindersStartLabel => 'Start time';

  @override
  String get onboardingRemindersEndLabel => 'End time';

  @override
  String get onboardingRemindersIntervalLabel => 'Remind me every';

  @override
  String onboardingRemindersIntervalOption(int minutes) {
    return '$minutes min';
  }

  @override
  String get onboardingRemindersWeekdaysLabel => 'Active days';

  @override
  String get onboardingRemindersDayLetterMon => 'M';

  @override
  String get onboardingRemindersDayLetterTue => 'T';

  @override
  String get onboardingRemindersDayLetterWed => 'W';

  @override
  String get onboardingRemindersDayLetterThu => 'T';

  @override
  String get onboardingRemindersDayLetterFri => 'F';

  @override
  String get onboardingRemindersDayLetterSat => 'S';

  @override
  String get onboardingRemindersDayLetterSun => 'S';

  @override
  String get onboardingRemindersDayNameMon => 'Monday';

  @override
  String get onboardingRemindersDayNameTue => 'Tuesday';

  @override
  String get onboardingRemindersDayNameWed => 'Wednesday';

  @override
  String get onboardingRemindersDayNameThu => 'Thursday';

  @override
  String get onboardingRemindersDayNameFri => 'Friday';

  @override
  String get onboardingRemindersDayNameSat => 'Saturday';

  @override
  String get onboardingRemindersDayNameSun => 'Sunday';

  @override
  String onboardingRemindersPreviewCount(int count, String times) {
    return 'You\'ll get $count reminders today: $times';
  }

  @override
  String get onboardingRemindersPreviewNote =>
      'You can change this anytime in Settings.';

  @override
  String get onboardingRemindersCta => 'Turn on reminders';

  @override
  String get onboardingErrorStorage =>
      'We couldn\'t save your profile. Please try again.';
}

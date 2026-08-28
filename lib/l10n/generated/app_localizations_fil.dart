// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appTitle => 'FLOW';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get retry => 'Subukan Muli';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get edit => 'I-edit';

  @override
  String get delete => 'Tanggalin';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get firstNameLabel => 'Pangalan';

  @override
  String get lastNameLabel => 'Apelyido';

  @override
  String get middleNameLabel => 'Gitnang Pangalan';

  @override
  String get homeWelcomeBack => 'Maligayang pagbabalik';

  @override
  String get loginSubtitle => 'Mag-sign in para magpatuloy';

  @override
  String get loginEmailRequired => 'Kailangan ang email.';

  @override
  String get loginPasswordRequired => 'Kailangan ang password.';

  @override
  String get loginButton => 'Mag-login';

  @override
  String get loginCreateAccount => 'Gumawa ng account';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoInfo => 'Walang available na impormasyon sa profile.';

  @override
  String get profileMemberSince => 'Kasapi Simula';

  @override
  String get profileLogout => 'Mag-logout';

  @override
  String get profileLogoutConfirmMessage =>
      'Sigurado ka bang gusto mong mag-logout sa iyong account?';

  @override
  String get profileLoggingOut => 'Nagla-logout...';

  @override
  String get profileLanguageLabel => 'Wika';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFilipino => 'Filipino';

  @override
  String get languageCebuano => 'Cebuano';

  @override
  String get registrationTitle => 'Pagpaparehistro';

  @override
  String get registrationUsernameLabel => 'Username';

  @override
  String get registrationButton => 'Magparehistro';

  @override
  String get registrationAlreadyHaveAccount => 'May account ka na? Mag-login';

  @override
  String get registrationSuccessMessage => 'Matagumpay na nakapagparehistro.';

  @override
  String get qrScannerTitle => 'I-scan ang QR code';

  @override
  String get qrScannerInstruction =>
      'Ilagay ang mga marker sa paligid ng QR code para magsimulang mag-scan';

  @override
  String get qrScannerCloseTooltip => 'Isara ang scanner';

  @override
  String get qrScannerTorchOnTooltip => 'I-on ang flashlight';

  @override
  String get qrScannerTorchOffTooltip => 'I-off ang flashlight';

  @override
  String get qrScannerStartingCamera => 'Binubuksan ang camera...';

  @override
  String get qrScannerPermissionTitle => 'Kailangan ang access sa camera';

  @override
  String get qrScannerPermissionMessage =>
      'Payagan ang access sa camera para makapag-scan ng QR code.';

  @override
  String get qrScannerPermissionBlockedMessage =>
      'Naka-off ang access sa camera para sa app na ito. I-on ito sa Settings para makapag-scan ng QR code.';

  @override
  String get qrScannerPermissionRestrictedMessage =>
      'Restricted ang access sa camera sa device na ito, kaya hindi available ang pag-scan.';

  @override
  String get qrScannerAllowCameraAccess => 'Payagan ang camera';

  @override
  String get qrScannerOpenSettings => 'Buksan ang Settings';

  @override
  String get faceCaptureTitle => 'Pag-capture ng Mukha';

  @override
  String get faceCaptureCameraReady => 'Handa na ang Camera';

  @override
  String get faceCaptureStartingCamera => 'Binubuksan ang camera...';

  @override
  String get faceCaptureSwitchCameraTooltip => 'Palitan ang camera';

  @override
  String get faceCaptureLightingHint =>
      'Tiyaking may sapat na liwanag sa mukha';

  @override
  String get faceCaptureGuidancePositionFace =>
      'Ilagay ang mukha sa loob ng frame';

  @override
  String get faceCaptureGuidanceMultipleFaces =>
      'Tiyaking isang mukha lang ang nakikita';

  @override
  String get faceCaptureGuidanceMoveCloser => 'Lumapit nang bahagya';

  @override
  String get faceCaptureGuidanceMoveBack => 'Umatras nang bahagya';

  @override
  String get faceCaptureGuidanceCenterFace => 'Igitna ang mukha';

  @override
  String get faceCaptureGuidanceLookStraight => 'Tumingin diretso sa camera';

  @override
  String get faceCaptureGuidanceTurnLeft => 'Ibaling ang ulo pakaliwa';

  @override
  String get faceCaptureGuidanceTurnRight => 'Ibaling ang ulo pakanan';

  @override
  String get faceCaptureGuidanceSmile => 'Ngumiti po';

  @override
  String get faceCaptureGuidanceHoldStill => 'Huwag gumalaw...';

  @override
  String faceCaptureGuidanceHoldStillCountdown(int seconds) {
    return 'Huwag gumalaw... $seconds';
  }

  @override
  String get faceCaptureGuidanceCapturing => 'Kinukuha...';

  @override
  String get faceCaptureGuidanceCaptured => 'Nakuha na';

  @override
  String get faceCaptureReadinessGetReady => 'Maghanda';

  @override
  String get faceCaptureReadinessKeepGoing => 'Ituloy lang';

  @override
  String get faceCaptureReadinessAlmostThere => 'Malapit na';

  @override
  String get faceCaptureReadinessReady => 'Handa na';

  @override
  String get faceCaptureStatusFace => 'Mukha';

  @override
  String get faceCaptureStatusPosition => 'Posisyon';

  @override
  String get faceCaptureStatusOrientation => 'Direksyon';

  @override
  String get faceCaptureStatusStability => 'Katatagan';

  @override
  String get faceCaptureStatusSmile => 'Ngiti';

  @override
  String get faceCaptureStatusDetected => 'Nakita';

  @override
  String get faceCaptureStatusGood => 'Maayos';

  @override
  String get faceCaptureStatusWaiting => 'Naghihintay';

  @override
  String get faceCaptureStatusNotApplicable => 'Wala';

  @override
  String get faceOrientationFront => 'Harap';

  @override
  String get faceOrientationLeft => 'Kaliwa';

  @override
  String get faceOrientationRight => 'Kanan';

  @override
  String get faceCaptureReviewTitle => 'Kunan ng selfie';

  @override
  String get faceCaptureReviewSubtitle => 'Tiyaking maliwanag ang larawan';

  @override
  String get faceCaptureReviewCompleted => 'Tapos na';

  @override
  String get faceCaptureReviewRequired => 'Kailangan';

  @override
  String get faceCaptureReviewOptional => 'Opsyonal';

  @override
  String get faceCaptureReviewTipsTitle => 'Mga tip para sa magandang larawan';

  @override
  String get faceCaptureReviewTipLighting => 'Gumamit ng maliwanag na lugar';

  @override
  String get faceCaptureReviewTipAccessories =>
      'Alisin ang salamin o accessories';

  @override
  String get faceCaptureReviewTipFrame =>
      'Panatilihin ang mukha sa loob ng frame';

  @override
  String get faceCaptureReviewContinue => 'Magpatuloy';

  @override
  String get faceCaptureReviewRetake => 'Kunan muli';

  @override
  String get imageViewerCloseTooltip => 'Isara ang larawan';

  @override
  String imageViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String imageViewerCounterSemantics(int current, int total) {
    return 'Larawan $current ng $total';
  }

  @override
  String get imageViewerImageSemantics => 'Larawan';

  @override
  String get imageViewerLoadFailed => 'Hindi ma-load ang larawan.';

  @override
  String get signaturePadTitle => 'Ilagda ang inyong lagda sa ibaba';

  @override
  String get signaturePadHint => 'Lagda dito';

  @override
  String get signaturePadClear => 'I-clear';

  @override
  String get signaturePadComplete => 'Tapusin';

  @override
  String get signaturePadCloseTooltip => 'Isara ang signature pad';

  @override
  String get signaturePadAreaSemantics => 'Lugar ng pagguhit ng lagda';

  @override
  String get signaturePadDiscardTitle => 'Itapon ang lagda?';

  @override
  String get signaturePadDiscardMessage => 'Hindi ma-save ang inyong lagda.';

  @override
  String get signaturePadDiscardConfirm => 'Itapon';

  @override
  String get errorNoInternet => 'Walang koneksyon sa internet.';

  @override
  String get errorServerGeneric => 'May naganap na problema sa server.';

  @override
  String get errorInvalidCredentials => 'Hindi wastong email o password.';

  @override
  String get errorUnknown => 'May naganap na problema.';

  @override
  String get errorInvalidRequest => 'Hindi wastong kahilingan.';

  @override
  String get errorInvalidInput => 'Hindi wastong input.';

  @override
  String get errorTitleRequired => 'Kailangan ang pamagat.';

  @override
  String get errorDescriptionRequired => 'Kailangan ang paglalarawan.';

  @override
  String get errorPhotoRequired => 'Kailangan ang larawan.';

  @override
  String get errorLocationRequired => 'Kailangan ang kasalukuyang lokasyon.';

  @override
  String get errorCameraGalleryUnavailable =>
      'Hindi ma-access ang camera o gallery.';

  @override
  String get errorLocationServicesDisabled =>
      'Naka-off ang location services. Paki-enable ito at subukan muli.';

  @override
  String get errorLocationUnableToDetermine =>
      'Hindi matukoy ang iyong kasalukuyang lokasyon.';

  @override
  String get errorLocationPermissionDenied =>
      'Tinanggihan ang pahintulot sa lokasyon.';

  @override
  String get errorLocationPermissionDeniedForever =>
      'Permanenteng tinanggihan ang pahintulot sa lokasyon.';

  @override
  String get errorCameraUnavailable => 'Hindi ma-access ang camera.';

  @override
  String get errorScannerUnsupported =>
      'Hindi suportado ang pag-scan sa device na ito.';

  @override
  String get errorScannerFailed => 'Hindi masimulan ang scanner.';

  @override
  String get errorCameraStartFailed => 'Hindi masimulan ang camera.';

  @override
  String get errorCaptureFailed => 'Hindi nakuha ang larawan. Subukan muli.';
}

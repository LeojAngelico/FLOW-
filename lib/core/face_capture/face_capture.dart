/// Core Face Capture — on-device face detection with auto-capture,
/// reusable by any feature that needs a framed photo of a face
/// (verification, KYC, onboarding, attendance).
///
/// Face **detection**, never recognition: it finds a face and checks
/// its framing, orientation and smile locally, then hands back a photo.
/// It does not identify people. Import this one file to use it.
///
/// ```dart
/// final result = await AppFaceCapture.capture(context);
/// ```
library;

export 'app_face_capture.dart';
export 'detection/face_capture_assessment.dart';
export 'detection/face_capture_evaluator.dart';
export 'detection/face_capture_geometry.dart';
export 'detection/face_sample.dart';
export 'detection/face_stability_tracker.dart';
export 'face_capture_config.dart';
export 'face_capture_localizer.dart';
export 'face_capture_page.dart';
export 'face_capture_result.dart';
export 'review/face_capture_review_slot.dart';
export 'review/face_capture_review_view.dart';

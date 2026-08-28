import '../face_capture_config.dart';

/// One capture position on the review screen.
///
/// The calling feature owns this list — it decides which orientations
/// a workflow needs, in what order, and which are optional. The Core
/// capability never hard-codes a "left, front, right" sequence.
class FaceCaptureReviewSlot {
  final FaceOrientation orientation;

  /// Path of the captured photo, or null while the slot is empty.
  final String? imagePath;

  /// Whether the workflow cannot continue without this slot.
  final bool isRequired;

  /// Overrides the default orientation label ("Front", "Left"...).
  final String? label;

  const FaceCaptureReviewSlot({
    required this.orientation,
    this.imagePath,
    this.isRequired = true,
    this.label,
  });

  bool get isCompleted => imagePath != null;

  FaceCaptureReviewSlot copyWith({String? imagePath, bool clearImage = false}) {
    return FaceCaptureReviewSlot(
      orientation: orientation,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isRequired: isRequired,
      label: label,
    );
  }
}

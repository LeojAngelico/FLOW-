import 'package:image_picker/image_picker.dart';

/// Reusable image picker utility.
///
/// Provides a single abstraction for selecting
/// images from the camera or device gallery.
///
/// Platform-specific implementation is handled
/// by the image_picker package.
class AppImagePicker {
  AppImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  /// Opens the device camera and captures
  /// an image.
  static Future<XFile?> pickFromCamera() async {
    return _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
  }

  /// Opens the device gallery/photo library
  /// and allows the user to select an image.
  static Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }
}

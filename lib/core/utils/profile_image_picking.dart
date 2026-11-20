import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/app_toast.dart';

/// Profile photo picking (camera / gallery) with permission handling.
/// Mix into any [ChangeNotifier] that needs a profile photo.
mixin ProfileImagePicking on ChangeNotifier {
  File? _profileImage;

  ImagePicker get imagePicker;

  File? get profileImage => _profileImage;

  void setProfileImage(File? image) {
    _profileImage = image;
    notifyListeners();
  }

  void clearImage() => setProfileImage(null);

  /// Requests camera permission and captures a new photo using the camera.
  Future<bool> pickImageFromCamera(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;

    if (!status.isGranted && !status.isLimited) {
      status = await Permission.camera.request();
    }

    if (status.isGranted || status.isLimited) {
      try {
        return await _pickImage(ImageSource.camera);
      } catch (e) {
        debugPrint("Camera capture error: $e");
        if (context.mounted) {
          AppToast.show(
            context: context,
            message: "Unable to capture photo. Please try again.",
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        AppToast.show(
          context: context,
          message:
              "Camera permission is permanently denied. Please allow it in device settings.",
        );
        await openAppSettings();
      }
    } else {
      // Fallback: directly open the camera in case the OS prompts natively
      try {
        return await _pickImage(ImageSource.camera);
      } catch (e) {
        if (context.mounted) {
          AppToast.show(
            context: context,
            message: "Camera permission is required to capture a photo.",
          );
        }
      }
    }
    return false;
  }

  /// Picks an image from the photo gallery.
  Future<bool> pickImageFromGallery(BuildContext context) async {
    try {
      return await _pickImage(ImageSource.gallery);
    } catch (e) {
      debugPrint("Gallery access error: $e");
      final photosStatus = await Permission.photos.status;
      if (!context.mounted) return false;
      if (photosStatus.isPermanentlyDenied) {
        AppToast.show(
          context: context,
          message:
              "Photo library access is permanently denied. Please enable it in device settings.",
        );
        await openAppSettings();
      } else {
        AppToast.show(
          context: context,
          message:
              "Unable to open photo library. Please grant permission in settings.",
        );
      }
    }
    return false;
  }

  Future<bool> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile == null) return false;
    setProfileImage(File(pickedFile.path));
    return true;
  }
}

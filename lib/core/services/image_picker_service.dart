import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../error/exceptions.dart' as exceptions;
import '../utils/logger.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickFromGallery() async {
    try {
      AppLogger.info('Picking image from gallery');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        AppLogger.info('No image selected');
        return null;
      }

      AppLogger.info('Image picked: ${image.path}');
      return image;
    } catch (e, stackTrace) {
      AppLogger.error('Error picking image from gallery', e, stackTrace);
      throw exceptions.StorageException(
        'Failed to pick image: ${e.toString()}',
      );
    }
  }

  /// Pick image from camera
  Future<XFile?> pickFromCamera() async {
    try {
      AppLogger.info('Taking photo from camera');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        AppLogger.info('No photo taken');
        return null;
      }

      AppLogger.info('Photo taken: ${image.path}');
      return image;
    } catch (e, stackTrace) {
      AppLogger.error('Error taking photo', e, stackTrace);
      throw exceptions.StorageException(
        'Failed to take photo: ${e.toString()}',
      );
    }
  }

  /// Pick multiple images from gallery
  Future<List<XFile>> pickMultipleFromGallery() async {
    try {
      AppLogger.info('Picking multiple images from gallery');

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      AppLogger.info('${images.length} images picked');
      return images;
    } catch (e, stackTrace) {
      AppLogger.error('Error picking multiple images', e, stackTrace);
      throw exceptions.StorageException(
        'Failed to pick images: ${e.toString()}',
      );
    }
  }

  /// Crop image
  Future<XFile?> cropImage(XFile imageFile, BuildContext context) async {
    try {
      AppLogger.info('Cropping image');

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        maxWidth: 1920,
        maxHeight: 1920,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: AppColors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 800, height: 600),
          ),
        ],
      );

      if (croppedFile == null) {
        AppLogger.info('Image cropping cancelled');
        return null;
      }

      // Convert CroppedFile to XFile
      final xFile = XFile(croppedFile.path);
      AppLogger.info('Image cropped successfully: ${xFile.path}');
      return xFile;
    } catch (e, stackTrace) {
      AppLogger.error('Error cropping image', e, stackTrace);
      throw exceptions.StorageException(
        'Failed to crop image: ${e.toString()}',
      );
    }
  }

  /// Show image picker bottom sheet
  Future<XFile?> showImagePickerBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Ambil Foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.error),
                title: const Text('Batal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null) return null;

    if (result == ImageSource.gallery) {
      return await pickFromGallery();
    } else {
      return await pickFromCamera();
    }
  }

  /// Pick and crop image
  Future<XFile?> pickAndCropImage(BuildContext context) async {
    final pickedFile = await showImagePickerBottomSheet(context);
    if (pickedFile == null || !context.mounted) return null;

    return await cropImage(pickedFile, context);
  }
}

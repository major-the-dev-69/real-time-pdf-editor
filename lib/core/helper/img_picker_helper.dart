import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/custom_buttons.dart';

class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();
  final Function(List<File>?, String) onImagePicked;

  /// Default compression size in MB
  static double maxFileSizeInMB = 2.0;

  ImagePickerHelper({required this.onImagePicked});

  void showImagePickerDialog(
    BuildContext context,
    String flags, {
    bool allowMultiple = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            context.mediaQueryPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text("Upload Media", style: context.textTheme.titleLarge),
              const SizedBox(height: 24),
              _buildOptionTile(
                context,
                icon: CupertinoIcons.camera_fill,
                iconColor: context.theme.primaryColor,
                label: "Take Photo",
                onTap: () {
                  Navigator.pop(context);
                  _checkCameraPermission(context, flags, allowMultiple);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                context,
                icon: Icons.photo,
                iconColor: context.theme.primaryColor,
                label: allowMultiple
                    ? "Choose Multiple Images"
                    : "Choose from Gallery",
                onTap: () {
                  Navigator.pop(context);
                  _checkGalleryPermission(context, flags, allowMultiple);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomOutlinedButton(
                  title: "Cancel",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required Color? iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor?.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// -------------------- Permissions --------------------

  Future<void> _checkCameraPermission(
    BuildContext context,
    String flags,
    bool allowMultiple,
  ) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      _pickImages(ImageSource.camera, flags, allowMultiple);
    } else {
      if (context.mounted) {
        _showPermissionDialog(context, "Camera");
      }
    }
  }

  Future<void> _checkGalleryPermission(
    BuildContext context,
    String flags,
    bool allowMultiple,
  ) async {
    PermissionStatus status;

    if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        status = await Permission.mediaLibrary.request();
      } else {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      _pickImages(ImageSource.gallery, flags, allowMultiple);
    } else {
      if (context.mounted) {
        _showPermissionDialog(context, "Gallery");
      }
    }
  }

  /// -------------------- Image Picking --------------------

  Future<void> _pickImages(
    ImageSource source,
    String flags,
    bool allowMultiple,
  ) async {
    try {
      if (allowMultiple && source == ImageSource.gallery) {
        final pickedFiles = await _picker.pickMultiImage();

        if (pickedFiles.isNotEmpty) {
          List<File> resultFiles = [];

          for (final xfile in pickedFiles) {
            final compressed = await _compressImage(File(xfile.path));
            resultFiles.add(compressed);
          }

          onImagePicked(resultFiles, flags);
        } else {
          onImagePicked(null, flags);
        }
      } else {
        final pickedFile = await _picker.pickImage(source: source);

        if (pickedFile != null) {
          final compressedFile = await _compressImage(File(pickedFile.path));
          onImagePicked([compressedFile], flags);
        } else {
          onImagePicked(null, flags);
        }
      }
    } catch (e) {
      onImagePicked(null, flags);
    }
  }

  /// -------------------- Image Compression --------------------

  Future<File> _compressImage(File originalFile) async {
    final targetSize = (maxFileSizeInMB * 1024 * 1024).toInt();

    if (!await originalFile.exists()) return originalFile;

    int quality = 95;
    const int minQuality = 10;

    File? resultFile;

    while (quality >= minQuality) {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        originalFile.path,
        quality: quality,
      );

      if (compressedBytes == null) break;

      final tempPath =
          "${originalFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

      resultFile = await File(tempPath).writeAsBytes(compressedBytes);

      if (resultFile.lengthSync() <= targetSize) {
        return resultFile;
      }

      quality -= 10;
    }

    return resultFile ?? originalFile;
  }

  /// -------------------- Permission Dialog --------------------

  void _showPermissionDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Required"),
          content: Text("Please allow $type permission from settings."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text("Go to Settings"),
            ),
          ],
        );
      },
    );
  }
}

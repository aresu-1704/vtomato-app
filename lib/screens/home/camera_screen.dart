// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:camera/camera.dart';
import 'package:vtomato_app/screens/history/predict_history_screen.dart';
import 'package:vtomato_app/screens/predict/predict_result_screen.dart';
import 'package:flutter/services.dart';
import 'package:vtomato_app/utils/toast_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vtomato_app/utils/image_utils.dart';

class CameraScreen extends StatefulWidget {
  final String UserId;
  const CameraScreen({super.key, required this.UserId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController cameraController;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isTakePicture = false;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await cameraController.initialize();
    if (mounted) {
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    try {
      if (isCameraInitialized) {
        cameraController.setFlashMode(FlashMode.off);
        cameraController.dispose();
      }
    } catch (e) {
      print('Error disposing camera: $e');
    }
    super.dispose();
  }

  Future<void> _takePicture() async {
    setState(() {
      isTakePicture = true;
    });

    try {
      XFile picture = await cameraController.takePicture();
      final imageBytes = await picture.readAsBytes();
      cameraController.setFlashMode(FlashMode.off);

      setState(() {
        isTakePicture = false;
      });

      if (!mounted) return;

      // CRITICAL FIX: Apply orientation fix to camera captures
      // Camera photos have EXIF rotation that must be baked into pixels
      final fixedBytes = await ImageUtils.fixOrientation(imageBytes);

      // Pause camera instead of stopping
      if (isCameraInitialized) {
        try {
          await cameraController.pausePreview();
        } catch (_) {}
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PredictResultScreen(image: fixedBytes, userID: widget.UserId),
        ),
      );

      // Resume camera when back
      if (mounted && isCameraInitialized) {
        try {
          await cameraController.resumePreview();
        } catch (_) {}
      }
    } catch (_) {
      if (mounted) ToastHelper.showError(context, "Lỗi khi chụp ảnh, thử lại.");
      setState(() {
        isTakePicture = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return;

      if (image != null) {
        final Uint8List rawBytes = await image.readAsBytes();

        if (!mounted) return;

        // Fix image orientation using EXIF data
        final fixedBytes = await ImageUtils.fixOrientation(rawBytes);

        // Pause camera instead of stopping
        if (isCameraInitialized) {
          try {
            await cameraController.pausePreview();
          } catch (_) {}
        }

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PredictResultScreen(
                  image: fixedBytes,
                  userID: widget.UserId,
                ),
          ),
        );

        // Resume camera when back
        if (mounted && isCameraInitialized) {
          try {
            await cameraController.resumePreview();
          } catch (_) {}
        }
      } else {
        ToastHelper.showInfo(context, "Không có ảnh nào được chọn.");
      }
    } catch (_) {
      if (mounted) ToastHelper.showError(context, "Lỗi khi chọn ảnh, thử lại.");
    }
  }

  Future<void> _initHistoryScreen() async {
    // Pause camera instead of stopping
    if (isCameraInitialized) {
      try {
        await cameraController.pausePreview();
      } catch (_) {}
    }

    if (!mounted) return;

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => PredictHistoryScreen(userID: widget.UserId),
        ),
      );

      // Resume camera when back
      if (mounted && isCameraInitialized) {
        try {
          await cameraController.resumePreview();
        } catch (_) {}
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(color: Colors.green[700]),
                )
                : Stack(
                  children: [
                    // Full screen camera preview
                    Positioned.fill(
                      child:
                          isCameraInitialized
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: CameraPreview(cameraController),
                              )
                              : Container(
                                color: Colors.black,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                    ),

                    // Top title overlay with gradient background
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          child: Text(
                            "Quét ảnh lá cây cà chua\nchẩn đoán bệnh",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom overlay with capture button & bottom bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            // Warning text
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: const Text(
                                "Lưu ý: Dự đoán không phải là chính xác 100%,\nchỉ dùng làm tài liệu tham khảo",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Capture button
                            Pulse(
                              duration: const Duration(seconds: 2),
                              infinite: !isTakePicture && isCameraInitialized,
                              child:
                                  isTakePicture || !isCameraInitialized
                                      ? Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.green[700],
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 15,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: const SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                      )
                                      : GestureDetector(
                                        onTap: _takePicture,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.green[700],
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(
                                                  0.5,
                                                ),
                                                blurRadius: 15,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                            ),

                            const SizedBox(height: 16),

                            // Bottom navigation bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Gallery button
                                  BounceInUp(
                                    delay: const Duration(milliseconds: 200),
                                    child: GestureDetector(
                                      onTap:
                                          isTakePicture || !isCameraInitialized
                                              ? null
                                              : _pickImageFromGallery,
                                      child: Opacity(
                                        opacity:
                                            isTakePicture ||
                                                    !isCameraInitialized
                                                ? 0.5
                                                : 1.0,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.add_photo_alternate,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "Thêm ảnh",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // History button
                                  BounceInUp(
                                    delay: const Duration(milliseconds: 400),
                                    child: GestureDetector(
                                      onTap:
                                          isTakePicture || !isCameraInitialized
                                              ? null
                                              : () {
                                                _initHistoryScreen();
                                              },
                                      child: Opacity(
                                        opacity:
                                            isTakePicture ||
                                                    !isCameraInitialized
                                                ? 0.5
                                                : 1.0,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.history,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "Lịch sử chẩn đoán",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:camera/camera.dart';
import 'package:tomato_detect_app/screens/history/predict_history_screen.dart';
import 'package:tomato_detect_app/screens/predict/predict_result_screen.dart';
import 'package:flutter/services.dart';
import 'package:tomato_detect_app/utils/toast_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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
    if (isCameraInitialized) {
      cameraController.setFlashMode(FlashMode.off);
      cameraController.dispose();
    }
    super.dispose();
  }

  void _stopCamera() {
    if (isCameraInitialized) {
      cameraController.setFlashMode(FlashMode.off);
      cameraController.dispose();
      setState(() {
        isCameraInitialized = false;
      });
    }
  }

  void _reInitCamera() {
    initCamera();
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

      _stopCamera();
      if (!mounted) return;

      bool? status = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PredictResultScreen(image: imageBytes, userID: widget.UserId),
        ),
      );

      if (status == null) {
        _reInitCamera();
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

        img.Image? originalImage = img.decodeImage(rawBytes);

        if (originalImage == null) {
          ToastHelper.showError(context, "Không thể đọc ảnh.");
          return;
        }

        img.Image rotatedImage = img.copyRotate(originalImage, angle: -90);
        final Uint8List rotatedBytes = Uint8List.fromList(
          img.encodeJpg(rotatedImage),
        );

        _stopCamera();
        if (!mounted) return;

        bool? status = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PredictResultScreen(
                  image: rotatedBytes,
                  userID: widget.UserId,
                ),
          ),
        );

        if (status == null) {
          _reInitCamera();
        }
      } else {
        ToastHelper.showInfo(context, "Không có ảnh nào được chọn.");
      }
    } catch (_) {
      if (mounted) ToastHelper.showError(context, "Lỗi khi chọn ảnh, thử lại.");
    }
  }

  Future<void> _initHistoryScreen() async {
    _stopCamera();
    bool? status = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictHistoryScreen(userID: widget.UserId),
      ),
    );

    if (status == null) {
      _reInitCamera();
    }
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
                : Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Quét ảnh lá cây cà chua\nchẩn đoán bệnh",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black,
                        ),
                        child:
                            isCameraInitialized
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [CameraPreview(cameraController)],
                                  ),
                                )
                                : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Lưu ý: Dự đoán không phải là chính xác 100%,\nchỉ dùng làm tài liệu tham khảo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child:
                          isTakePicture || !isCameraInitialized
                              ? Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 5,
                                  ),
                                ),
                              )
                              : GestureDetector(
                                onTap: _takePicture,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      color: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap:
                                isTakePicture || !isCameraInitialized
                                    ? null
                                    : _pickImageFromGallery,
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Thêm ảnh",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                isTakePicture || !isCameraInitialized
                                    ? null
                                    : () {
                                      _initHistoryScreen();
                                    },
                            child: Column(
                              children: const [
                                Icon(Icons.history, color: Colors.white),
                                SizedBox(height: 4),
                                Text(
                                  "Lịch sử chẩn đoán",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

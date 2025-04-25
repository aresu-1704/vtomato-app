import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tomato_detect_app/views//predict_history_screen.dart';
import 'package:tomato_detect_app/views//predict_result_screen.dart';
import 'package:flutter/services.dart';
import 'package:tomato_detect_app/view_models/camera_viewmodel.dart';

class CameraScreen extends StatefulWidget {
  final int UserId;
  const CameraScreen({super.key, required this.UserId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isLoading = false;
  bool _isTakePicture = false;
  bool _isCameraInitialized = false;
  late CameraViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CameraViewModel();
    _viewModel.loadHistory(_onLoadingChange, widget.UserId);
    _viewModel.initCamera(_onCameraInitializedChange);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onTakePictureChange(bool takePicture){
    setState(() => _isTakePicture = takePicture);
  }

  void _onLoadingChange(bool loading){
    setState(() => _isLoading = loading);
  }

  void _onCameraInitializedChange(bool cameraInitialized){
    setState(() => _isCameraInitialized = cameraInitialized);
  }

  Future<void> _takePicture() async {
    try {
      final imageBytes = await _viewModel.takePicture(_onTakePictureChange);
      if(imageBytes != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PredictResultScreen(
                  image: imageBytes,
                  userID: widget.UserId,
                ),
          ),
        );
      }
    } catch (_){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi chụp ảnh, thử lại.")),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final imageBytes = await _viewModel.pickImageFromGallery();
      if(imageBytes != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PredictResultScreen(
                  image: imageBytes,
                  userID: widget.UserId,
                ),
          ),
        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không có ảnh nào được chọn.")),
        );
      }
    } catch (_){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi chọn ảnh, thử lại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.green[700],
          ),
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
                child: _isCameraInitialized
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      CameraPreview(_viewModel.cameraController),
                    ],
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
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _isTakePicture || !_isCameraInitialized
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5
                  )
                )
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
                      color: Colors.white
                    ),
                  ),
                )
              ),
            const SizedBox(height: 16),

            Container(
              color: Colors.green[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: _isTakePicture || !_isCameraInitialized
                    ? null
                    : _pickImageFromGallery,
                    child: Column(
                      children: const [
                        Icon(Icons.add_photo_alternate, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          "Thêm ảnh",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isTakePicture || !_isCameraInitialized
                      ? null
                      : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                          PredictHistoryScreen(userID: widget.UserId)
                        )
                      );
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
            )
          ],
        ),
      ),
    );
  }
}
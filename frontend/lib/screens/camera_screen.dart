import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tomato_detect_app/services/predict_history_repository_service.dart';
import 'package:tomato_detect_app/screens/predict_history_screen.dart';
import 'package:tomato_detect_app/screens/predict_result_screen.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final int UserId;
  const CameraScreen({super.key, required this.UserId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isTakePicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    await PredictHistoryReposotory
        .fetchHistory(widget.UserId)
        .timeout(Duration(seconds: 10));
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    await _cameraController.initialize();
    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _takePicture() async {
    try {

      setState(() {
        isTakePicture = true;
      });

      XFile picture = await _cameraController.takePicture();
      final imageBytes = await picture.readAsBytes();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictResultScreen(
            image: imageBytes,
            userID: widget.UserId,
          ),
        ),
      );
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi chụp ảnh, thử lại.")),
      );
    } finally {
      setState(() {
        isTakePicture = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();

      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        print("Không thể decode ảnh");
        return;
      }

      img.Image rotatedImage = img.copyRotate(originalImage, angle: -90);

      final Uint8List rotatedBytes = Uint8List.fromList(img.encodeJpg(rotatedImage));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictResultScreen(
              image: rotatedBytes,
              userID: widget.UserId
          ),
        ),
      );
    } else {
      print("Không có ảnh nào được chọn");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      body: SafeArea(
        child: isLoading
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
                      CameraPreview(_cameraController),
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
              child: isTakePicture
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
                  child: const Icon(Icons.camera_alt, color: Colors.white),
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
                    onTap: _pickImageFromGallery,
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
                    onTap: () {
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

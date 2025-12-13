import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:vtomato_app/utils/toast_helper.dart';
import 'package:vtomato_app/models/disease_info_model.dart';
import 'package:vtomato_app/services/predict_service.dart';
import 'package:vtomato_app/services/disease_history_service.dart';
import 'package:vtomato_app/widgets/modern_loading_indicator.dart';
import 'package:vtomato_app/widgets/gradient_background.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vtomato_app/core/service_locator.dart';

class PredictResultScreen extends StatefulWidget {
  final Uint8List image;
  final String userID;

  const PredictResultScreen({
    super.key,
    required this.image,
    required this.userID,
  });

  @override
  State<PredictResultScreen> createState() => _PredictResultScreenState();
}

class _PredictResultScreenState extends State<PredictResultScreen> {
  // Use service locator instead of direct instantiation
  final PredictService _predictService = getIt<PredictService>();
  final DiseaseHistoryService _diseaseHistoryService =
      getIt<DiseaseHistoryService>();

  Uint8List? annotatedImage;
  List<int> classIndices = [];
  List<DiseaseInfoModel> resultDiseaseInfo = [];
  bool isLoading = true;
  String? message;

  @override
  void initState() {
    super.initState();
    _handlePrediction();
  }

  Future<void> _handlePrediction() async {
    // Step 1: Upload image and get annotated image from API
    final result = await _predictService.uploadImageForPrediction(widget.image);

    if (!mounted) return;

    if (result == null) {
      setState(() {
        message = "Có lỗi xảy ra khi xử lý ảnh.";
        isLoading = false;
      });
      return;
    }

    if (result['status'] == 'success') {
      final Uint8List annotatedImg = result['annotatedImage'];
      final List<int> indices = result['class_indices'];
      List<DiseaseInfoModel> diseaseInfoList = [];

      // Step 2: Get disease info if diseases detected
      if (indices.isNotEmpty) {
        final diseaseInfo = await _predictService.getDiseaseInfo(indices);
        if (diseaseInfo != null) {
          diseaseInfoList = diseaseInfo;
        }
      }

      if (mounted) {
        setState(() {
          annotatedImage = annotatedImg;
          classIndices = indices;
          resultDiseaseInfo = diseaseInfoList;
          isLoading = false;
          if (indices.isEmpty) {
            message = "Không phát hiện bệnh nào.";
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          message = "Có lỗi xảy ra khi xử lý ảnh.";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveHistory() async {
    if (classIndices.isEmpty || annotatedImage == null) return;

    ToastHelper.showInfo(context, "Đang lưu...");

    bool reloadStatus = await _diseaseHistoryService.saveDiseaseHistory(
      annotatedImage!,
      widget.userID,
      classIndices,
    );

    if (!mounted) return;

    if (reloadStatus) {
      ToastHelper.showSuccess(context, "Đã lưu lịch sử !");
      Navigator.pop(context);
    } else {
      ToastHelper.showError(context, "Lưu lịch sử thất bại.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      appBar: AppBar(
        title: const Text(
          'Thông tin nhận diện bệnh',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        colors: [
          const Color(0xFFFEF7ED),
          const Color(0xFFE8F5E9),
          const Color(0xFFFEF7ED),
        ],
        child:
            isLoading
                ? Center(
                  child: ModernLoadingIndicator(
                    message: 'Đang phân tích ảnh...',
                    color: Colors.green[700],
                    icon: Icons.biotech_rounded,
                  ),
                )
                : Column(
                  children: [
                    // Content area with scrolling
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Image display area
                            classIndices.isEmpty
                                ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                    child: FadeIn(
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 100,
                                            color: Colors.green[600],
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Cây cà chua của bạn\nhoàn toàn khỏe mạnh\n🍅🍅🍅🍅🍅🍅🍅🍅',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                : annotatedImage != null
                                ? ZoomIn(
                                  duration: const Duration(milliseconds: 600),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: _buildFlexibleImage(annotatedImage!),
                                  ),
                                )
                                : const Center(
                                  child: Text(
                                    'Không có ảnh hoặc lỗi trong quá trình xử lý.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 12),
                            // Disease info list
                            if (classIndices.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: List.generate(resultDiseaseInfo.length, (
                                    index,
                                  ) {
                                    final disease = resultDiseaseInfo[index];
                                    return FadeInUp(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      delay: Duration(
                                        milliseconds: 200 + (index * 150),
                                      ),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 4,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        shadowColor: Colors.green.withOpacity(
                                          0.3,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blue[50]!,
                                                Colors.green.withOpacity(0.1),
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Bệnh ${disease.diseaseName.toLowerCase()} cà chua',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[800],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Divider(
                                                  color: Colors.green[200],
                                                  thickness: 1,
                                                ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                  icon:
                                                      Icons
                                                          .coronavirus_outlined,
                                                  title: 'Nguyên nhân:',
                                                  content: disease.cause,
                                                ),
                                                const SizedBox(height: 12),
                                                _buildInfoRow(
                                                  icon:
                                                      Icons
                                                          .medical_services_outlined,
                                                  title: 'Triệu chứng:',
                                                  content: disease.symptoms,
                                                ),
                                                const SizedBox(height: 12),
                                                _buildInfoRow(
                                                  icon:
                                                      Icons.wb_cloudy_outlined,
                                                  title: 'Điều kiện phát sinh:',
                                                  content: disease.conditions,
                                                ),
                                                const SizedBox(height: 12),
                                                _buildInfoRow(
                                                  icon: Icons.healing_outlined,
                                                  title: 'Cách điều trị:',
                                                  content: disease.treatment,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            const SizedBox(height: 80), // Space for button
                          ],
                        ),
                      ),
                    ),
                    // Save button - fixed at bottom
                    if (classIndices.isNotEmpty)
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Pulse(
                                infinite: true,
                                duration: const Duration(seconds: 2),
                                child: GestureDetector(
                                  onTap: isLoading ? null : _saveHistory,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.save_as_rounded,
                                          color: Colors.green[700],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Lưu vào lịch sử",
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
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
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build flexible image that adapts to its aspect ratio
  Widget _buildFlexibleImage(Uint8List imageBytes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<ImageInfo>(
          future: _getImageInfo(MemoryImage(imageBytes)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final imageInfo = snapshot.data!;
            final aspectRatio = imageInfo.image.width / imageInfo.image.height;

            return AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(imageBytes, fit: BoxFit.contain),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Helper to get image info for aspect ratio calculation
  Future<ImageInfo> _getImageInfo(ImageProvider imageProvider) {
    final completer = Completer<ImageInfo>();
    final stream = imageProvider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((info, _) => completer.complete(info));
    stream.addListener(listener);
    return completer.future;
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tomato_detect_app/utils/toast_helper.dart';
import 'package:tomato_detect_app/models/disease_info_model.dart';
import 'package:tomato_detect_app/services/predict_service.dart';
import 'package:tomato_detect_app/services/disease_history_service.dart';
import 'package:animate_do/animate_do.dart';

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
  final PredictService _predictService = PredictService();
  final DiseaseHistoryService _diseaseHistoryService = DiseaseHistoryService();

  Uint8List? resultImage;
  int? resultClassCount = 0;
  List<int> resultClassList = [];
  List<DiseaseInfoModel> resultDiseaseInfo = [];
  bool isLoading = true;
  String? message;

  @override
  void initState() {
    super.initState();
    _handlePrediction();
  }

  Future<void> _handlePrediction() async {
    // Step 1: Upload image and get annotated result with class_indices
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
      List<int> classIndices = List<int>.from(result['class_indices']);
      List<DiseaseInfoModel> diseaseInfoList = [];

      // Step 2: Get disease info if diseases detected
      if (classIndices.isNotEmpty) {
        final diseaseInfo = await _predictService.getDiseaseInfo(classIndices);
        if (diseaseInfo != null) {
          diseaseInfoList = diseaseInfo;
        } else {
          // keep empty but maybe show error
        }
      }

      if (mounted) {
        setState(() {
          resultImage = result['image'];
          resultClassCount = result['class_count'];
          resultClassList = classIndices;
          resultDiseaseInfo = diseaseInfoList;
          isLoading = false;
          if (classIndices.isEmpty) {
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
    ToastHelper.showInfo(context, "Đang lưu...");

    // Optimistic UI update or just wait? The original code didn't set loading on saveHistory but the VM did.
    // The VM logic was: save -> isLoading=true -> wait 1s -> isLoading=false.
    // This seems weird. It should probably be: isLoading=true -> save -> isLoading=false.
    // However, since we navigate back after save, maybe we don't need complex loading state.

    // Implementing directly:
    bool reloadStatus = await _diseaseHistoryService.saveDiseaseHistory(
      resultImage!,
      widget.userID,
      resultClassList,
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
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Pulse(
                      infinite: true,
                      child: Icon(
                        Icons.biotech_rounded,
                        size: 80,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Đang phân tích ảnh...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CircularProgressIndicator(color: Colors.green[700]),
                  ],
                ),
              )
              : Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 7,
                    child:
                        resultClassCount == 0
                            ? Center(
                              child: FadeIn(
                                duration: const Duration(milliseconds: 800),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                            )
                            : ZoomIn(
                              duration: const Duration(milliseconds: 600),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.black,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child:
                                    resultImage != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Image.memory(
                                            resultImage!,
                                            fit: BoxFit.contain,
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
                              ),
                            ),
                  ),
                  const SizedBox(height: 12),
                  if (resultClassCount != null && resultClassCount! > 0)
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: resultDiseaseInfo.length,
                          itemBuilder: (context, index) {
                            final disease = resultDiseaseInfo[index];
                            return FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(
                                milliseconds: 200 + (index * 150),
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                shadowColor: Colors.green.withOpacity(0.3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
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
                                          icon: Icons.coronavirus_outlined,
                                          title: 'Nguyên nhân:',
                                          content: disease.cause,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          icon: Icons.medical_services_outlined,
                                          title: 'Triệu chứng:',
                                          content: disease.symptoms,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          icon: Icons.wb_cloudy_outlined,
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
                          },
                        ),
                      ),
                    ),
                  if (resultClassCount != null && resultClassCount! > 0)
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
                                        "Lưu lịch sử nhận diện",
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
                  // Bottom buttons
                ],
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
}

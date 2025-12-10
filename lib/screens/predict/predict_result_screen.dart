import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tomato_detect_app/utils/toast_helper.dart';
import 'package:tomato_detect_app/models/disease_info_model.dart';
import 'package:tomato_detect_app/services/predict_service.dart';
import 'package:tomato_detect_app/services/disease_history_service.dart';

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
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.green[700]),
              )
              : Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 7,
                    child:
                        resultClassCount == 0
                            ? const Center(
                              child: Text(
                                'Cây cà chua của bạn\n hoàn toàn khỏe mạnh\n🍅🍅🍅🍅🍅🍅🍅🍅',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black,
                              ),
                              child:
                                  resultImage != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
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
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bệnh ${disease.diseaseName.toLowerCase()} cà chua',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '🦠 Nguyên nhân:\n',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${disease.cause}\n\n',
                                          ),
                                          TextSpan(
                                            text: '🩺 Triệu chứng:\n',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${disease.symptoms}\n\n',
                                          ),
                                          TextSpan(
                                            text: '🌦️ Điều kiện phát sinh:\n',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${disease.conditions}\n\n',
                                          ),
                                          TextSpan(
                                            text: '💊 Cách điều trị:\n',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${disease.treatment}\n',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (resultClassCount != null && resultClassCount! > 0)
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
                            onTap: isLoading ? null : _saveHistory,
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.save_as_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Lưu lịch sử nhận diện",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Bottom buttons
                ],
              ),
    );
  }
}

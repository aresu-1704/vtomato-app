import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tomato_detect_app/view_models/predict_result_viewmodel.dart';

class PredictResultScreen extends StatefulWidget {
  final Uint8List image;
  final int userID;

  const PredictResultScreen({super.key, required this.image, required this.userID});

  @override
  State<PredictResultScreen> createState() => _PredictResultScreenState();
}

class _PredictResultScreenState extends State<PredictResultScreen> {
  late PredictResultViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PredictResultViewModel();
    _handlePrediction();
  }

  Future<void> _handlePrediction() async {
    await _viewModel.handlePrediction(widget.image);
    setState(() {});
  }

  Future<void> _saveHistory() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Đang lưu..."))
    );
    await _viewModel.saveHistory(widget.userID);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Đã lưu lịch sử !"))
    );
    Navigator.pop(context);
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
      body: _viewModel.isLoading
        ? Center(
        child: CircularProgressIndicator(color: Colors.green[700]),
        )
        : Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              flex: 7,
              child: _viewModel.resultClassCount == 0
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
                margin: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
                child: _viewModel.resultImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    _viewModel.resultImage!,
                    fit: BoxFit.contain,
                  ),
                )
                : const Center(
                  child: Text(
                    'Không có ảnh hoặc lỗi trong quá trình xử lý.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (_viewModel.resultClassCount != null &&
              _viewModel.resultClassCount! > 0)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: _viewModel.diseaseInfo.length,
                  itemBuilder: (context, index) {
                    final disease = _viewModel.diseaseInfo[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.cause}\n\n'),
                                  TextSpan(
                                    text: '🩺 Triệu chứng:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.symptoms}\n\n'),
                                  TextSpan(
                                    text: '🌦️ Điều kiện phát sinh:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.conditions}\n\n'),
                                  TextSpan(
                                    text: '💊 Cách điều trị:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.treatment}\n'),
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
          if (_viewModel.resultClassCount != null &&
              _viewModel.resultClassCount! > 0)
            Container(
              color: Colors.green[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: _viewModel.isLoading
                    ? null
                    : _saveHistory,
                    child: Column(
                      children: const [
                        Icon(Icons.save_as_rounded, color: Colors.white),
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

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tomato_detect_app/models/DiseaseInfo.dart';
import 'package:tomato_detect_app/view_models/history_detail_viewmodel.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Uint8List image;
  final int resultClassCount;
  final String timestamp;
  final List<DiseaseInfo> diseaseInfo;

  const HistoryDetailScreen({
    super.key,
    required this.image,
    required this.resultClassCount,
    required this.timestamp,
    required this.diseaseInfo,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late HistoryDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HistoryDetailViewModel(
      diseaseInfo: widget.diseaseInfo,
      resultClassCount: widget.resultClassCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      appBar: AppBar(
        title: Text(
          widget.timestamp,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  widget.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_viewModel.hasDiseases)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: widget.diseaseInfo.length,
                  itemBuilder: (context, index) {
                    final disease = widget.diseaseInfo[index];
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
                                  const TextSpan(
                                    text: '🦠 Nguyên nhân:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.cause}\n\n'),
                                  const TextSpan(
                                    text: '🩺 Triệu chứng:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.symptoms}\n\n'),
                                  const TextSpan(
                                    text: '🌦️ Điều kiện phát sinh:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.conditions}\n\n'),
                                  const TextSpan(
                                    text: '💊 Cách điều trị:\n',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${disease.treatment}\n'),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tomato_detect_app/models/DiseaseHistory.dart';
import 'package:tomato_detect_app/screens/history_detail_screen.dart';
import 'package:tomato_detect_app/services/predict_history_repository_service.dart';

class PredictHistoryScreen extends StatefulWidget {
  final int userID;

  const PredictHistoryScreen({super.key, required this.userID});

  @override
  State<PredictHistoryScreen> createState() => _PredictHistoryScreenState();
}

class _PredictHistoryScreenState extends State<PredictHistoryScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildHistoryCard(DiseaseHistory history) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                history.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🕓 Thời gian rà soát",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    history.timestamp,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "🦠 Những bệnh nhận diện được",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    history.getListDiseaseName(),
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      appBar: AppBar(
        title: const Text(
          'Lịch sử dự đoán',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(color: Colors.green[700]),
      )
          : PredictHistoryReposotory.listDiseaseHistory.isEmpty
          ? const Center(
        child: Text(
          'Chưa có lịch sử dự đoán nào.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.builder(
        itemCount: PredictHistoryReposotory.listDiseaseHistory.length,
        itemBuilder: (context, index) {
          final history = PredictHistoryReposotory.listDiseaseHistory[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryDetailScreen(
                    image: history.image,
                    timestamp: history.timestamp,
                    diseaseInfo: history.detectedDiseases,
                    resultClassCount: history.detectedDiseases.length,
                  ),
                ),
              );
            },
            child: _buildHistoryCard(history),
          );
        },
      ),
    );
  }
}

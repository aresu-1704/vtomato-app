import 'package:flutter/material.dart';
import 'package:tomato_detect_app/models/disease_history_model.dart';
import 'package:tomato_detect_app/screens/history/history_detail_screen.dart';
import 'package:tomato_detect_app/services/disease_history_service.dart';

class PredictHistoryScreen extends StatefulWidget {
  final int userID;

  const PredictHistoryScreen({super.key, required this.userID});

  @override
  _PredictHistoryScreenState createState() => _PredictHistoryScreenState();
}

class _PredictHistoryScreenState extends State<PredictHistoryScreen> {
  final DiseaseHistoryService _service = DiseaseHistoryService();
  bool isLoading = true;
  List<DiseaseHistoryModel> historyList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      historyList = await _service.getHistoryByUser(widget.userID);
    } catch (e) {
      // handle error if needed
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildHistoryCard(DiseaseHistoryModel history) {
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
              child: Image.network(
                history.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  );
                },
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
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.green[700]),
              )
              : historyList.isEmpty
              ? const Center(
                child: Text(
                  'Chưa có lịch sử dự đoán nào.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
              : ListView.builder(
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  final history = historyList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => HistoryDetailScreen(
                                imageUrl: history.imageUrl,
                                timestamp: history.timestamp,
                                diseaseInfo: history.detectedDiseases,
                                resultClassCount:
                                    history.detectedDiseases.length,
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

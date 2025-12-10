import 'package:flutter/material.dart';
import 'package:tomato_detect_app/models/disease_info_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String imageUrl;
  final int resultClassCount;
  final String timestamp;
  final List<DiseaseInfoModel> diseaseInfo;

  const HistoryDetailScreen({
    super.key,
    required this.imageUrl,
    required this.resultClassCount,
    required this.timestamp,
    required this.diseaseInfo,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  bool get hasDiseases => widget.resultClassCount > 0;

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      appBar: AppBar(
        title: FadeIn(
          child: Text(
            widget.timestamp,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            flex: 7,
            child: FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildShimmerPlaceholder();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error, size: 50, color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (hasDiseases)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: widget.diseaseInfo.length,
                  itemBuilder: (context, index) {
                    final disease = widget.diseaseInfo[index];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 200 + (index * 150)),
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
                                const SizedBox(height: 8),
                                Divider(color: Colors.green[200], thickness: 1),
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

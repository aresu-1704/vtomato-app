import 'dart:convert';
import 'dart:typed_data';
import 'package:tomato_detect_app/models/DiseaseInfo.dart';

class DiseaseHistory {
  final Uint8List image;
  final String timestamp;
  final List<DiseaseInfo> detectedDiseases;

  DiseaseHistory({
    required this.image,
    required this.timestamp,
    required this.detectedDiseases,
  });

  factory DiseaseHistory.fromJson(Map<String, dynamic> json) {
    return DiseaseHistory(
      image: base64Decode(json['Image']),
      timestamp: json['Timestamp'],
      detectedDiseases: (json['ListDisease'] as List<dynamic>)
          .map((e) => DiseaseInfo.fromJson(e))
          .toList(),
    );
  }

  String getListDiseaseName() {
    return detectedDiseases.map((e) => e.diseaseName).join(', ');
  }
}

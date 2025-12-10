import 'package:tomato_detect_app/models/disease_info_model.dart';

class DiseaseHistoryModel {
  final String imageUrl; // Changed from Uint8List to String (Cloudinary URL)
  final String timestamp;
  final List<DiseaseInfoModel> detectedDiseases;

  DiseaseHistoryModel({
    required this.imageUrl,
    required this.timestamp,
    required this.detectedDiseases,
  });

  factory DiseaseHistoryModel.fromJson(Map<String, dynamic> json) {
    return DiseaseHistoryModel(
      imageUrl: json['ImageURL'], // Changed from base64Decode(json['Image'])
      timestamp: json['Timestamp'],
      detectedDiseases:
          (json['ListDisease'] as List<dynamic>)
              .map((e) => DiseaseInfoModel.fromJson(e))
              .toList(),
    );
  }

  String getListDiseaseName() {
    return detectedDiseases.map((e) => e.diseaseName).join(', ');
  }
}

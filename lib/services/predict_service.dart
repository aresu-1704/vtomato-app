import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tomato_detect_app/constants/api_constant.dart';
import 'package:tomato_detect_app/models/disease_info_model.dart';

class PredictService {
  /// Upload image to /predict endpoint (API v2.0)
  /// Returns map with: image (Uint8List), class_count (int), class_indices (List<int>)
  Future<Map<String, dynamic>?> uploadImageForPrediction(
    Uint8List imageBytes,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/predict/predict');

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Decode base64 image
          final processedImage = base64Decode(data['image']);
          final classCount = data['class_count'];
          final classIndices = List<int>.from(data['class_indices']);

          return {
            'status': 'success',
            'image': processedImage,
            'class_count': classCount,
            'class_indices': classIndices,
          };
        } else {
          print("Unexpected status: ${data['status']}");
          return null;
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi gửi ảnh: $e');
      return null;
    }
  }

  /// Get disease info from /predict-disease endpoint (API v2.0)
  Future<List<DiseaseInfoModel>?> getDiseaseInfo(List<int> diseaseIds) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/predict/predict-disease');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"disease_ids": diseaseIds}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => DiseaseInfoModel.fromJson(json))
              .toList();
        }
      }

      print('Failed to get disease info: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin bệnh: $e');
      return null;
    }
  }
}

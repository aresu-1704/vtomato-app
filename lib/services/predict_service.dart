import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tomato_detect_app/constants/api_constant.dart';
import 'package:tomato_detect_app/models/disease_info_model.dart';

class PredictService {
  /// Upload image to /predict endpoint (API v3.0 - server-side bbox drawing)
  /// Returns map with: annotatedImage (Uint8List), class_indices (List<int>)
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
          // Parse base64 annotated image
          final base64Image = data['annotated_image'] as String;
          final annotatedImageBytes = base64.decode(base64Image);

          // Parse class indices
          final classIndices =
              (data['class_indices'] as List<dynamic>)
                  .map((e) => e as int)
                  .toList();

          return {
            'status': 'success',
            'annotatedImage': Uint8List.fromList(annotatedImageBytes),
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

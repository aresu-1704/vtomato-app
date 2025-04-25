import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tomato_detect_app/constants/api_constant.dart';
import 'package:tomato_detect_app/models/DiseaseInfo.dart';

class PredictService {
  Future<Map<String, dynamic>?> sendImage(Uint8List imageBytes) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/predict/predict-image');

    try {
      final base64Image = base64Encode(imageBytes);
      final requestBody = json.encode({"Image": base64Image});

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == "success") {
          final processedImage = base64Decode(data['image']);
          final classCount = data['class_count'];
          final classIndices = data['class_indices'];
          final diseaseInfoData = data['data'];
          final List<DiseaseInfo> _diseaseInfoList = (diseaseInfoData as List)
              .map((json) => DiseaseInfo.fromJson(json))
              .toList();

          return {
            'status': 'have_an_disease',
            'image': processedImage,
            'class_count': classCount,
            'class_indices': classIndices,
            'disease_info': _diseaseInfoList
          };
        } else if (data['status'] == "no_disease") {
          return {
            'status': 'no_disease',
            'message': data['message'],
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
      print('Lỗi khi mã hóa hoặc gửi ảnh: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tomato_detect_app/constants/api_constant.dart';
import 'package:tomato_detect_app/models/disease_history_model.dart';

class DiseaseHistoryService {
  Future<bool> saveDiseaseHistory(
    Uint8List imageBytes,
    int userID,
    List<int> classList,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/disease-history/save');

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['UserID'] = userID.toString();
      request.fields['ClassIdxList'] = json.encode(classList);
      request.files.add(
        http.MultipartFile.fromBytes(
          'Image',
          imageBytes,
          filename: 'history.jpg',
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);

      return data['Reload_Status'] ?? false;
    } catch (e) {
      print('Lỗi khi lưu lịch sử: $e');
      return false;
    }
  }

  Future<List<DiseaseHistoryModel>> getHistoryByUser(int userID) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/disease-history/$userID');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['history'] != null) {
          return (data['history'] as List)
              .map((json) => DiseaseHistoryModel.fromJson(json))
              .toList();
        } else {
          print("No 'history' key in response.");
          return [];
        }
      } else {
        print("Server error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception occurred in getHistoryByUser: $e");
      return [];
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tomato_detect_app/constants/api_constant.dart';

class AuthService {

  Future<int?> login(String email, String password) async {
    try{
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Email": email,
          "Password": password,
        }),
      );

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body);
        if(message['message'] == "Login successful"){
          return message['UserID'];
        }
      } else if (response.statusCode == 429) {
        return -2;
      }
      else {
        return null;
      }
    }
    on SocketException{
      return -3;
    }
    catch (ex) {
      print('Lỗi: $ex');
      return null;
    }
  }

  Future<String?> register(String email, String phoneNumber, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Email": email,
          "PhoneNumber": phoneNumber,
          "Password": password
        }),
      );

      if (response.statusCode == 200) {
        return null;
      }
      else {
        final data = jsonDecode(response.body);
        return data['detail'];
      }
    }
    on SocketException{
      return "Connection Error";
    }
    catch (ex) {
      print('Lỗi: $ex');
      return null;
    }
  }

  Future<int?> sendOTPtoemail(String email) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/send-otp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Email": email,
        }),
      );

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body);
        return message['UserID'];
      }
      else if (response.statusCode == 401) {
        return -1;
      }
    }
    // on SocketException{
    //   return -2;
    // }

    catch (ex) {
      print('Lỗi: $ex');
      return null;
    }
  }

  Future<int?> verifyOTP(int userID, int otp) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_id": userID,
        "OTP": otp
      }),
    );

    if (response.statusCode == 200){
      final message = jsonDecode(response.body);
      if(message['Message'] == "Invalid OTP.") {
        return 0;
      }
      else if (message['Message'] == "OTP verified successfully!"){
        return 1;
      }
      else {
        return -1;
      }
    }
    else if (response.statusCode == 401){
      return -1;
    }
  }

  Future<bool?> resetPassword(int userID, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/$userID');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "NewPassword": password,
      }),
    );

    if (response.statusCode == 200) {
      final message = jsonDecode(response.body);
      if(message['message'] == "Password reset successful"){
        return true;
      }
      return false;
    }
    else {
      return false;
    }
  }
}
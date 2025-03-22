import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:japx/japx.dart';

class ApiService {
  static const String baseUrl = "https://test.myfliqapp.com/api/v1";

  /// Send OTP

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final url = Uri.parse(
      "$baseUrl/auth/registration-otp-codes/actions/phone/send-otp",
    );

    Map<String, dynamic> requestData = {
      "data": {
        "type": "registration_otp_codes",
        "attributes": {"phone": phone},
      },
    };

    print("Request Data: ${jsonEncode(requestData)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(requestData),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['data'] is int) {
        return {'otp': jsonResponse['data']};
      } else {
        return jsonResponse['data'];
      }
    } else {
      throw Exception("Failed to send OTP");
    }
  }

  /// Verify OTP
 static Future<String?> verifyOtp(String phone, String otp) async {
    final url = Uri.parse("${baseUrl}/auth/registration-otp-codes/actions/phone/verify-otp");

    final Map<String, dynamic> requestData = {
       "data": {
       "type": "registration_otp_codes",
       "attributes": {
           "phone": phone,
           "otp": 111111,
           "device_meta": {
               "type": "web",
               "name": "HP Pavilion 14-EP0068TU",
               "os": "Linux x86_64",
               "browser": "Mozilla Firefox Snap for Ubuntu (64-bit)",
               "browser_version": "112.0.2",
               "user_agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/112.0",
               "screen_resolution": "1600x900",
               "language": "en-GB"
           }
       }
   }

    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestData),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
      
        String? token = jsonResponse['token'];
        return token;  // Return the token
      } else {
        throw Exception("OTP verification failed: ${jsonResponse['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      throw Exception("Failed to verify OTP");
    }
  }
  /// Get Chat List
  static Future<List<dynamic>> getChatList() async {
    final url = Uri.parse("$baseUrl/chat/chat-messages/queries/contact-users");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final decodedData = Japx.decode(jsonResponse);
      return decodedData['data'];
    } else {
      throw Exception("Failed to load chat list");
    }
  }

  /// Get Chat Between Users
  static Future<List<dynamic>> getChatBetweenUsers(
    String senderId,
    String receiverId,
  ) async {
    final url = Uri.parse(
      "$baseUrl/chat/chat-messages/queries/chat-between-users/$senderId/$receiverId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final decodedData = Japx.decode(jsonResponse);
      return decodedData['data'];
    } else {
      throw Exception("Failed to load messages");
    }
  }
}

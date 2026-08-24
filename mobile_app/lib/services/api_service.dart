import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/inspection_model.dart';

class ApiService {
  // IP Config:
  // Android Emulator: 'http://10.0.2.2:8000'
  // Real Phone: 'http://<Laptop_WiFi_IP>:8000'
  // Web/Desktop: 'http://localhost:8000'
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<InspectionResult> scanProductImage(File imageFile) async {
    try {
      var uri = Uri.parse('/api/scan');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return InspectionResult.fromJson(jsonData);
      } else {
        throw Exception('Server returned status: ');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: ');
    }
  }

  static String getPdfDownloadUrl(int inspectionId) {
    return '/api/download-notice/';
  }
}

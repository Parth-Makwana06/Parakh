import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/inspection_model.dart';

class ApiService {
  // 💡 IP CONFIGURATION:
  // - Android Emulator: 'http://10.0.2.2:8000'
  // - Real Physical Android Phone: 'http://<Laptop_WiFi_IP>:8000' (e.g. 'http://192.168.1.5:8000')
  // - Windows / Web: 'http://localhost:8000'
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<InspectionResult> scanProductImage(File imageFile) async {
    try {
      final uri = Uri.parse('/api/scan');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return InspectionResult.fromJson(jsonData);
      } else {
        throw Exception('Server returned status : ');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend (): ');
    }
  }

  static String getPdfDownloadUrl(int inspectionId) {
    return '/api/download-notice/';
  }
}

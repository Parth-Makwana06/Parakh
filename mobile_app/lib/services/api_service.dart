import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/inspection_model.dart';

class ApiService {
  // 💡 IP CONFIGURATION FOR PHYSICAL PHONE & EMULATOR:
  // - Tamara Laptop nu Wi-Fi IP: 'http://192.168.0.214:8000'
  // - USB reverse / Localhost: 'http://127.0.0.1:8000'
  // - Emulator: 'http://10.0.2.2:8000'
  static const String primaryUrl = 'http://127.0.0.1:8000';
  static const String wifiUrl = 'http://192.168.0.214:8000';
  static const String emulatorUrl = 'http://10.0.2.2:8000';

  static String activeBaseUrl = wifiUrl;

  static Future<InspectionResult> scanProductImage(File imageFile) async {
    final candidateUrls = [wifiUrl, primaryUrl, emulatorUrl];
    Exception? lastException;

    for (final baseUrl in candidateUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/scan');
        final request = http.MultipartRequest('POST', uri);

        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

        final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          activeBaseUrl = baseUrl;
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return InspectionResult.fromJson(jsonData);
        } else {
          throw Exception('Server returned status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        lastException = Exception('Failed to connect to ($baseUrl): $e');
      }
    }

    throw lastException ?? Exception('Failed to connect to any backend endpoint.');
  }

  static String getPdfDownloadUrl(dynamic inspectionId) {
    return '$activeBaseUrl/api/download-notice/$inspectionId';
  }
}

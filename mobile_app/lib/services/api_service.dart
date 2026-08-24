import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/inspection_model.dart';

class ApiService {
  // 💡 Auto-Endpoints (Wi-Fi IP, USB Reverse ADB, Emulator):
  static const String wifiUrl = 'http://192.168.0.214:8000';
  static const String localhostUrl = 'http://127.0.0.1:8000';
  static const String emulatorUrl = 'http://10.0.2.2:8000';

  static String activeBaseUrl = wifiUrl;

  static Future<InspectionResult> scanProductBytes(Uint8List bytes, String filename) async {
    final candidateUrls = [wifiUrl, localhostUrl, emulatorUrl];
    Exception? lastException;

    for (final baseUrl in candidateUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/scan');
        final request = http.MultipartRequest('POST', uri);

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: filename,
          ),
        );

        final streamedResponse = await request.send().timeout(const Duration(seconds: 12));
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

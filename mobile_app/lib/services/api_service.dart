import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/inspection_model.dart';

class ApiService {
  // 💡 Endpoints:
  // 1. USB ADB Reverse (127.0.0.1:8000) - Instant over USB cable!
  // 2. Wi-Fi IP (192.168.0.214:8000)
  // 3. Android Emulator (10.0.2.2:8000)
  static const String localhostUrl = 'http://127.0.0.1:8000';
  static const String wifiUrl = 'http://192.168.0.214:8000';
  static const String emulatorUrl = 'http://10.0.2.2:8000';

  static String customUrl = localhostUrl;

  static Future<InspectionResult> scanProductBytes(Uint8List bytes, String filename) async {
    final candidateUrls = [customUrl, localhostUrl, wifiUrl, emulatorUrl];
    final uniqueUrls = candidateUrls.toSet().toList();
    Exception? lastException;

    for (final baseUrl in uniqueUrls) {
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

        final streamedResponse = await request.send().timeout(const Duration(seconds: 5));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          customUrl = baseUrl;
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return InspectionResult.fromJson(jsonData);
        } else {
          throw Exception('Server error (${response.statusCode}): ${response.body}');
        }
      } catch (e) {
        lastException = Exception('Failed on $baseUrl: $e');
      }
    }

    throw lastException ?? Exception('Failed to connect to backend.');
  }

  static String getPdfDownloadUrl(dynamic inspectionId) {
    return '$customUrl/api/download-notice/$inspectionId';
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inspection_model.dart';

class ApiService {
  // 💡 Default to USB ADB Reverse (127.0.0.1:8000) for instant 100% reliable connection:
  static String customUrl = 'http://127.0.0.1:8000';

  // Test Server Health Connection
  static Future<bool> testConnection(String url) async {
    try {
      final uri = Uri.parse(url.endsWith('/') ? url : '$url/');
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Scan Product Multipart
  static Future<InspectionResult> scanProductFiles(List<Map<String, dynamic>> files, String location) async {
    final targetUrl = customUrl.trim().endsWith('/')
        ? customUrl.trim().substring(0, customUrl.trim().length - 1)
        : customUrl.trim();

    try {
      final uri = Uri.parse('$targetUrl/api/scan');
      final request = http.MultipartRequest('POST', uri);
      
      // Inspector Location
      request.fields['location'] = location;

      for (var file in files) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            file['bytes'],
            filename: file['filename'],
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return InspectionResult.fromJson(jsonData);
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Could not reach $targetUrl ($e)');
    }
  }

  static String getPdfDownloadUrl(dynamic inspectionId) {
    final targetUrl = customUrl.trim().endsWith('/')
        ? customUrl.trim().substring(0, customUrl.trim().length - 1)
        : customUrl.trim();
    return '$targetUrl/api/download-notice/$inspectionId';
  }

  // Fetch all past inspections from backend SQLite DB
  static Future<List<Map<String, dynamic>>> fetchHistory() async {
    final targetUrl = customUrl.trim().endsWith('/')
        ? customUrl.trim().substring(0, customUrl.trim().length - 1)
        : customUrl.trim();
    try {
      final uri = Uri.parse('$targetUrl/api/history');
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}

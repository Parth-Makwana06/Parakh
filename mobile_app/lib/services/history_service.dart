import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inspection_model.dart';
import 'api_service.dart';

class HistoryItem {
  final InspectionResult result;
  final List<Uint8List> images; // empty list for backend-loaded items
  final DateTime timestamp;
  final bool isFromBackend;

  HistoryItem({
    required this.result,
    required this.images,
    required this.timestamp,
    this.isFromBackend = false,
  });
}

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<HistoryItem> _items = [];
  bool isLoading = false;
  String? loadError;

  List<HistoryItem> get items => List.unmodifiable(_items);

  // ─── Local Save (SharedPreferences) ────────────────────────────────────────

  /// Locally phone ma save karo (backend vinaa pn dekhay)
  Future<void> _saveLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((item) {
        return {
          'inspection_id': item.result.inspectionId?.toString(),
          'status': item.result.status,
          'total_violations': item.result.totalViolations,
          'timestamp': item.timestamp.toIso8601String(),
          'violations_list': item.result.violations.map((v) => {
            'rule': v.rule,
            'severity': v.severity,
            'description': v.description,
          }).toList(),
          'extracted_fields': {
            'MRP': item.result.extractedFields.mrp,
            'Net_Quantity': item.result.extractedFields.netQty,
            'Mfg_Date': item.result.extractedFields.mfgDate,
            'Consumer_Care': item.result.extractedFields.consumerPhone,
            'consumer_email': item.result.extractedFields.consumerEmail,
            'mfg_declaration': item.result.extractedFields.mfgDeclaration,
          },
        };
      }).toList();
      await prefs.setString('parakh_history', jsonEncode(list));
    } catch (e) {
      debugPrint('Local save error: $e');
    }
  }

  /// Locally saved data phone thi load karo
  Future<List<HistoryItem>> _loadLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('parakh_history');
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List;
      return list.map((json) {
        DateTime ts = DateTime.now();
        try { ts = DateTime.parse(json['timestamp'] ?? ''); } catch (_) {}

        final result = InspectionResult(
          inspectionId: json['inspection_id'],
          status: json['status']?.toString() ?? 'Unknown',
          totalViolations: json['total_violations'] is int
              ? json['total_violations']
              : int.tryParse(json['total_violations']?.toString() ?? '0') ?? 0,
          violations: ((json['violations_list'] as List?) ?? [])
              .map((v) => Violation.fromJson(v))
              .toList(),
          extractedFields: ExtractedFields.fromJson(
            json['extracted_fields'] is Map<String, dynamic>
                ? json['extracted_fields']
                : {},
          ),
        );

        return HistoryItem(
          result: result,
          images: [],
          timestamp: ts,
          isFromBackend: true,
        );
      }).toList();
    } catch (e) {
      debugPrint('Local load error: $e');
      return [];
    }
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Called after a new scan — adds to top + saves locally
  void addInspection(InspectionResult result, List<Uint8List> images) {
    _items.insert(0, HistoryItem(
      result: result,
      images: List.from(images),
      timestamp: DateTime.now(),
      isFromBackend: false,
    ));
    notifyListeners();
    _saveLocally(); // phone ma save karo
  }

  /// App open thay tyare: pehla local data dekhao, pachi backend thi sync karo
  Future<void> loadFromBackend() async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    // Step 1: Local data thi instant load (backend vinaa pn dekhay)
    final localItems = await _loadLocally();
    if (localItems.isNotEmpty) {
      _items
        ..clear()
        ..addAll(localItems);
      isLoading = false;
      notifyListeners(); // turant dekhao
    }

    // Step 2: Backend thi fresh data fetch karo (available hoy to)
    try {
      final rawList = await ApiService.fetchHistory();
      if (rawList.isEmpty) {
        // Backend na mile to local data j rakho
        if (localItems.isEmpty) loadError = 'No data found.';
        isLoading = false;
        notifyListeners();
        return;
      }

      final backendItems = rawList.map((json) {
        DateTime ts = DateTime.now();
        try { ts = DateTime.parse(json['timestamp'] ?? ''); } catch (_) {}

        final result = InspectionResult(
          inspectionId: json['inspection_id'],
          status: json['status']?.toString() ?? 'Unknown',
          totalViolations: json['total_violations'] is int
              ? json['total_violations']
              : int.tryParse(json['total_violations']?.toString() ?? '0') ?? 0,
          violations: ((json['violations_list'] as List?) ?? [])
              .map((v) => Violation.fromJson(v))
              .toList(),
          extractedFields: ExtractedFields.fromJson(
            json['extracted_fields'] is Map<String, dynamic>
                ? json['extracted_fields']
                : {},
          ),
        );

        return HistoryItem(
          result: result,
          images: [],
          timestamp: ts,
          isFromBackend: true,
        );
      }).toList();

      // Sort newest first
      backendItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _items
        ..clear()
        ..addAll(backendItems);

      // Backend thi milelu local ma pn save karo
      await _saveLocally();

    } catch (e) {
      // Backend na mile to local data already dekhay che — koi problem nahi
      loadError = localItems.isEmpty ? e.toString() : null;
      debugPrint('Backend fetch error (local data shown): $e');
    }

    isLoading = false;
    notifyListeners();
  }
}

final historyService = HistoryService();

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/inspection_model.dart';

class HistoryItem {
  final InspectionResult result;
  final List<Uint8List> images;
  final DateTime timestamp;

  HistoryItem({
    required this.result,
    required this.images,
    required this.timestamp,
  });
}

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<HistoryItem> _items = [];

  List<HistoryItem> get items => List.unmodifiable(_items);

  void addInspection(InspectionResult result, List<Uint8List> images) {
    _items.insert(0, HistoryItem(
      result: result,
      images: List.from(images), // Copy the list
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}

final historyService = HistoryService();

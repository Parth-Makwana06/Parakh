import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/inspection_model.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<XFile> _pickedFiles = [];
  List<Uint8List> _imageBytesList = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  InspectionResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLostData();
  }

  Future<void> _checkLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.file != null) {
        final bytes = await response.file!.readAsBytes();
        setState(() {
          _pickedFiles.add(response.file!);
          _imageBytesList.add(bytes);
          _result = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint("Lost data error: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> files = await _picker.pickMultiImage(
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 85,
        );
        if (files.isNotEmpty) {
          for (var file in files) {
            final bytes = await file.readAsBytes();
            _pickedFiles.add(file);
            _imageBytesList.add(bytes);
          }
          setState(() {
            _result = null;
            _errorMessage = null;
          });
        }
      } else {
        final XFile? file = await _picker.pickImage(
          source: source,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 85,
        );
        if (file != null) {
          final bytes = await file.readAsBytes();
          setState(() {
            _pickedFiles.add(file);
            _imageBytesList.add(bytes);
            _result = null;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error capturing image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytesList.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Map<String, dynamic>> filesData = [];
      for (int i = 0; i < _pickedFiles.length; i++) {
        filesData.add({
          'bytes': _imageBytesList[i],
          'filename': _pickedFiles[i].name
        });
      }

      final result = await ApiService.scanProductFiles(filesData);
      setState(() {
        _result = result;
        _isLoading = false;
      });
      historyService.addInspection(result, _imageBytesList);
      setState(() {
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection Error: Make sure FastAPI server is running!\n($e)';
      });
    }
  }

  void _resetScan() {
    setState(() {
      _imageBytesList.clear();
      _pickedFiles.clear();
      _result = null;
      _errorMessage = null;
    });
  }

  Future<void> _downloadPdf(dynamic id) async {
    final url = Uri.parse(ApiService.getPdfDownloadUrl(id));
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF file.')),
      );
    }
  }

  void _showServerConfigDialog() {
    final controller = TextEditingController(text: ApiService.customUrl);
    String? testStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(settingsService.translate('server_url'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected FastAPI Server URL:', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  hintText: 'http://192.168.0.214:8000',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ActionChip(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    label: Text('Wi-Fi (192.168.0.214:8000)', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      setDialogState(() {
                        controller.text = 'http://192.168.0.214:8000';
                        testStatus = null;
                      });
                    },
                  ),
                  ActionChip(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    label: Text('USB (127.0.0.1:8000)', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      setDialogState(() {
                        controller.text = 'http://127.0.0.1:8000';
                        testStatus = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  setDialogState(() => testStatus = 'Testing connection...');
                  final ok = await ApiService.testConnection(controller.text.trim());
                  setDialogState(() => testStatus = ok ? '✅ Server Connected Online!' : '❌ Cannot reach server');
                },
                icon: const Icon(Icons.wifi_tethering, size: 16),
                label: Text(settingsService.translate('test_connection'), style: TextStyle(fontSize: 12)),
              ),
              if (testStatus != null) ...[
                const SizedBox(height: 6),
                Text(testStatus!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: testStatus!.startsWith('✅') ? Colors.green : Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(settingsService.translate('cancel'))),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  ApiService.customUrl = controller.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server set to: ${ApiService.customUrl}')),
                );
              },
              child: Text(settingsService.translate('save')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(settingsService.translate('capture_photo'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library, color: themeColor),
                      label: Text(settingsService.translate('gallery'), style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: themeColor, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // 2. Image Preview Card
            if (_imageBytesList.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          child: SizedBox(
                            height: 240,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageBytesList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      _imageBytesList[index],
                                      height: 232,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (_result == null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              onPressed: _resetScan,
                              style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7)),
                            ),
                          ),
                      ],
                    ),
                    if (_result == null)
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.add_a_photo, size: 18),
                                label: Text(settingsService.translate('add'), style: TextStyle(fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _analyzeImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(settingsService.translate('analyze'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 3. Error Alert
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 12))),
                  ],
                ),
              ),

            // 4. Results View
            if (_result != null) ...[
              _buildStatusCard(context, _result!),
              const SizedBox(height: 14),
              _buildExtractedFieldsCard(context, _result!.extractedFields),
              const SizedBox(height: 14),
              _buildViolationsList(context, _result!.violations),
              const SizedBox(height: 18),
              if (_result!.inspectionId != null)
                ElevatedButton.icon(
                  onPressed: () => _downloadPdf(_result!.inspectionId!),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text(settingsService.translate('download_pdf'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _resetScan,
                icon: const Icon(Icons.refresh),
                label: Text(settingsService.translate('scan_another'), style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, InspectionResult result) {
    final isCompliant = result.status.toLowerCase() == 'pass' || result.status.toLowerCase() == 'compliant';
    final bgColor = isCompliant ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.errorContainer;
    final borderColor = isCompliant ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error;
    final textColor = isCompliant ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onErrorContainer;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(isCompliant ? Icons.check_circle : Icons.cancel, color: textColor, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompliant ? '100% LMPC COMPLIANT' : 'NON-COMPLIANCE DETECTED',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  isCompliant
                      ? 'All mandatory declarations meet Legal Metrology Rules, 2011.'
                      : '${result.totalViolations} Legal Violation(s) flagged on this package.',
                  style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedFieldsCard(BuildContext context, ExtractedFields fields) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settingsService.translate('extracted_declarations'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
          const Divider(height: 16),
          _buildInfoRow('Net Quantity:', fields.netQty ?? 'Missing', fields.netQty != null),
          _buildInfoRow('Declared MRP:', fields.mrp ?? 'Missing', fields.mrp != null),
          _buildInfoRow('Mfg / Packing Date:', fields.mfgDate ?? 'Missing', fields.mfgDate != null),
          _buildInfoRow('Consumer Care:', fields.consumerPhone ?? fields.consumerEmail ?? 'Missing', fields.consumerPhone != null || fields.consumerEmail != null),
          _buildInfoRow('Manufacturer Address:', fields.mfgDeclaration ? 'Detected' : 'Missing', fields.mfgDeclaration),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, bool isFound) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isFound ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationsList(BuildContext context, List<Violation> violations) {
    if (violations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settingsService.translate('legal_violations'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        ...violations.map((v) => Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).colorScheme.error),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(v.rule, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 12.5)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(v.severity, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(v.description, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 11.5)),
                ],
              ),
            )),
      ],
    );
  }
}

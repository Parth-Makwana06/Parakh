import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/inspection_model.dart';
import '../services/api_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  XFile? _pickedFile;
  Uint8List? _imageBytes;
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
          _pickedFile = response.file;
          _imageBytes = bytes;
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
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _pickedFile = file;
          _imageBytes = bytes;
          _result = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error capturing image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.scanProductBytes(
        _imageBytes!,
        _pickedFile?.name ?? 'label_scan.jpg',
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection Error: Make sure FastAPI server is running!\n($e)';
      });
    }
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
          title: const Text('⚙️ Server Endpoint URL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selected FastAPI Server URL:', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    backgroundColor: const Color(0xFFEFF6FF),
                    label: const Text('Wi-Fi (192.168.0.214:8000)', style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold)),
                    onPressed: () {
                      setDialogState(() {
                        controller.text = 'http://192.168.0.214:8000';
                        testStatus = null;
                      });
                    },
                  ),
                  ActionChip(
                    backgroundColor: const Color(0xFFF1F5F9),
                    label: const Text('USB (127.0.0.1:8000)', style: TextStyle(fontSize: 11)),
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
                label: const Text('Test Connection', style: TextStyle(fontSize: 12)),
              ),
              if (testStatus != null) ...[
                const SizedBox(height: 6),
                Text(testStatus!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: testStatus!.startsWith('✅') ? Colors.green : Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF1B365D);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.verified_outlined, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MetrologyLens AI',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Field Inspector Portal • LMPC 2011',
                  style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_find, color: Colors.white, size: 22),
            tooltip: 'Server Settings',
            onPressed: _showServerConfigDialog,
          ),
          Container(
            margin: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'InsightX',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Capture Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Capture Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: themeColor),
                    label: const Text('Gallery', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: themeColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Image Preview Card
            if (_imageBytes != null) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.memory(
                        _imageBytes!,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _analyzeImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                  SizedBox(width: 12),
                                  Text('Running OCR & Rule Engine...', style: TextStyle(color: Colors.white)),
                                ],
                              )
                            : const Text('🔍 Analyze Compliance (LMPC 2011)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF87171)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12))),
                  ],
                ),
              ),

            // 4. Results View
            if (_result != null) ...[
              _buildStatusCard(_result!),
              const SizedBox(height: 14),
              _buildExtractedFieldsCard(_result!.extractedFields),
              const SizedBox(height: 14),
              _buildViolationsList(_result!.violations),
              const SizedBox(height: 18),
              if (_result!.inspectionId != null)
                ElevatedButton.icon(
                  onPressed: () => _downloadPdf(_result!.inspectionId!),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text('📄 Download Legal Notice (PDF)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(InspectionResult result) {
    final isCompliant = result.status.toLowerCase() == 'pass' || result.status.toLowerCase() == 'compliant';
    final bgColor = isCompliant ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final borderColor = isCompliant ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
    final textColor = isCompliant ? const Color(0xFF166534) : const Color(0xFF991B1B);

    return Container(
      padding: const EdgeInsets.all(16),
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

  Widget _buildExtractedFieldsCard(ExtractedFields fields) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📋 Extracted Declarations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isFound ? const Color(0xFF1E293B) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationsList(List<Violation> violations) {
    if (violations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🚨 Legal Violations Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        ...violations.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(v.rule, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 12.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(v.severity, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(v.description, style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 11.5)),
                ],
              ),
            )),
      ],
    );
  }
}

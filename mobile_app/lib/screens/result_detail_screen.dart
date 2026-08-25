import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/history_service.dart';
import '../models/inspection_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class ResultDetailScreen extends StatelessWidget {
  final HistoryItem item;

  const ResultDetailScreen({super.key, required this.item});

  Future<void> _downloadPdf(BuildContext context, dynamic id) async {
    final url = Uri.parse(ApiService.getPdfDownloadUrl(id));
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = item.result;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListenableBuilder(
        listenable: settingsService,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display Images
                if (item.images.isNotEmpty)
                  Container(
                    height: 240,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: item.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              item.images[index],
                              height: 232,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Result Cards
                _buildStatusCard(context, result),
                const SizedBox(height: 14),
                _buildExtractedFieldsCard(context, result.extractedFields),
                const SizedBox(height: 14),
                _buildViolationsList(context, result.violations),
                const SizedBox(height: 18),
                if (result.inspectionId != null)
                  ElevatedButton.icon(
                    onPressed: () => _downloadPdf(context, result.inspectionId!),
                    icon: Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.onError),
                    label: Text(settingsService.translate('download_pdf'), style: TextStyle(color: Theme.of(context).colorScheme.onError, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
          Icon(
            isCompliant ? Icons.check_circle : Icons.warning_amber_rounded,
            color: borderColor,
            size: 40,
          ),
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
          _buildInfoRow(context, 'Net Quantity:', fields.netQty ?? 'Missing', fields.netQty != null),
          _buildInfoRow(context, 'Declared MRP:', fields.mrp ?? 'Missing', fields.mrp != null),
          _buildInfoRow(context, 'Mfg / Packing Date:', fields.mfgDate ?? 'Missing', fields.mfgDate != null),
          _buildInfoRow(context, 'Consumer Care:', fields.consumerPhone ?? fields.consumerEmail ?? 'Missing', fields.consumerPhone != null || fields.consumerEmail != null),
          _buildInfoRow(context, 'Manufacturer Address:', fields.mfgDeclaration ? 'Detected' : 'Missing', fields.mfgDeclaration),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value, bool isFound) {
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
                    children: [
                      Icon(Icons.gavel, color: Theme.of(context).colorScheme.error, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          v.rule,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          v.severity,
                          style: TextStyle(color: Theme.of(context).colorScheme.onError, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    v.description,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}

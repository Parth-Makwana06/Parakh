import 'result_detail_screen.dart';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([settingsService, historyService]),
      builder: (context, child) {
        final inspections = historyService.items;

        if (inspections.isEmpty) {
          return Center(
            child: Text(
              'No inspection history found.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: inspections.length,
          itemBuilder: (context, index) {
            final item = inspections[index];
            final result = item.result;
            final isCompliant = result.totalViolations == 0;
            
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultDetailScreen(item: item),
                  ),
                );
              },
              child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ),
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: isCompliant 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    isCompliant ? Icons.check_circle : Icons.warning,
                    color: isCompliant 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.error,
                  ),
                ),
                title: Text(
                  isCompliant ? 'Compliant Inspection' : 'Violation Detected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Violations: ${result.totalViolations}\n'
                    'Net Qty: ${result.extractedFields.netQty ?? "N/A"}',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            );
          },
        );
      },
    );
  }
}

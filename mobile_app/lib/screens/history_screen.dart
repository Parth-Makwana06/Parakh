import 'result_detail_screen.dart';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // MainScreen already loads on startup.
    // Sirf reload karo je history already empty hoy to (fresh open case)
    if (historyService.items.isEmpty && !historyService.isLoading) {
      historyService.loadFromBackend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([settingsService, historyService]),
      builder: (context, child) {

        // Loading state
        if (historyService.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading inspection history...'),
              ],
            ),
          );
        }

        final inspections = historyService.items;

        // Empty state
        if (inspections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  'No inspection history found.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                if (historyService.loadError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Could not load from server.\nMake sure backend is running.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => historyService.loadFromBackend(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          // Pull-to-refresh thi pn reload thay
          onRefresh: () => historyService.loadFromBackend(),
          child: ListView.builder(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Violations: ${result.totalViolations}\n'
                            'Net Qty: ${result.extractedFields.netQty ?? "N/A"}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(item.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          // Backend thi loaded che to badge dekhao
                          if (item.isFromBackend)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'From DB',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

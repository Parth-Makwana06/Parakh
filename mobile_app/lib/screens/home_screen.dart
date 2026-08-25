import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parakh Dashboard'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Inspector',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B365D),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending\nInspections',
                    '12',
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Completed\nToday',
                    '5',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B365D),
              ),
            ),
            const SizedBox(height: 12),
            _buildActivityItem('Shop XYZ Inspection', 'Approved - 2 hours ago'),
            _buildActivityItem('ABC Traders', 'Rejected - 5 hours ago'),
            _buildActivityItem('Supermart', 'Pending Review - 1 day ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B365D).withOpacity(0.1),
          child: const Icon(Icons.history, color: Color(0xFF1B365D)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

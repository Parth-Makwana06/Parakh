import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../services/settings_service.dart';
import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showProfile = false;

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
    final colorScheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, child) {
        final List<Widget> screens = [
          const HomeScreen(),
          const ScanScreen(),
          const HistoryScreen(),
          const SettingsScreen(),
        ];

        String getAppBarTitle() {
          if (_showProfile) return settingsService.translate('profile');
          switch (_currentIndex) {
            case 0: return settingsService.translate('dashboard');
            case 1: return settingsService.translate('app_title_parakh');
            case 2: return settingsService.translate('history');
            case 3: return settingsService.translate('settings');
            default: return 'Parakh';
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/logo.jpg', height: 32, width: 32, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Text(getAppBarTitle()),
              ],
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            actions: [
              if (_currentIndex == 1 && !_showProfile)
                IconButton(
                  icon: Icon(Icons.wifi_find, color: colorScheme.onPrimary, size: 22),
                  tooltip: 'Server Settings',
                  onPressed: _showServerConfigDialog,
                ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                iconSize: 32,
                tooltip: settingsService.translate('profile'),
                onPressed: () {
                  setState(() {
                    _showProfile = true;
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _showProfile ? const ProfileScreen() : screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _showProfile = false;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurfaceVariant,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: settingsService.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.document_scanner),
                label: settingsService.translate('scan'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: settingsService.translate('history'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: settingsService.translate('settings'),
              ),
            ],
          ),
        );
      }
    );
  }
}

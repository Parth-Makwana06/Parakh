import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader(context, settingsService.translate('theme')),
            _buildThemeOption(context, ThemeMode.system, settingsService.translate('system'), Icons.brightness_auto),
            _buildThemeOption(context, ThemeMode.light, settingsService.translate('light'), Icons.light_mode),
            _buildThemeOption(context, ThemeMode.dark, settingsService.translate('dark'), Icons.dark_mode),
            const SizedBox(height: 24),
            _buildSectionHeader(context, settingsService.translate('language')),
            _buildLanguageOption(context, const Locale('en'), settingsService.translate('english'), '🇬🇧'),
            _buildLanguageOption(context, const Locale('hi'), settingsService.translate('hindi'), '🇮🇳'),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode mode, String title, IconData icon) {
    final isSelected = settingsService.themeMode == mode;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant),
        title: Text(title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: () => settingsService.setThemeMode(mode),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, Locale locale, String title, String flag) {
    final isSelected = settingsService.locale.languageCode == locale.languageCode;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: () => settingsService.setLocale(locale),
      ),
    );
  }
}

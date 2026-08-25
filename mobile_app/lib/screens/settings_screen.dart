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
              _buildThemeOption(context, ThemeMode.system, settingsService.translate('system')),
              _buildThemeOption(context, ThemeMode.light, settingsService.translate('light')),
              _buildThemeOption(context, ThemeMode.dark, settingsService.translate('dark')),
              const SizedBox(height: 24),
              _buildSectionHeader(context, settingsService.translate('language')),
              _buildLanguageOption(context, const Locale('en'), settingsService.translate('english')),
              _buildLanguageOption(context, const Locale('hi'), settingsService.translate('hindi')),
            ],
          );
      }
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

  Widget _buildThemeOption(BuildContext context, ThemeMode mode, String title) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: mode,
      groupValue: settingsService.themeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          settingsService.setThemeMode(value);
        }
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, Locale locale, String title) {
    return RadioListTile<Locale>(
      title: Text(title),
      value: locale,
      groupValue: settingsService.locale,
      onChanged: (Locale? value) {
        if (value != null) {
          settingsService.setLocale(value);
        }
      },
    );
  }
}

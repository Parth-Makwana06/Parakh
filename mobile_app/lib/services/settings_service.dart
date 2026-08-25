import 'package:flutter/material.dart';

class SettingsService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // General
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'system': 'System Default',
      'light': 'Light',
      'dark': 'Dark',
      'english': 'English',
      'hindi': 'Hindi',
      
      // Profile
      'profile': 'Profile',
      'inspector_id': 'Inspector ID',
      'email': 'Email',
      'login': 'Login',
      'logout': 'Logout',
      'delete_account': 'Delete Account',
      
      // Home / Dashboard
      'home': 'Home',
      'dashboard': 'Parakh Dashboard',
      'welcome': 'Welcome, Inspector',
      'pending_inspections': 'Pending\nInspections',
      'completed_today': 'Completed\nToday',
      'recent_activities': 'Recent Activities',
      'history_coming_soon': 'History (Coming Soon)',
      
      // Main Navigation
      'scan': 'Scan',
      'history': 'History',
      
      // Scan Screen
      'app_title_parakh': 'PARAKH',
      'app_subtitle': 'AI Metrology Inspector',
      'capture_photo': 'Capture Photo',
      'gallery': 'Gallery',
      'add': 'Add',
      'analyze': '🔍 Analyze',
      'download_pdf': '📄 Download Legal Notice (PDF)',
      'scan_another': 'Scan Another Product (Reset)',
      'extracted_declarations': '📋 Extracted Declarations',
      'legal_violations': '🚨 Legal Violations Breakdown',
      'server_url': '⚙️ Server Endpoint URL',
      'test_connection': 'Test Connection',
      'cancel': 'Cancel',
      'save': 'Save',
      'error_capturing': 'Error capturing image',
      'could_not_open_pdf': 'Could not open PDF file.',
      
      // Splash
      'inspector_portal': 'Legal Metrology Inspector Portal',
    },
    'hi': {
      // General
      'settings': 'सेटिंग्स',
      'theme': 'थीम',
      'language': 'भाषा',
      'system': 'सिस्टम डिफ़ॉल्ट',
      'light': 'लाइट',
      'dark': 'डार्क',
      'english': 'अंग्रेज़ी (English)',
      'hindi': 'हिन्दी (Hindi)',
      
      // Profile
      'profile': 'प्रोफ़ाइल',
      'inspector_id': 'इंस्पेक्टर आईडी',
      'email': 'ईमेल',
      'login': 'लॉग इन करें',
      'logout': 'लॉग आउट',
      'delete_account': 'खाता हटाएं',
      
      // Home / Dashboard
      'home': 'होम',
      'dashboard': 'परख डैशबोर्ड',
      'welcome': 'नमस्ते, इंस्पेक्टर',
      'pending_inspections': 'लंबित\nनिरीक्षण',
      'completed_today': 'आज पूरे\nकिए गए',
      'recent_activities': 'हाल की गतिविधियां',
      'history_coming_soon': 'इतिहास (जल्द आ रहा है)',
      
      // Main Navigation
      'scan': 'स्कैन',
      'history': 'इतिहास',
      
      // Scan Screen
      'app_title_parakh': 'परख',
      'app_subtitle': 'एआई मेट्रोलॉजी इंस्पेक्टर',
      'capture_photo': 'फोटो खींचें',
      'gallery': 'गैलरी',
      'add': 'जोड़ें',
      'analyze': '🔍 विश्लेषण करें',
      'download_pdf': '📄 कानूनी नोटिस डाउनलोड करें (PDF)',
      'scan_another': 'दूसरा उत्पाद स्कैन करें (रीसेट)',
      'extracted_declarations': '📋 निकाली गई जानकारी',
      'legal_violations': '🚨 कानूनी उल्लंघन',
      'server_url': '⚙️ सर्वर URL',
      'test_connection': 'कनेक्शन जांचें',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'error_capturing': 'चित्र लेने में त्रुटि',
      'could_not_open_pdf': 'पीडीएफ फाइल नहीं खुल सकी।',
      
      // Splash
      'inspector_portal': 'कानूनी मापविज्ञान निरीक्षक पोर्टल',
    }
  };

  String translate(String key) {
    return _translations[_locale.languageCode]?[key] ?? key;
  }
}

final settingsService = SettingsService();

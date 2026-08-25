import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/settings_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MetrologyLensApp());
}

class MetrologyLensApp extends StatelessWidget {
  const MetrologyLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Parakh',
          debugShowCheckedModeBanner: false,
          themeMode: settingsService.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B365D), brightness: Brightness.light),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B365D), brightness: Brightness.dark),
            useMaterial3: true,
          ),
          locale: settingsService.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('hi', ''),
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}

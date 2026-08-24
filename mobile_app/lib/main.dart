import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MetrologyLensApp());
}

class MetrologyLensApp extends StatelessWidget {
  const MetrologyLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parakh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B365D)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

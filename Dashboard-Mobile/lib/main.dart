import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/screens/splash_screen.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await FcmService.initialize();
  } catch (e) {
    if (kDebugMode) print('Firebase initialization failed: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Enable in debug mode
      builder: (context) => const RiyadlulHudaApp(),
    ),
  );
}

class RiyadlulHudaApp extends StatelessWidget {
  const RiyadlulHudaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Management Riyadlul Huda',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context), // Required for DevicePreview
      builder: DevicePreview.appBuilder, // Required for DevicePreview
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Green for Riyadlul Huda
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF4CAF50),
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.outfit().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF1F2937)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

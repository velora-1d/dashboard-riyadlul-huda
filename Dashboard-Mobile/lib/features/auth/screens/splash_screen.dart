import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Artificial delay for branding
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await ApiService().loadToken();
      if (token != null) {
        // Verify token validity by fetching user profile
        try {
          final response = await ApiService().get('user');
          final role = response.data['role'];
          final name = response.data['name'];

          // Save role for future reference
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_role', role);
          await prefs.setString('user_name', name);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(role: role),
              ),
            );
          }
        } catch (e) {
          // Token invalid or network error
          debugPrint('Session check failed: $e');
          _goToLogin();
        }
      } else {
        _goToLogin();
      }
    } catch (e) {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.school, size: 80, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 24),
            Text(
              'MANAGEMENT\nRIYADLUL HUDA',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFF1B5E20),
            ),
          ],
        ),
      ),
    );
  }
}

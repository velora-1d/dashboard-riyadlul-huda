import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../services/fcm_service.dart';
import '../../dashboard/screens/dashboard_screen.dart'; // Will be created next

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaSantriController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isParentLogin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _namaSantriController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    debugPrint("Attempting login...");
    if (!_formKey.currentState!.validate()) {
      debugPrint("Form validation failed");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final endpoint = _isParentLogin ? 'parent/login' : 'login';
      Map<String, dynamic> payload = {};

      if (_isParentLogin) {
        // Parse DD-MM-YYYY -> YYYY-MM-DD
        String finalTanggalLahir = _tanggalLahirController.text;
        if (finalTanggalLahir.contains('-')) {
          final parts = finalTanggalLahir.split('-');
          if (parts.length == 3) {
            finalTanggalLahir = '${parts[2]}-${parts[1]}-${parts[0]}';
          }
        }

        payload = {
          'nama_santri': _namaSantriController.text,
          'tanggal_lahir': finalTanggalLahir,
        };
      } else {
        payload = {
          'email': _emailController.text,
          'password': _passwordController.text,
        };
      }

      debugPrint(
          "Sending request to ${apiService.client.options.baseUrl}$endpoint");

      final response = await apiService.client.post(endpoint, data: payload);

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response data: ${response.data}");

      if (response.statusCode == 200) {
        // Access Token & User Data Extraction
        String token;
        String name;
        String role;

        if (_isParentLogin) {
          // Parent Response Structure
          token = response.data['data']['token'];
          name = response.data['data']['santri']['nama_santri'];
          role = response.data['data']['role']; // 'wali_santri'
        } else {
          // Staff/Admin Response Structure
          token = response.data['access_token'];
          name = response.data['user']['name'];
          role = response.data['user']['role'];
        }

        debugPrint("Token received: $token");

        // Save token & user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', name);
        await prefs.setString('user_role', role);

        await apiService.setToken(token);

        // Sync FCM Token with Backend
        try {
          await FcmService.syncTokenWithBackend();
        } catch (e) {
          debugPrint("FCM Sync Error: $e");
          // Don't block login if FCM fails
        }

        if (mounted) {
          debugPrint("Navigating to Dashboard...");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Berhasil!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } on DioException catch (e) {
      debugPrint("Login Error: ${e.message}");
      debugPrint("Error Response: ${e.response?.data}");
      String errorMessage = 'Login Gagal. Cek koneksi atau kredensial.';

      if (e.response != null && e.response!.data != null) {
        if (e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20), // Background dasar hijau
      body: Stack(
        children: [
          // 1. Header Section (Image + Gradient + Content)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // A. Background Image (Blurred)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Image.asset(
                    'assets/images/background.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                // B. Gradient Overlay (Green Transparency)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1B5E20).withOpacity(0.85),
                        const Color(0xFF2E7D32).withOpacity(0.75),
                      ],
                    ),
                  ),
                ),

                // C. Logo & Text Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            12), // Reduced padding slightly
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 70,
                          width: 70,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.school,
                                  size: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'MANAGEMENT\nRIYADLUL HUDA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40), // Space for curve
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. White Card Container (Bottom Sheet Style)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height:
                  MediaQuery.of(context).size.height * 0.65, // Increased height
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 30,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 32, 25, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle Switch (Staff/Wali)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isParentLogin = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !_isParentLogin
                                        ? const Color(0xFF1B5E20)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_isParentLogin
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    'Pengurus',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: !_isParentLogin
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isParentLogin = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isParentLogin
                                        ? const Color(0xFF1B5E20)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _isParentLogin
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    'Wali Santri',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: _isParentLogin
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        _isParentLogin ? 'Login Wali Santri' : 'Login Pengurus',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isParentLogin
                            ? 'Masuk menggunakan nama dan tanggal lahir santri.'
                            : 'Masuk dengan email dan password anda.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (!_isParentLogin) ...[
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            hintStyle: GoogleFonts.outfit(
                                color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.email_outlined,
                                color:
                                    const Color(0xFF1B5E20).withOpacity(0.7)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!value.contains('@')) {
                              return 'Format email salah';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: GoogleFonts.outfit(
                                color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.lock_outline_rounded,
                                color:
                                    const Color(0xFF1B5E20).withOpacity(0.7)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade400,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Password Wajib Diisi';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        // Nama Santri Field
                        TextFormField(
                          controller: _namaSantriController,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Nama Lengkap Santri',
                            hintStyle: GoogleFonts.outfit(
                                color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.person_outline,
                                color:
                                    const Color(0xFF1B5E20).withOpacity(0.7)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Santri wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Tanggal Lahir Field (Date Picker)
                        TextFormField(
                          controller: _tanggalLahirController,
                          readOnly: true, // Prevent manual typing
                          onTap: () async {
                            DateTime initialDate = DateTime(2015);
                            if (_tanggalLahirController.text.isNotEmpty) {
                              try {
                                final parts =
                                    _tanggalLahirController.text.split('-');
                                if (parts.length == 3) {
                                  initialDate = DateTime(int.parse(parts[2]),
                                      int.parse(parts[1]), int.parse(parts[0]));
                                }
                              } catch (_) {}
                            }

                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(
                                          0xFF1B5E20), // Header text color
                                      onPrimary:
                                          Colors.white, // Header text color
                                      onSurface:
                                          Colors.black, // Body text color
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                // Format: DD-MM-YYYY
                                _tanggalLahirController.text =
                                    "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                              });
                            }
                          },
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Tanggal Lahir (DD-MM-YYYY)',
                            hintStyle: GoogleFonts.outfit(
                                color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.calendar_today_outlined,
                                color:
                                    const Color(0xFF1B5E20).withOpacity(0.7)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal Lahir wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ],
                      const Spacer(),

                      // Login Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF1B5E20).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  _isParentLogin
                                      ? 'Masuk sebagai Wali'
                                      : 'Masuk sebagai Pengurus',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

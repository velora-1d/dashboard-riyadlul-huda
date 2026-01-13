import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WatermarkWrapper extends StatelessWidget {
  final Widget child;
  const WatermarkWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          color: const Color(0xFF1B5E20), // Changed container color
          child: Material(
            type: MaterialType
                .transparency, // Keep transparency for Material if container has color
            child: DefaultTextStyle(
              style: GoogleFonts.tinos(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white, // Changed text color to white
                fontStyle: FontStyle.italic,
                decoration:
                    TextDecoration.none, // Vital to remove yellow underline
              ),
              child: const Text(
                'Dibuat Oleh : Mahin Utsman Nawawi, S.H',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

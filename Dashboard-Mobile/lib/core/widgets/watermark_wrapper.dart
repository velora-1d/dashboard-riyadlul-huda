import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WatermarkWrapper extends StatelessWidget {
  final Widget child;
  const WatermarkWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Material(
            type: MaterialType.transparency,
            child: Opacity(
              opacity: 0.8, // Adjusted for black text to be clearly visible
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Management Riyadlul Huda',
                    style: GoogleFonts.tinos(
                      // Serif font similar to Times New Roman
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dibuat Oleh : Mahin Utsman Nawawi, S.H',
                    style: GoogleFonts.tinos(
                      // Serif font similar to Times New Roman
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

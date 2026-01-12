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
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.15,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Management Riyadlul Huda',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dibuat Oleh : Mahin Utsman Nawawi, S.H',
                      style: GoogleFonts.caveat(
                        // Using a handwritten style or similar if available, or just italic outfit
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

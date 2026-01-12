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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Created by Mahin Utsman Nawawi',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: Colors.black,
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

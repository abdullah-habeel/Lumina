import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/app_routes.dart';

class InsightsCard extends StatelessWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.emotionInsights),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFC9A84C),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF50370A).withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFD6DFB8),
              Color(0xFFEDE8C4),
              Color(0xFFF5EDCD),
            ],
            stops: [0.0, 0.32, 1.0],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Emotion illustration — moved closer to the left edge
              Positioned(
                left: -8,
                top: 0,
                bottom: 0,
                width: 138,
                child: Image.asset(
                  'assets/images/emotion.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              ),

              // Text and arrow
              Positioned(
                left: 112,
                right: 0,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Emotion Insights',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C1F0A),
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "See how you've been feeling over time.",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF5A4020),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Arrow
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFB48C3C).withOpacity(0.15),
                          border: Border.all(
                            color: const Color(0xFFB48C3C).withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Color(0xFF7A5C20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
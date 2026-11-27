import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/service/privacy_gate_service.dart';

class PrivacyGateScreen extends StatelessWidget {
  const PrivacyGateScreen({super.key});

  static const Color cream = Color(0xFFF5EBD5);
  static const Color green = Color(0xFF2F4F41);
  static const Color gold = Color(0xFFC79A4B);
  static const Color brown = Color(0xFF55402C);
  static const Color lightBrown = Color(0xFF7A6652);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    

                    const SizedBox(height: 18),

                    const Text(
                      'Before we\ncontinue',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5EBD5),
                        fontFamily: 'serif',
                        height: 1.2,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Your memories live only on your device. To write your life story, Lumina needs cloud AI for deep understanding.',
                      style: TextStyle(
                        fontSize: 14,
                        color: cream.withOpacity(0.75),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sent to cloud section ──
                    _sectionLabel('Sent to cloud AI'),
                    const SizedBox(height: 10),
                    _infoCard(
                      icon: Icons.cloud_upload_outlined,
                      iconColor: Colors.orange.shade700,
                      bgColor: Colors.orange.withOpacity(0.07),
                      borderColor: Colors.orange.withOpacity(0.2),
                      text: 'Your memory content (what you wrote)',
                    ),

                    const SizedBox(height: 24),

                    // ── Never leaves section ──
                    _sectionLabel('Never leaves your device'),
                    const SizedBox(height: 10),
                    _infoCard(
                      icon: Icons.person_off_outlined,
                      iconColor: green,
                      bgColor: green.withOpacity(0.06),
                      borderColor: green.withOpacity(0.18),
                      text:
                          'Person names — replaced with [Person_1], [Person_2] before sending',
                    ),
                    const SizedBox(height: 8),
                    _infoCard(
                      icon: Icons.phone_android_rounded,
                      iconColor: green,
                      bgColor: green.withOpacity(0.06),
                      borderColor: green.withOpacity(0.18),
                      text: 'Your account information',
                    ),
                    const SizedBox(height: 8),
                    _infoCard(
                      icon: Icons.shield_outlined,
                      iconColor: green,
                      bgColor: green.withOpacity(0.06),
                      borderColor: green.withOpacity(0.18),
                      text:
                          'On-device tagged data (emotions, themes, keywords)',
                    ),

                    const SizedBox(height: 24),

                    // ── Note ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: gold.withOpacity(0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: gold,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This is a one-time choice. You can change it anytime in Settings.',
                              style: TextStyle(
                                fontSize: 13,
                                color: lightBrown,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Cloud button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await PrivacyGateService()
                              .saveChoice(PrivacyChoice.cloudEnabled);
                          Get.back(result: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: cream,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'I understand — write my story',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── On-device button ──
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await PrivacyGateService()
                              .saveChoice(PrivacyChoice.onDeviceOnly);
                          Get.back(result: false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: gold.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Keep my memories on-device',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: brown,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: lightBrown,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
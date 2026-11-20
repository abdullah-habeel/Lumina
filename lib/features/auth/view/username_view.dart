import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/features/auth/controller/username_controller.dart';
import 'package:lumina/features/auth/widgets/auth_constants.dart';

class UsernameSetupView extends StatelessWidget {
  const UsernameSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsernameController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full screen background ────────────────────────────────
          Image.asset(AppImages.sharebg, fit: BoxFit.cover),

          // ── Dark gradient overlay ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ── App icon ─────────────────────────────────────
                  ClipOval(
                    child: Image.asset(
                      AppImages.appicon,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 20),

                  // ── Title ─────────────────────────────────────────
                  const Text(
                    'Choose a Username',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'This is how friends will find and add you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Frosted glass card ────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Text field ───────────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: TextField(
                                controller: controller.usernameController,
                                keyboardType: TextInputType.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Lora',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Username',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 15,
                                    fontFamily: 'Lora',
                                  ),
                                  prefixIcon: Icon(
                                    Icons.alternate_email,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── Validation message ───────────────
                            Obx(() {
                              final message = controller.statusMessage.value;
                              if (message.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      controller.isAvailable.value
                                          ? Icons.check_circle_outline
                                          : Icons.error_outline,
                                      size: 14,
                                      color: controller.isAvailable.value
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      message,
                                      style: TextStyle(
                                        fontFamily: 'Lora',
                                        fontSize: 13,
                                        color: controller.isAvailable.value
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 20),

                            // ── Continue button ──────────────────
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: controller.isSaving.value
                                      ? null
                                      : controller.submitUsername,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AuthColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isSaving.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Continue',
                                          style: TextStyle(
                                            fontFamily: 'Lora',
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Bottom hint ───────────────────────────────────
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

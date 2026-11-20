import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/features/auth/widgets/app_textfield.dart';
import 'package:lumina/features/auth/widgets/auth_constants.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import '../controller/auth_controller.dart';
import '../widgets/app_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();

    return DaylightBookBackground(
      debugOverrideHour: 16,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Full screen background ────────────────────────────────

            // ── Dark overlay for readability ──────────────────────────
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // ── Back arrow ──────────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.chevron_left,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Title ───────────────────────────────────────
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          fontSize: 34,
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
                      const SizedBox(height: 10),
                      Text(
                        'Every story continues.\nLet\'s pick up where you left off.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontStyle: FontStyle.italic,
                          fontSize: 14.5,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.55,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Frosted card ─────────────────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Fields ──────────────────────────────
                                AppTextField(
                                  hint: 'Email address',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  controller: ctrl.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),

                                Obx(
                                  () => AppTextField(
                                    hint: 'Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscureText: ctrl.loginObscure.value,
                                    onToggleObscure: ctrl.toggleLoginObscure,
                                    controller: ctrl.passwordController,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // ── Forgot password ──────────────────────
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: ctrl.forgotPassword,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontFamily: 'Lora',
                                        fontSize: 13.5,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // ── Login button ─────────────────────────
                                Obx(
                                  () => ctrl.isLoading.value
                                      ? const SizedBox(
                                          height: 54,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AuthColors.primary,
                                            ),
                                          ),
                                        )
                                      : AppButton(
                                          label: 'Log In',
                                          onTap: ctrl.login,
                                        ),
                                ),
                                const SizedBox(height: 20),

                                // ── Divider ──────────────────────────────
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: AuthColors.divider,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'or continue with',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontFamily: 'Lora',
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: AuthColors.divider,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // ── Google button ────────────────────────
                                _GoogleButton(onTap: ctrl.loginWithGoogle),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Switch to register ───────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 13.5,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Google Button ──────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          side: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.googlelogo, width: 22, height: 22),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/features/auth/widgets/app_textfield.dart';
import 'package:lumina/features/auth/widgets/auth_constants.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/auth_controller.dart';
import '../widgets/app_button.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();

    return DaylightBookBackground(
      debugOverrideHour: 16,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Full screen background ────────────────────────────────
            // Image.asset(AppImages.sharebg, fit: BoxFit.cover),

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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // ── Back arrow ──────────────────────────────────
                      Align(
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

                      const SizedBox(height: 16),

                      // ── Title ───────────────────────────────────────
                      Text(
                        'Create Account',
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
                      const SizedBox(height: 8),
                      Text(
                        'Start your journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontStyle: FontStyle.italic,
                          fontSize: 14.5,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Frosted glass card ───────────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            // ✅ reduced padding
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
                                // ── Fields with reduced padding ───────
                                _CompactTextField(
                                  hint: 'Full name',
                                  prefixIcon: Icons.person_outline_rounded,
                                  controller: ctrl.nameController,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 10),

                                _CompactTextField(
                                  hint: 'Email address',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  controller: ctrl.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 10),

                                Obx(
                                  () => _CompactTextField(
                                    hint: 'Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscureText: ctrl.signupObscure.value,
                                    onToggleObscure: ctrl.toggleSignupObscure,
                                    controller: ctrl.passwordController,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Obx(
                                  () => _CompactTextField(
                                    hint: 'Confirm password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscureText: ctrl.confirmObscure.value,
                                    onToggleObscure: ctrl.toggleConfirmObscure,
                                    controller: ctrl.confirmPassController,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // ✅ Privacy — single italic line, no card
                                Text(
                                  'Your story is private. We never share your data.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: AppColors.chapterTextDark,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // ── Terms checkbox ────────────────────
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: 'Lora',
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── Sign Up button ────────────────────
                                Obx(
                                  () => ctrl.isLoading.value
                                      ? const SizedBox(
                                          height: 54,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : AppButton(
                                          label: 'Sign Up',
                                          onTap: ctrl.signUp,
                                        ),
                                ),
                                const SizedBox(height: 12),

                                // ✅ Google button directly below, no divider
                                _GoogleButton(onTap: ctrl.loginWithGoogle),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Switch to login ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 13.5,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.login),
                            child: const Text(
                              'Log In',
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
                      const SizedBox(height: 32),
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

// ── Compact TextField ──────────────────────────────────────────────────────────
class _CompactTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const _CompactTextField({
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontFamily: 'Lora',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
            fontFamily: 'Lora',
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
                  splashRadius: 20,
                )
              : null,
          border: InputBorder.none,
          // ✅ reduced vertical padding
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 11,
          ),
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
      height: 50,
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

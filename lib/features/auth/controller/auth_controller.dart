import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/services/device_info_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/features/auth/controller/username_controller.dart';
import 'package:lumina/features/auth/service/auth_service.dart';
import 'package:lumina/features/auth/service/username_service.dart';
import 'package:lumina/features/auth/view/username_view.dart';
import 'package:lumina/features/music/controller/music_controller.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPassController = TextEditingController();

  final loginObscure = true.obs;
  final signupObscure = true.obs;
  final confirmObscure = true.obs;
  final isLoading = false.obs;

  void toggleLoginObscure() => loginObscure.toggle();
  void toggleSignupObscure() => signupObscure.toggle();
  void toggleConfirmObscure() => confirmObscure.toggle();

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _snack('Missing fields', 'Please enter your email and password.');
      return;
    }

    isLoading.value = true;
    try {
      await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await _goToUsernameOrHome();
    } on FirebaseAuthException catch (e) {
      _snack('Login failed', _firebaseErrorMessage(e));
    } catch (_) {
      _snack('Login failed', 'Unable to sign in. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final success = await AuthService.signInWithGoogle();
      if (success) {
        await _goToUsernameOrHome();
      } else {
        _snack(
          'Google sign in cancelled',
          'Please choose an account to continue.',
        );
      }
    } on FirebaseAuthException catch (e) {
      _snack('Google sign in failed', _firebaseErrorMessage(e));
    } catch (e) {
      print('GOOGLE ERROR: $e');
      _snack('Google sign in failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _snack('Missing fields', 'Please fill in all fields.');
      return;
    }
    if (passwordController.text != confirmPassController.text) {
      _snack('Password mismatch', 'Passwords do not match.');
      return;
    }

    isLoading.value = true;
    try {
      await AuthService.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _goToUsernameOrHome(forceUsernameSetup: true);
    } on FirebaseAuthException catch (e) {
      _snack('Sign up failed', _firebaseErrorMessage(e));
    } catch (_) {
      _snack(
        'Sign up failed',
        'Unable to create an account. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _goToUsernameOrHome({bool forceUsernameSetup = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Get.offAllNamed(AppRoutes.main);
      return;
    }

    // Link this device/session to the signed-in user in OneSignal so
    // push notifications can be targeted at them specifically.
    await OneSignal.login(uid);
    DeviceInfoService.saveDeviceInfo();
    if (Get.isRegistered<MusicController>()) {
      await Get.find<MusicController>().loadPreference();
    }

    final needsSetup =
        forceUsernameSetup || await UsernameService().needsUsernameSetup(uid);

    if (needsSetup) {
      if (Get.isRegistered<UsernameController>()) {
        Get.delete<UsernameController>();
      }
      Get.put(UsernameController(), permanent: true);
      Get.offAll(() => const UsernameSetupView());
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      _snack('Missing email', 'Please enter your email to reset password.');
      return;
    }

    isLoading.value = true;
    try {
      await AuthService.forgotPassword(emailController.text.trim());
      _snack(
        'Reset email sent',
        'Please check your inbox for password reset instructions.',
      );
    } on FirebaseAuthException catch (e) {
      _snack('Reset failed', _firebaseErrorMessage(e));
    } catch (_) {
      _snack('Reset failed', 'Unable to send password reset email.');
    } finally {
      isLoading.value = false;
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2F4E35),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPassController.dispose();
    super.onClose();
  }
}

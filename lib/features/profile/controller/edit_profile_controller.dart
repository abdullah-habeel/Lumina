import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumina/features/home/models/controller/home_controller.dart';
import 'package:lumina/features/profile/controller/profile_controller.dart';

class EditProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final displayNameController = TextEditingController();

  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final profileController = Get.find<ProfileController>();
    displayNameController.text = profileController.displayName.value;
    username.value = profileController.username.value;
    email.value = profileController.email.value;
  }

  Future<void> saveDisplayName() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final newName = displayNameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar(
        'Error',
        'Display name cannot be empty',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
      });
      await user.updateDisplayName(newName);
      await user.reload();

      // Update ProfileController
      final profileController = Get.find<ProfileController>();
      profileController.displayName.value = newName;

      // Update HomeController
      final homeController = Get.find<HomeController>();
      homeController.loadUserName();
      Get.snackbar(
        'Saved',
        'Display name updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isDeleting.value = true;
    try {
      await _tryDelete(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        isDeleting.value = false;
        await _reauthAndDelete(user);
      } else {
        Get.snackbar(
          'Error',
          e.message ?? 'Something went wrong',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        isDeleting.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      isDeleting.value = false;
    }
  }

  Future<void> _tryDelete(User user) async {
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
    Get.offAllNamed('/login');
  }

  Future<void> _reauthAndDelete(User user) async {
    final providers = user.providerData.map((p) => p.providerId).toList();
    final isGoogle = providers.contains('google.com');

    if (isGoogle) {
      await _reauthGoogle(user);
    } else {
      await _reauthEmailPassword(user);
    }
  }

  Future<void> _reauthGoogle(User user) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      isDeleting.value = true;
      await _tryDelete(user);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Re-authentication failed',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      isDeleting.value = false;
    }
  }

  Future<void> _reauthEmailPassword(User user) async {
    final passwordController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Text('Confirm your password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter your password'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passwordController.text.trim(),
                );
                await user.reauthenticateWithCredential(credential);
                isDeleting.value = true;
                await _tryDelete(user);
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Wrong password',
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
                isDeleting.value = false;
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    displayNameController.dispose();
    super.onClose();
  }
}

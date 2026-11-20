import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';

class ProfileController extends GetxController {
  final RxString displayName = ''.obs;
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString profilePhotoUrl = ''.obs;
  final RxInt journalEntriesCount = 0.obs;
  final RxInt trustedPeopleCount = 0.obs;
  final RxInt sharedMemoriesCount = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isUploadingPhoto = false.obs;
  final List<Worker> _statsWorkers = [];

  @override
  void onInit() {
    super.onInit();
    _bindLiveStats();
    _loadProfile();
  }

  void _bindLiveStats() {
    if (Get.isRegistered<JournalController>()) {
      final journalController = Get.find<JournalController>();
      journalEntriesCount.value = journalController.entries.length;
      _statsWorkers.add(
        ever(journalController.entries, (_) {
          journalEntriesCount.value = journalController.entries.length;
        }),
      );
    }

    if (Get.isRegistered<SharedController>()) {
      final sharedController = Get.find<SharedController>();
      trustedPeopleCount.value = sharedController.trustedPeople.length;
      _statsWorkers.add(
        ever(sharedController.trustedPeople, (_) {
          trustedPeopleCount.value = sharedController.trustedPeople.length;
        }),
      );
    }

    if (Get.isRegistered<SharedMemoryController>()) {
      final sharedMemoryController = Get.find<SharedMemoryController>();
      void updateSharedCount() {
        sharedMemoriesCount.value =
            sharedMemoryController.sentPages.length +
            sharedMemoryController.receivedPages.length;
      }

      updateSharedCount();
      _statsWorkers.add(
        ever(sharedMemoryController.sentPages, (_) => updateSharedCount()),
      );
      _statsWorkers.add(
        ever(sharedMemoryController.receivedPages, (_) => updateSharedCount()),
      );
    }
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    email.value = user.email ?? '';
    displayName.value = user.displayName?.trim() ?? '';
    username.value = user.email?.split('@').first ?? '';
    profilePhotoUrl.value = user.photoURL ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final fetchedUsername = (data['username'] as String?)?.trim();
        final fetchedDisplayName = (data['displayName'] as String?)?.trim();
        final fetchedPhotoUrl = (data['photoUrl'] as String?)?.trim();

        if (fetchedUsername != null && fetchedUsername.isNotEmpty) {
          username.value = fetchedUsername;
        }
        if (fetchedDisplayName != null && fetchedDisplayName.isNotEmpty) {
          displayName.value = fetchedDisplayName;
        } else if (displayName.value.isEmpty) {
          displayName.value = username.value;
        }
        if (fetchedPhotoUrl != null && fetchedPhotoUrl.isNotEmpty) {
          profilePhotoUrl.value = fetchedPhotoUrl;
        }
      }

      final entriesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journal_entries')
          .count()
          .get();
      journalEntriesCount.value = entriesSnapshot.count ?? 0;
    } catch (_) {
      // Keep whatever defaults/auth values we already have.
    }

    isLoading.value = false;
  }

  /// Shows a "Take photo / Choose from gallery" sheet, then compresses
  /// and uploads the result to Firebase Storage, saving the URL to Firestore.
  Future<void> pickAndUploadPhoto() async {
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    await _pickAndUpload(source);
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('PROFILE PHOTO: no signed-in user, aborting');
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) {
      debugPrint('PROFILE PHOTO: user cancelled picker');
      return;
    }

    isUploadingPhoto.value = true;
    try {
      final compressedFile = await _compressImage(File(picked.path));
      debugPrint(
        'PROFILE PHOTO: compressed to ${(compressedFile.lengthSync() / 1024).toStringAsFixed(1)} KB',
      );

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      debugPrint('PROFILE PHOTO: uploading to ${ref.fullPath}');
      await ref.putFile(compressedFile);

      final downloadUrl = await ref.getDownloadURL();
      debugPrint('PROFILE PHOTO: got download URL $downloadUrl');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': downloadUrl,
      }, SetOptions(merge: true));

      profilePhotoUrl.value = downloadUrl;
      debugPrint('PROFILE PHOTO: done');
    } catch (e, st) {
      debugPrint('PROFILE PHOTO: upload failed: $e\n$st');
      Get.snackbar('Upload failed', e.toString());
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Compresses an image to roughly under 300KB at max 800px on the
  /// longest side — good enough quality for an avatar, small enough
  /// to upload fast and stay well inside Storage free quota.
  Future<File> _compressImage(File original) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      original.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 800,
      minHeight: 800,
      format: CompressFormat.jpeg,
    );

    // If compression fails for any reason, fall back to the original file
    // rather than blocking the upload entirely.
    if (result == null) return original;
    return File(result.path);
  }

  

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final providers = user.providerData.map((p) => p.providerId).toList();
      final isGoogle = providers.contains('google.com');

      if (isGoogle) {
        await _reauthGoogle(user);
      } else {
        await _reauthEmailPassword(user);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final providers = user.providerData.map((p) => p.providerId).toList();
        final isGoogle = providers.contains('google.com');
        if (isGoogle) {
          await _reauthGoogle(user);
        } else {
          await _reauthEmailPassword(user);
        }
      } else {
        Get.snackbar(
          'Error',
          e.message ?? 'Something went wrong',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
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
      await _hardDelete(user);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Re-authentication failed',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
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
                await _hardDelete(user);
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Wrong password',
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _hardDelete(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    await user.delete();
    Get.offAllNamed('/login');
  }

  Future<void> logout() async {
    await OneSignal.logout();
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    for (final worker in _statsWorkers) {
      worker.dispose();
    }
    super.onClose();
  }
}

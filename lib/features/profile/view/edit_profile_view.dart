import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import '../controller/edit_profile_controller.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Display Name ─────────────────────────────────────
              _SectionLabel(label: 'Display Name'),
              const SizedBox(height: 8),
              TextField(
                controller: controller.displayNameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  hint: 'Enter your display name',
                  enabled: true,
                ),
              ),

              const SizedBox(height: 24),

              // ── Username ─────────────────────────────────────────
              _SectionLabel(label: 'Username'),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(
                  text: controller.username.value,
                ),
                enabled: false,
                style: const TextStyle(color: AppColors.textMuted),
                decoration: _inputDecoration(hint: 'Username', enabled: false),
              ),

              const SizedBox(height: 24),

              // ── Email ─────────────────────────────────────────────
              _SectionLabel(label: 'Email'),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: controller.email.value),
                enabled: false,
                style: const TextStyle(color: AppColors.textMuted),
                decoration: _inputDecoration(hint: 'Email', enabled: false),
              ),

              const SizedBox(height: 36),

              // ── Save Button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveDisplayName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.primaryGreen.withOpacity(
                      0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteConfirmation(EditProfileController controller) {
    final confirmController = TextEditingController();
    final RxBool matches = false.obs;

    confirmController.addListener(() {
      matches.value = confirmController.text.trim() == 'DELETE';
    });

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. Type DELETE to confirm.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(hint: 'Type DELETE', enabled: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: matches.value
                  ? () {
                      Get.back();
                      controller.deleteAccount();
                    }
                  : null,
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool enabled,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: enabled
          ? AppColors.cardBackground
          : AppColors.cardBackground.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

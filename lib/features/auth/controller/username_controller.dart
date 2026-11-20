import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/features/auth/service/username_service.dart';

class UsernameController extends GetxController {
  final UsernameService _usernameService = UsernameService();

  final TextEditingController usernameController = TextEditingController();

  final RxString statusMessage = ''.obs;
  final RxBool isAvailable = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isChecking = false.obs;

  Timer? _debounce;
  final Map<String, bool> _availabilityCache = {};
  int _checkId = 0;

  @override
  void onInit() {
    super.onInit();
    usernameController.addListener(_onUsernameChanged);
  }

  void _onUsernameChanged() {
    final value = usernameController.text.trim();

    _debounce?.cancel();
    statusMessage.value = '';
    isAvailable.value = false;
    isChecking.value = false;

    if (value.isEmpty) return;

    if (!_isValidFormat(value)) {
      statusMessage.value =
          '3-20 characters, letters, numbers,\nunderscores only';
      return;
    }

    final normalized = value.toLowerCase();
    if (_availabilityCache.containsKey(normalized)) {
      final available = _availabilityCache[normalized]!;
      isAvailable.value = available;
      statusMessage.value = available
          ? 'Username available'
          : 'Username already taken';
      return;
    }

    isChecking.value = true;
    statusMessage.value = 'Checking availability...';

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      await _checkAvailability(value);
    });
  }

  Future<void> _checkAvailability(String value) async {
    final checkId = ++_checkId;
    final normalized = value.trim().toLowerCase();

    try {
      final available = await _usernameService
          .isUsernameAvailable(value)
          .timeout(const Duration(seconds: 4));

      if (checkId != _checkId) return;

      _availabilityCache[normalized] = available;
      isAvailable.value = available;
      statusMessage.value = available
          ? 'Username available'
          : 'Username already taken';
    } catch (_) {
      if (checkId != _checkId) return;
      isAvailable.value = false;
      statusMessage.value = 'Could not check right now. Please try again.';
    } finally {
      if (checkId == _checkId) {
        isChecking.value = false;
      }
    }
  }

  bool _isValidFormat(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return regex.hasMatch(value);
  }

  Future<void> submitUsername() async {
    final value = usernameController.text.trim();

    if (isChecking.value) {
      statusMessage.value = 'Checking availability...';
      return;
    }

    if (!_isValidFormat(value) || !isAvailable.value) {
      statusMessage.value = 'Please choose a valid, available username';
      return;
    }

    isSaving.value = true;
    try {
      await _usernameService.saveUsername(value);
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      statusMessage.value = 'Something went wrong. Try again.';
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    usernameController.dispose();
    super.onClose();
  }
}

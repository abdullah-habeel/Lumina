import 'package:get/get.dart';
import 'package:lumina/features/pin/service/pin_service.dart';

class PinController extends GetxController {
  final PinService _pinService = PinService();

  final RxBool isPinEnabled = false.obs;
  final RxBool isUnlocked = false.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPinStatus();
  }

  Future<void> loadPinStatus() async {
    try {
      final exists = await _pinService.hasPin();

      isPinEnabled.value = exists;

      if (exists) {
        // PIN exists → app must be unlocked with PIN.
        isUnlocked.value = false;
      } else {
        // No PIN → app can open normally.
        isUnlocked.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPin(String pin) async {
    if (pin.length != 4) {
      return false;
    }

    isLoading.value = true;

    try {
      await _pinService.savePin(pin);

      final saved = await _pinService.getPin();

      if (saved != pin) {
        return false;
      }

      isPinEnabled.value = true;
      isUnlocked.value = true;

      return true;
    } catch (e) {
      print('Error creating PIN: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    if (pin.length != 4) {
      return false;
    }

    final correct = await _pinService.verifyPin(pin);

    if (correct) {
      isUnlocked.value = true;
    }

    return correct;
  }

  void lockApp() {
    if (isPinEnabled.value) {
      isUnlocked.value = false;
    }
  }

  Future<void> disablePin() async {
    isLoading.value = true;

    try {
      await _pinService.deletePin();

      isPinEnabled.value = false;
      isUnlocked.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}

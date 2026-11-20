import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/pin/controller/pin_controller.dart';
import 'package:lumina/features/pin/widgets/pin_keypad.dart';

class EnterPinView extends StatefulWidget {
  const EnterPinView({super.key});

  @override
  State<EnterPinView> createState() => _EnterPinViewState();
}

class _EnterPinViewState extends State<EnterPinView> {
  final PinController controller = Get.find<PinController>();

  String _pin = '';
  bool _checking = false;

  void _addDigit(String digit) {
    if (_pin.length >= 4 || _checking) return;

    setState(() {
      _pin += digit;
    });

    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  void _deleteDigit() {
    if (_pin.isEmpty || _checking) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    setState(() {
      _checking = true;
    });

    final correct = await controller.verifyPin(_pin);

    if (!mounted) return;

    if (correct) {
      // The controller is now unlocked.
      return;
    }

    setState(() {
      _pin = '';
      _checking = false;
    });

    Get.snackbar(
      'Incorrect PIN',
      'Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryGreen,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 70),

              const Icon(
                Icons.lock_outline,
                size: 42,
                color: AppColors.primaryGreen,
              ),

              const SizedBox(height: 24),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Enter your PIN to continue',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),

              const SizedBox(height: 45),

              _buildPinIndicators(),

              const Spacer(),

              if (_checking)
                const CircularProgressIndicator(color: AppColors.primaryGreen)
              else
                PinKeypad(
                  onDigitPressed: _addDigit,
                  onDeletePressed: _deleteDigit,
                ),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < _pin.length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: filled ? AppColors.primaryGreen : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGreen, width: 1.5),
          ),
        );
      }),
    );
  }
}

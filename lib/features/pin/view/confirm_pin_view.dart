import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/pin/controller/pin_controller.dart';
import 'package:lumina/features/pin/widgets/pin_keypad.dart';

class ConfirmPinView extends StatefulWidget {
  final String firstPin;

  const ConfirmPinView({super.key, required this.firstPin});

  @override
  State<ConfirmPinView> createState() => _ConfirmPinViewState();
}

class _ConfirmPinViewState extends State<ConfirmPinView> {
  final PinController controller = Get.find<PinController>();

  String _pin = '';
  bool _isSaving = false;

  void _addDigit(String digit) {
    if (_pin.length >= 4 || _isSaving) return;

    setState(() {
      _pin += digit;
    });

    if (_pin.length == 4) {
      _confirmPin();
    }
  }

  void _deleteDigit() {
    if (_pin.isEmpty || _isSaving) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _confirmPin() async {
    if (_pin.length != 4) return;

    // Check whether both PIN entries match.
    if (_pin != widget.firstPin) {
      setState(() {
        _pin = '';
      });

      Get.snackbar(
        'PINs do not match',
        'Please enter the same PIN again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Create/update the PIN.
    final success = await controller.createPin(_pin);

    if (!mounted) return;

    if (success) {
      // Return directly to the Profile screen.
      Get.offNamed(AppRoutes.profile);

      Get.snackbar(
        'PIN updated',
        'Your journal is now protected with your new PIN.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } else {
      setState(() {
        _isSaving = false;
        _pin = '';
      });

      Get.snackbar(
        'Something went wrong',
        'Your PIN could not be saved. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Confirm PIN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 35),

            const Text(
              'Confirm your PIN',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Enter your PIN one more time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),

            const SizedBox(height: 40),

            _buildPinIndicators(),

            const Spacer(),

            if (_isSaving)
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

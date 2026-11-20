import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/pin/controller/pin_controller.dart';
import 'package:lumina/features/pin/widgets/pin_keypad.dart';

class VerifyCurrentPinView extends StatefulWidget {
  const VerifyCurrentPinView({super.key});

  @override
  State<VerifyCurrentPinView> createState() => _VerifyCurrentPinViewState();
}

class _VerifyCurrentPinViewState extends State<VerifyCurrentPinView> {
  final PinController controller = Get.find<PinController>();

  String _pin = '';
  bool _isChecking = false;

  // Determines what happens after the current PIN is verified.
  String get _action {
    final arguments = Get.arguments;

    if (arguments is Map && arguments['action'] == 'disable') {
      return 'disable';
    }

    return 'change';
  }

  bool get _isDisabling => _action == 'disable';

  void _addDigit(String digit) {
    if (_pin.length >= 4 || _isChecking) return;

    setState(() {
      _pin += digit;
    });

    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  void _deleteDigit() {
    if (_pin.isEmpty || _isChecking) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    if (_pin.length != 4) return;

    setState(() {
      _isChecking = true;
    });

    final correct = await controller.verifyPin(_pin);

    if (!mounted) return;

    if (correct) {
      if (_isDisabling) {
        // User verified the current PIN.
        // Now disable PIN protection.
        await controller.disablePin();

        if (!mounted) return;

        Get.offNamed(AppRoutes.profile);

        Get.snackbar(
          'PIN protection disabled',
          'Your journal is no longer protected by a PIN.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        // Normal Change PIN flow.
        // Current PIN is correct → choose a new PIN.
        Get.toNamed(AppRoutes.choosePin);

        setState(() {
          _pin = '';
          _isChecking = false;
        });
      }
    } else {
      setState(() {
        _pin = '';
        _isChecking = false;
      });

      Get.snackbar(
        'Incorrect PIN',
        'The PIN you entered is not correct.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryGreen,
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
        title: Text(_isDisabling ? 'Turn Off PIN' : 'Verify PIN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 35),

            Text(
              _isDisabling
                  ? 'Enter your current PIN'
                  : 'Enter your current PIN',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _isDisabling
                    ? 'Enter your current PIN to turn off PIN protection.'
                    : 'Enter your current PIN to choose a new one.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),

            const SizedBox(height: 40),

            _buildPinIndicators(),

            const Spacer(),

            if (_isChecking)
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

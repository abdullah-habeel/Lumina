import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/pin/controller/pin_controller.dart';
import 'package:lumina/features/pin/view/confirm_pin_view.dart';
import 'package:lumina/features/pin/widgets/pin_keypad.dart';

class ChoosePinView extends StatefulWidget {
  const ChoosePinView({super.key});

  @override
  State<ChoosePinView> createState() => _ChoosePinViewState();
}

class _ChoosePinViewState extends State<ChoosePinView> {
  final PinController controller = Get.find<PinController>();

  String _pin = '';

  void _addDigit(String digit) {
    if (_pin.length >= 4) return;

    setState(() {
      _pin += digit;
    });

    if (_pin.length == 4) {
      _continue();
    }
  }

  void _deleteDigit() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _continue() {
    if (_pin.length != 4) return;

    Get.to(() => ConfirmPinView(firstPin: _pin));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Choose New PIN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 35),

            const Text(
              'Create a new PIN',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Choose a new 4-digit PIN to protect your journal.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ),

            const SizedBox(height: 40),

            _buildPinIndicators(),

            const Spacer(),

            PinKeypad(onDigitPressed: _addDigit, onDeletePressed: _deleteDigit),

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

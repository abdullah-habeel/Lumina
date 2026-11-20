import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;

  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 14),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 14),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 14),
        _buildLastRow(),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map(_buildNumberButton).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return SizedBox(
      width: 72,
      height: 58,
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onDigitPressed(number),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(width: 72, height: 58),

        _buildNumberButton('0'),

        SizedBox(
          width: 72,
          height: 58,
          child: Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onDeletePressed,
              child: const Center(
                child: Icon(
                  Icons.backspace_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

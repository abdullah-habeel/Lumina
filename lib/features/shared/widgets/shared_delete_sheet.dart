import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/shared/model/shared_model.dart';

Future<SharedDeleteScope?> showSharedDeleteSheet(
  BuildContext context, {
  required SharedPage page,
  bool allowEveryone = true,
}) {
  final isReceived = page.direction == SharedDirection.received;

  return showModalBottomSheet<SharedDeleteScope>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F0E2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderGold.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C2416).withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4B49A),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Retract this letter?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2416),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isReceived
                      ? 'This memory from ${page.personName} will leave your book.'
                      : 'This letter to ${page.personName} can leave only your book, or theirs as well.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF6B5E4A),
                  ),
                ),
                const SizedBox(height: 22),
                _PaperAction(
                  label: 'Remove from my book',
                  subtitle: allowEveryone
                      ? 'They can still keep their copy'
                      : 'Only your copy is removed',
                  onTap: () => Navigator.pop(context, SharedDeleteScope.forMe),
                ),
                if (allowEveryone) ...[
                  const SizedBox(height: 10),
                  _PaperAction(
                    label: 'Retract for everyone',
                    subtitle: 'Gone from both books',
                    danger: true,
                    onTap: () =>
                        Navigator.pop(context, SharedDeleteScope.forEveryone),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Keep the letter',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PaperAction extends StatelessWidget {
  const _PaperAction({
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFF8B2E2E) : const Color(0xFF2C2416);

    return Material(
      color: danger ? const Color(0xFFF3E2D6) : const Color(0xFFFFFBF2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: danger
                  ? const Color(0xFFB86A4A).withOpacity(0.45)
                  : AppColors.borderGold.withOpacity(0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12.5, color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

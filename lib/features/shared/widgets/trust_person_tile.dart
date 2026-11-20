import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/shared/model/shared_model.dart';

class TrustPersonTile extends StatelessWidget {
  final TrustedPerson person;
  final int? memoryCount;
  final VoidCallback? onTap;

  const TrustPersonTile({
    super.key,
    required this.person,
    this.memoryCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
        child: Text(
          person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        person.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        '${memoryCount ?? person.sharedMemoriesCount} memories',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
  }
}

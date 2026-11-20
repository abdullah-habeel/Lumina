import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConsentDialog extends StatelessWidget {
  const ConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF5EDD9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Your story stays yours',
        style: GoogleFonts.cormorantGaramond(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C1A0E),
        ),
      ),
      content: Text(
        'To write your story, Lumina sends your memories to Google AI. '
        'Your data is used only to generate this response and is not stored by Google.\n\n'
        'You can change this anytime in Settings.',
        style: GoogleFonts.lora(
          fontSize: 14,
          color: const Color(0xFF4A3728),
          height: 1.6,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Not Now',
            style: GoogleFonts.lora(
              color: const Color(0xFF8B6F5E),
              fontSize: 14,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C1A0E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Allow',
            style: GoogleFonts.lora(
              color: const Color(0xFFF5EDD9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
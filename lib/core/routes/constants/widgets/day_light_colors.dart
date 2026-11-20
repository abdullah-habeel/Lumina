import 'package:flutter/material.dart';

/// Time-of-day variations of your base AppColors.
///
/// Keyframes:
/// 06:00 — sunrise
/// 07:00 — early morning
/// 08:00 — morning
/// 09:00 — morning
/// 12:00 — noon
/// 15:00 — afternoon
/// 17:00 — late afternoon
/// 17:30 — golden hour
/// 18:00 — sunset
/// 19:00 — dusk
///
/// Colors are smoothly interpolated between these keyframes,
/// so times such as 07:30, 10:00, 16:20, or 18:40 receive
/// a natural intermediate color.
class DaylightAppColors {
  // ────────────────────────────────────────────────────────────
  // KEYFRAME HOURS
  // ────────────────────────────────────────────────────────────

  static const List<double> _hours = [
    6.0, // 06:00 — sunrise
    7.0, // 07:00 — early morning
    8.0, // 08:00 — morning
    9.0, // 09:00 — morning
    12.0, // 12:00 — noon
    15.0, // 15:00 — afternoon
    17.0, // 17:00 — late afternoon
    17.5, // 17:30 — golden hour
    18.0, // 18:00 — sunset
    19.0, // 19:00 — dusk
  ];

  // ────────────────────────────────────────────────────────────
  // borderGold variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _borderGold = [
    Color(0xFFBFA07A), // 06:00 sunrise
    Color(0xFFC6A474), // 07:00 early morning
    Color(0xFFCCA970), // 08:00 morning
    Color(0xFFD4AF6A), // 09:00 morning
    Color(0xFFE0BC77), // 12:00 noon
    Color(0xFFD2A85E), // 15:00 afternoon
    Color(0xFFCE9F53), // 17:00 late afternoon
    Color(0xFFCC9A4A), // 17:30 golden hour
    Color(0xFFD59F45), // 18:00 sunset
    Color(0xFFE8B84A), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // cardBackground variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _cardBackground = [
    Color(0xFFEFEAE0), // 06:00 sunrise
    Color(0xFFF2ECDF), // 07:00 early morning
    Color(0xFFF6EFE0), // 08:00 morning
    Color(0xFFF8F1DD), // 09:00 morning
    Color(0xFFFAF4E3), // 12:00 noon
    Color(0xFFF6EDD6), // 15:00 afternoon
    Color(0xFFF4E8CF), // 17:00 late afternoon
    Color(0xFFF3E4C4), // 17:30 golden hour
    Color(0xFFF1E3C6), // 18:00 sunset
    Color(0xFFF0E4C8), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // bookTitleText variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _bookTitleText = [
    Color(0xFFFFFCF2), // 06:00 sunrise
    Color(0xFFF8F1E2), // 07:00 early morning
    Color(0xFFE8DFCA), // 08:00 morning
    Color(0xFF161206), // 09:00 morning
    Color(0xFF0F0D06), // 12:00 noon
    Color(0xFF161206), // 15:00 afternoon
    Color(0xFF2A1E0D), // 17:00 late afternoon
    Color(0xFFFFF8E8), // 17:30 golden hour
    Color(0xFFFFF8E8), // 18:00 sunset
    Color(0xFFFFF8E8), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // iconColor variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _iconColor = [
    Color(0xFFBFA07A), // 06:00 sunrise
    Color(0xFFC2A278), // 07:00 early morning
    Color(0xFFC6A570), // 08:00 morning
    Color(0xFFC9A25F), // 09:00 morning
    Color(0xFFD0A861), // 12:00 noon
    Color(0xFFC79A52), // 15:00 afternoon
    Color(0xFFC08E47), // 17:00 late afternoon
    Color(0xFFB8823E), // 17:30 golden hour
    Color(0xFFD09A43), // 18:00 sunset
    Color(0xFFE0AA45), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // bookTitleSubtext variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _bookTitleSubtext = [
    Color(0xFFF0E6CC), // 06:00 sunrise
    Color(0xFFDCD1B8), // 07:00 early morning
    Color(0xFF897A5B), // 08:00 morning
    Color(0xFF3A3018), // 09:00 morning
    Color(0xFF322A16), // 12:00 noon
    Color(0xFF3A3018), // 15:00 afternoon
    Color(0xFF705638), // 17:00 late afternoon
    Color(0xFFFFF8E8), // 17:30 golden hour
    Color(0xFFF8EBCB), // 18:00 sunset
    Color(0xFFF2E4BC), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // accentGold variants
  // Dividers, decorative elements and secondary icons.
  // ────────────────────────────────────────────────────────────

  static const List<Color> _accentGold = [
    Color(0xFFA6884F), // 06:00 sunrise
    Color(0xFFB18D53), // 07:00 early morning
    Color(0xFFBC9759), // 08:00 morning
    Color(0xFFC9A25F), // 09:00 morning
    Color(0xFFD6AE68), // 12:00 noon
    Color(0xFFC79A52), // 15:00 afternoon
    Color(0xFFBE8C45), // 17:00 late afternoon
    Color(0xFFB8823E), // 17:30 golden hour
    Color(0xFFCC9642), // 18:00 sunset
    Color(0xFFD9A94A), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // cardText variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _cardText = [
    Color(0xFF2A2418), // 06:00 sunrise
    Color(0xFF2B2518), // 07:00 early morning
    Color(0xFF2C2514), // 08:00 morning
    Color(0xFF2C2410), // 09:00 morning
    Color(0xFF221E10), // 12:00 noon
    Color(0xFF261F0E), // 15:00 afternoon
    Color(0xFF291F10), // 17:00 late afternoon
    Color(0xFF2A1E10), // 17:30 golden hour
    Color(0xFF2D2010), // 18:00 sunset
    Color(0xFF2E2110), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // headingText variants
  //
  // Text directly on the sky:

  // "What's your story today?"
  // "My Chapters"
  // ────────────────────────────────────────────────────────────

  static const List<Color> _headingText = [
  Color(0xFFEDE6D8), // 06:00 sunrise
  Color(0xFFDCD3BF), // 07:00 early morning
  Color(0xFF3D3520), // 08:00 morning — darker for contrast
  Color(0xFF1A1508), // 09:00 morning — darker for contrast
  Color(0xFF131008), // 12:00 noon — darker for contrast
  Color(0xFF161208), // 15:00 afternoon — darker for contrast
  Color(0xFF241A0C), // 17:00 late afternoon — darker
  Color(0xFF3A2A14), // 17:30 golden hour
  Color(0xFFBFA982), // 18:00 sunset
  Color(0xFFF3E6C8), // 19:00 dusk
];

  // ────────────────────────────────────────────────────────────
  // headingSubtext variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _headingSubtext = [
  Color(0xFFC9BCA0), // 06:00 sunrise
  Color(0xFFB5A98D), // 07:00 early morning
  Color(0xFF4A3F28), // 08:00 morning — darker for contrast
  Color(0xFF3A3018), // 09:00 morning — darker for contrast
  Color(0xFF332C18), // 12:00 noon — darker for contrast
  Color(0xFF352E18), // 15:00 afternoon — darker for contrast
  Color(0xFF4A3820), // 17:00 late afternoon — darker
  Color(0xFF6E5636), // 17:30 golden hour
  Color(0xFFB69D72), // 18:00 sunset
  Color(0xFFD9C494), // 19:00 dusk
];

  // ────────────────────────────────────────────────────────────
  // treeOverlay variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _treeOverlay = [
    Color(0xFFD8CDB0), // 06:00 sunrise
    Color(0xFFE5DBC2), // 07:00 early morning
    Color(0xFFF5F0E3), // 08:00 morning
    Color(0xFFFFFFFF), // 09:00 morning
    Color(0xFFFFFFFF), // 12:00 noon
    Color(0xFFF0E4C0), // 15:00 afternoon
    Color(0xFFD8B77D), // 17:00 late afternoon
    Color(0xFFCBA36A), // 17:30 golden hour
    Color(0xFF896B53), // 18:00 sunset
    Color(0xFF5C4A3C), // 19:00 dusk
  ];
  static const List<Color> _rainColor = [
    Color(0xFFC8D4E0), // 06:00 sunrise (dark sky, light rain)
    Color(0xFFA9BAC9), // 07:00 early morning
    Color(0xFF8CA3B8), // 08:00 morning
    Color(0xFF6F8AA5), // 09:00 morning
    Color(0xFF5B7A99), // 12:00 noon
    Color(0xFF5F7C99), // 15:00 afternoon
    Color(0xFF7A8CA3), // 17:00 late afternoon
    Color(0xFF8E9BB0), // 17:30 golden hour
    Color(0xFFB4BCC8), // 18:00 sunset
    Color(0xFFD5DAE3), // 19:00 dusk (dark sky, light rain)
  ];

  // ────────────────────────────────────────────────────────────
  // cardSubtext variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _cardSubtext = [
    Color(0xFF6C6048), // 06:00 sunrise
    Color(0xFF716348), // 07:00 early morning
    Color(0xFF74613F), // 08:00 morning
    Color(0xFF75623E), // 09:00 morning
    Color(0xFF6E5C38), // 12:00 noon
    Color(0xFF6E5834), // 15:00 afternoon
    Color(0xFF6E512F), // 17:00 late afternoon
    Color(0xFF6E4E2C), // 17:30 golden hour
    Color(0xFF6E5029), // 18:00 sunset
    Color(0xFF6E5228), // 19:00 dusk
  ];
  static const List<Color> _lightningGlow = [
    Color(0xFFFFF3B0), // 06:00 sunrise
    Color(0xFFFFF0A0), // 07:00 early morning
    Color(0xFFFFE680), // 08:00 morning
    Color(0xFFFFD84D), // 09:00 morning
    Color(0xFFFFCC33), // 12:00 noon
    Color(0xFFFFD23F), // 15:00 afternoon
    Color(0xFFFFE066), // 17:00 late afternoon
    Color(0xFFFFEB85), // 17:30 golden hour
    Color(0xFFFFF3B0), // 18:00 sunset
    Color(0xFFFFF6C8), // 19:00 dusk
  ];
  static const List<Color> _lightningOutline = [
    Color(0x003B4A6B), // 06:00 sunrise (none)
    Color(0x333B4A6B), // 07:00 early morning
    Color(0x803B4A6B), // 08:00 morning
    Color(0xCC3B4A6B), // 09:00 morning
    Color(0xE63B4A6B), // 12:00 noon
    Color(0xCC3B4A6B), // 15:00 afternoon
    Color(0x803B4A6B), // 17:00 late afternoon
    Color(0x4D3B4A6B), // 17:30 golden hour
    Color(0x1A3B4A6B), // 18:00 sunset
    Color(0x003B4A6B), // 19:00 dusk (none)
  ];

  // ────────────────────────────────────────────────────────────
  // shadow variants
  // ────────────────────────────────────────────────────────────

  static const List<Color> _shadow = [
    Color(0x33000000), // 06:00 sunrise
    Color(0x30000000), // 07:00 early morning
    Color(0x2D000000), // 08:00 morning
    Color(0x2A000000), // 09:00 morning
    Color(0x22000000), // 12:00 noon
    Color(0x2A000000), // 15:00 afternoon
    Color(0x30000000), // 17:00 late afternoon
    Color(0x33000000), // 17:30 golden hour
    Color(0x4DE0AA45), // 18:00 sunset
    Color(0x66E8B84A), // 19:00 dusk
  ];

  // ────────────────────────────────────────────────────────────
  // RESOLVER
  //
  // Finds the two surrounding keyframes and smoothly
  // interpolates between them.
  // ────────────────────────────────────────────────────────────

  static Color _resolve(double hour, List<Color> variants) {
    final clamped = hour.clamp(_hours.first, _hours.last);

    if (clamped <= _hours.first) {
      return variants.first;
    }

    if (clamped >= _hours.last) {
      return variants.last;
    }

    for (int i = 0; i < _hours.length - 1; i++) {
      final a = _hours[i];
      final b = _hours[i + 1];

      if (clamped >= a && clamped <= b) {
        final t = (clamped - a) / (b - a);

        return Color.lerp(variants[i], variants[i + 1], t)!;
      }
    }

    return variants.last;
  }

  // ────────────────────────────────────────────────────────────
  // PUBLIC API
  // ────────────────────────────────────────────────────────────

  static Color borderGold(double hour) => _resolve(hour, _borderGold);

  static Color bookTitleText(double hour) => _resolve(hour, _bookTitleText);

  static Color bookTitleSubtext(double hour) =>
      _resolve(hour, _bookTitleSubtext);

  static Color cardBackground(double hour) => _resolve(hour, _cardBackground);

  static Color accentGold(double hour) => _resolve(hour, _accentGold);

  static Color iconColor(double hour) => _resolve(hour, _iconColor);

  static Color cardText(double hour) => _resolve(hour, _cardText);

  static Color cardSubtext(double hour) => _resolve(hour, _cardSubtext);

  static Color shadow(double hour) => _resolve(hour, _shadow);

  static Color headingText(double hour) => _resolve(hour, _headingText);

  static Color headingSubtext(double hour) => _resolve(hour, _headingSubtext);

  static Color treeOverlay(double hour) => _resolve(hour, _treeOverlay);
  static Color rainColor(double hour) => _resolve(hour, _rainColor);
  static Color lightningGlow(double hour) => _resolve(hour, _lightningGlow);

  static Color lightningOutline(double hour) =>
      _resolve(hour, _lightningOutline);
}

import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.muted,
    required this.idleFill,
    required this.idleLine,
    required this.accent,
    required this.text,
    required this.error,
    required this.glow,
  });

  final Color bg;
  final Color muted;
  final Color idleFill;
  final Color idleLine;
  final Color accent;
  final Color text;
  final Color error;
  final Color glow;

  static const dark = AppPalette(
    bg: Color(0xFF0A0A0A),
    muted: Color(0xFF9A9A9A),
    idleFill: Color(0xFF9A9A9A),
    idleLine: Color(0xFF3A3A3A),
    accent: Color(0xFF00E5C3),
    text: Color(0xFFF2F2F2),
    error: Color(0xFFE57373),
    glow: Color(0x2900E5C3),
  );

  static const light = AppPalette(
    bg: Color(0xFFF3F0E8),
    muted: Color(0xFF5F5A50),
    idleFill: Color(0xFF9A9488),
    idleLine: Color(0xFFD2CCC0),
    accent: Color(0xFF0C7F70),
    text: Color(0xFF1A1916),
    error: Color(0xFFC45656),
    glow: Color(0x3300B89A),
  );

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>()!;
  }

  @override
  AppPalette copyWith({
    Color? bg,
    Color? muted,
    Color? idleFill,
    Color? idleLine,
    Color? accent,
    Color? text,
    Color? error,
    Color? glow,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      muted: muted ?? this.muted,
      idleFill: idleFill ?? this.idleFill,
      idleLine: idleLine ?? this.idleLine,
      accent: accent ?? this.accent,
      text: text ?? this.text,
      error: error ?? this.error,
      glow: glow ?? this.glow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      idleFill: Color.lerp(idleFill, other.idleFill, t)!,
      idleLine: Color.lerp(idleLine, other.idleLine, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      text: Color.lerp(text, other.text, t)!,
      error: Color.lerp(error, other.error, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppPalette.light);

  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark
        ? ColorScheme.dark(
            surface: palette.bg,
            primary: palette.accent,
            error: palette.error,
          )
        : ColorScheme.light(
            surface: palette.bg,
            primary: palette.accent,
            error: palette.error,
          );

    return ThemeData(
      brightness: brightness,
      fontFamily: 'IBMPlexMono',
      scaffoldBackgroundColor: palette.bg,
      colorScheme: scheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: palette.accent.withValues(alpha: 0.08),
      extensions: [palette],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_daydreaming/theme_controller.dart';

void main() {
  test('toggle flips dark to light and back', () {
    final theme = ThemeController(persist: false);
    addTearDown(theme.dispose);

    expect(theme.mode, ThemeMode.dark);
    expect(theme.isDark, isTrue);

    theme.toggle();
    expect(theme.mode, ThemeMode.light);
    expect(theme.isDark, isFalse);

    theme.toggle();
    expect(theme.mode, ThemeMode.dark);
  });
}

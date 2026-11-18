import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/themes/theme.dart';

void main() {
  group('themes', () {
    test('contains a theme for every ThemeType', () {
      for (final type in ThemeType.values) {
        expect(
          themes[type],
          isNotNull,
          reason: 'ThemeType.${type.name} has no AppTheme',
        );
      }
      expect(themes, hasLength(ThemeType.values.length));
    });

    test('every theme provides a light and a dark ThemeData', () {
      for (final type in ThemeType.values) {
        final appTheme = themes[type]!;

        expect(appTheme.theme.brightness, Brightness.light);
        expect(appTheme.darkTheme.brightness, Brightness.dark);
      }
    });
  });
}

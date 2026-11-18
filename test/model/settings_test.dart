import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/settings.dart';
import 'package:mrlgplayer/themes/theme.dart';

void main() {
  Settings createSettings() {
    return Settings(
      theme: ThemeType.miku,
      themeMode: ThemeMode.dark,
      lyricsProvider: LyricsProviderType.petitLyrics,
      nicosid: 'nicosid',
      userSession: 'user-session',
    );
  }

  group('Settings', () {
    test('keeps the values passed to the constructor', () {
      final settings = createSettings();

      expect(settings.theme, ThemeType.miku);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.lyricsProvider, LyricsProviderType.petitLyrics);
      expect(settings.nicosid, 'nicosid');
      expect(settings.userSession, 'user-session');
    });

    test('copyWith without arguments keeps every value', () {
      final settings = createSettings();
      final copy = settings.copyWith();

      expect(copy.theme, settings.theme);
      expect(copy.themeMode, settings.themeMode);
      expect(copy.lyricsProvider, settings.lyricsProvider);
      expect(copy.nicosid, settings.nicosid);
      expect(copy.userSession, settings.userSession);
    });

    test('copyWith replaces non-nullable values', () {
      final copy = createSettings().copyWith(
        theme: ThemeType.gumi,
        themeMode: ThemeMode.light,
        lyricsProvider: LyricsProviderType.genius,
      );

      expect(copy.theme, ThemeType.gumi);
      expect(copy.themeMode, ThemeMode.light);
      expect(copy.lyricsProvider, LyricsProviderType.genius);
    });

    test('copyWith keeps nullable values when they are omitted', () {
      final copy = createSettings().copyWith(theme: ThemeType.rin);

      expect(copy.nicosid, 'nicosid');
      expect(copy.userSession, 'user-session');
    });

    test('copyWith can clear nullable values with null', () {
      final copy = createSettings().copyWith(nicosid: null, userSession: null);

      expect(copy.nicosid, isNull);
      expect(copy.userSession, isNull);
    });

    test('copyWith can set nullable values to an empty string', () {
      final copy = createSettings().copyWith(nicosid: '', userSession: '');

      expect(copy.nicosid, isEmpty);
      expect(copy.userSession, isEmpty);
    });

    test('copyWith does not modify the original instance', () {
      final settings = createSettings();

      settings.copyWith(theme: ThemeType.len, nicosid: null);

      expect(settings.theme, ThemeType.miku);
      expect(settings.nicosid, 'nicosid');
    });
  });
}

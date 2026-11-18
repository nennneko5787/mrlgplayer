import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/notifier/lyrics.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/model/settings.dart';
import 'package:mrlgplayer/model/song.dart';
import 'package:mrlgplayer/settings.dart';
import 'package:mrlgplayer/themes/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsNotifier', () {
    setUp(() {
      SettingsManager().prefs = null;
      SettingsManager().settings = Settings(
        theme: ThemeType.initial,
        themeMode: ThemeMode.system,
        lyricsProvider: LyricsProviderType.nicovideo,
      );
    });

    test('builds from the current SettingsManager values', () {
      final container = ProviderContainer.test();
      final subscription = container.listen(settingsProvider, (_, _) {});
      addTearDown(subscription.close);

      final settings = container.read(settingsProvider);

      expect(settings.theme, ThemeType.initial);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.lyricsProvider, LyricsProviderType.nicovideo);
    });

    test('updates the theme, theme mode and lyrics provider', () async {
      final container = ProviderContainer.test();
      final subscription = container.listen(settingsProvider, (_, _) {});
      addTearDown(subscription.close);

      final notifier = container.read(settingsProvider.notifier);
      await notifier.changeTheme(ThemeType.miku);
      await notifier.changeThemeMode(ThemeMode.dark);
      await notifier.changeLyricsProvider(LyricsProviderType.genius);

      final settings = container.read(settingsProvider);
      expect(settings.theme, ThemeType.miku);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.lyricsProvider, LyricsProviderType.genius);
    });

    test('keeps working when no preferences are available', () async {
      final container = ProviderContainer.test();
      final subscription = container.listen(settingsProvider, (_, _) {});
      addTearDown(subscription.close);

      await container.read(settingsProvider.notifier).changeTheme(ThemeType.rin);

      expect(container.read(settingsProvider).theme, ThemeType.rin);
    });
  });

  group('LyricsNotifier', () {
    test('starts without lyrics and can set them', () {
      final container = ProviderContainer.test();
      final subscription = container.listen(lyricsProvider, (_, _) {});
      addTearDown(subscription.close);

      expect(container.read(lyricsProvider).lyrics, isNull);

      final lyrics = Lyrics(
        characters: [Character(id: 0)],
        textLines: [TextLine(characterId: 0, text: 'line')],
      );
      container.read(lyricsProvider.notifier).setLyrics(lyrics);

      final state = container.read(lyricsProvider);
      expect(state.lyrics, same(lyrics));
      expect(state.hasError, isFalse);
    });

    test('opens and closes the lyrics view', () {
      final container = ProviderContainer.test();
      final subscription = container.listen(lyricsProvider, (_, _) {});
      addTearDown(subscription.close);

      final notifier = container.read(lyricsProvider.notifier);
      notifier.setLyricsViewOpened(true);
      expect(container.read(lyricsProvider).isLyricsViewOpened, isTrue);

      notifier.setLyricsViewOpened(false);
      expect(container.read(lyricsProvider).isLyricsViewOpened, isFalse);
    });

    test('reset clears the lyrics and the flags', () {
      final container = ProviderContainer.test();
      final subscription = container.listen(lyricsProvider, (_, _) {});
      addTearDown(subscription.close);

      final notifier = container.read(lyricsProvider.notifier);
      notifier.setLyrics(
        Lyrics(
          characters: [Character(id: 0)],
          textLines: [TextLine(characterId: 0, text: 'line')],
        ),
      );
      notifier.setLyricsViewOpened(true);
      notifier.reset();

      final state = container.read(lyricsProvider);
      expect(state.lyrics, isNull);
      expect(state.hasError, isFalse);
      expect(state.isLyricsViewOpened, isFalse);
    });
  });

  group('PlayingNotifier', () {
    test('starts without a song and can set and stop it', () {
      final container = ProviderContainer.test();
      final subscription = container.listen(playingProvider, (_, _) {});
      addTearDown(subscription.close);

      expect(container.read(playingProvider), isNull);

      final song = Song(
        id: 'sm9',
        service: 'nicovideo',
        title: 'テスト曲',
        artist: 'uploader',
        websiteUrl: 'https://nico.ms/sm9',
      );
      final notifier = container.read(playingProvider.notifier);
      notifier.setSong(song);

      expect(container.read(playingProvider), same(song));

      notifier.stop();
      expect(container.read(playingProvider), isNull);
    });
  });
}

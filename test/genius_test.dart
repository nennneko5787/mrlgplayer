import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/genius/genius.dart';
import 'package:mrlgplayer/genius/models/songs.dart';

void main() {
  GeniusHitResult hit(String title, String artist) =>
      GeniusHitResult(id: title.hashCode, title: title, artistNames: artist);

  group('isGeniusTranslationPage', () {
    test('rejects pages by Genius Romanizations', () {
      expect(
        isGeniusTranslationPage(
          hit('フォニイ (phony) (Romanized)', 'Genius Romanizations'),
        ),
        isTrue,
      );
    });

    test('rejects an English translation suffix', () {
      expect(
        isGeniusTranslationPage(
          hit('フォニイ (phony) (English Translation)', 'Some Translator'),
        ),
        isTrue,
      );
    });

    test('accepts the original song with a reading in parentheses', () {
      expect(
        isGeniusTranslationPage(hit('フォニイ (phony)', 'ツミキ (Tsumiki)')),
        isFalse,
      );
    });
  });

  group('pickBestGeniusHit', () {
    test('prefers the original over romanized and translated pages', () {
      final results = [
        hit(
          'ツミキ (Tsumiki) - フォニイ (phony) ft. 可不 (KAFU) (Romanized)',
          'Genius Romanizations',
        ),
        hit(
          'ツミキ (Tsumiki) - フォニイ (phony) ft. 可不 (KAFU) (English Translation)',
          'Genius English Translations',
        ),
        hit('フォニイ (phony)', 'ツミキ (Tsumiki) (Ft. 可不 (KAFU))'),
      ];

      final best = pickBestGeniusHit(
        results,
        expectedTitles: ['フォニイ'],
        artist: 'ツミキ',
      );

      expect(best?.title, 'フォニイ (phony)');
    });

    test('returns null when no hit matches the requested song', () {
      final results = [
        hit('INMU KING', 'やじゅまん (Yajuman) & YAJU-MC'),
        hit('Imu', 'Someone'),
      ];

      final best = pickBestGeniusHit(
        results,
        expectedTitles: ['フォニイ'],
        artist: 'ツミキ',
      );

      expect(best, isNull);
    });

    test(
      'does not accept a shorter title when the full title is requested',
      () {
        final results = [
          hit('Hibana', 'Someone'),
          hit('Hibana -Reloaded-', 'Another'),
        ];

        final best = pickBestGeniusHit(
          results,
          expectedTitles: ['Hibana -Reloaded-'],
        );

        expect(best?.title, 'Hibana -Reloaded-');
      },
    );

    test('uses the artist to choose between identically named songs', () {
      final results = [
        hit('Never Gonna Give You Up', 'The Black Keys'),
        hit('Never Gonna Give You Up', 'Rick Astley'),
      ];

      final best = pickBestGeniusHit(
        results,
        expectedTitles: ['Never Gonna Give You Up'],
        artist: 'Rick Astley',
      );

      expect(best?.artistNames, 'Rick Astley');
    });

    test('returns null for an empty result list', () {
      expect(pickBestGeniusHit(const [], expectedTitles: ['フォニイ']), isNull);
    });
  });
}

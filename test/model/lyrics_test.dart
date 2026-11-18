import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/model/lyrics.dart';

void main() {
  Lyrics createLyrics() {
    return Lyrics(
      characters: [
        Character(id: 0, name: 'main', align: TextAlign.center),
        Character(id: 1, name: 'second', color: Colors.red),
      ],
      textLines: [
        TextLine(
          characterId: 0,
          start: const Duration(seconds: 1),
          end: const Duration(seconds: 2),
          text: 'line 1',
        ),
        TextLine(characterId: 1, text: 'line 2'),
      ],
    );
  }

  group('Lyrics', () {
    test('stores characters and text lines', () {
      final lyrics = createLyrics();

      expect(lyrics.characters, hasLength(2));
      expect(lyrics.characters.first.align, TextAlign.center);
      expect(lyrics.characters.last.color, Colors.red);
      expect(lyrics.textLines, hasLength(2));
      expect(lyrics.textLines.first.start, const Duration(seconds: 1));
      expect(lyrics.textLines.first.end, const Duration(seconds: 2));
      expect(lyrics.textLines.last.end, isNull);
      expect(lyrics.textLines.last.text, 'line 2');
    });
  });

  group('LyricsState', () {
    test('has sensible defaults', () {
      final state = LyricsState(lyrics: null);

      expect(state.lyrics, isNull);
      expect(state.hasError, isFalse);
      expect(state.isLyricsViewOpened, isFalse);
    });

    test('copyWith without arguments keeps every value', () {
      final lyrics = createLyrics();
      final state = LyricsState(
        lyrics: lyrics,
        hasError: true,
        isLyricsViewOpened: true,
      );

      final copy = state.copyWith();

      expect(copy.lyrics, same(lyrics));
      expect(copy.hasError, isTrue);
      expect(copy.isLyricsViewOpened, isTrue);
    });

    test('copyWith replaces lyrics and flags', () {
      final lyrics = createLyrics();
      final copy = LyricsState(
        lyrics: null,
      ).copyWith(lyrics: lyrics, hasError: true, isLyricsViewOpened: true);

      expect(copy.lyrics, same(lyrics));
      expect(copy.hasError, isTrue);
      expect(copy.isLyricsViewOpened, isTrue);
    });

    test('copyWith can clear lyrics with null', () {
      final state = LyricsState(lyrics: createLyrics(), hasError: true);

      final copy = state.copyWith(lyrics: null);

      expect(copy.lyrics, isNull);
      expect(copy.hasError, isTrue);
    });

    test('copyWith can reset flags to false', () {
      final state = LyricsState(
        lyrics: null,
        hasError: true,
        isLyricsViewOpened: true,
      );

      final copy = state.copyWith(hasError: false, isLyricsViewOpened: false);

      expect(copy.hasError, isFalse);
      expect(copy.isLyricsViewOpened, isFalse);
    });
  });
}

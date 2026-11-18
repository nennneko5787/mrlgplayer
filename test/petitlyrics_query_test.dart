import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/petitlyrics/query.dart';

void main() {
  List<PetitLyricsQuery> queries(String title, {String uploader = ''}) =>
      inferPetitLyricsQueries(title: title, uploader: uploader);

  List<String> titles(String title, {String uploader = ''}) =>
      queries(title, uploader: uploader).map((query) => query.title).toList();

  group('PetitLyricsQuery', () {
    test('compares by title and artist', () {
      const query = PetitLyricsQuery(title: 'フォニイ', artist: 'ツミキ');

      expect(
        query,
        const PetitLyricsQuery(title: 'フォニイ', artist: 'ツミキ'),
      );
      expect(
        query.hashCode,
        const PetitLyricsQuery(title: 'フォニイ', artist: 'ツミキ').hashCode,
      );
      expect(
        query,
        isNot(const PetitLyricsQuery(title: 'フォニイ', artist: 'DECO*27')),
      );
    });

    test('has a readable string representation', () {
      expect(
        const PetitLyricsQuery(title: 'フォニイ', artist: 'ツミキ').toString(),
        'PetitLyricsQuery(title: "フォニイ", artist: "ツミキ")',
      );
    });
  });

  group('inferPetitLyricsQueries', () {
    test('keeps English titles intact instead of taking the first word', () {
      expect(
        titles('Never Gonna Give You Up / Rick Astley').first,
        'Never Gonna Give You Up',
      );
    });

    test('does not strip the title with a greedy bracket match', () {
      expect(titles('【初音ミク】フォニイ / ツミキ【オリジナル曲】').first, 'フォニイ');
    });

    test('removes decorations around an English title', () {
      expect(
        titles('【MV】English Song Title【Official Video】').first,
        'English Song Title',
      );
    });

    test('removes Japanese quotes around the title', () {
      expect(titles('【初音ミク】「フォニイ」 / ツミキ【オリジナル】').first, 'フォニイ');
    });

    test('keeps a dash that belongs to the title', () {
      expect(titles('Hibana -Reloaded- / 初音ミク').first, 'Hibana -Reloaded-');
    });

    test('splits on a full-width slash', () {
      final inferred = queries('Song ／ Artist');

      expect(inferred.first.title, 'Song');
      expect(inferred.first.artist, isEmpty);
      expect(inferred[1].title, 'Song');
      expect(inferred[1].artist, 'Artist');
    });

    test('uses the uploader to detect "artist - title" order', () {
      final inferred = queries(
        'DECO*27 - ヴァンパイア feat. 初音ミク',
        uploader: 'DECO*27',
      );

      expect(inferred.first.title, 'ヴァンパイア');
      expect(inferred.first.artist, isEmpty);
    });

    test('falls back to the other side of the separator', () {
      final inferred = queries('DECO*27 - ヴァンパイア feat. 初音ミク');

      expect(inferred.map((query) => query.title), contains('ヴァンパイア'));
      expect(inferred.map((query) => query.title), contains('DECO*27'));
    });

    test('keeps the artist when the uploader does not match', () {
      final inferred = queries('Song / Artist', uploader: 'Someone else');

      expect(inferred.first.title, 'Song');
      expect(inferred.first.artist, isEmpty);
      expect(inferred[1].artist, 'Artist');
    });

    test('removes feat performers from the title', () {
      final inferred = queries('ヴァンパイア feat. 初音ミク');

      expect(inferred.first.title, 'ヴァンパイア');
      expect(inferred.first.artist, isEmpty);
      expect(
        inferred.map((query) => query.artist),
        contains('初音ミク'),
      );
    });

    test('keeps parentheses in the last-resort query', () {
      final inferred = titles('Song (TV size)');

      expect(inferred, contains('Song'));
      expect(inferred, contains('Song (TV size)'));
    });

    test('returns no queries for an empty title', () {
      expect(queries(''), isEmpty);
      expect(queries('   '), isEmpty);
    });

    test('does not return empty queries or duplicates', () {
      final inferred = queries('【】Song【】');

      expect(inferred, isNotEmpty);
      expect(inferred.every((query) => query.title.isNotEmpty), isTrue);
      expect(inferred.toSet().length, inferred.length);
    });
  });

  group('normalizeLyricsText', () {
    test('ignores spaces, punctuation, case and full-width forms', () {
      expect(
        normalizeLyricsText('Ｈｉｂａｎａ -Reloaded-'),
        normalizeLyricsText('hibana reloaded'),
      );
    });

    test('converts full-width latin letters and digits', () {
      expect(normalizeLyricsText('ＡＢＣ１２３'), 'abc123');
    });

    test('removes full-width spaces and keeps unicode letters', () {
      expect(normalizeLyricsText('初音　ミク'), '初音ミク');
    });

    test('returns an empty string when nothing remains', () {
      expect(normalizeLyricsText(' !!! '), isEmpty);
    });
  });

  group('lyricsSimilarity', () {
    test('returns 1 for equivalent text', () {
      expect(
        lyricsSimilarity('Hibana -Reloaded-', 'ｈｉｂａｎａ reloaded'),
        1,
      );
    });

    test('returns 0 when either side is empty', () {
      expect(lyricsSimilarity('', 'Hibana'), 0);
      expect(lyricsSimilarity('Hibana', '  '), 0);
    });

    test('gives a partial score to one-character titles', () {
      expect(lyricsSimilarity('a', 'ab'), 0.8);
      expect(lyricsSimilarity('a', 'b'), 0);
    });

    test('returns 0 for unrelated titles', () {
      expect(lyricsSimilarity('Hibana', 'Unrelated Song'), 0);
    });

    test('scores similar titles above the confidence threshold', () {
      expect(
        lyricsSimilarity('Hibana -Reloaded-', 'ヒバナ -Reloaded-'),
        greaterThanOrEqualTo(0.6),
      );
    });

    test('tolerates decorations around the title', () {
      expect(lyricsSimilarity('フォニイ', 'フォニイ (TV size)'), greaterThan(0));
    });
  });

  group('isConfidentLyricsMatch', () {
    test('accepts an exact normalized match', () {
      expect(isConfidentLyricsMatch('Ｈｉｂａｎａ', 'hibana'), isTrue);
    });

    test('accepts a candidate with a suffix', () {
      expect(isConfidentLyricsMatch('フォニイ', 'フォニイ (phony)'), isTrue);
    });

    test('accepts a romanized variant', () {
      expect(
        isConfidentLyricsMatch('Hibana -Reloaded-', 'ヒバナ -Reloaded-'),
        isTrue,
      );
    });

    test('rejects unrelated candidates', () {
      expect(isConfidentLyricsMatch('Hibana', 'Unrelated Song'), isFalse);
    });

    test('rejects empty values', () {
      expect(isConfidentLyricsMatch('', 'Hibana'), isFalse);
      expect(isConfidentLyricsMatch('Hibana', ''), isFalse);
    });
  });
}

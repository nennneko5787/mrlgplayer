import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/genius/genius.dart';

import '../support/fake_http_adapter.dart';

void main() {
  Map<String, dynamic> searchResponse(List<Map<String, dynamic>> results) {
    return {
      'response': {
        'sections': [
          {
            'hits': [
              for (final result in results) {'result': result},
            ],
          },
        ],
      },
    };
  }

  late Genius genius;

  setUp(() {
    genius = Genius();
  });

  group('searchSongs', () {
    test('parses every hit and sends the query', () async {
      final adapter = FakeHttpAdapter((request) {
        expect(request.uri.path, '/search/song');
        expect(request.uri.queryParameters['q'], 'フォニイ');
        return jsonResponse(
          searchResponse([
            {'id': 1, 'title': 'フォニイ', 'artist_names': 'ツミキ'},
            {'id': 2, 'title': 'フォニイ (TV size)', 'artist_names': 'ツミキ'},
          ]),
        );
      });
      genius.http.httpClientAdapter = adapter;

      final results = await genius.searchSongs('フォニイ');

      expect(results, hasLength(2));
      expect(results.first.id, 1);
      expect(results.first.title, 'フォニイ');
      expect(results.first.artistNames, 'ツミキ');
      expect(results.last.title, 'フォニイ (TV size)');
      expect(adapter.requests, hasLength(1));
    });

    test('throws when the server returns an error', () async {
      genius.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({'error': 'boom'}, statusCode: 500),
      );

      await expectLater(
        genius.searchSongs('フォニイ'),
        throwsA(isA<GeniusServerException>()),
      );
    });
  });

  group('searchSong', () {
    test('picks the result that best matches the title', () async {
      genius.http.httpClientAdapter = FakeHttpAdapter((request) {
        return jsonResponse(
          searchResponse([
            {'id': 1, 'title': 'Hibana', 'artist_names': 'Artist'},
            {'id': 2, 'title': 'Hibana -Reloaded-', 'artist_names': 'Artist'},
            {'id': 3, 'title': 'Unrelated', 'artist_names': 'Other'},
          ]),
        );
      });

      final song = await genius.searchSong(query: 'Hibana -Reloaded-');

      expect(song, isNotNull);
      expect(song!.id, 2);
      expect(song.title, 'Hibana -Reloaded-');
    });

    test('uses the artist as a tie breaker', () async {
      genius.http.httpClientAdapter = FakeHttpAdapter((request) {
        return jsonResponse(
          searchResponse([
            {'id': 1, 'title': 'Song', 'artist_names': 'Someone Else'},
            {'id': 2, 'title': 'Song', 'artist_names': 'The Artist'},
          ]),
        );
      });

      final song = await genius.searchSong(
        query: 'Song',
        artist: 'The Artist',
      );

      expect(song, isNotNull);
      expect(song!.id, 2);
    });

    test('returns null when the search has no hits', () async {
      genius.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse(searchResponse([])),
      );

      expect(await genius.searchSong(query: 'フォニイ'), isNull);
    });

    test('throws when the server returns an error', () async {
      genius.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({'error': 'boom'}, statusCode: 500),
      );

      await expectLater(
        genius.searchSong(query: 'フォニイ'),
        throwsA(isA<GeniusServerException>()),
      );
    });
  });

  group('getLyricBySongId', () {
    test('requests plain lyrics and splits them into lines', () async {
      final adapter = FakeHttpAdapter((request) {
        expect(request.uri.path, '/songs/123');
        expect(request.uri.queryParameters['text_format'], 'plain');
        return jsonResponse({
          'response': {
            'song': {
              'lyrics': {'plain': 'first line\nsecond line\n\n'},
            },
          },
        });
      });
      genius.http.httpClientAdapter = adapter;

      final lines = await genius.getLyricBySongId(123);

      expect(lines, ['first line', 'second line']);
      expect(adapter.requests, hasLength(1));
    });

    test('throws when the server returns an error', () async {
      genius.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({'error': 'boom'}, statusCode: 500),
      );

      await expectLater(
        genius.getLyricBySongId(123),
        throwsA(isA<GeniusServerException>()),
      );
    });
  });

  group('GeniusServerException', () {
    test('includes the message when one is provided', () {
      expect(
        GeniusServerException('Server returned 500').toString(),
        'GeniusServerException: Server returned 500',
      );
    });

    test('uses the plain name without a message', () {
      expect(GeniusServerException().toString(), 'GeniusServerException');
    });
  });
}

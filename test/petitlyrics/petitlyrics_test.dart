import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/petitlyrics/petitlyrics.dart';

import '../support/fake_http_adapter.dart';

void main() {
  const searchHtml = '''
<html><body>
<table id="lyrics_list">
  <tr>
    <td><a href="/lyrics/111">Hibana</a></td>
    <td class="lyrics-list-artist">Artist A</td>
  </tr>
  <tr>
    <td><a href="/lyrics/222">Hibana -Reloaded-</a></td>
    <td class="lyrics-list-artist">Artist B</td>
  </tr>
  <tr>
    <td><a href="/lyrics/333">Something Else</a></td>
    <td class="lyrics-list-artist">Artist C</td>
  </tr>
</table>
</body></html>
''';

  const pageWithoutResults = '''
<html><body>
<table id="lyrics_list"></table>
</body></html>
''';

  const scriptWithToken = "foo('X-CSRF-Token', 'token-abc');";

  List<Map<String, dynamic>> lyricsResponse() {
    return [
      {
        'lyrics': base64Encode(utf8.encode('line 1\nline 2\n')),
      },
      {
        'lyrics': base64Encode(utf8.encode('line 3\r\n\r\n')),
      },
    ];
  }

  late PetitLyrics petitLyrics;

  setUp(() {
    petitLyrics = PetitLyrics();
  });

  group('getLyrics', () {
    test('picks the best result and returns the decoded lyrics', () async {
      final adapter = FakeHttpAdapter((request) {
        switch (request.uri.path) {
          case '/search_lyrics':
            expect(request.uri.queryParameters['title'], 'Hibana -Reloaded-');
            expect(request.uri.queryParameters['artist'], 'Artist B');
            return htmlResponse(searchHtml);

          case '/lyrics/222':
            return htmlResponse('<html></html>');

          case '/lib/pl-lib.js':
            return textResponse(
              scriptWithToken,
              contentType: 'text/javascript; charset=utf-8',
            );

          case '/com/get_lyrics.ajax':
            expect(request.data, {'lyrics_id': '222'});
            expect(request.headers['X-CSRF-Token'], 'token-abc');
            return jsonResponse(lyricsResponse());

          default:
            return jsonResponse({'error': 'unexpected'}, statusCode: 404);
        }
      });
      petitLyrics.http.httpClientAdapter = adapter;

      final lyrics = await petitLyrics.getLyrics(
        title: 'Hibana -Reloaded-',
        artist: 'Artist B',
      );

      expect(lyrics, ['line 1\nline 2', 'line 3']);
      expect(
        adapter.requests.map((request) => request.uri.path),
        ['/search_lyrics', '/lyrics/222', '/lib/pl-lib.js', '/com/get_lyrics.ajax'],
      );
    });

    test('returns null when the search has no results', () async {
      final adapter = FakeHttpAdapter(
        (request) => htmlResponse(pageWithoutResults),
      );
      petitLyrics.http.httpClientAdapter = adapter;

      expect(await petitLyrics.getLyrics(title: 'Unknown'), isNull);
      expect(adapter.requests, hasLength(1));
    });

    test('returns null when the CSRF token cannot be found', () async {
      final adapter = FakeHttpAdapter((request) {
        switch (request.uri.path) {
          case '/search_lyrics':
            return htmlResponse(searchHtml);
          case '/lyrics/222':
            return htmlResponse('<html></html>');
          case '/lib/pl-lib.js':
            return textResponse('no token here');
          default:
            return jsonResponse({'error': 'unexpected'}, statusCode: 404);
        }
      });
      petitLyrics.http.httpClientAdapter = adapter;

      expect(
        await petitLyrics.getLyrics(
          title: 'Hibana -Reloaded-',
          artist: 'Artist B',
        ),
        isNull,
      );
      expect(adapter.requests, hasLength(3));
    });

    test('throws when the search request fails', () async {
      petitLyrics.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({'error': 'boom'}, statusCode: 500),
      );

      await expectLater(
        petitLyrics.getLyrics(title: 'Hibana -Reloaded-'),
        throwsA(isA<PetitLyricsServerException>()),
      );
    });

    test('throws when fetching the lyrics fails', () async {
      petitLyrics.http.httpClientAdapter = FakeHttpAdapter((request) {
        switch (request.uri.path) {
          case '/search_lyrics':
            return htmlResponse(searchHtml);
          case '/lyrics/222':
            return htmlResponse('<html></html>');
          case '/lib/pl-lib.js':
            return textResponse(scriptWithToken);
          default:
            return jsonResponse({'error': 'boom'}, statusCode: 500);
        }
      });

      await expectLater(
        petitLyrics.getLyrics(
          title: 'Hibana -Reloaded-',
          artist: 'Artist B',
        ),
        throwsA(isA<PetitLyricsServerException>()),
      );
    });
  });

  group('PetitLyricsServerException', () {
    test('includes the message when one is provided', () {
      expect(
        PetitLyricsServerException('Server returned 500').toString(),
        'PetitLyricsServerException: Server returned 500',
      );
    });

    test('uses the plain name without a message', () {
      expect(
        PetitLyricsServerException().toString(),
        'PetitLyricsServerException',
      );
    });
  });
}

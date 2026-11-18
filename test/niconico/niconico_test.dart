import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/niconico/models/watchdatav3.dart';
import 'package:mrlgplayer/niconico/niconico.dart';

import '../support/fake_http_adapter.dart';
import '../support/fixtures.dart';

void main() {
  WatchDataV3Media createMedia() {
    return WatchDataV3Response.fromJson(sampleWatchDataJson()).media;
  }

  Map<String, dynamic> accessRightJson() {
    return {
      'data': {
        'contentUrl': 'https://example.com/playlist.m3u8',
        'createTime': '2024-01-02T03:04:05+09:00',
        'expireTime': '2024-01-02T04:04:05+09:00',
      },
    };
  }

  late Niconico niconico;

  setUp(() {
    niconico = Niconico();
  });

  group('getVideoLyrics', () {
    test('parses the lyrics response', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter((request) {
        expect(request.uri.path, '/v1/videos/sm9/lyrics');
        return jsonResponse({
          'data': {
            'id': 'sm9',
            'lyrics': [
              {
                'lines': ['line 1', 'line 2'],
                'startMs': 1000,
                'endMs': 2000,
              },
            ],
          },
        });
      });

      final response = await niconico.getVideoLyrics('sm9');

      expect(response, isNotNull);
      expect(response!.id, 'sm9');
      expect(response.lyrics.single.lines, ['line 1', 'line 2']);
      expect(response.lyrics.single.startMs, 1000);
      expect(response.lyrics.single.endMs, 2000);
    });

    test('returns null when the video has no lyrics', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({}, statusCode: 404),
      );

      expect(await niconico.getVideoLyrics('sm9'), isNull);
    });

    test('throws when the server returns an error', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({'error': 'boom'}, statusCode: 500),
      );

      await expectLater(
        niconico.getVideoLyrics('sm9'),
        throwsA(isA<NiconicoServerException>()),
      );
    });
  });

  group('getActionTrackId', () {
    const html = r'''
<html><body>
<script>window.__reactRouterContext.streamController.enqueue("[\"watchTrackId\",\"track-from-html\"]")</script>
</body></html>
''';

    test('extracts the watch track id from the page', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter((request) {
        expect(request.uri.path, '/watch/sm9');
        return htmlResponse(html);
      });

      expect(await niconico.getActionTrackId('sm9'), 'track-from-html');
    });

    test('throws when the script element is missing', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter(
        (request) => htmlResponse('<html><body>no script</body></html>'),
      );

      await expectLater(
        niconico.getActionTrackId('sm9'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('WatchTrackId'),
          ),
        ),
      );
    });

    test('throws when the track id is missing from the script', () async {
      const page = r'''
<html><body>
<script>window.__reactRouterContext.streamController.enqueue("{\"watchId\":\"watch-id\"}")</script>
</body></html>
''';
      niconico.http.httpClientAdapter = FakeHttpAdapter(
        (request) => htmlResponse(page),
      );

      await expectLater(
        niconico.getActionTrackId('sm9'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('watchTrackId'),
          ),
        ),
      );
    });

    test('throws when the server returns an error', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter(
        (request) => htmlResponse('error', statusCode: 503),
      );

      await expectLater(
        niconico.getActionTrackId('sm9'),
        throwsA(isA<NiconicoServerException>()),
      );
    });
  });

  group('getV3WatchData', () {
    test('uses the guest endpoint for guests', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter((request) {
        expect(request.uri.path, '/api/watch/v3_guest/sm9');
        expect(request.uri.queryParameters['actionTrackId'], 'track-id');
        expect(request.uri.queryParameters['_clientOsType'], 'others');
        expect(request.uri.queryParameters['_frontendId'], '3');
        expect(request.uri.queryParameters['i18nLanguage'], 'ja-jp');

        return jsonResponse({'data': sampleWatchDataJson()});
      });

      final response = await niconico.getV3WatchData('sm9', 'track-id', true);

      expect(response.client.watchTrackId, 'track-id');
      expect(response.video.title, 'テスト曲');
      expect(response.media.domand.audios, hasLength(3));
    });

    test('uses the logged-in endpoint for logged-in users', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter((request) {
        expect(request.uri.path, '/api/watch/v3/sm9');
        return jsonResponse({'data': sampleWatchDataJson()});
      });

      final response = await niconico.getV3WatchData('sm9', 'track-id', false);

      expect(response.owner.nickname, 'uploader');
    });

    test('throws when the server returns an error', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({'error': 'boom'}, statusCode: 500),
      );

      await expectLater(
        niconico.getV3WatchData('sm9', 'track-id', true),
        throwsA(isA<NiconicoServerException>()),
      );
    });
  });

  group('getNvApiV1DomandHlsAccessRightAsync', () {
    test('requests only available audio streams by default', () async {
      final adapter = FakeHttpAdapter((request) {
        expect(request.method, 'POST');
        expect(request.uri.path, '/v1/watch/sm9/access-rights/hls');
        expect(request.uri.queryParameters['actionTrackId'], 'track-id');
        expect(request.headers['X-Access-Right-Key'], 'access-right-key');

        final body = jsonDecode(request.data as String);
        expect(body, {
          'outputs': [
            ['audio1'],
            ['audio2'],
          ],
        });

        return jsonResponse(
          accessRightJson(),
          headers: {
            'set-cookie': ['domand_bid=bid-value; Path=/;'],
          },
        );
      });
      niconico.http.httpClientAdapter = adapter;

      final result = await niconico.getNvApiV1DomandHlsAccessRightAsync(
        'sm9',
        createMedia(),
        watchTrackId: 'track-id',
      );

      expect(result.response.contentUrl, 'https://example.com/playlist.m3u8');
      expect(result.domandBid, 'bid-value');
      expect(adapter.requests, hasLength(1));
    });

    test(
      'combines available videos and audios when audioOnly is false',
      () async {
        final adapter = FakeHttpAdapter((request) {
          final body = jsonDecode(request.data as String);
          expect(body, {
            'outputs': [
              ['video1', 'audio1'],
              ['video1', 'audio2'],
            ],
          });

          return jsonResponse(
            accessRightJson(),
            headers: {
              'set-cookie': ['domand_bid=bid-value; Path=/;'],
            },
          );
        });
        niconico.http.httpClientAdapter = adapter;

        await niconico.getNvApiV1DomandHlsAccessRightAsync(
          'sm9',
          createMedia(),
          audioOnly: false,
        );

        expect(adapter.requests, hasLength(1));
      },
    );

    test('throws when the server returns an error', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({'error': 'boom'}, statusCode: 500),
      );

      await expectLater(
        niconico.getNvApiV1DomandHlsAccessRightAsync('sm9', createMedia()),
        throwsA(isA<NiconicoServerException>()),
      );
    });
  });

  group('getVariantsDomandHlsAccessRight', () {
    test('requests the access right and reads the domand bid cookie', () async {
      niconico.http.httpClientAdapter = FakeHttpAdapter((request) {
        expect(request.method, 'POST');
        expect(request.uri.path, '/v1/watch/sm9/access-rights/hls');
        expect(request.headers['Referer'], 'https://www.nicovideo.jp/');

        return jsonResponse(
          accessRightJson(),
          headers: {
            'set-cookie': ['domand_bid=variant-bid; Path=/;'],
          },
        );
      });

      final result = await niconico.getVariantsDomandHlsAccessRight(
        'sm9',
        createMedia(),
      );

      expect(result.response.contentUrl, 'https://example.com/playlist.m3u8');
      expect(result.domandBid, 'variant-bid');
    });
  });

  group('NiconicoServerException', () {
    test('includes the message when one is provided', () {
      expect(
        NiconicoServerException('Server returned 500').toString(),
        'NiconicoServerException: Server returned 500',
      );
    });

    test('uses the plain name without a message', () {
      expect(NiconicoServerException().toString(), 'NiconicoServerException');
    });
  });
}

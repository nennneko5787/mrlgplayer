import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/genius/models/songs.dart';
import 'package:mrlgplayer/niconico/models/domand.dart';
import 'package:mrlgplayer/niconico/models/lyrics.dart';
import 'package:mrlgplayer/niconico/models/watchdatav3.dart';

import '../support/fixtures.dart';

void main() {
  group('VideoLyricsResponse', () {
    test('parses the niconico lyrics response', () {
      final response = VideoLyricsResponse.fromJson({
        'id': 'sm9',
        'lyrics': [
          {
            'lines': ['first line', 'second line'],
            'startMs': 1000,
            'endMs': 2000,
          },
          {
            'lines': ['third line'],
            'startMs': 2000,
            'endMs': 3000,
          },
        ],
      });

      expect(response.id, 'sm9');
      expect(response.lyrics, hasLength(2));
      expect(response.lyrics.first.lines, ['first line', 'second line']);
      expect(response.lyrics.first.startMs, 1000);
      expect(response.lyrics.first.endMs, 2000);
      expect(response.lyrics.last.lines, ['third line']);
    });

    test('can be encoded back to JSON', () {
      final response = VideoLyricsResponse(
        id: 'sm9',
        lyrics: [
          VideoLyrics(lines: ['line'], startMs: 1, endMs: 2),
        ],
      );

      expect(jsonDecode(jsonEncode(response)), {
        'id': 'sm9',
        'lyrics': [
          {'lines': ['line'], 'startMs': 1, 'endMs': 2},
        ],
      });
    });
  });

  group('WatchDataV3Response', () {
    test('parses the watch data', () {
      final response = WatchDataV3Response.fromJson(sampleWatchDataJson());

      expect(response.client.nicosid, 'nicosid-value');
      expect(response.client.watchTrackId, 'track-id');
      expect(response.media.domand.accessRightKey, 'access-right-key');
      expect(response.media.domand.videos, hasLength(2));
      expect(response.media.domand.videos.first.id, 'video1');
      expect(response.media.domand.videos.first.isAvailable, isTrue);
      expect(response.media.domand.videos.last.isAvailable, isFalse);
      expect(response.media.domand.audios, hasLength(3));
      expect(response.media.domand.audios.first.label.quality, 'AAC');
      expect(response.media.domand.audios.first.loudnessCollection, hasLength(1));
      expect(response.owner.id, 42);
      expect(response.owner.nickname, 'uploader');
      expect(response.video.id, 'sm9');
      expect(response.video.title, 'テスト曲');
      expect(response.video.count.view, 100);
      expect(response.video.thumbnail.url, 'https://example.com/thumb.png');
      expect(response.video.thumbnail.middleUrl, isNull);
      expect(
        response.video.registeredAt,
        DateTime.parse('2024-01-02T03:04:05+09:00'),
      );
    });

    test('survives a JSON round trip', () {
      final response = WatchDataV3Response.fromJson(sampleWatchDataJson());
      final encoded = jsonDecode(jsonEncode(response)) as Map<String, dynamic>;
      final decoded = WatchDataV3Response.fromJson(encoded);

      expect(decoded.client.watchTrackId, response.client.watchTrackId);
      expect(decoded.media.domand.accessRightKey, 'access-right-key');
      expect(decoded.media.domand.audios, hasLength(3));
      expect(decoded.video.title, 'テスト曲');
      expect(decoded.video.registeredAt, response.video.registeredAt);
    });
  });

  group('DomandHlsAccessRightResponse', () {
    test('parses the access right response', () {
      final response = DomandHlsAccessRightResponse.fromJson({
        'contentUrl': 'https://example.com/playlist.m3u8',
        'createTime': '2024-01-02T03:04:05+09:00',
        'expireTime': '2024-01-02T04:04:05+09:00',
      });

      expect(response.contentUrl, 'https://example.com/playlist.m3u8');
      expect(
        response.createTime,
        DateTime.parse('2024-01-02T03:04:05+09:00'),
      );
      expect(
        response.expireTime,
        DateTime.parse('2024-01-02T04:04:05+09:00'),
      );
    });

    test('can be encoded back to JSON', () {
      final response = DomandHlsAccessRightResponse(
        contentUrl: 'https://example.com/playlist.m3u8',
        createTime: DateTime.utc(2024, 1, 2),
        expireTime: DateTime.utc(2024, 1, 3),
      );

      expect(response.toJson(), {
        'contentUrl': 'https://example.com/playlist.m3u8',
        'createTime': '2024-01-02T00:00:00.000Z',
        'expireTime': '2024-01-03T00:00:00.000Z',
      });
    });
  });

  group('GeniusHitResult', () {
    test('maps artist_names to artistNames', () {
      final result = GeniusHitResult.fromJson({
        'id': 1,
        'title': 'フォニイ',
        'artist_names': 'ツミキ',
      });

      expect(result.id, 1);
      expect(result.title, 'フォニイ');
      expect(result.artistNames, 'ツミキ');
      expect(result.toJson(), {
        'id': 1,
        'title': 'フォニイ',
        'artist_names': 'ツミキ',
      });
    });
  });
}

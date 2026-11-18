import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('extractNiconicoVideoId', () {
    test('supports the nico.ms short URL', () {
      expect(extractNiconicoVideoId('https://nico.ms/sm9'), 'sm9');
      expect(extractNiconicoVideoId('http://nico.ms/sm9'), 'sm9');
    });

    test('supports nicovideo.jp watch URLs', () {
      expect(
        extractNiconicoVideoId('https://www.nicovideo.jp/watch/sm9'),
        'sm9',
      );
      expect(extractNiconicoVideoId('https://nicovideo.jp/watch/sm9'), 'sm9');
      expect(
        extractNiconicoVideoId('http://www.nicovideo.jp/watch/sm9'),
        'sm9',
      );
    });

    test('ignores query strings, fragments and trailing paths', () {
      expect(extractNiconicoVideoId('https://nico.ms/sm9?ref=share'), 'sm9');
      expect(extractNiconicoVideoId('https://nico.ms/sm9#section'), 'sm9');
      expect(
        extractNiconicoVideoId('https://www.nicovideo.jp/watch/sm9/extra'),
        'sm9',
      );
    });

    test('returns null for other URLs', () {
      expect(extractNiconicoVideoId('https://example.com/watch/sm9'), isNull);
      expect(extractNiconicoVideoId('https://www.nicovideo.jp/watch/'), isNull);
      expect(extractNiconicoVideoId('ftp://nico.ms/sm9'), isNull);
      expect(extractNiconicoVideoId(''), isNull);
    });
  });

  group('AudioManager', () {
    test('rejects a URL that does not point to niconico', () async {
      await expectLater(
        AudioManager().loadAudioFromUrl('https://example.com/video'),
        throwsA(isA<UnsupportedServiceException>()),
      );
    });

    test('rejects an unsupported service', () async {
      await expectLater(
        AudioManager().loadAudioFromServiceAndId(
          service: 'youtube',
          id: 'abc',
        ),
        throwsA(isA<UnsupportedServiceException>()),
      );
    });
  });

  group('UnsupportedServiceException', () {
    test('includes the message when one is provided', () {
      expect(
        UnsupportedServiceException('youtube is not supported').toString(),
        'UnsupportedServiceException: youtube is not supported',
      );
    });

    test('uses the plain name without a message', () {
      expect(
        UnsupportedServiceException().toString(),
        'UnsupportedServiceException',
      );
    });
  });
}

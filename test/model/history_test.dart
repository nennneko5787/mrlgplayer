import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/model/history.dart';
import 'package:mrlgplayer/model/song.dart';

void main() {
  Song createSong({String? artworkUrl}) {
    return Song(
      id: 'sm9',
      service: 'nicovideo',
      title: 'テスト曲',
      artist: 'uploader',
      artworkUrl: artworkUrl,
      websiteUrl: 'https://nico.ms/sm9',
    );
  }

  group('History.fromSong', () {
    test('copies every song field and uses the given date', () {
      final viewedAt = DateTime.utc(2024, 1, 2, 3, 4, 5);
      final song = createSong(
        artworkUrl: 'https://example.com/artwork.png',
      );

      final history = History.fromSong(song: song, dateTime: viewedAt);

      expect(history.id, song.id);
      expect(history.service, song.service);
      expect(history.title, song.title);
      expect(history.artist, song.artist);
      expect(history.artworkUrl, song.artworkUrl);
      expect(history.websiteUrl, song.websiteUrl);
      expect(history.viewedAt, viewedAt);
      expect(history.historyId, isNull);
    });

    test('keeps a missing artwork URL as null', () {
      final history = History.fromSong(
        song: createSong(),
        dateTime: DateTime.utc(2024),
      );

      expect(history.artworkUrl, isNull);
    });

    test('accepts an explicit history id', () {
      final history = History(
        id: 'sm9',
        service: 'nicovideo',
        title: 'テスト曲',
        artist: 'uploader',
        websiteUrl: 'https://nico.ms/sm9',
        viewedAt: DateTime.utc(2024),
        historyId: 12,
      );

      expect(history.historyId, 12);
    });
  });
}

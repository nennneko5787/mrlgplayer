import 'package:flutter_test/flutter_test.dart';
import 'package:mrlgplayer/history.dart';
import 'package:mrlgplayer/model/history.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  History createHistory({
    String id = 'sm9',
    String title = 'テスト曲',
    String? artworkUrl,
    DateTime? viewedAt,
  }) {
    return History(
      id: id,
      service: 'nicovideo',
      title: title,
      artist: 'uploader',
      artworkUrl: artworkUrl,
      websiteUrl: 'https://nico.ms/$id',
      viewedAt: viewedAt ?? DateTime.utc(2024, 1, 2, 3, 4, 5),
    );
  }

  late PlayHistory playHistory;

  setUp(() async {
    playHistory = PlayHistory();
    await playHistory.dispose();
    playHistory.db = null;
    await playHistory.init(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await playHistory.dispose();
    playHistory.db = null;
  });

  group('PlayHistory', () {
    test('creates an empty history table', () async {
      expect(await playHistory.db!.query('history'), isEmpty);
      expect(await playHistory.fetchPlayHistory(), isEmpty);
    });

    test('stores and reads a play history entry', () async {
      final viewedAt = DateTime.utc(2024, 6, 7, 8, 9, 10);
      await playHistory.pushPlayHistory(
        createHistory(
          artworkUrl: 'https://example.com/artwork.png',
          viewedAt: viewedAt,
        ),
      );

      final entries = await playHistory.fetchPlayHistory();

      expect(entries, hasLength(1));
      final entry = entries.single;
      expect(entry.historyId, 1);
      expect(entry.id, 'sm9');
      expect(entry.service, 'nicovideo');
      expect(entry.title, 'テスト曲');
      expect(entry.artist, 'uploader');
      expect(entry.artworkUrl, 'https://example.com/artwork.png');
      expect(entry.websiteUrl, 'https://nico.ms/sm9');
      expect(entry.viewedAt, viewedAt);
    });

    test('keeps a missing artwork URL as null', () async {
      await playHistory.pushPlayHistory(createHistory());

      final entry = (await playHistory.fetchPlayHistory()).single;

      expect(entry.artworkUrl, isNull);
    });

    test('returns the newest entry first', () async {
      await playHistory.pushPlayHistory(createHistory(id: 'first'));
      await playHistory.pushPlayHistory(createHistory(id: 'second'));

      final entries = await playHistory.fetchPlayHistory();

      expect(entries.map((entry) => entry.id), ['second', 'first']);
      expect(entries.map((entry) => entry.historyId), [2, 1]);
    });

    test('deletes a single entry by its history id', () async {
      await playHistory.pushPlayHistory(createHistory(id: 'first'));
      await playHistory.pushPlayHistory(createHistory(id: 'second'));

      final newest = (await playHistory.fetchPlayHistory()).first;
      await playHistory.deletePlayHistory(newest);

      final remaining = await playHistory.fetchPlayHistory();
      expect(remaining, hasLength(1));
      expect(remaining.single.id, 'first');
    });

    test('clears the history and resets the auto increment', () async {
      await playHistory.pushPlayHistory(createHistory(id: 'first'));
      await playHistory.pushPlayHistory(createHistory(id: 'second'));

      await playHistory.clearPlayHistory();
      expect(await playHistory.fetchPlayHistory(), isEmpty);

      await playHistory.pushPlayHistory(createHistory(id: 'after-clear'));
      final entry = (await playHistory.fetchPlayHistory()).single;
      expect(entry.id, 'after-clear');
      expect(entry.historyId, 1);
    });

    test('does nothing when the database is not open', () async {
      await playHistory.dispose();
      playHistory.db = null;

      expect(await playHistory.fetchPlayHistory(), isEmpty);
      await expectLater(
        playHistory.pushPlayHistory(createHistory()),
        completes,
      );
      await expectLater(
        playHistory.deletePlayHistory(createHistory()),
        completes,
      );
      await expectLater(playHistory.clearPlayHistory(), completes);
    });
  });
}

import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/history.dart';
import 'package:mrlgplayer/model/history.dart';
import 'package:mrlgplayer/model/notifier/lyrics.dart';
import 'package:mrlgplayer/model/song.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'playing.g.dart';

@riverpod
class PlayingNotifier extends _$PlayingNotifier {
  @override
  Song? build() => null;

  void setSong(Song song) {
    state = song;
  }

  Future<void> loadAudioFromServiceAndId({
    required String service,
    required String id,
  }) async {
    stop();
    ref.read(lyricsProvider.notifier).reset();

    final song = await AudioManager().loadAudioFromServiceAndId(
      service: service,
      id: id,
    );
    state = song;

    PlayHistory().pushPlayHistory(
      History.fromSong(song: song, dateTime: DateTime.now()),
    );
  }

  Future<void> loadAudioFromUrl(String url) async {
    stop();
    ref.read(lyricsProvider.notifier).reset();

    final song = await AudioManager().loadAudioFromUrl(url);
    state = song;

    PlayHistory().pushPlayHistory(
      History.fromSong(song: song, dateTime: DateTime.now()),
    );
  }

  void stop() {
    state = null;
  }
}

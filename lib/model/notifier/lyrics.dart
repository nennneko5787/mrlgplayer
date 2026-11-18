import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics.g.dart';

@riverpod
class LyricsNotifier extends _$LyricsNotifier {
  @override
  LyricsState build() => LyricsState(lyrics: null);

  void setLyrics(Lyrics lyrics) {
    state = LyricsState(lyrics: lyrics);
  }

  Future<void> loadLyricsFromServiceAndId({
    required String service,
    required String id,
  }) async {
    if (state.lyrics != null) reset();

    final lyrics = await AudioManager().loadLyricsFromServiceAndId(
      service: service,
      id: id,
    );
    state = LyricsState(
      lyrics: lyrics,
      hasError: (lyrics == null),
      isLyricsViewOpened: true,
    );
  }

  Future<void> searchLyricsFromPetitLyrics({
    required String title,
    String artist = '',
  }) async {
    if (state.lyrics != null) reset();

    final lyrics = await AudioManager().searchLyricsFromPetitLyrics(
      title: title,
      artist: artist,
    );
    state = LyricsState(
      lyrics: lyrics,
      hasError: (lyrics == null),
      isLyricsViewOpened: true,
    );
  }

  Future<void> searchLyricsFromGenius({
    required String title,
    String artist = '',
  }) async {
    if (state.lyrics != null) reset();

    final lyrics = await AudioManager().searchLyricsFromGenius(
      title: title,
      artist: artist,
    );
    state = LyricsState(
      lyrics: lyrics,
      hasError: (lyrics == null),
      isLyricsViewOpened: true,
    );
  }

  void setLyricsViewOpened(bool open) {
    state = state.copyWith(isLyricsViewOpened: open);
  }

  void reset() {
    state = LyricsState(lyrics: null);
  }
}

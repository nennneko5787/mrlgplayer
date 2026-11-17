import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/model/song.dart';

class LyricsView extends ConsumerWidget {
  const LyricsView({super.key});

  Future<Lyrics?> fetchLyrics(Song song, {required WidgetRef ref}) async {
    final notifier = ref.read(playingProvider.notifier);
    final settings = ref.watch(settingsProvider);

    if (song.lyrics == null && !song.lyricsError) {
      Lyrics? lyrics;

      if (settings.lyricsProvider == LyricsProviderType.petitLyrics) {
        lyrics = await AudioManager().searchLyricsFromPetitLyrics(
          title: song.title,
        );
      } else {
        lyrics = await AudioManager().loadLyricsFromServiceAndId(
          service: song.service,
          id: song.id,
        );
      }

      if (lyrics == null) {
        song.lyricsError = true;
      } else {
        song.lyrics = lyrics;
      }

      notifier.setSong(song);
    }

    return song.lyrics;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(playingProvider);

    if (song == null) {
      return SingleChildScrollView(
        child: Column(children: [Text("Hey, you have to load song")]),
      );
    }

    return FutureBuilder<Lyrics?>(
      future: fetchLyrics(song, ref: ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Lyrics error: ${snapshot.error}");
        }

        final lyrics = snapshot.data;

        if (lyrics == null) {
          return const Text("Lyrics fetch error");
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              for (final tl in lyrics.textLines)
                Text(
                  tl.text,
                  style: Theme.of(context).textTheme.headlineMedium!
                      .apply(fontWeightDelta: 2),
                ),
            ],
          ),
        );
      },
    );
  }
}

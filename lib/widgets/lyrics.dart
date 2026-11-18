import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/model/notifier/lyrics.dart';
import 'package:mrlgplayer/model/song.dart';

class LyricsWidget extends ConsumerStatefulWidget {
  const LyricsWidget({super.key});

  @override
  LyricsWidgetState createState() => LyricsWidgetState();
}

class LyricsWidgetState extends ConsumerState<LyricsWidget> {
  Future<Lyrics?> fetchLyrics(Song song, {required WidgetRef ref}) async {
    final lyrics = ref.watch(lyricsProvider);
    final notifier = ref.read(lyricsProvider.notifier);
    final settings = ref.watch(settingsProvider);

    if (lyrics.lyrics == null && !lyrics.hasError) {
      if (settings.lyricsProvider == LyricsProviderType.petitLyrics) {
        await notifier.searchLyricsFromPetitLyrics(
          title: song.title,
          artist: song.artist,
        );
      } else if (settings.lyricsProvider == LyricsProviderType.genius) {
        await notifier.searchLyricsFromGenius(
          title: song.title,
          artist: song.artist,
        );
      } else {
        await notifier.loadLyricsFromServiceAndId(
          service: song.service,
          id: song.id,
        );
      }
    }

    return lyrics.lyrics;
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playingProvider);
    final settings = ref.watch(settingsProvider);

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

        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0.0, 0.1, 0.9, 1.0], // 0%〜10%と90%〜100%の位置でぼかす
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn, // 透明部分に合わせて切り抜く
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.directional(
                        start: 0,
                        end: 0,
                        top: 5,
                        bottom: 20,
                      ),
                      child: Text(
                        '歌詞の自動同期は現在のバージョンではまだ実装されていません。実装をお待ちください。',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    for (final tl in lyrics.textLines)
                      Text(
                        tl.text,
                        style: Theme.of(context).textTheme.headlineMedium!,
                        textAlign:
                            lyrics.characters[tl.characterId].align ??
                            TextAlign.left,
                      ),
                    Text('歌詞プロバイダー: ${settings.lyricsProvider.name}'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

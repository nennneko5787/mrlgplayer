import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/pages/drawer.dart';
import 'package:mrlgplayer/model/position.dart';
import 'package:marquee/marquee.dart';
import 'package:mrlgplayer/widgets/lyrics.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();
  bool playingBeforeSeek = false;
  bool isLyricsViewOpened = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isOverFlowed({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  Future<void> playAudio(String url) async {
    if (url.isEmpty) return;

    _controller.clear();
    await ref.read(playingProvider.notifier).loadAudioFromUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playingProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: SizedBox(height: MediaQuery.of(context).padding.top),
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'ニコニコ動画のURLを入力',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (url) async {
            await playAudio(url);
          },
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'メニューを開く',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final url = _controller.text;
              await playAudio(url);
            },
            icon: Icon(Icons.arrow_right),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          mainAxisAlignment: .end,
          crossAxisAlignment: .start,
          children: [
            (isLyricsViewOpened == true)
                ? LyricsView()
                : Center(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: (song != null || song?.artworkUrl != null)
                            ? Image.network(song!.artworkUrl!)
                            : Image.asset("assets/untitled.png"),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 22),
              child: SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: (song != null && song.title.isNotEmpty)
                          ? (isOverFlowed(
                                  text: song.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .apply(fontWeightDelta: 2),
                                  maxWidth:
                                      MediaQuery.of(context).size.width -
                                      40 * 2,
                                ))
                                ? Marquee(
                                    key: Key('${song.service}_${song.id}'),
                                    text: song.title,
                                    blankSpace: 100.0,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .apply(fontWeightDelta: 2),
                                  )
                                : Text(
                                    key: Key('${song.service}_${song.id}'),
                                    song.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .apply(fontWeightDelta: 2),
                                  )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<PositionData>(
              stream: AudioManager().positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                final duration = positionData?.duration ?? Duration.zero;
                final position = positionData?.position ?? Duration.zero;
                final buffered =
                    positionData?.bufferedPosition ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble(),
                      value: position.inMilliseconds.toDouble().clamp(
                        0.0,
                        duration.inMilliseconds.toDouble(),
                      ),
                      secondaryTrackValue: buffered.inMilliseconds
                          .toDouble()
                          .clamp(0.0, duration.inMilliseconds.toDouble()),
                      onChangeStart: (value) {
                        if (AudioManager().player.playing) {
                          AudioManager().player.pause();
                          playingBeforeSeek = true;
                        }
                      },
                      onChanged: (value) {
                        AudioManager().player.seek(
                          Duration(milliseconds: value.round()),
                        );
                      },
                      onChangeEnd: (value) {
                        if (playingBeforeSeek) {
                          AudioManager().player.play();
                          playingBeforeSeek = false;
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: .start,
                      children: [
                        Text(
                          position.toString().split(".")[0],
                          style: Theme.of(context).textTheme.bodySmall!,
                        ),
                        const Spacer(),
                        Text(
                          duration.toString().split(".")[0],
                          style: Theme.of(context).textTheme.bodySmall!,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: .center,
              children: [
                IconButton(
                  onPressed: () async {
                    if (AudioManager().player.loopMode == LoopMode.off) {
                      await AudioManager().player.setLoopMode(LoopMode.all);
                    } else if (AudioManager().player.loopMode == LoopMode.all) {
                      await AudioManager().player.setLoopMode(LoopMode.one);
                    } else {
                      await AudioManager().player.setLoopMode(LoopMode.off);
                    }
                    setState(() {});
                  },
                  icon: (AudioManager().player.loopMode == LoopMode.off)
                      ? Icon(Icons.repeat)
                      : (AudioManager().player.loopMode == LoopMode.all)
                      ? Icon(Icons.repeat_on)
                      : Icon(Icons.repeat_one_on),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isLyricsViewOpened = !isLyricsViewOpened;
                    });
                  },
                  icon: Icon(Icons.lyrics),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    if (AudioManager().player.duration == null) return;
                    await AudioManager().player.seek(
                      Duration(
                        seconds: (AudioManager().player.position.inSeconds - 10)
                            .clamp(
                              0,
                              AudioManager().player.duration!.inSeconds,
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.replay_10),
                ),
                StreamBuilder<PlayerState>(
                  stream: AudioManager().player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;

                    return IconButton(
                      onPressed: () async {
                        if (playingBeforeSeek) return;

                        if (playing) {
                          await AudioManager().player.pause();
                        } else {
                          await AudioManager().player.play();
                        }
                      },
                      icon: playing
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                    );
                  },
                ),
                IconButton(
                  onPressed: () async {
                    if (AudioManager().player.duration == null) return;
                    await AudioManager().player.seek(
                      Duration(
                        seconds: (AudioManager().player.position.inSeconds + 10)
                            .clamp(
                              0,
                              AudioManager().player.duration!.inSeconds,
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.forward_10),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    if (song == null) return;
                    SharePlus.instance.share(
                      ShareParams(uri: Uri.parse(song.websiteUrl)),
                    );
                  },
                  icon: Icon(Icons.share),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

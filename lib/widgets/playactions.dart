import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';
import 'package:mrlgplayer/model/notifier/lyrics.dart';
import 'package:mrlgplayer/model/position.dart';
import 'package:share_plus/share_plus.dart';

class PlayActionsWidget extends ConsumerStatefulWidget {
  const PlayActionsWidget({super.key});

  @override
  PlayActionsWidgetState createState() => PlayActionsWidgetState();
}

class PlayActionsWidgetState extends ConsumerState<PlayActionsWidget> {
  bool playingBeforeSeek = false;

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

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playingProvider);
    final lyrics = ref.watch(lyricsProvider);
    final lyricsNotifier = ref.read(lyricsProvider.notifier);

    final textStyle = Theme.of(context).textTheme.headlineMedium;
    final fontSize = textStyle?.fontSize ?? 28.0;
    final heightMultiplier = textStyle?.height ?? 1.29;

    final double lineHeightInPixels = fontSize * heightMultiplier;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 22),
          child: SizedBox(
            height: lineHeightInPixels,
            child: Row(
              children: [
                Expanded(
                  child: (song != null && song.title.isNotEmpty)
                      ? (isOverFlowed(
                              text: song.title,
                              style: Theme.of(context).textTheme.headlineMedium!
                                  .apply(fontWeightDelta: 2),
                              maxWidth:
                                  MediaQuery.of(context).size.width - 40 * 2,
                            ))
                            ? Marquee(
                                key: Key('${song.service}_${song.id}'),
                                text: song.title,
                                blankSpace: 100.0,
                                style: textStyle!.apply(fontWeightDelta: 2),
                              )
                            : Text(
                                key: Key('${song.service}_${song.id}'),
                                song.title,
                                style: textStyle!.apply(fontWeightDelta: 2),
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
            final buffered = positionData?.bufferedPosition ?? Duration.zero;

            return Column(
              children: [
                Slider(
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble(),
                  value: position.inMilliseconds.toDouble().clamp(
                    0.0,
                    duration.inMilliseconds.toDouble(),
                  ),
                  secondaryTrackValue: buffered.inMilliseconds.toDouble().clamp(
                    0.0,
                    duration.inMilliseconds.toDouble(),
                  ),
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
                  ? const Icon(Icons.repeat)
                  : (AudioManager().player.loopMode == LoopMode.all)
                  ? const Icon(Icons.repeat_on)
                  : const Icon(Icons.repeat_one_on),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  lyricsNotifier.setLyricsViewOpened(
                    !lyrics.isLyricsViewOpened,
                  );
                });
              },
              icon: const Icon(Icons.lyrics),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                if (AudioManager().player.duration == null) return;
                await AudioManager().player.seek(
                  Duration(
                    seconds: (AudioManager().player.position.inSeconds - 10)
                        .clamp(0, AudioManager().player.duration!.inSeconds),
                  ),
                );
              },
              icon: const Icon(Icons.replay_10),
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
                        .clamp(0, AudioManager().player.duration!.inSeconds),
                  ),
                );
              },
              icon: const Icon(Icons.forward_10),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                if (song == null) return;
                SharePlus.instance.share(
                  ShareParams(uri: Uri.parse(song.websiteUrl)),
                );
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/pages/drawer.dart';
import 'package:mrlgplayer/model/position.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();
  bool playingBeforeSeek = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'ニコニコ動画のURLを入力',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (url) async {
            _controller.clear();
            await AudioManager().loadAudioFromUrl(url);
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final url = _controller.text;
              _controller.clear();
              await AudioManager().loadAudioFromUrl(url);
              setState(() {});
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
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child:
                      (AudioManager().song != null ||
                          AudioManager().song?.artworkUrl != null)
                      ? Image.network(AudioManager().song!.artworkUrl!)
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
                      child:
                          (AudioManager().song != null &&
                              AudioManager().song!.title.isNotEmpty)
                          ? (isOverFlowed(
                                  text: AudioManager().song!.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .apply(fontWeightDelta: 2),
                                  maxWidth:
                                      MediaQuery.of(context).size.width -
                                      40 * 2,
                                ))
                                ? Marquee(
                                    key: Key(
                                      '${AudioManager().song!.service}_${AudioManager().song!.id}',
                                    ),
                                    text: AudioManager().song!.title,
                                    blankSpace: 100.0,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .apply(fontWeightDelta: 2),
                                  )
                                : Text(
                                    key: Key(
                                      '${AudioManager().song!.service}_${AudioManager().song!.id}',
                                    ),
                                    AudioManager().song!.title,
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
                IconButton(
                  onPressed: () async {
                    if (playingBeforeSeek) return;

                    if (AudioManager().player.playing) {
                      await AudioManager().player.pause();
                    } else {
                      await AudioManager().player.play();
                    }
                    setState(() {});
                  },
                  icon: AudioManager().player.playing
                      ? Icon(Icons.pause)
                      : Icon(Icons.play_arrow),
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
                    if (AudioManager().song == null) return;
                    SharePlus.instance.share(
                      ShareParams(
                        uri: Uri.parse(AudioManager().song!.websiteUrl),
                      ),
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/pages/drawer.dart';
import 'package:mrlgplayer/widgets/lyrics.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';
import 'package:mrlgplayer/model/notifier/lyrics.dart';
import 'package:mrlgplayer/widgets/playactions.dart';
import 'package:mrlgplayer/widgets/unfocus.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> playAudio(String url) async {
    if (url.isEmpty) return;

    _controller.clear();
    await ref.read(playingProvider.notifier).loadAudioFromUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(playingProvider);
    final lyrics = ref.watch(lyricsProvider);

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
                final currentScope = FocusScope.of(context);
                if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                  currentScope.unfocus();
                }
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
      body: UnFocus(
        child: Column(
          mainAxisAlignment: .end,
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: (lyrics.isLyricsViewOpened == true)
                  ? LyricsWidget()
                  : Center(
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: (song != null && song.artworkUrl != null)
                              ? Image.network(song.artworkUrl!)
                              : Image.asset("assets/untitled.png"),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: PlayActionsWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/history.dart';
import 'package:mrlgplayer/model/history.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';
import 'package:share_plus/share_plus.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends ConsumerState<HistoryPage> {
  final ScrollController _scrollController = ScrollController();

  void showAllDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('警告'),
          content: Text('再生履歴を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                PlayHistory().clearPlayHistory().then((_) => {setState(() {})});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('再生履歴を削除しました。'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('削除する'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, History history) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('警告'),
          content: Text('この曲の再生履歴を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                PlayHistory()
                    .deletePlayHistory(history)
                    .then((_) => {setState(() {})});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('再生履歴を削除しました。'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('削除する'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("再生履歴"),
        actions: [
          IconButton(
            onPressed: () async {
              showAllDeleteDialog(context);
            },
            icon: Icon(Symbols.delete),
          ),
        ],
      ),
      body: FutureBuilder(
        future: PlayHistory().fetchPlayHistory(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [Text('Error: ${snapshot.error}')],
                  ),
                );
              } else {
                final songs = snapshot.data as List<History>;
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return ListTile(
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: (song.artworkUrl != null)
                                    ? Image.network(song.artworkUrl!)
                                    : Image.asset("assets/untitled.png"),
                              ),
                            ),
                            title: Text(song.title),
                            subtitle: Text(song.artist),
                            trailing: Text(
                              song.viewedAt.toString().split(".")[0],
                            ),
                            onTap: () {
                              final notifier = ref.read(
                                playingProvider.notifier,
                              );

                              Navigator.pop(context);

                              notifier.loadAudioFromServiceAndId(
                                id: song.id,
                                service: song.service,
                              );
                            },
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.share),
                                          title: Text('シェアする'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            SharePlus.instance.share(
                                              ShareParams(
                                                uri: Uri.parse(song.websiteUrl),
                                              ),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Symbols.delete),
                                          title: Text(
                                            '削除',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            showDeleteDialog(context, song);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
          }
        },
      ),
    );
  }
}

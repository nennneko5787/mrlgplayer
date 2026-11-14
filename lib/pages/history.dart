import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/history.dart';
import 'package:mrlgplayer/model/history.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends ConsumerState<HistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("再生履歴")),
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
                            onTap: () async {
                              AudioManager().loadAudioFromServiceAndId(
                                id: song.id,
                                service: song.service,
                              );
                              Navigator.pop(context);
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

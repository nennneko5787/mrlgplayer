import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mrlgplayer/history.dart';
import 'package:mrlgplayer/model/history.dart';
import 'package:mrlgplayer/model/position.dart';
import 'package:mrlgplayer/model/song.dart';
import 'package:mrlgplayer/niconico/niconico.dart';
import 'package:rxdart/rxdart.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  AudioManager._internal();
  factory AudioManager() {
    return _instance;
  }

  final niconico = Niconico();
  final player = AudioPlayer(useProxyForRequestHeaders: true);

  Song? song;

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  Future<void> dispose() async {
    await player.dispose();
  }

  Future<void> loadAudioFromServiceAndId({
    required String service,
    required String id,
  }) async {
    if (service == "nicovideo") {
      await loadAudioFromNiconico(id);
    }
  }

  Future<void> loadAudioFromUrl(String url) async {
    final match = RegExp(
      r'^https?://(?:nico\.ms/|(?:www\.)?nicovideo\.jp/watch/)([^/?#]+)',
    ).firstMatch(url);

    if (match != null) {
      final videoId = match.group(1)!;
      await loadAudioFromNiconico(videoId);
    }
  }

  Future<void> loadAudioFromNiconico(String videoId) async {
    try {
      if (player.currentIndex != null && player.playing) {
        await player.stop();
      }

      final actionTrackId = await niconico.getActionTrackId(videoId);
      final watchData = await niconico.getV3WatchData(
        videoId,
        actionTrackId,
        true,
      );
      final domand = await niconico.getNvApiV1DomandHlsAccessRightAsync(
        videoId,
        watchData.media,
        watchTrackId: watchData.client.watchTrackId,
      );
      await player.setUrl(
        domand.response.contentUrl,
        headers: {
          "Cookie": 'domand_bid=${domand.domandBid}',
          'Referer': 'https://www.nicovideo.jp/',
          'Origin': 'https://www.nicovideo.jp',
          'X-Frontend-Version': '0',
          'X-Frontend-Id': '6',
          'X-Niconico-Language': 'ja-jp',
          'X-Request-With': 'https://www.nicovideo.jp',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-site',
        },
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: watchData.video.id,
          // Metadata to display in the notification:
          album: "ニコニコ動画",
          title: watchData.video.title,
          artUri: Uri.parse(watchData.video.thumbnail.url),
        ),
      );

      song = Song(
        id: watchData.video.id,
        service: "nicovideo",
        title: watchData.video.title,
        artist: watchData.owner.nickname,
        artworkUrl:
            watchData.video.thumbnail.player ??
            watchData.video.thumbnail.largeUrl ??
            watchData.video.thumbnail.middleUrl ??
            watchData.video.thumbnail.url,
        websiteUrl: 'https://nico.ms/${watchData.video.id}',
      );
      await player.play();

      PlayHistory().pushPlayHistory(
        History.fromSong(song: song!, dateTime: DateTime.now()),
      );
    } catch (e, stackTrace) {
      debugPrint('[Audio] ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

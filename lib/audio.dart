import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/position.dart';
import 'package:mrlgplayer/model/song.dart';
import 'package:mrlgplayer/niconico/niconico.dart';
import 'package:mrlgplayer/petitlyrics/petitlyrics.dart';
import 'package:mrlgplayer/settings.dart';
import 'package:rxdart/rxdart.dart';

class UnsupportedServiceException implements Exception {
  final String message;

  UnsupportedServiceException([this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) return 'UnsupportedServiceException';
    return 'UnsupportedServiceException: $message';
  }
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  AudioManager._internal();
  factory AudioManager() {
    return _instance;
  }

  final niconico = Niconico();
  final petitLyrics = PetitLyrics();
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
    await player.stop();
    await player.dispose();
  }

  Future<Song> loadAudioFromServiceAndId({
    required String service,
    required String id,
  }) async {
    if (service == "nicovideo") {
      return await loadAudioFromNiconico(id);
    }

    throw UnsupportedServiceException();
  }

  Future<Song> loadAudioFromUrl(String url) async {
    final match = RegExp(
      r'^https?://(?:nico\.ms/|(?:www\.)?nicovideo\.jp/watch/)([^/?#]+)',
    ).firstMatch(url);

    if (match != null) {
      final videoId = match.group(1)!;
      return await loadAudioFromNiconico(videoId);
    }

    throw UnsupportedServiceException();
  }

  Future<Song> loadAudioFromNiconico(String videoId) async {
    try {
      if (player.currentIndex != null && player.playing) {
        await player.stop();
      }

      final actionTrackId = await niconico.getActionTrackId(videoId);
      final watchData = await niconico.getV3WatchData(
        videoId,
        actionTrackId,
        (SettingsManager().settings?.userSession == null),
      );
      final domand = await niconico.getNvApiV1DomandHlsAccessRightAsync(
        videoId,
        watchData.media,
        watchTrackId: watchData.client.watchTrackId,
      );

      final cookie = [
        'domand_bid=${domand.domandBid}',
        if (SettingsManager().settings?.userSession != null)
          'user_session=${SettingsManager().settings!.userSession}',
        if (SettingsManager().settings?.nicosid != null)
          'nicosid=${SettingsManager().settings!.nicosid}',
      ].join('; ');
      await player.setUrl(
        domand.response.contentUrl,
        headers: {
          "Cookie": cookie,
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

      return song!;
    } catch (e, stackTrace) {
      debugPrint('[Audio] ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Lyrics?> loadLyricsFromServiceAndId({
    required String service,
    required String id,
  }) async {
    if (service == "nicovideo") {
      final response = await niconico.getVideoLyrics(id);
      if (response == null) return null;

      final List<TextLine> textLines = List.empty(growable: true);
      for (var part in response.lyrics) {
        textLines.add(
          TextLine(
            characterId: 0,
            start: Duration(milliseconds: part.startMs),
            end: Duration(milliseconds: part.endMs),
            text: part.lines.join("\n"),
          ),
        );
      }

      return Lyrics(characters: [Character(id: 0)], textLines: textLines);
    }
    throw UnsupportedServiceException();
  }

  Future<Lyrics?> searchLyricsFromPetitLyrics({required String title}) async {
    final lines = await petitLyrics.getLyrics(
      title: title.replaceAll(RegExp(r"【(.*)】"), "").split(" ")[0],
    );
    if (lines == null) return null;

    final List<TextLine> textLines = List.empty(growable: true);
    for (var line in lines) {
      textLines.add(TextLine(characterId: 0, text: line));
    }

    return Lyrics(characters: [Character(id: 0)], textLines: textLines);
  }
}

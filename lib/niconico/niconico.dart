import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:mrlgplayer/niconico/models/lyrics.dart';
import 'package:unixtime/unixtime.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:mrlgplayer/niconico/models/watchdatav3.dart';
import 'package:mrlgplayer/niconico/models/domand.dart';
import 'package:cookie_jar/cookie_jar.dart';

class DomandHlsAccessRightResponseAndCookie {
  final DomandHlsAccessRightResponse response;
  final String domandBid;

  DomandHlsAccessRightResponseAndCookie({
    required this.response,
    required this.domandBid,
  });
}

class NiconicoServerException implements Exception {
  final String message;

  NiconicoServerException([this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) return 'NiconicoServerException';
    return 'NiconicoServerException: $message';
  }
}

class Niconico {
  final http = Dio(
    BaseOptions(
      headers: {
        "User-Agent": "MRLGPlayer/1.00 (repository is https://github.com/nennneko5787/MRLGPlayer)",
      },
      preserveHeaderCase: true,
      validateStatus: (int? statusCode) => (statusCode != null),
    ),
  );

  final cookieJar = CookieJar();

  Niconico() {
    http.interceptors.add(CookieManager(cookieJar));
  }

  Future<VideoLyricsResponse?> getVideoLyrics(String videoId) async {
    var response = await http.get(
      'https://nvapi.nicovideo.jp/v1/videos/$videoId/lyrics',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Frontend-Version': '8.39.1',
          'X-Frontend-Id': '76',
        },
      ),
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw NiconicoServerException(
        'Server returned ${response.statusCode} ${response.data}',
      );
    }

    return VideoLyricsResponse.fromJson(response.data["data"]);
  }

  Future<String> getActionTrackId(String videoId) async {
    var response = await http.get(
      'https://sp.nicovideo.jp/watch/$videoId?redirected=1',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw NiconicoServerException('Server returned ${response.statusCode}');
    }

    Document document = parser.parse(response.data);

    String? scriptText;
    document.querySelectorAll("script").forEach((content) {
      if (content.textContent()!.startsWith(
        "window.__reactRouterContext.streamController.enqueue",
      )) {
        scriptText = content.textContent();
      }
    });
    if (scriptText == null) {
      throw StateError('The WatchTrackId script element was not found');
    }

    final match = RegExp(r'\\?"watchTrackId\\?"\s*,\s*\\?"([^"\\]+)\\?"')
        .firstMatch(scriptText!);
    final trackId = match?.group(1);

    if (trackId == null) {
      throw StateError("watchTrackId was not found in the S:0 script");
    }

    return trackId;
  }

  Future<WatchDataV3Response> getV3WatchData(
    String videoId,
    String actionTrackId,
    bool isGuest,
  ) async {
    final timestamp = DateTime.now().unixtime;
    final url = Uri.parse(
      'https://www.nicovideo.jp/api/watch/${isGuest ? "v3_guest" : "v3"}/$videoId'
      '?_clientOsType=others&_frontendId=3&_frontendVersion=0.1.0'
      '&actionTrackId=${Uri.encodeFull(actionTrackId)}'
      '&skips=harmful&additionals=pcWatchPage%2Cseries'
      '&i18nLanguage=ja-jp&t=$timestamp',
    );

    var response = await http.get(
      url.toString(),
      options: Options(
        headers: {
          "Origin": "https://sp.nicovideo.jp",
          "Referer": "https://sp.nicovideo.jp/",
        },
      ),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw NiconicoServerException(
        'Server returned ${response.statusCode} ${response.data}',
      );
    }

    return WatchDataV3Response.fromJson(response.data["data"]);
  }

  Future<DomandHlsAccessRightResponseAndCookie> getVariantsDomandHlsAccessRight(
    String videoId,
    WatchDataV3Media media, {
    String? watchTrackId,
    bool audioOnly = true,
  }) async {
    List<String> qualities = List.empty(growable: true);

    if (audioOnly) {
      media.domand.audios.where((audio) => audio.isAvailable).forEach((audio) {
        qualities.add('["${audio.id}"]');
      });
    } else {
      media.domand.videos.where((video) => video.isAvailable).forEach((video) {
        media.domand.audios.where((audio) => audio.isAvailable).forEach((
          audio,
        ) {
          qualities.add('["${video.id}", "${audio.id}"]');
        });
      });
    }

    var response = await http.post(
      'https://nvapi.nicovideo.jp/v1/watch/$videoId/access-rights/hls${(watchTrackId != null ? '?actionTrackId=$watchTrackId' : "")}',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://www.nicovideo.jp/',
          'Origin': 'https://www.nicovideo.jp',
          'X-Access-Right-Key': media.domand.accessRightKey,
          'X-Frontend-Version': '0',
          'X-Frontend-Id': '6',
          'X-Niconico-Language': 'ja-jp',
          'X-Request-With': 'https://www.nicovideo.jp',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-site',
        },
      ),
      data: '{"outputs":[${qualities.join(",")}]}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw NiconicoServerException(
        'Server returned ${response.statusCode} ${response.data}',
      );
    }

    return DomandHlsAccessRightResponseAndCookie(
      response: DomandHlsAccessRightResponse.fromJson(response.data["data"]),
      domandBid: response.headers["set-cookie"]![0].split(";")[0].split("=")[1],
    );
  }

  Future<DomandHlsAccessRightResponseAndCookie>
  getNvApiV1DomandHlsAccessRightAsync(
    String videoId,
    WatchDataV3Media media, {
    String? watchTrackId,
    bool audioOnly = true,
  }) async {
    List<String> qualities = List.empty(growable: true);

    if (audioOnly) {
      media.domand.audios.where((audio) => audio.isAvailable).forEach((audio) {
        qualities.add('["${audio.id}"]');
      });
    } else {
      media.domand.videos.where((video) => video.isAvailable).forEach((video) {
        media.domand.audios.where((audio) => audio.isAvailable).forEach((
          audio,
        ) {
          qualities.add('["${video.id}", "${audio.id}"]');
        });
      });
    }

    var response = await http.post(
      'https://nvapi.nicovideo.jp/v1/watch/$videoId/access-rights/hls${(watchTrackId != null ? '?actionTrackId=$watchTrackId' : "")}',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://sp.nicovideo.jp/',
          'Origin': 'https://sp.nicovideo.jp',
          'X-Access-Right-Key': media.domand.accessRightKey,
          'X-Frontend-Version': '0.1.0',
          'X-Frontend-Id': '3',
          'X-Niconico-Language': 'ja-jp',
          'X-Request-With': 'nicovideo',
        },
      ),
      data: '{"outputs":[${qualities.join(',')}]}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw NiconicoServerException(
        'Server returned ${response.statusCode} ${response.data}',
      );
    }

    return DomandHlsAccessRightResponseAndCookie(
      response: DomandHlsAccessRightResponse.fromJson(response.data["data"]),
      domandBid: response.headers["set-cookie"]![0].split(";")[0].split("=")[1],
    );
  }
}

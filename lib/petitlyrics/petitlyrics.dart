import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart' as parser;
import 'package:mrlgplayer/petitlyrics/query.dart';

import 'dart:convert';

import "package:mrlgplayer/utils.dart";

class _LyricsSearchResult {
  final String lyricId;
  final String title;
  final String artist;

  const _LyricsSearchResult({
    required this.lyricId,
    required this.title,
    required this.artist,
  });
}

class PetitLyricsServerException implements Exception {
  final String message;

  PetitLyricsServerException([this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) return 'PetitLyricsServerException';
    return 'PetitLyricsServerException: $message';
  }
}

class PetitLyrics {
  final http = Dio(
    BaseOptions(
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36",
      },
      preserveHeaderCase: true,
      validateStatus: (int? statusCode) => (statusCode != null),
    ),
  );
  final cookieJar = CookieJar();

  PetitLyrics() {
    http.interceptors.add(CookieManager(cookieJar));
  }

  Future<List<String>?> getLyrics({
    String title = "",
    String artist = "",
    String album = "",
  }) async {
    final uri = Uri.https('petitlyrics.com', '/search_lyrics', {
      'title': title,
      'artist': artist,
      'album': album,
    });
    final response = await http.get(uri.toString());
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw PetitLyricsServerException(
        'Server returned ${response.statusCode} ${response.data}',
      );
    }

    final html = response.data as String;
    final results = _parseSearchResults(html);
    if (results.isEmpty) {
      debugPrint(
        'No lyrics found for title="$title" artist="$artist" album="$album"',
      );
      return null;
    }

    final result = _pickBestResult(results, title: title, artist: artist);
    final lyricId = result.lyricId;

    debugPrint(
      'PetitLyrics: picked "${result.title}" by "${result.artist}" '
      '(id: $lyricId)',
    );

    // fake req
    final lyricPage = 'https://petitlyrics.com/lyrics/$lyricId';
    await http.get(lyricPage);

    var response2 = await http.get("https://petitlyrics.com/lib/pl-lib.js");
    if (response2.statusCode == null ||
        response2.statusCode! < 200 ||
        response2.statusCode! >= 300) {
      throw PetitLyricsServerException(
        'Server returned ${response2.statusCode} ${response2.data}',
      );
    }

    var tokenMatch = RegExp(r"'X-CSRF-Token', '(?<token>[^']+)")
        .firstMatch(response2.data as String);
    if (tokenMatch == null) {
      debugPrint("tokenMatch");
      return null;
    }
    final token = tokenMatch.namedGroup("token")!;

    var response3 = await http.post(
      "https://petitlyrics.com/com/get_lyrics.ajax",
      data: {"lyrics_id": lyricId},
      options: Options(
        headers: {
          "Accept": "*/*",
          "Accept-Language":
              "ja,en-US;q=0.9,en;q=0.8,zh-CN;q=0.7,zh;q=0.6,ru;q=0.5",
          "Origin": "https://petitlyrics.com",
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          "X-CSRF-Token": token,
          "X-Requested-With": "XMLHttpRequest",
          "Referer": "https://petitlyrics.com/lyrics/$lyricId",
        },
        preserveHeaderCase: true,
      ),
    );

    debugPrint('Status: ${response3.statusCode}');
    debugPrint('Body: ${response3.data}');
    debugPrint('Token: $token');
    debugPrint('Lyric ID: $lyricId');
    if (response3.statusCode == null ||
        response3.statusCode! < 200 ||
        response3.statusCode! >= 300) {
      throw PetitLyricsServerException(
        'Server returned ${response3.statusCode} ${response3.data}',
      );
    }

    return (response3.data as List<dynamic>)
        .map((item) {
          final map = item as Map<String, dynamic>;

          return utf8
              .decode(base64Decode(map["lyrics"] as String))
              .replaceFirst(RegExp(r'[\r\n]+$'), '');
        })
        .toList(growable: false);
  }
}

List<_LyricsSearchResult> _parseSearchResults(String html) {
  final document = parser.parse(html);
  final list = document.querySelector('#lyrics_list');
  if (list == null) return const [];

  final results = <_LyricsSearchResult>[];

  for (final row in list.querySelectorAll('tr')) {
    String? lyricId;
    var resultTitle = '';

    for (final link in row.querySelectorAll('a[href*="/lyrics/"]')) {
      final match = RegExp(r'/lyrics/(\d+)')
          .firstMatch(link.attributes['href'] ?? '');
      if (match == null) continue;

      lyricId = match.group(1);
      resultTitle = link.text.trim();
      break;
    }

    if (lyricId == null) continue;

    results.add(
      _LyricsSearchResult(
        lyricId: lyricId,
        title: resultTitle,
        artist: row.querySelector('.lyrics-list-artist')?.text.trim() ?? '',
      ),
    );
  }

  return results;
}

/// Picks the result that is the closest match to the searched title, so a
/// partial match such as "Hibana" does not win over "Hibana -Reloaded-".
_LyricsSearchResult _pickBestResult(
  List<_LyricsSearchResult> results, {
  required String title,
  required String artist,
}) {
  var best = results.first;
  var bestScore = double.negativeInfinity;

  for (final result in results) {
    var score = lyricsSimilarity(title, result.title);

    // The artist is only a tie breaker, because the artist registered on
    // PetitLyrics often differs from the uploader name.
    if (artist.isNotEmpty) {
      score += lyricsSimilarity(artist, result.artist) * 0.1;
    }

    if (score > bestScore) {
      bestScore = score;
      best = result;
    }
  }

  return best;
}

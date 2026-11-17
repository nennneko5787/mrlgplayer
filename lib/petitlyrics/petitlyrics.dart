import 'package:dio/dio.dart';

import 'dart:convert';

import 'package:material_ui/material_ui.dart';

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
    ),
  );

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

    var html = response.data as String;
    final startIndex = html.indexOf('id="lyrics_list"');
    if (startIndex == -1) {
      debugPrint("startIndex");
      return null;
    }

    final endIndex = html.indexOf('id="lyrics_list_pager"', startIndex);
    if (endIndex == -1) {
      debugPrint("endIndex");
      return null;
    }

    final lyricsHtml = html.substring(startIndex, endIndex);
    final lyricsMatch = RegExp(r'href="/lyrics/(?<lyricId>\d+)')
        .firstMatch(lyricsHtml);

    if (lyricsMatch == null) {
      debugPrint("lyricsMatch not found");
      return null;
    }

    final lyricId = lyricsMatch.namedGroup("lyricId")!;

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

    List<String> lines = RegExp(r'{"lyrics":"(?<base64>[^"]*)"}')
        .allMatches(response3.data as String)
        .map((match) {
          return utf8
              .decode(
                base64Decode(
                  match.namedGroup("base64")!.replaceAll(r'\/', '/'),
                ),
              )
              .replaceFirst(RegExp(r'[\r\n]+$'), '');
        })
        .toList(growable: false);

    return lines;
  }
}

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:mrlgplayer/genius/models/songs.dart';
import 'package:mrlgplayer/petitlyrics/query.dart';

class GeniusServerException implements Exception {
  final String message;

  GeniusServerException([this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) return 'GeniusServerException';
    return 'GeniusServerException: $message';
  }
}

class Genius {
  final http = Dio(
    BaseOptions(
      headers: {
        "X-Genius-iOS-Version": "6.21.0",
        "X-Genius-Logged-Out": "true",
        "User-Agent": "Genius/1109 CFNetwork/1568.200.51 Darwin/24.1.0",
      },
      preserveHeaderCase: true,
      validateStatus: (int? statusCode) => (statusCode != null),
    ),
  );
  final cookieJar = CookieJar();

  Genius() {
    http.interceptors.add(CookieManager(cookieJar));
  }

  Future<List<GeniusHitResult>> searchSongs(String query) async {
    final uri = Uri.https("api.genius.com", '/search/song', {'q': query});
    final response = await http.get(uri.toString());
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw GeniusServerException(
        'Server returned ${response.statusCode} ${response.data}',
      );
    }

    final sections = response.data["response"]["sections"] as List<dynamic>;
    final results = <GeniusHitResult>[];

    for (final section in sections) {
      final hits = (section as Map<String, dynamic>)["hits"] as List<dynamic>;
      for (final hit in hits) {
        final result = (hit as Map<String, dynamic>)["result"];
        if (result is Map) {
          results.add(
            GeniusHitResult.fromJson(Map<String, dynamic>.from(result)),
          );
        }
      }
    }

    return results;
  }

  Future<GeniusHitResult?> searchSong({
    required String query,
    List<String> expectedTitles = const [],
    String artist = "",
  }) async {
    final songs = await searchSongs(query);
    if (songs.isEmpty) return null;

    return pickBestGeniusHit(
      songs,
      expectedTitles: expectedTitles.isEmpty ? [query] : expectedTitles,
      artist: artist,
    );
  }

  Future<List<String>> getLyricBySongId(int songId) async {
    final uri = Uri.https("api.genius.com", '/songs/$songId', {
      "text_format": "plain",
    });
    final response = await http.get(uri.toString());
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw GeniusServerException(
        'Server returned ${response.statusCode} ${response.data}',
      );
    }

    return (response.data["response"]["song"]["lyrics"]["plain"] as String)
        .trim()
        .split("\n");
  }
}

/// Suffixes that Genius uses for pages that contain a translation or a
/// transliteration of the lyrics instead of the original text.
const _translationMarkers = [
  'romanized',
  'english translation',
  'çeviri',
  'traducción',
  'tradução',
  'übersetzung',
  '번역',
  '翻訳',
  '翻译',
];

/// Whether [result] is a translation/transliteration page rather than the
/// original lyrics. Those pages are usually written by
/// "Genius Romanizations" / "Genius English Translations".
bool isGeniusTranslationPage(GeniusHitResult result) {
  final artist = result.artistNames.toLowerCase();
  if (artist.contains('genius romanizations') ||
      artist.contains('genius english translations')) {
    return true;
  }

  final title = result.title.trimRight().toLowerCase();
  if (!title.endsWith(')')) return false;

  final suffixStart = title.lastIndexOf('(');
  if (suffixStart == -1) return false;

  final suffix = title.substring(suffixStart);
  return _translationMarkers.any(suffix.contains);
}

/// Picks the Genius result that actually is the requested song.
///
/// Genius is a free-text search, so it returns hits for almost any query.
/// A result is therefore only accepted when its title is close enough to one
/// of [expectedTitles]. Translation pages are ignored because their lyrics are
/// not the original ones.
///
/// Returns `null` when no result is close enough, so the caller can try the
/// next query instead of showing lyrics of an unrelated song.
GeniusHitResult? pickBestGeniusHit(
  List<GeniusHitResult> results, {
  required List<String> expectedTitles,
  String artist = '',
}) {
  GeniusHitResult? best;
  var bestScore = 0.0;

  for (final result in results) {
    if (isGeniusTranslationPage(result)) continue;

    final titleScore = _bestTitleScore(result.title, expectedTitles);
    if (titleScore == 0) continue;

    // The artist is only a tie breaker, because the artist registered on
    // Genius often differs from the uploader name.
    final score =
        titleScore +
        (artist.isEmpty
            ? 0
            : lyricsSimilarity(artist, result.artistNames) * 0.1);

    if (score > bestScore) {
      bestScore = score;
      best = result;
    }
  }

  return best;
}

double _bestTitleScore(String candidateTitle, List<String> expectedTitles) {
  var best = 0.0;

  for (final expectedTitle in expectedTitles) {
    if (!isConfidentLyricsMatch(expectedTitle, candidateTitle)) continue;

    // A result that starts with the expected title, such as
    // "フォニイ (phony)", has a low Dice score because of the reading in
    // parentheses, but it is still a valid match. Keep it at the confidence
    // threshold so exact matches still win.
    final score = lyricsSimilarity(expectedTitle, candidateTitle);
    final adjusted = score < 0.5 ? 0.5 : score;

    if (adjusted > best) best = adjusted;
  }

  return best;
}

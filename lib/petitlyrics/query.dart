/// Candidate search queries for PetitLyrics, inferred from niconico titles.
library;

/// A single set of parameters for the PetitLyrics lyrics search.
class PetitLyricsQuery {
  /// Song title to search for.
  final String title;

  /// Artist name to search for. May be empty.
  final String artist;

  const PetitLyricsQuery({this.title = '', this.artist = ''});

  @override
  String toString() => 'PetitLyricsQuery(title: "$title", artist: "$artist")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetitLyricsQuery &&
          other.title == title &&
          other.artist == artist;

  @override
  int get hashCode => Object.hash(title, artist);
}

/// Converts full-width ASCII to half-width and removes anything that is not a
/// letter or a number, so that titles can be compared with each other.
String normalizeLyricsText(String input) {
  final buffer = StringBuffer();

  for (final codeUnit in input.codeUnits) {
    if (codeUnit >= 0xFF01 && codeUnit <= 0xFF5E) {
      buffer.writeCharCode(codeUnit - 0xFEE0);
    } else if (codeUnit == 0x3000) {
      buffer.write(' ');
    } else {
      buffer.writeCharCode(codeUnit);
    }
  }

  return buffer.toString().toLowerCase().replaceAll(
    RegExp(r'[^\p{L}\p{N}]', unicode: true),
    '',
  );
}

/// Dice coefficient over character bigrams. Works for Japanese and English
/// titles alike and tolerates decorations such as "(TV size)".
double lyricsSimilarity(String a, String b) {
  final left = normalizeLyricsText(a);
  final right = normalizeLyricsText(b);

  if (left.isEmpty || right.isEmpty) return 0;
  if (left == right) return 1;

  if (left.length < 2 || right.length < 2) {
    return left.contains(right) || right.contains(left) ? 0.8 : 0;
  }

  final leftBigrams = <String>{};
  for (var i = 0; i < left.length - 1; i++) {
    leftBigrams.add(left.substring(i, i + 2));
  }

  var intersection = 0;
  final rightBigrams = <String>{};
  for (var i = 0; i < right.length - 1; i++) {
    final bigram = right.substring(i, i + 2);
    if (rightBigrams.add(bigram) && leftBigrams.contains(bigram)) {
      intersection++;
    }
  }

  return 2 * intersection / (leftBigrams.length + rightBigrams.length);
}

/// Whether [candidateTitle] looks like the same song as [title].
///
/// This is used to reject search results that only share a word with the song.
/// Free-text search engines such as Genius almost always return something, so
/// a result must be verified before its lyrics are shown.
bool isConfidentLyricsMatch(String title, String candidateTitle) {
  final normalizedTitle = normalizeLyricsText(title);
  final normalizedCandidate = normalizeLyricsText(candidateTitle);

  if (normalizedTitle.isEmpty || normalizedCandidate.isEmpty) return false;
  if (normalizedTitle == normalizedCandidate) return true;

  // e.g. "フォニイ" vs "フォニイ (phony)".
  if (normalizedTitle.length >= 2 &&
      normalizedCandidate.startsWith(normalizedTitle)) {
    return true;
  }

  // e.g. "Hibana -Reloaded-" vs "ヒバナ -Reloaded-".
  return lyricsSimilarity(title, candidateTitle) >= 0.6;
}

/// Brackets that niconico uploaders commonly use for decorations such as the
/// vocaloid name, "MV" or "歌ってみた".
final _decorationPattern = RegExp(
  r'【[^】]*】|［[^］]*］|\[[^\]]*\]|（[^）]*）|\([^)]*\)|〔[^〕]*〕|｛[^｝]*｝|\{[^}]*\}',
);

/// Subset of the decorations above that is only used for videos, and therefore
/// safe to remove even when parentheses may be part of the song title.
final _looseDecorationPattern = RegExp(r'【[^】]*】|［[^］]*］');

final _whitespacePattern = RegExp(r'\s+');
final _quotePattern = RegExp(r'[「」『』]');
final _edgeJunkPattern = RegExp(r'^[\s/／|｜:：,、]+|[\s/／|｜:：,、]+$');

final _slashSeparator = RegExp(r'\s*[/／|｜]\s*');
final _dashSeparator = RegExp(r'\s+[-‐‑‒–—―−－]\s+');
final _featSeparator = RegExp(r'\s+(?:feat\.?|ft\.?)\s*', caseSensitive: false);

/// Infers the likely PetitLyrics search queries from a niconico video title.
///
/// Niconico titles are noisy, for example:
///
/// - `【初音ミク】フォニイ / ツミキ【オリジナル曲】`
/// - `DECO*27 - ヴァンパイア feat. 初音ミク`
/// - `Never Gonna Give You Up / Rick Astley`
///
/// The usual niconico format is `title / artist`, but some uploads use the
/// western `artist - title` order instead. [uploader] is used as a hint for
/// telling the two apart.
///
/// The returned queries are ordered from the most to the least specific, so
/// the caller should try them in order and stop at the first one that returns
/// lyrics.
List<PetitLyricsQuery> inferPetitLyricsQueries({
  required String title,
  String uploader = '',
}) {
  final raw = title.trim();
  final cleaned = _clean(raw);
  final base = cleaned.isEmpty ? raw : cleaned;

  if (base.isEmpty) return const [];

  final queries = <PetitLyricsQuery>[];
  final seen = <String>{};

  void add({required String title, String artist = ''}) {
    final cleanedTitle = title.trim();
    final cleanedArtist = artist.trim();

    if (cleanedTitle.isEmpty && cleanedArtist.isEmpty) return;

    final key =
        '${normalizeLyricsText(cleanedTitle)}\u0000'
        '${normalizeLyricsText(cleanedArtist)}';
    if (!seen.add(key)) return;

    queries.add(PetitLyricsQuery(title: cleanedTitle, artist: cleanedArtist));
  }

  var titlePart = base;
  var artistPart = '';
  // The side that was not chosen as the title. It is used as a fallback when
  // the title/artist order could not be determined.
  var otherPart = '';

  final split =
      _splitOnce(base, _slashSeparator) ?? _splitOnce(base, _dashSeparator);

  if (split != null) {
    final leftIsUploader = _sameName(split.left, uploader);

    if (leftIsUploader) {
      titlePart = split.right;
      artistPart = split.left;
    } else {
      titlePart = split.left;
      artistPart = split.right;
      otherPart = split.right;
    }
  }

  // "feat." and "ft." introduce a performer, and are not part of the title.
  var featArtist = '';
  final feat = _splitOnce(titlePart, _featSeparator);
  if (feat != null) {
    titlePart = feat.left;
    featArtist = feat.right;
  }

  add(title: titlePart);

  if (artistPart.isNotEmpty) {
    add(title: titlePart, artist: _withoutFeat(artistPart));
  }

  if (featArtist.isNotEmpty) {
    add(title: titlePart, artist: featArtist);
  }

  if (otherPart.isNotEmpty) {
    add(title: _withoutFeat(otherPart));
  }

  // The whole title may already be the song title, without any artist part.
  add(title: base);

  // Last resort: keep parentheses, as they may be part of the actual title.
  add(title: _clean(raw, keepParentheses: true));

  return queries;
}

String _clean(String input, {bool keepParentheses = false}) {
  return input
      .replaceAll(
        keepParentheses ? _looseDecorationPattern : _decorationPattern,
        ' ',
      )
      .replaceAll(_quotePattern, ' ')
      .replaceAll(_whitespacePattern, ' ')
      .replaceAll(_edgeJunkPattern, '')
      .trim();
}

({String left, String right})? _splitOnce(String input, RegExp separator) {
  final match = separator.firstMatch(input);
  if (match == null) return null;

  final left = input.substring(0, match.start).trim();
  final right = input.substring(match.end).trim();

  if (left.isEmpty || right.isEmpty) return null;

  return (left: left, right: right);
}

String _withoutFeat(String input) {
  final split = _splitOnce(input, _featSeparator);
  return split == null ? input : split.left;
}

bool _sameName(String a, String b) {
  final normalizedA = normalizeLyricsText(a);
  final normalizedB = normalizeLyricsText(b);

  if (normalizedA.isEmpty || normalizedB.isEmpty) return false;
  if (normalizedA == normalizedB) return true;

  return normalizedA.startsWith(normalizedB) ||
      normalizedA.endsWith(normalizedB) ||
      normalizedB.startsWith(normalizedA) ||
      normalizedB.endsWith(normalizedA);
}

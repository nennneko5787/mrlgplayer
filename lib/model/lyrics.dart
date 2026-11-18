import 'package:material_ui/material_ui.dart';

enum LyricsProviderType { nicovideo, petitLyrics, genius }

class Character {
  final int id;
  final TextAlign? align;
  final Color? color;
  final String? name;

  Character({required this.id, this.align, this.color, this.name});
}

class TextLine {
  final int characterId;
  final Duration? start;
  final Duration? end;
  final String text;

  TextLine({
    required this.characterId,
    this.start,
    this.end,
    required this.text,
  });
}

class Lyrics {
  final List<Character> characters;
  final List<TextLine> textLines;

  Lyrics({required this.characters, required this.textLines});
}

class LyricsState {
  final Lyrics? lyrics;
  bool hasError = false;
  bool isLyricsViewOpened = false;

  LyricsState({
    required this.lyrics,
    this.hasError = false,
    this.isLyricsViewOpened = false,
  });

  static const _unset = Object();

  LyricsState copyWith({
    Object? lyrics = _unset,
    bool? hasError,
    bool? isLyricsViewOpened,
  }) {
    return LyricsState(
      lyrics: identical(lyrics, _unset) ? this.lyrics : lyrics as Lyrics?,
      hasError: (hasError == null) ? this.hasError : hasError,
      isLyricsViewOpened: (isLyricsViewOpened == null)
          ? this.isLyricsViewOpened
          : isLyricsViewOpened,
    );
  }
}

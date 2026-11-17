import 'package:material_ui/material_ui.dart';

enum LyricsProviderType { nicovideo, petitLyrics }

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

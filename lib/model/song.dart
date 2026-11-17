import 'package:mrlgplayer/model/lyrics.dart';

class Song {
  final String id;
  final String service;
  final String title;
  final String artist;
  final String? artworkUrl;
  final String websiteUrl;
  Lyrics? lyrics;
  bool lyricsError = false;

  Song({
    required this.id,
    required this.service,
    required this.title,
    required this.artist,
    this.artworkUrl,
    required this.websiteUrl,
    this.lyrics,
  });
}

import 'package:mrlgplayer/model/song.dart';

class History extends Song {
  final DateTime viewedAt;

  History({
    required super.id,
    required super.service,
    required super.title,
    required super.artist,
    super.artworkUrl,
    required super.websiteUrl,
    required this.viewedAt,
  });

  factory History.fromSong({required Song song, required DateTime dateTime}) {
    return History(
      id: song.id,
      service: song.service,
      title: song.title,
      artist: song.artist,
      websiteUrl: song.websiteUrl,
      viewedAt: dateTime,
      artworkUrl: song.artworkUrl,
    );
  }
}

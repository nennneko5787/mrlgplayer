import 'package:json_annotation/json_annotation.dart';

part 'lyrics.g.dart';

@JsonSerializable()
class VideoLyrics {
  final List<String> lines;
  final int startMs;
  final int endMs;

  VideoLyrics({
    required this.lines,
    required this.startMs,
    required this.endMs,
  });

  factory VideoLyrics.fromJson(Map<String, dynamic> json) =>
      _$VideoLyricsFromJson(json);

  Map<String, dynamic> toJson() => _$VideoLyricsToJson(this);
}

@JsonSerializable()
class VideoLyricsResponse {
  final String id;
  final List<VideoLyrics> lyrics;

  VideoLyricsResponse({required this.id, required this.lyrics});

  factory VideoLyricsResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoLyricsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VideoLyricsResponseToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoLyrics _$VideoLyricsFromJson(Map<String, dynamic> json) => VideoLyrics(
  lines: (json['lines'] as List<dynamic>).map((e) => e as String).toList(),
  startMs: (json['startMs'] as num).toInt(),
  endMs: (json['endMs'] as num).toInt(),
);

Map<String, dynamic> _$VideoLyricsToJson(VideoLyrics instance) =>
    <String, dynamic>{
      'lines': instance.lines,
      'startMs': instance.startMs,
      'endMs': instance.endMs,
    };

VideoLyricsResponse _$VideoLyricsResponseFromJson(Map<String, dynamic> json) =>
    VideoLyricsResponse(
      id: json['id'] as String,
      lyrics: (json['lyrics'] as List<dynamic>)
          .map((e) => VideoLyrics.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VideoLyricsResponseToJson(
  VideoLyricsResponse instance,
) => <String, dynamic>{'id': instance.id, 'lyrics': instance.lyrics};

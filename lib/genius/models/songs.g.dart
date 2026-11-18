// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeniusHitResult _$GeniusHitResultFromJson(Map<String, dynamic> json) =>
    GeniusHitResult(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      artistNames: json['artist_names'] as String,
    );

Map<String, dynamic> _$GeniusHitResultToJson(GeniusHitResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist_names': instance.artistNames,
    };

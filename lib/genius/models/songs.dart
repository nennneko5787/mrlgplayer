import 'package:json_annotation/json_annotation.dart';

part 'songs.g.dart';

@JsonSerializable()
class GeniusHitResult {
  final int id;
  final String title;
  @JsonKey(name: 'artist_names')
  final String artistNames;

  GeniusHitResult({
    required this.id,
    required this.title,
    required this.artistNames,
  });

  factory GeniusHitResult.fromJson(Map<String, dynamic> json) =>
      _$GeniusHitResultFromJson(json);

  Map<String, dynamic> toJson() => _$GeniusHitResultToJson(this);
}

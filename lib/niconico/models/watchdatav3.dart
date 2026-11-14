import 'package:json_annotation/json_annotation.dart';

part 'watchdatav3.g.dart';

@JsonSerializable()
class WatchDataV3ClientData {
  final String nicosid;
  final String watchId;
  final String watchTrackId;

  WatchDataV3ClientData({
    required this.nicosid,
    required this.watchId,
    required this.watchTrackId,
  });

  factory WatchDataV3ClientData.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3ClientDataFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3ClientDataToJson(this);
}

@JsonSerializable()
class WatchDataV3Video {
  final String id;
  final bool isAvailable;
  final String label;
  final int bitRate;
  final int width;
  final int height;
  final int qualityLevel;
  final int recommendedHighestAudioQualityLevel;

  WatchDataV3Video({
    required this.id,
    required this.isAvailable,
    required this.label,
    required this.bitRate,
    required this.width,
    required this.height,
    required this.qualityLevel,
    required this.recommendedHighestAudioQualityLevel,
  });

  factory WatchDataV3Video.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3VideoFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3VideoToJson(this);
}

@JsonSerializable()
class WatchDataV3LoudnessCollection {
  final String type;
  final double value;

  WatchDataV3LoudnessCollection({required this.type, required this.value});

  factory WatchDataV3LoudnessCollection.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3LoudnessCollectionFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3LoudnessCollectionToJson(this);
}

@JsonSerializable()
class WatchDataV3AudioLabel {
  final String quality;
  final String bitrate;

  WatchDataV3AudioLabel({required this.quality, required this.bitrate});

  factory WatchDataV3AudioLabel.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3AudioLabelFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3AudioLabelToJson(this);
}

@JsonSerializable()
class WatchDataV3Audio {
  final String id;
  final bool isAvailable;
  final WatchDataV3AudioLabel label;
  final int bitRate;
  final double samplingRate;
  final double integratedLoudness;
  final double truePeak;
  final int qualityLevel;
  final List<WatchDataV3LoudnessCollection> loudnessCollection;

  WatchDataV3Audio({
    required this.id,
    required this.isAvailable,
    required this.label,
    required this.bitRate,
    required this.samplingRate,
    required this.integratedLoudness,
    required this.truePeak,
    required this.qualityLevel,
    required this.loudnessCollection,
  });

  factory WatchDataV3Audio.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3AudioFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3AudioToJson(this);
}

@JsonSerializable()
class WatchDataV3Domand {
  final List<WatchDataV3Video> videos;
  final List<WatchDataV3Audio> audios;
  final String accessRightKey;

  WatchDataV3Domand({
    required this.videos,
    required this.audios,
    required this.accessRightKey,
  });

  factory WatchDataV3Domand.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3DomandFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3DomandToJson(this);
}

@JsonSerializable()
class WatchDataV3Media {
  final WatchDataV3Domand domand;

  WatchDataV3Media({required this.domand});

  factory WatchDataV3Media.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3MediaFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3MediaToJson(this);
}

@JsonSerializable()
class WatchDataV3Owner {
  final int id;
  final String nickname;
  final String iconUrl;

  WatchDataV3Owner({
    required this.id,
    required this.nickname,
    required this.iconUrl,
  });

  factory WatchDataV3Owner.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3OwnerToJson(this);
}

@JsonSerializable()
class WatchDataV3VideoStats {
  final int view;
  final int comment;
  final int mylist;
  final int like;

  WatchDataV3VideoStats({
    required this.view,
    required this.comment,
    required this.mylist,
    required this.like,
  });

  factory WatchDataV3VideoStats.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3VideoStatsFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3VideoStatsToJson(this);
}

@JsonSerializable()
class WatchDataV3Thumbnail {
  final String url;
  final String? middleUrl;
  final String? largeUrl;
  final String? player;
  final String? ogp;
  final String? short;

  WatchDataV3Thumbnail({
    required this.url,
    required this.middleUrl,
    required this.largeUrl,
    required this.player,
    required this.ogp,
    required this.short,
  });

  factory WatchDataV3Thumbnail.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3ThumbnailFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3ThumbnailToJson(this);
}

@JsonSerializable()
class WatchDataV3VideoInfo {
  final String id;
  final String contentType;
  final String title;
  final String description;
  final WatchDataV3VideoStats count;
  final WatchDataV3Thumbnail thumbnail;
  final DateTime registeredAt;

  WatchDataV3VideoInfo({
    required this.id,
    required this.contentType,
    required this.title,
    required this.description,
    required this.count,
    required this.thumbnail,
    required this.registeredAt,
  });

  factory WatchDataV3VideoInfo.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3VideoInfoFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3VideoInfoToJson(this);
}

@JsonSerializable()
class WatchDataV3Response {
  final WatchDataV3ClientData client;
  final WatchDataV3Media media;
  final WatchDataV3Owner owner;
  final WatchDataV3VideoInfo video;

  WatchDataV3Response({
    required this.client,
    required this.media,
    required this.owner,
    required this.video,
  });

  factory WatchDataV3Response.fromJson(Map<String, dynamic> json) =>
      _$WatchDataV3ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WatchDataV3ResponseToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchdatav3.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchDataV3ClientData _$WatchDataV3ClientDataFromJson(
  Map<String, dynamic> json,
) => WatchDataV3ClientData(
  nicosid: json['nicosid'] as String,
  watchId: json['watchId'] as String,
  watchTrackId: json['watchTrackId'] as String,
);

Map<String, dynamic> _$WatchDataV3ClientDataToJson(
  WatchDataV3ClientData instance,
) => <String, dynamic>{
  'nicosid': instance.nicosid,
  'watchId': instance.watchId,
  'watchTrackId': instance.watchTrackId,
};

WatchDataV3Video _$WatchDataV3VideoFromJson(Map<String, dynamic> json) =>
    WatchDataV3Video(
      id: json['id'] as String,
      isAvailable: json['isAvailable'] as bool,
      label: json['label'] as String,
      bitRate: (json['bitRate'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      qualityLevel: (json['qualityLevel'] as num).toInt(),
      recommendedHighestAudioQualityLevel:
          (json['recommendedHighestAudioQualityLevel'] as num).toInt(),
    );

Map<String, dynamic> _$WatchDataV3VideoToJson(WatchDataV3Video instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isAvailable': instance.isAvailable,
      'label': instance.label,
      'bitRate': instance.bitRate,
      'width': instance.width,
      'height': instance.height,
      'qualityLevel': instance.qualityLevel,
      'recommendedHighestAudioQualityLevel':
          instance.recommendedHighestAudioQualityLevel,
    };

WatchDataV3LoudnessCollection _$WatchDataV3LoudnessCollectionFromJson(
  Map<String, dynamic> json,
) => WatchDataV3LoudnessCollection(
  type: json['type'] as String,
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$WatchDataV3LoudnessCollectionToJson(
  WatchDataV3LoudnessCollection instance,
) => <String, dynamic>{'type': instance.type, 'value': instance.value};

WatchDataV3AudioLabel _$WatchDataV3AudioLabelFromJson(
  Map<String, dynamic> json,
) => WatchDataV3AudioLabel(
  quality: json['quality'] as String,
  bitrate: json['bitrate'] as String,
);

Map<String, dynamic> _$WatchDataV3AudioLabelToJson(
  WatchDataV3AudioLabel instance,
) => <String, dynamic>{
  'quality': instance.quality,
  'bitrate': instance.bitrate,
};

WatchDataV3Audio _$WatchDataV3AudioFromJson(
  Map<String, dynamic> json,
) => WatchDataV3Audio(
  id: json['id'] as String,
  isAvailable: json['isAvailable'] as bool,
  label: WatchDataV3AudioLabel.fromJson(json['label'] as Map<String, dynamic>),
  bitRate: (json['bitRate'] as num).toInt(),
  samplingRate: (json['samplingRate'] as num).toDouble(),
  integratedLoudness: (json['integratedLoudness'] as num).toDouble(),
  truePeak: (json['truePeak'] as num).toDouble(),
  qualityLevel: (json['qualityLevel'] as num).toInt(),
  loudnessCollection: (json['loudnessCollection'] as List<dynamic>)
      .map(
        (e) =>
            WatchDataV3LoudnessCollection.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$WatchDataV3AudioToJson(WatchDataV3Audio instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isAvailable': instance.isAvailable,
      'label': instance.label,
      'bitRate': instance.bitRate,
      'samplingRate': instance.samplingRate,
      'integratedLoudness': instance.integratedLoudness,
      'truePeak': instance.truePeak,
      'qualityLevel': instance.qualityLevel,
      'loudnessCollection': instance.loudnessCollection,
    };

WatchDataV3Domand _$WatchDataV3DomandFromJson(Map<String, dynamic> json) =>
    WatchDataV3Domand(
      videos: (json['videos'] as List<dynamic>)
          .map((e) => WatchDataV3Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      audios: (json['audios'] as List<dynamic>)
          .map((e) => WatchDataV3Audio.fromJson(e as Map<String, dynamic>))
          .toList(),
      accessRightKey: json['accessRightKey'] as String,
    );

Map<String, dynamic> _$WatchDataV3DomandToJson(WatchDataV3Domand instance) =>
    <String, dynamic>{
      'videos': instance.videos,
      'audios': instance.audios,
      'accessRightKey': instance.accessRightKey,
    };

WatchDataV3Media _$WatchDataV3MediaFromJson(Map<String, dynamic> json) =>
    WatchDataV3Media(
      domand: WatchDataV3Domand.fromJson(
        json['domand'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$WatchDataV3MediaToJson(WatchDataV3Media instance) =>
    <String, dynamic>{'domand': instance.domand};

WatchDataV3Owner _$WatchDataV3OwnerFromJson(Map<String, dynamic> json) =>
    WatchDataV3Owner(
      id: (json['id'] as num).toInt(),
      nickname: json['nickname'] as String,
      iconUrl: json['iconUrl'] as String,
    );

Map<String, dynamic> _$WatchDataV3OwnerToJson(WatchDataV3Owner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'iconUrl': instance.iconUrl,
    };

WatchDataV3VideoStats _$WatchDataV3VideoStatsFromJson(
  Map<String, dynamic> json,
) => WatchDataV3VideoStats(
  view: (json['view'] as num).toInt(),
  comment: (json['comment'] as num).toInt(),
  mylist: (json['mylist'] as num).toInt(),
  like: (json['like'] as num).toInt(),
);

Map<String, dynamic> _$WatchDataV3VideoStatsToJson(
  WatchDataV3VideoStats instance,
) => <String, dynamic>{
  'view': instance.view,
  'comment': instance.comment,
  'mylist': instance.mylist,
  'like': instance.like,
};

WatchDataV3Thumbnail _$WatchDataV3ThumbnailFromJson(
  Map<String, dynamic> json,
) => WatchDataV3Thumbnail(
  url: json['url'] as String,
  middleUrl: json['middleUrl'] as String?,
  largeUrl: json['largeUrl'] as String?,
  player: json['player'] as String?,
  ogp: json['ogp'] as String?,
  short: json['short'] as String?,
);

Map<String, dynamic> _$WatchDataV3ThumbnailToJson(
  WatchDataV3Thumbnail instance,
) => <String, dynamic>{
  'url': instance.url,
  'middleUrl': instance.middleUrl,
  'largeUrl': instance.largeUrl,
  'player': instance.player,
  'ogp': instance.ogp,
  'short': instance.short,
};

WatchDataV3VideoInfo _$WatchDataV3VideoInfoFromJson(
  Map<String, dynamic> json,
) => WatchDataV3VideoInfo(
  id: json['id'] as String,
  contentType: json['contentType'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  count: WatchDataV3VideoStats.fromJson(json['count'] as Map<String, dynamic>),
  thumbnail: WatchDataV3Thumbnail.fromJson(
    json['thumbnail'] as Map<String, dynamic>,
  ),
  registeredAt: DateTime.parse(json['registeredAt'] as String),
);

Map<String, dynamic> _$WatchDataV3VideoInfoToJson(
  WatchDataV3VideoInfo instance,
) => <String, dynamic>{
  'id': instance.id,
  'contentType': instance.contentType,
  'title': instance.title,
  'description': instance.description,
  'count': instance.count,
  'thumbnail': instance.thumbnail,
  'registeredAt': instance.registeredAt.toIso8601String(),
};

WatchDataV3Response _$WatchDataV3ResponseFromJson(Map<String, dynamic> json) =>
    WatchDataV3Response(
      client: WatchDataV3ClientData.fromJson(
        json['client'] as Map<String, dynamic>,
      ),
      media: WatchDataV3Media.fromJson(json['media'] as Map<String, dynamic>),
      owner: WatchDataV3Owner.fromJson(json['owner'] as Map<String, dynamic>),
      video: WatchDataV3VideoInfo.fromJson(
        json['video'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$WatchDataV3ResponseToJson(
  WatchDataV3Response instance,
) => <String, dynamic>{
  'client': instance.client,
  'media': instance.media,
  'owner': instance.owner,
  'video': instance.video,
};

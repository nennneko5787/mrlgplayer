// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DomandHlsAccessRightResponse _$DomandHlsAccessRightResponseFromJson(
  Map<String, dynamic> json,
) => DomandHlsAccessRightResponse(
  contentUrl: json['contentUrl'] as String,
  createTime: DateTime.parse(json['createTime'] as String),
  expireTime: DateTime.parse(json['expireTime'] as String),
);

Map<String, dynamic> _$DomandHlsAccessRightResponseToJson(
  DomandHlsAccessRightResponse instance,
) => <String, dynamic>{
  'contentUrl': instance.contentUrl,
  'createTime': instance.createTime.toIso8601String(),
  'expireTime': instance.expireTime.toIso8601String(),
};

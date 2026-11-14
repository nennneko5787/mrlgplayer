import 'package:json_annotation/json_annotation.dart';

part 'domand.g.dart';

@JsonSerializable()
class DomandHlsAccessRightResponse {
  final String contentUrl;
  final DateTime createTime;
  final DateTime expireTime;

  DomandHlsAccessRightResponse({
    required this.contentUrl,
    required this.createTime,
    required this.expireTime,
  });

  factory DomandHlsAccessRightResponse.fromJson(Map<String, dynamic> json) =>
      _$DomandHlsAccessRightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DomandHlsAccessRightResponseToJson(this);
}

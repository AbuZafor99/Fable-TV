import 'package:equatable/equatable.dart';

class StreamModel extends Equatable {
  final String channelId;
  final String url;
  final String? quality;
  final String? label;
  final String? userAgent;
  final String? referrer;
  final bool isBroken;

  const StreamModel({
    required this.channelId,
    required this.url,
    this.quality,
    this.label,
    this.userAgent,
    this.referrer,
    this.isBroken = false,
  });

  factory StreamModel.fromIptvOrg(Map<String, dynamic> json) {
    return StreamModel(
      channelId: (json['channel'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      quality: json['quality'] as String?,
      label: (json['label'] ?? json['title']) as String?,
      userAgent: json['user_agent'] as String?,
      referrer: (json['referrer'] ?? json['http_referrer']) as String?,
      isBroken: json['is_broken'] == true,
    );
  }

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      channelId: (json['channelId'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      quality: json['quality'] as String?,
      label: json['label'] as String?,
      userAgent: json['userAgent'] as String?,
      referrer: json['referrer'] as String?,
      isBroken: json['isBroken'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'channelId': channelId,
        'url': url,
        'quality': quality,
        'label': label,
        'userAgent': userAgent,
        'referrer': referrer,
        'isBroken': isBroken,
      };

  @override
  List<Object?> get props => [channelId, url];
}

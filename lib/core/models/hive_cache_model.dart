import 'dart:convert';

class HiveCacheModel {
  final String data;
  final bool isPlainText;
  final DateTime createdAt;

  const HiveCacheModel({
    required this.data,
    required this.isPlainText,
    required this.createdAt,
  });

  bool isStale(Duration ttl) => DateTime.now().difference(createdAt) > ttl;

  String encode() => jsonEncode({
        'data': data,
        'isPlainText': isPlainText,
        'createdAt': createdAt.toIso8601String(),
      });

  static HiveCacheModel? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return HiveCacheModel(
        data: json['data'] as String,
        isPlainText: json['isPlainText'] == true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

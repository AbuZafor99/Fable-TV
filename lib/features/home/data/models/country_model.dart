import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class CountryModel extends Equatable {
  final String code; // "BD"
  final String name; // "Bangladesh"
  final String flag; // "🇧🇩"
  final double latitude; // centroid for map pin
  final double longitude;

  const CountryModel({
    required this.code,
    required this.name,
    required this.flag,
    this.latitude = 0,
    this.longitude = 0,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final code = ((json['code'] as String?) ?? '').toUpperCase();
    final centroid = kCountryCentroids[code];
    return CountryModel(
      code: code,
      name: (json['name'] as String?) ?? '',
      flag: (json['flag'] as String?) ?? '',
      latitude: (json['lat'] as num?)?.toDouble() ?? centroid?.latitude ?? 0,
      longitude: (json['lng'] as num?)?.toDouble() ?? centroid?.longitude ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'flag': flag,
        'lat': latitude,
        'lng': longitude,
      };

  bool get hasCoordinates => latitude != 0 || longitude != 0;

  LatLng get latLng => LatLng(latitude, longitude);

  /// Nearest centroid to a tapped point, used when reverse geocoding is
  /// unavailable. Returns null when nothing is within [maxDegrees].
  static String? nearestCountryCode(double lat, double lng, {double maxDegrees = 12}) {
    String? best;
    double bestDist = double.infinity;
    kCountryCentroids.forEach((code, point) {
      final dLat = point.latitude - lat;
      final dLng = point.longitude - lng;
      final dist = dLat * dLat + dLng * dLng;
      if (dist < bestDist) {
        bestDist = dist;
        best = code;
      }
    });
    if (best == null || bestDist > maxDegrees * maxDegrees) return null;
    return best;
  }

  @override
  List<Object?> get props => [code, name];
}

/// Approximate centroids for the most-watched countries; used for map pins
/// and as the offline fallback for tap-to-country resolution.
const Map<String, LatLng> kCountryCentroids = {
  'BD': LatLng(23.7, 90.3),
  'IN': LatLng(20.0, 77.0),
  'US': LatLng(38.0, -97.0),
  'GB': LatLng(54.0, -2.0),
  'DE': LatLng(51.0, 10.0),
  'FR': LatLng(46.6, 2.4),
  'TR': LatLng(39.0, 35.0),
  'SA': LatLng(24.0, 45.0),
  'PK': LatLng(30.0, 70.0),
  'NG': LatLng(9.1, 8.7),
  'BR': LatLng(-10.0, -52.0),
  'MX': LatLng(23.6, -102.5),
  'ES': LatLng(40.2, -3.7),
  'IT': LatLng(42.5, 12.5),
  'RU': LatLng(60.0, 90.0),
  'CN': LatLng(35.0, 103.0),
  'JP': LatLng(36.2, 138.3),
  'KR': LatLng(36.5, 127.8),
  'ID': LatLng(-2.5, 118.0),
  'PH': LatLng(12.9, 121.8),
  'TH': LatLng(15.0, 101.0),
  'VN': LatLng(16.0, 106.0),
  'MY': LatLng(4.2, 102.0),
  'EG': LatLng(26.8, 30.8),
  'IR': LatLng(32.4, 53.7),
  'IQ': LatLng(33.2, 43.7),
  'AE': LatLng(24.0, 54.0),
  'QA': LatLng(25.3, 51.2),
  'KW': LatLng(29.3, 47.6),
  'JO': LatLng(31.3, 36.4),
  'LB': LatLng(33.9, 35.9),
  'IL': LatLng(31.4, 35.0),
  'UA': LatLng(49.0, 32.0),
  'PL': LatLng(52.0, 19.4),
  'NL': LatLng(52.2, 5.3),
  'BE': LatLng(50.6, 4.7),
  'CH': LatLng(46.8, 8.2),
  'AT': LatLng(47.6, 14.1),
  'SE': LatLng(62.0, 15.0),
  'NO': LatLng(61.0, 9.0),
  'DK': LatLng(56.0, 10.0),
  'FI': LatLng(64.0, 26.0),
  'PT': LatLng(39.6, -8.0),
  'GR': LatLng(39.0, 22.0),
  'RO': LatLng(45.9, 24.9),
  'CZ': LatLng(49.8, 15.5),
  'HU': LatLng(47.2, 19.5),
  'BG': LatLng(42.7, 25.5),
  'RS': LatLng(44.0, 20.9),
  'CA': LatLng(56.0, -106.0),
  'AU': LatLng(-25.0, 134.0),
  'NZ': LatLng(-41.5, 172.8),
  'AR': LatLng(-34.0, -64.0),
  'CL': LatLng(-33.5, -70.7),
  'CO': LatLng(4.6, -74.1),
  'PE': LatLng(-9.2, -75.0),
  'VE': LatLng(8.0, -66.0),
  'ZA': LatLng(-29.0, 24.0),
  'KE': LatLng(0.0, 38.0),
  'ET': LatLng(9.1, 40.5),
  'GH': LatLng(7.9, -1.0),
  'MA': LatLng(31.8, -7.1),
  'DZ': LatLng(28.0, 1.7),
  'TN': LatLng(34.0, 9.6),
  'LK': LatLng(7.9, 80.8),
  'NP': LatLng(28.4, 84.1),
  'AF': LatLng(33.9, 67.7),
  'MM': LatLng(21.9, 95.9),
  'SG': LatLng(1.35, 103.8),
  'HK': LatLng(22.3, 114.2),
  'TW': LatLng(23.7, 121.0),
};

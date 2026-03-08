import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSearchResult {
  final String title;
  final String addressLabel;
  final double latitude;
  final double longitude;

  PlaceSearchResult({
    required this.title,
    required this.addressLabel,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    final List position = json['Position'] as List;
    final Map<String, dynamic>? address =
        json['Address'] as Map<String, dynamic>?;

    return PlaceSearchResult(
      title: (json['Title'] ?? '') as String,
      addressLabel: (address?['Label'] ?? json['Title'] ?? '') as String,
      longitude: (position[0] as num).toDouble(),
      latitude: (position[1] as num).toDouble(),
    );
  }
}

class AwsPlacesService {
  final String apiKey;
  final String region;

  AwsPlacesService({
    required this.apiKey,
    required this.region,
  });

  Future<List<PlaceSearchResult>> searchText({
    required String query,
    double? biasLat,
    double? biasLng,
  }) async {
    final uri = Uri.parse(
      'https://places.geo.$region.amazonaws.com/v2/geocode?key=$apiKey',
    );

    final Map<String, dynamic> body = {
      'QueryText': query,
      'MaxResults': 5,
      'Language': 'es',
      'IntendedUse': 'SingleUse',
    };

    if (biasLat != null && biasLng != null) {
      body['BiasPosition'] = [biasLng, biasLat];
    }

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error buscando lugar en AWS Places: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['ResultItems'] as List? ?? []);

    return items
        .map((item) => PlaceSearchResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteSummary {
  final double distanceMeters;
  final double durationSeconds;
  final List<List<double>> coordinates;

  RouteSummary({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.coordinates,
  });

  factory RouteSummary.fromV2Json(Map<String, dynamic> json) {
    final summaries = (json['Routes'] as List?) ?? [];
    if (summaries.isEmpty) {
      return RouteSummary(
        distanceMeters: 0,
        durationSeconds: 0,
        coordinates: const [],
      );
    }

    final firstRoute = summaries.first as Map<String, dynamic>;
    final legs = (firstRoute['Legs'] as List?) ?? [];

    double distance = 0;
    double duration = 0;
    List<List<double>> coords = [];

    if (legs.isNotEmpty) {
      final firstLeg = legs.first as Map<String, dynamic>;
      final summary = firstLeg['Summary'] as Map<String, dynamic>? ?? {};
      distance = (summary['Distance'] as num?)?.toDouble() ?? 0;
      duration = (summary['Duration'] as num?)?.toDouble() ?? 0;

      final geometry = firstLeg['Geometry'] as Map<String, dynamic>? ?? {};
      final lineString = (geometry['LineString'] as List?) ?? [];

      coords = lineString
          .map((e) => [
                (e[0] as num).toDouble(),
                (e[1] as num).toDouble(),
              ])
          .toList();
    }

    return RouteSummary(
      distanceMeters: distance,
      durationSeconds: duration,
      coordinates: coords,
    );
  }
}

class AwsRoutesService {
  final String apiKey;
  final String region;

  AwsRoutesService({
    required this.apiKey,
    required this.region,
  });

  Future<RouteSummary> calculateRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required bool isWalking,
  }) async {
    final uri = Uri.parse(
      'https://routes.geo.$region.amazonaws.com/v2/routes?key=$apiKey',
    );

    final body = {
      'Origin': [originLng, originLat],
      'Destination': [destLng, destLat],
      'TravelMode': isWalking ? 'Pedestrian' : 'Car',
      'LegGeometryFormat': 'Simple',
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      print('ROUTES ERROR STATUS: ${response.statusCode}');
      print('ROUTES ERROR BODY: ${response.body}');
      throw Exception('Error calculando ruta: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return RouteSummary.fromV2Json(data);
  }
}
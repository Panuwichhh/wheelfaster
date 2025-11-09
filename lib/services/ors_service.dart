import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OrsStep {
  final String instruction;
  final double distance; // m
  final double duration; // s
  final int fromIndex;
  final int toIndex;

  OrsStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.fromIndex,
    required this.toIndex,
  });
}

class OrsRoute {
  final List<LatLng> geometry;
  final double distance; // m
  final double duration; // s
  final List<OrsStep> steps;

  OrsRoute({
    required this.geometry,
    required this.distance,
    required this.duration,
    required this.steps,
  });
}

class OrsService {
  OrsService(this.apiKey);
  final String apiKey;

  Future<OrsRoute> wheelchairRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    // ต้องมี /geojson
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/wheelchair/geojson',
    );

    final body = {
      "coordinates": [
        [from.longitude, from.latitude], // [lon, lat]
        [to.longitude, to.latitude],
      ],
      "instructions": true,
      "options": {
        "avoid_features": ["steps"], // เลี่ยงบันได
      },
    };

    http.Response res;
    try {
      res = await http
          .post(
            url,
            headers: {
              "Authorization": apiKey,
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception('เชื่อมต่อ ORS ไม่สำเร็จ (timeout)');
    }

    if (res.statusCode != 200) {
      // ช่วยดีบัก: แจ้ง endpoint + body ที่ใช้
      throw Exception(
        'ORS error ${res.statusCode}: ${res.body}\n'
        'endpoint: ${url.toString()}',
      );
    }

    final data = jsonDecode(res.body);
    final feats = data["features"];
    if (feats is! List || feats.isEmpty) {
      throw Exception('ไม่พบเส้นทางจาก ORS (features ว่าง)');
    }

    final feat0 = feats.first;
    final geom = feat0["geometry"];
    if (geom == null || geom["coordinates"] == null) {
      throw Exception('ผลลัพธ์ไม่มี geometry.coordinates');
    }

    // geometry: LineString [lon, lat]
    final coordsJson = (geom["coordinates"] as List);
    final coords = coordsJson
        .map<LatLng>(
          (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
        )
        .toList();

    final props = feat0["properties"];
    if (props == null) {
      throw Exception('ผลลัพธ์ไม่มี properties');
    }

    final summary = props["summary"];
    if (summary == null) {
      throw Exception('ผลลัพธ์ไม่มี summary');
    }

    final segments = props["segments"];
    final stepsJson = (segments is List && segments.isNotEmpty)
        ? (segments[0]["steps"] as List? ?? const [])
        : const [];

    final steps = stepsJson.map<OrsStep>((s) {
      final wp = (s["way_points"] as List?) ?? const [0, 0];
      return OrsStep(
        instruction: (s["instruction"] as String?) ?? '',
        distance: (s["distance"] as num?)?.toDouble() ?? 0.0,
        duration: (s["duration"] as num?)?.toDouble() ?? 0.0,
        fromIndex: (wp[0] as num).toInt(),
        toIndex: (wp[1] as num).toInt(),
      );
    }).toList();

    return OrsRoute(
      geometry: coords,
      distance: (summary["distance"] as num).toDouble(),
      duration: (summary["duration"] as num).toDouble(),
      steps: steps,
    );
  }
}

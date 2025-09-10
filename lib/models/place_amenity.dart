import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceAmenity {
  final String id;
  final String name;
  final String description;
  final double lat;
  final double lng;

  /// ตัวอย่าง: "TOILET" | "PARKING" | "ELEVATOR" | "RAMP" | "UNKNOWN"
  final String typeKey;

  PlaceAmenity({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.typeKey,
  });

  factory PlaceAmenity.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // location: รองรับทั้ง [lat, lng] และ GeoPoint
    double? lat;
    double? lng;
    final loc = data['location'];
    if (loc is List && loc.length >= 2) {
      lat = (loc[0] as num?)?.toDouble();
      lng = (loc[1] as num?)?.toDouble();
    } else if (loc is GeoPoint) {
      lat = loc.latitude;
      lng = loc.longitude;
    }

    // type: DocumentReference หรืออื่น ๆ
    String key = 'UNKNOWN';
    final typeRef = data['type'];
    if (typeRef is DocumentReference) {
      key = typeRef.id.trim().toUpperCase();
    }

    return PlaceAmenity(
      id: doc.id,
      name: (data['name'] ?? 'ไม่มีชื่อ').toString(),
      description: (data['description'] ?? '').toString(),
      lat: lat ?? 0,
      lng: lng ?? 0,
      typeKey: key,
    );
  }
}

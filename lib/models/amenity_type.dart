// lib/models/amenity_type.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AmenityType {
  toilet,
  elevator,
  ramp,
  parking,
  servicePoint,
  specialPath,
  unknown,
}

AmenityType amenityTypeFromFirestore(dynamic typeRefOrId) {
  final id = switch (typeRefOrId) {
    DocumentReference ref => ref.id,
    String s => s,
    _ => '',
  }.trim().toLowerCase();

  return switch (id) {
    'toilet' || 'toilet_accessible' => AmenityType.toilet,
    'elevator' => AmenityType.elevator,
    'ramp' => AmenityType.ramp,
    'parking' || 'parking_accessible' => AmenityType.parking,
    'service_point' => AmenityType.servicePoint,
    'special_path' => AmenityType.specialPath,
    _ => AmenityType.unknown,
  };
}

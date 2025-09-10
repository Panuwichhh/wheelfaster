import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wheelfaster/models/place_amenity.dart';

class PlaceAmenityService {
  final FirebaseFirestore _db;
  PlaceAmenityService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// stream all documents and map to model
  Stream<List<PlaceAmenity>> watchAll() {
    return _db
        .collection('place_amenities')
        .snapshots()
        .map((qs) => qs.docs.map((d) => PlaceAmenity.fromDoc(d)).toList());
  }
}

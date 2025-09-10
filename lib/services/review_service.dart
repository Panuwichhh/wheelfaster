import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final _col = FirebaseFirestore.instance
      .collection('reviews')
      .withConverter<Review>(
        fromFirestore: (snap, _) => Review.fromDoc(snap),
        toFirestore: (review, _) => review.toMap(),
      );

  /// ดึงรีวิวทั้งหมด
  Stream<List<Review>> streamAll({int limit = 50}) {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((qs) => qs.docs.map((d) => d.data()).toList());
  }

  /// ดึงรีวิวตาม placeRef
  Stream<List<Review>> streamByPlace(
    DocumentReference placeRef, {
    int limit = 50,
  }) {
    return _col
        .where(
          'placeId',
          isEqualTo: placeRef,
        ) // ใช้ DocumentReference เทียบตรงๆ
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((qs) => qs.docs.map((d) => d.data()).toList());
  }

  /// เพิ่มรีวิวใหม่
  Future<void> addReview({
    required DocumentReference placeRef,
    required String userId,
    required String comment,
    required double rating,
  }) async {
    await _col.add(
      Review(
        id: '',
        placeRef: placeRef,
        userId: userId,
        comment: comment,
        rating: rating,
        createdAt: null,
      ),
    );
  }

  Future<void> updateReview(
    String reviewId, {
    String? comment,
    double? rating,
  }) async {
    final updates = <String, dynamic>{};
    if (comment != null) updates['comment'] = comment;
    if (rating != null) updates['rating'] = rating;
    await _col.doc(reviewId).update(updates);
  }

  Future<void> deleteReview(String reviewId) async {
    await _col.doc(reviewId).delete();
  }
}

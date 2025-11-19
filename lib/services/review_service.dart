import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import 'dart:math';
class ReviewService {
  String _randomUserId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(
      10,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

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
          'placeRef', 
          isEqualTo: placeRef,
        )
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((qs) => qs.docs.map((d) => d.data()).toList());
  }

  Future<void> addReview({
    required DocumentReference placeRef,
    String? userId,
    required String comment,
    required double rating,
    String? ip,
  }) async {
    try {
      final uid = userId ?? _randomUserId();

      // print("กำลังเพิ่มรีวิว...");
      // print("placeRef = ${placeRef.path}");
      // print("rating = $rating");
      // print("comment = $comment");
      // print("userId = $uid");

      await _col.add(
        Review(
          id: '',
          placeRef: placeRef,
          userId: uid,
          comment: comment,
          rating: rating,
          createdAt: null,
          // ip: resolvedIp,
        ),
      );

      // print("เพิ่มรีวิวสำเร็จ!");
    } catch (e, stack) {
      // print("เพิ่มรีวิวล้มเหลว: $e");
      // print(stack);
      rethrow; // เผื่อ UI จับ error ต่อ
    }
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

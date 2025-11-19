import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final DocumentReference placeRef; 
  final String userId;
  final String comment;
  final double rating;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.placeRef,
    required this.userId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Review(
      id: doc.id,
      placeRef: data['placeRef'] as DocumentReference, 
      userId: data['userId'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeRef': placeRef, 
      'userId': userId,
      'comment': comment,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

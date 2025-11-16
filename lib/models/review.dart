import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final DocumentReference placeRef; // เก็บเป็น reference โดยตรง
  final String userId;
  final String comment;
  final double rating;
  // final String? ip; // ⭐ nullable
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.placeRef,
    required this.userId,
    required this.comment,
    required this.rating,
    // required this.ip,
    required this.createdAt,
  });

  factory Review.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Review(
      id: doc.id,
      placeRef: data['placeRef'] as DocumentReference, // ⭐ แก้ชื่อ key
      userId: data['userId'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      // ip: data['ip'] as String?, // ⭐ เอาแบบ String? ไม่ต้อง default เป็น ''
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeRef': placeRef, // ⭐ ใช้ key นี้ให้ตรงกับ service
      'userId': userId,
      'comment': comment,
      'rating': rating,
      // 'ip': ip, // ⭐ เก็บ ip ด้วย
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

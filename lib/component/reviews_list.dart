import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewsList extends StatelessWidget {
  final DocumentReference? placeRef; // ถ้า null = แสดงทั้งหมด
  final _service = ReviewService();

  ReviewsList({super.key, this.placeRef});

  @override
  Widget build(BuildContext context) {
    final stream = (placeRef == null)
        ? _service.streamAll(limit: 50)
        : _service.streamByPlace(placeRef!, limit: 50);

    return StreamBuilder<List<Review>>(
      stream: stream,
      builder: (context, snapshot) {
        //print(
          //'conn=${snapshot.connectionState} hasData=${snapshot.hasData} err=${snapshot.error}',
        //);
        if (snapshot.hasError) {
          return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(child: Text("ยังไม่มีรีวิว"));
        }

        return ListView.separated(
          shrinkWrap: true, 
          physics:
              const NeverScrollableScrollPhysics(), 
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final r = items[i];
            return ListTile(
              title: Text("⭐️ ${r.rating.toStringAsFixed(1)}  •  ${r.comment}"),
              subtitle: Text("by ${r.userId}  •  ${r.createdAt}"),
            );
          },
        );
      },
    );
  }
}

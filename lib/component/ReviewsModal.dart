import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wheelfaster/services/review_service.dart';

class ReviewModal extends StatefulWidget {
  final DocumentReference placeRef; 

  const ReviewModal({super.key, required this.placeRef});

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  double rating = 0;
  bool loading = false;
  final commentController = TextEditingController();
  final _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00C853); // เขียวสด
    const darkGreen = Color(0xFF009624); // เขียวเข้ม

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'รีวิวสถานที่',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ให้คะแนน', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),

          //Rating Bar สีเขียว
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (_, __) =>
                const Icon(Icons.star, color: Colors.yellowAccent, size: 32),
            onRatingUpdate: (r) => setState(() => rating = r),
          ),

          const SizedBox(height: 18),

          // Text Field สีเขียว
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: 'แสดงความคิดเห็น',
              labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: green, width: 2),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),

      //ปุ่มสีเขียว–ขาว
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      actions: [
        // ปุ่มยกเลิก
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text(
            'ยกเลิก',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 175, 0, 0),
            ),
          ),
        ),

        // ปุ่มส่งรีวิว (พื้นเขียว)
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: darkGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);

                  await _reviewService.addReview(
                    placeRef: widget.placeRef,
                    comment: commentController.text.trim(),
                    rating: rating,
                  );

                  if (mounted) Navigator.pop(context);
                },
          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text(
                  'ส่งรีวิว',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}

// วิธีเรียกใช้งาน
void showReviewModal(
  BuildContext context, {
  required DocumentReference placeRef,
}) {
  showDialog(
    context: context,
    builder: (_) => ReviewModal(placeRef: placeRef),
  );
}

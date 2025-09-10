import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewModal extends StatefulWidget {
  final Function(double rating, String comment)? onSubmit;
  const ReviewModal({super.key, this.onSubmit});

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  double rating = 0;
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'รีวิวสถานที่',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ให้คะแนน'),
          const SizedBox(height: 8),
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (r) => setState(() => rating = r),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentController,
            decoration: const InputDecoration(
              labelText: 'แสดงความคิดเห็น',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSubmit?.call(rating, commentController.text);
            Navigator.pop(context);
          },
          child: const Text('ส่งรีวิว'),
        ),
      ],
    );
  }
}

// วิธีเรียกใช้งาน
void showReviewModal(BuildContext context, Function(double, String) onSubmit) {
  showDialog(
    context: context,
    builder: (_) => ReviewModal(onSubmit: onSubmit),
  );
}

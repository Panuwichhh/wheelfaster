import 'package:flutter/material.dart';

class HorizontalImageList extends StatelessWidget {
  // สมมติว่านี่คือ List ของ URL ที่คุณดึงมาจาก Firestore/Cloudinary
  final List<String> imageUrls;

  const HorizontalImageList({Key? key, required this.imageUrls})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. ใช้ Container กำหนด "ความสูง" ของแถบรูปภาพ
    return Container(
      height: 150, // <-- คุณสามารถปรับความสูงตรงนี้ได้ตามต้องการ
      // 2. ใช้ ListView.builder เพื่อสร้างรายการ
      child: ListView.builder(
        //    กำหนดให้เลื่อนแนวนอน
        scrollDirection: Axis.horizontal,

        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final url = imageUrls[index];

          // 4. สร้าง Widget สำหรับรูปภาพแต่ละใบ
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0), // ระยะห่างซ้าย
            child: ClipRRect(
              // 5. ทำให้มีมุมมน
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                url,
                width: 250, // <-- ปรับความกว้างของรูป
                fit: BoxFit.cover,

                // (Optional) เพิ่ม Loading และ Error
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 250,
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 250,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 💡 วิธีเรียกใช้งาน ---
// 
// final List<String> myImages = [
//   "https://url_to_image_1.jpg",
//   "https://url_to_image_2.jpg",
//   "https://url_to_image_3.jpg",
// ];
// 
// // ... ใน Column หรือ ListView ของคุณ ...
// HorizontalImageList(imageUrls: myImages),
//
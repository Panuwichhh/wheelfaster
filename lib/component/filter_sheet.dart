// lib/component/filter_sheet.dart
import 'package:flutter/material.dart';

/// ตัวเลือกที่ component นี้จะส่งกลับไปให้ผู้เรียก
/// ใช้ key สั้นๆ เช่น 'ALL' | 'toilet' | 'elevator' | 'ramp' | 'parking' | 'service_point' | 'special_path'
typedef OnPickFilter = void Function(String key);

class FilterSheet extends StatelessWidget {
  final OnPickFilter onPick;
  const FilterSheet({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "กรุณาเลือกประเภทสถานที่",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ทั้งหมด
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("ทั้งหมด"),
              onTap: () {
                Navigator.pop(context);
                onPick('ALL');
              },
            ),

            // ห้องน้ำ
            ListTile(
              leading: const Icon(Icons.wc),
              title: const Text("ห้องน้ำ"),
              onTap: () {
                Navigator.pop(context);
                onPick('TOILET');
              },
            ),

            // ลิฟต์
            ListTile(
              leading: const Icon(Icons.elevator),
              title: const Text("ลิฟต์"),
              onTap: () {
                Navigator.pop(context);
                onPick('elevator');
              },
            ),

            // ทางลาด
            ListTile(
              leading: const Icon(Icons.accessible_forward),
              title: const Text("ทางลาด"),
              onTap: () {
                Navigator.pop(context);
                onPick('ramp');
              },
            ),

            // (เพิ่มได้ตามต้องการ)
            // ที่จอดผู้พิการ
            ListTile(
              leading: const Icon(Icons.local_parking),
              title: const Text("ที่จอดผู้พิการ"),
              onTap: () {
                Navigator.pop(context);
                onPick('parking');
              },
            ),
            // จุดบริการ
            // ListTile(
            //   leading: const Icon(Icons.support_agent),
            //   title: const Text("จุดให้บริการ"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     onPick('service_point');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

/// helper function เรียกเปิด bottom sheet แบบง่าย
Future<void> showFilterOptionsSheet(
  BuildContext context, {
  required OnPickFilter onPick,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => FilterSheet(onPick: onPick),
  );
}

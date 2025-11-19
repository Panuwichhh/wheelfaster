import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LabelMarker extends StatelessWidget {
  final Widget icon; // ไอคอนที่จะใส่ในหมุด
  final Color circleColor; // ใช้เป็นสีของหมุดทั้งอัน
  final String title; // เก็บไว้ (ถ้าอยากใช้ label ด้านล่าง)
  final VoidCallback? onTap;
  final double size; // ขนาด marker (ค่าเริ่มต้น 56)

  const LabelMarker({
    super.key,
    required this.icon,
    required this.title,
    required this.circleColor,
    this.onTap,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 0.4;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== หมุดทึบ + icon ด้านใน =====
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.locationPin,
                  size: size,
                  color: circleColor, // ใช้ circleColor เป็นสีหมุด
                ),
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: FittedBox(child: icon),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

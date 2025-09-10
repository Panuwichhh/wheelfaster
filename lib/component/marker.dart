import 'package:flutter/material.dart';

class LabelMarker extends StatelessWidget {
  final Widget icon;
  final Color circleColor;
  final String title;
  final VoidCallback? onTap;

  const LabelMarker({
    super.key,
    required this.icon,
    required this.title,
    required this.circleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== วงกลมด้านบน =====
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 6),

            // ===== กล่องข้อความด้านล่าง =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

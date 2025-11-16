import 'package:flutter/material.dart';
import 'package:wheelfaster/notifier/notifier.dart';
import 'package:wheelfaster/extension.dart';

typedef MapTypeValue = String;

/// เปิด Bottom Sheet ให้เลือกประเภทแผนที่
/// คืนค่าเป็น 'openstreet' | 'satellite' | 'light' ถ้าเลือก, หรือ null ถ้าปิด
Future<MapTypeValue?> showMapTypeSheet({
  required BuildContext context,
  required MapTypeValue current,
  void Function(MapTypeValue value)? onSelected,
}) {
  Widget tile({
    required String value,
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.onText),
      title: Text(label, style: TextStyle(color: context.onText)),

      // leading: Icon(
      //   icon,
      //   color: current == value ? Colors.white : Colors.black54,
      // ),
      // title: Text(
      //   label,
      //   style: TextStyle(
      //     fontWeight: current == value ? FontWeight.w600 : FontWeight.w400,
      //     color: current == value ? Colors.white : Colors.black87,
      //   ),
      // ),
      // selected: current == value,
      // selectedTileColor: Colors.green, // พื้นหลังฟ้าเมื่อเลือก
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        onSelected?.call(value);
        Navigator.pop(context, value);
      },
    );
  }

  return showModalBottomSheet<MapTypeValue>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return ValueListenableBuilder(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return SafeArea(
            
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    "เลือกประเภทแผนที่",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  tile(
                    value: 'openstreet',
                    icon: Icons.map,
                    label: 'OpenStreetMap',
                    
                  ),
                  tile(
                    value: 'satellite',
                    icon: Icons.satellite_alt,
                    label: 'Satellite (Esri)',
                  ),
                  tile(
                    value: 'light',
                    icon: Icons.wb_sunny,
                    label: 'Light (Carto)',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        }
      );
    },
  );
}

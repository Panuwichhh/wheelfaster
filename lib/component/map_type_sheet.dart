import 'package:flutter/material.dart';

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
      leading: Icon(icon, color: Colors.black),
      title: Text(label, style: const TextStyle(color: Colors.black)),
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
    },
  );
}

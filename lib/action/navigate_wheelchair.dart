// lib/actions/navigate_wheelchair.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../controllers/map_controller.dart';
import '../services/ors_service.dart';

Future<void> navigateToPlaceWheelchair(
  BuildContext context, {
  required DocumentReference<Map<String, dynamic>> placeRef,
  required String orsApiKey, // << ใส่คีย์ ORS ตรงนี้
  bool showStepsSheet = true, // << จะโชว์ step bottom sheet ไหม
}) async {
  try {
    // 1) เช็คสิทธิ์ตำแหน่ง
    // LocationPermission perm = await Geolocator.checkPermission();
    // if (perm == LocationPermission.denied ||
    //     perm == LocationPermission.deniedForever) {
    //   perm = await Geolocator.requestPermission();
    //   if (perm == LocationPermission.denied ||
    //       perm == LocationPermission.deniedForever) {
    //     throw Exception('ต้องอนุญาตสิทธิ์ตำแหน่งก่อน');
    //   }
    // }

    // 2) ตำแหน่งผู้ใช้ปัจจุบัน
    // final pos = await Geolocator.getCurrentPosition();
    // final from = LatLng(pos.latitude, pos.longitude);
    final from = LatLng(14.07192845223585, 100.59834886409122);

    // 3) อ่านพิกัดปลายทางจาก placeRef
    final to = await _getLatLngFromPlaceRef(placeRef);

    // 4) เรียก ORS wheelchair
    final ors = OrsService(orsApiKey);
    final route = await ors.wheelchairRoute(from: from, to: to);

    if (route.geometry.isEmpty) {
      throw Exception('ไม่พบเส้นทางที่เหมาะสมในพื้นที่นี้');
    }

    print('from: $from, to: $to');
    print('route geometry: ${route.geometry}');

    // 5) อัปเดต controller ให้แผนที่วาดเส้นทาง
    final ctrl = context.read<MyMapController>();
    ctrl.setRoute(route);

    // 6) (ออปชัน) เปิด steps sheet
    if (showStepsSheet && context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (_) => _RouteStepsSheet(
          route: route,
          onStopNavigation: () {
            // ลบเส้นทางออกจากแผนที่
            final ctrl = context.read<MyMapController>();
            ctrl.clearRoute();
            Navigator.pop(context); // ปิดแผ่นคำสั่ง
          },
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('นำทางล้มเหลว: $e')));
    }
  }
}

Future<LatLng> _getLatLngFromPlaceRef(
  DocumentReference<Map<String, dynamic>> placeRef,
) async {
  final snap = await placeRef.get();
  final data = snap.data() ?? {};
  final loc = data['location'];
  // กรณีเก็บเป็น GeoPoint
  if (loc is GeoPoint) {
    return LatLng(loc.latitude, loc.longitude);
  }
  // กรณีเก็บเป็น [lat, lng]
  if (loc is List && loc.length >= 2) {
    final lat = (loc[0] as num).toDouble();
    final lng = (loc[1] as num).toDouble();
    return LatLng(lat, lng);
  }
  // กรณีเก็บเป็น map: {'lat': x, 'lng': y}
  if (loc is Map) {
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    if (lat != null && lng != null) return LatLng(lat, lng);
  }
  throw Exception('ไม่พบพิกัดปลายทางใน placeRef');
}

/// ===== UI: แผ่นคำสั่งเลี้ยว (steps) =====
class _RouteStepsSheet extends StatelessWidget {
  const _RouteStepsSheet({required this.route, required this.onStopNavigation});
  final OrsRoute route;
  final VoidCallback onStopNavigation;

  String _fmtDist(double m) => m >= 1000
      ? '${(m / 1000).toStringAsFixed(1)} km'
      : '${m.toStringAsFixed(0)} m';
  String _fmtTime(double s) {
    final mins = (s / 60).round();
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60, m = mins % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'เส้นทางวีลแชร์',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('${_fmtDist(route.distance)} • ${_fmtTime(route.duration)}'),
            const Divider(),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: route.steps.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = route.steps[i];
                  return ListTile(
                    leading: const Icon(Icons.directions_walk),
                    title: Text(s.instruction),
                    subtitle: Text(
                      '${_fmtDist(s.distance)} • ${_fmtTime(s.duration)}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('หยุดนำทาง'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onStopNavigation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/actions/navigate_wheelchair.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // NEW
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../controllers/map_controller.dart';
import '../services/ors_service.dart';

Future<void> navigateToPlaceWheelchair(
    BuildContext context, {
    required DocumentReference<Map<String, dynamic>> placeRef,
    required String orsApiKey,
    bool showStepsSheet = true,
  }) async {
  try {
    // 1) ตรวจว่า location service เปิดอยู่หรือไม่
    final serviceEnabled = await Geolocator.isLocationServiceEnabled(); // NEW
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('กรุณาเปิด Location (GPS) ก่อนใช้งาน');
    }

    // 2) ขอสิทธิ์ตำแหน่ง (runtime permission)
    LocationPermission perm = await Geolocator.checkPermission(); 
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw Exception('ต้องอนุญาตสิทธิ์ตำแหน่งก่อน');
    }
    if (perm == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception('สิทธิ์ตำแหน่งถูกปฏิเสธถาวร กรุณาไปเปิดใน Settings');
    }

    // 3) ตำแหน่งผู้ใช้ปัจจุบัน (ใช้ความแม่นยำสำหรับการนำทาง + กันค้างด้วย timeLimit)
    final pos = await Geolocator.getCurrentPosition(
      // NEW
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );
    final from = LatLng(pos.latitude, pos.longitude); // NEW

    // 4) อ่านพิกัดปลายทางจาก placeRef
    final to = await _getLatLngFromPlaceRef(placeRef);
    //print('FROM: ${from.latitude}, ${from.longitude}');
    //print('TO  : ${to.latitude}, ${to.longitude}');
    // 5) เรียก ORS wheelchair
    final ors = OrsService(orsApiKey);
    final route = await ors.wheelchairRoute(from: from, to: to);

    if (route.geometry.isEmpty) {
      throw Exception('ไม่พบเส้นทางที่เหมาะสมในพื้นที่นี้');
    }

    // 6) อัปเดต controller ให้แผนที่วาดเส้นทาง
    final ctrl = context.read<MyMapController>();
    ctrl.setRoute(route);

    // แพนกล้องไปที่จุดเริ่มต้นเล็กน้อย (ถ้ามีเมธอดให้ทำ)
    // ctrl.moveCameraTo(from); // <-- ถ้ามีเมธอดใน controller

    // 7) (ออปชัน) เปิด steps sheet
    if (showStepsSheet && context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (_) => _RouteStepsSheet(
          route: route,
          onStopNavigation: () {
            final ctrl = context.read<MyMapController>();
            ctrl.clearRoute();
            Navigator.pop(context);
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
  ) 
  async {
  //print("Fetching document from: ${placeRef.path}");
    final snap = await placeRef.get();
    if (!snap.exists) {
    //print("Document does not exist!");
    throw Exception('ไม่พบเอกสารที่ placeRef');
  }

  final data = snap.data() ?? {};
  //print("Document data: $data");

  final loc = data['location'];
  //print("Location field: $loc (type: ${loc?.runtimeType})");

  // Check GeoPoint
  if (loc is GeoPoint) {
    //print("Found GeoPoint: ${loc.latitude}, ${loc.longitude}");
    return LatLng(loc.latitude, loc.longitude);
  }

  // Check List
  if (loc is List && loc.length >= 2) {
    final lat = (loc[0] as num).toDouble();
    final lng = (loc[1] as num).toDouble();
    //print("Found List: $lat, $lng");
    return LatLng(lat, lng);
  }

  // Check Map
  if (loc is Map) {
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    //print("Found Map: lat=$lat, lng=$lng");
    if (lat != null && lng != null) return LatLng(lat, lng);
  }

  //print("Could not parse location data!");
  throw Exception('ไม่พบพิกัดปลายทางใน placeRef (format ไม่ถูกต้อง)');
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';

/// ใช้ร่วมกับ showModalBottomSheet(backgroundColor: Colors.transparent, isScrollControlled: true)
class RouteStepsSheet extends StatelessWidget {
  const RouteStepsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, // ✅ ป้องกันไม่ให้กินพื้นที่เต็มจอ
      initialChildSize: 0.35, // เริ่มต้นแสดง 35% ของจอ
      minChildSize: 0.20, // ดึงลงได้ต่ำสุด 20%
      maxChildSize: 0.90, // ดึงขึ้นได้สูงสุด 90%
      builder: (context, scrollController) {
        return _RouteStepsPanel(scrollController: scrollController);
      },
    );
  }
}

class _RouteStepsPanel extends StatelessWidget {
  const _RouteStepsPanel({super.key, required this.scrollController});
  final ScrollController scrollController;

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
    final c = context.watch<MyMapController>();

    if (!c.hasRoute) {
      return const Center(child: Text('ยังไม่มีเส้นทาง'));
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'เส้นทางวีลแชร์',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${_fmtDist(c.routeDistance)} • ${_fmtTime(c.routeDuration)}',
              style: const TextStyle(color: Colors.black54),
            ),
            const Divider(),

            Expanded(
              child: ListView.separated(
                controller: scrollController, // ✅ ต้องใส่ controller ตรงนี้
                itemCount: c.routeSteps.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = c.routeSteps[i];
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('หยุดนำทาง'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  context.read<MyMapController>().clearRoute();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

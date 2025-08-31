import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Page')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(14.0711, 100.6031),
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  14.0689791,
                  100.6059037,
                ), // พิกัดคณะวิศวกรรมศาสตร์ มธ.
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('คณะวิศวกรรมศาสตร์ มธ.'),
                        content: const Text(
                          'มหาวิทยาลัยธรรมศาสตร์ ศูนย์รังสิต',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('ปิด'),
                          ),
                        ],
                      ),
                    );
                  },
                  // child: const Icon(
                  //   Icons.location_on,
                  //   color: Colors.red,
                  //   size: 100,
                  // ),
                  child: Image.asset('assets/images/dog.jpg'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

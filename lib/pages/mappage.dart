import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // ฟังก์ชันเปิดแผ่นข้อมูลสถานที่
    Future<void> _showPlaceSheet({
      required String title,
      required String subtitle,
      required String description,
    }) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.18,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.28, 0.55, 0.9],
            builder: (context, scrollController) {
              final surface = Theme.of(context).colorScheme.surface;
              return Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      offset: Offset(0, -2),
                      color: Colors.black26,
                    ),
                  ],
                ),
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
                    const SizedBox(height: 8),

                    // Header คงที่ด้านบน
                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 24,
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Divider(height: 1),
                    // เนื้อหาเลื่อนขึ้นลงได้
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ชิ้นแรก
                                      Row(
                                        children: const [
                                          Icon(Icons.accessible, size: 34),
                                          SizedBox(width: 8),
                                          Text(
                                            '2 ห้องน้ำ',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 16,
                                      ), // ระยะห่างระหว่างชิ้นใหญ่
                                      // ชิ้นที่สอง
                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.elevator_rounded,
                                            size: 34,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '4 ตัว',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(width: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(Icons.local_parking_rounded, size: 34),
                                  Text(
                                    '3 ที่จอด',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // FilledButton.icon(
                          //   onPressed: () {
                          //     // TODO: ใส่การนำทางไปยังสถานที่นี้
                          //   },
                          //   icon: const Icon(Icons.directions),
                          //   label: const Text('นำทางไปที่นี่'),
                          // ),
                          // const SizedBox(height: 12),
                          // OutlinedButton.icon(
                          //   onPressed: () {}, // TODO: โทร/ดูข้อมูลเพิ่ม
                          //   icon: const Icon(Icons.info_outline),
                          //   label: const Text('ข้อมูลเพิ่มเติม'),
                          // ),
                          // const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "ชั้น 1",
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Color(
                                                  0xFF01CE55,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                              onPressed: () {},
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.navigation_rounded,
                                                  ),
                                                  Text(
                                                    "นำทาง",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                              onPressed: () {},
                                              child: Text(
                                                "รีวิว",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 200, // ความสูงของ slider
                                      margin: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.black12,
                                      ),
                                      child: PageView(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              "https://cdn.pixabay.com/photo/2016/07/26/10/51/toilet-1542514_1280.jpg",
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              "https://cdn.pixabay.com/photo/2014/02/13/11/47/wc-265275_1280.jpg",
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              "https://cdn.pixabay.com/photo/2016/02/19/19/13/wc-1210963_1280.jpg",
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'รีวิว',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            3,
                            (i) => const ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text('ผู้ใช้'),
                              subtitle: Text('สถานที่เข้าถึงรถเข็นได้ สะดวกดี'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(14.0711, 100.6031),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(14.0689791, 100.6059037),
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        _showPlaceSheet(
                          title: 'คณะวิศวกรรมศาสตร์ มธ.',
                          subtitle: 'มหาวิทยาลัยธรรมศาสตร์ ศูนย์รังสิต',
                          description:
                              'สิ่งอำนวยความสะดวก: ทางลาด, ลิฟต์, ห้องน้ำผู้ใช้รถเข็น.\nเวลาเปิด-ปิด: 08:00–20:00.\nคำอธิบายเพิ่มเติม...',
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          "https://engr.tu.ac.th/uploads/identity/Main_Logo.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 👇 ปุ่มย้อนกลับ
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: onBack, // 👈 สลับแท็บกลับไปหน้า Home
              ),
            ),
          ),
        ],
      ),
    );
  }
}

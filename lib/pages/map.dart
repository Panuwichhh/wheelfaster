import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wheelfaster/action/navigate_wheelchair.dart';
import 'package:wheelfaster/action/routeStepsSheet.dart';
import 'package:wheelfaster/component/filter_sheet.dart';
import 'package:wheelfaster/component/map_type_sheet.dart';
import 'package:wheelfaster/component/marker.dart';
import 'package:wheelfaster/component/place_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wheelfaster/widgets/bouncy_on_tap.dart';
import '../controllers/map_controller.dart';

class AllMap extends StatefulWidget {
  const AllMap({super.key});

  @override
  State<AllMap> createState() => _AllMapState();
}

class _AllMapState extends State<AllMap> {
  final String orsApiKey = dotenv.env['ORS_API_KEY'] ?? '';

  Stream<QuerySnapshot> _placesStream() {
    final c = context.watch<MyMapController>();
    final selectedType = c.selectedTypeKey; // ใช้ค่าจาก controller
    final col = FirebaseFirestore.instance.collection('place_amenities');
    if (selectedType == 'ALL') {
      return col.snapshots();
    }
    final typeRef = FirebaseFirestore.instance.doc(
      'amenity_types/${selectedType.toUpperCase()}',
    );
    return col.where('type', isEqualTo: typeRef).snapshots();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MyMapController>();
    final tileUrl = c.tileUrl;
    final mapType = c.mapType;
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(14.0711, 100.6041),
          initialZoom: 16,
          // minZoom: 14,
          // maxZoom: 18,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all, // เปิดให้ซูม/แพน/หมุนได้
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: tileUrl, // ใช้ urlTemplate จาก controller
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          StreamBuilder(
            stream: _placesStream(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Debug
              print("Docs count: ${snapshot.data!.docs.length}");
              for (var doc in snapshot.data!.docs) {
                print("Doc ID: ${doc.id}, Data: ${doc.data()}");
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No data found"));
              }

              return MarkerLayer(
                markers: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final loc = data['location'];
                  double lat = 0, lng = 0;
                  if (loc is List) {
                    if (loc.isNotEmpty) lat = (loc[0] as num).toDouble();
                    if (loc.length > 1) lng = (loc[1] as num).toDouble();
                  } else if (loc is GeoPoint) {
                    lat = loc.latitude;
                    lng = loc.longitude;
                  }

                  // Debug Type Ref
                  final typeRef = data['type'];
                  print("Type Ref: $typeRef");
                  final String typeId = (typeRef is DocumentReference)
                      ? typeRef.id
                      : 'UNKNOWN';
                  print(" Type ID: $typeId");

                  final key = typeId.trim().toUpperCase();
                  final placeRef = FirebaseFirestore.instance
                      .collection('place_amenities')
                      .doc(doc.id);

                  final placeName = data['name'] ?? 'ไม่มีชื่อ';
                  final placeDesc = data['description'] ?? '';

                  final Map<String, Map<String, dynamic>> typeConfig = {
                    'TOILET': {
                      'color': Colors.green,
                      'icon': Icons.accessible_rounded,
                    },
                    'PARKING': {
                      'color': Colors.blue,
                      'icon': Icons.local_parking,
                    },
                    'ELEVATOR': {
                      'color': Colors.orange,
                      'icon': Icons.elevator,
                    },
                    'RAMP': {
                      'color': Colors.purple,
                      'icon': Icons.accessible_forward,
                    },
                  };
                  final selectedConfig =
                      typeConfig[key] ??
                      {'color': Colors.grey, 'icon': Icons.location_on};

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 100,
                    height: 100,
                    alignment: Alignment.topCenter,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        // value จะวิ่งจาก 0.0 → 1.0 (linear)
                        final opacity = value;
                        final scale = Tween<double>(
                          begin: 0.8,
                          end: 1.0,
                        ).transform(Curves.easeOutBack.transform(value));
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(opacity: opacity, child: child),
                        );
                      },
                      child: BouncyOnTap(
                        onTap: () {
                          showPlaceSheet(
                            context,
                            title: placeName,
                            placeRef: placeRef,
                            description: placeDesc,
                            images: const [
                              'https://preview.redd.it/68birnfq82701.png?width=320&crop=smart&auto=webp&s=0aabfe14ddd96ab5c511a2f4804c4353e5099b0f',
                              'https://preview.redd.it/68birnfq82701.png?width=320&crop=smart&auto=webp&s=0aabfe14ddd96ab5c511a2f4804c4353e5099b0f',
                            ],
                            // toilets: 2,
                            // elevators: 1,
                            // parkings: 10,
                            onNavigate: () {
                              navigateToPlaceWheelchair(
                                context,
                                placeRef: placeRef,
                                orsApiKey: orsApiKey, // ส่ง API key ตรงนี้
                                showStepsSheet: true,
                              );
                            },
                            onReview: () {},
                          );
                        },
                        child: LabelMarker(
                          circleColor: selectedConfig['color'],
                          icon: Icon(
                            selectedConfig['icon'],
                            size: 28,
                            color: Colors.black87,
                          ),
                          title: placeName,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ปุ่ม Filter
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    await showFilterOptionsSheet(
                      context,
                      onPick: (key) {
                        context.read<MyMapController>().setFilter(key);
                      },
                    );
                  },
                  child: const Icon(Icons.filter_list, color: Colors.black),
                ),

                const SizedBox(height: 16),

                // ปุ่มสลับ Map Type
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.layers, color: Colors.black),
                  onPressed: () async {
                    final chosen = await showMapTypeSheet(
                      context: context,
                      current: mapType,
                      onSelected: c.setMapType, // อัปเดตทันทีเมื่อแตะรายการ
                    );

                    // ถ้าอยากอัปเดตเฉพาะตอนปิด sheet ก็ทำแบบนี้แทน:
                    // if (chosen != null) c.setMapType(chosen);
                  },
                ),
                const SizedBox(height: 16),
                // ปุ่มหยุดเดินทาง (แสดงเมื่อมีเส้นทาง)
                if (c.routePoints.isNotEmpty)
                  FloatingActionButton(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) =>
                            const RouteStepsSheet(), // <-- เรียกใช้ widget ที่เราแยกไว้
                      );
                    },
                    child: const Icon(
                      Icons.list,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    tooltip: 'ดูเส้นทางนำทาง',
                  ),
              ],
            ),
          ),
          if (c.routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: c.routePoints,
                  strokeWidth: 6,
                  color: const Color.fromARGB(
                    255,
                    29,
                    108,
                    255,
                  ), // เปลี่ยนสีตรงนี้
                ),
              ],
            ),
        ],
      ),
    );
  }
}

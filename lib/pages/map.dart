import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wheelfaster/action/navigate_wheelchair.dart';
import 'package:wheelfaster/action/route_steps_sheet.dart';
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
  late MapController _flutterMapController;

  Stream<QuerySnapshot> _placesStream() {
    final c = context.watch<MyMapController>();
    final selectedType = c.selectedTypeKey; // ใช้ค่าจาก controller
    final col = FirebaseFirestore.instance.collection('place_amenities');
    final placeCol = FirebaseFirestore.instance.collection('places');

    // แสดงทั้งหมดจาก place_amenities
    if (selectedType == 'ALL') {
      return col.snapshots();
    }

    // ถ้าเลือกเป็น PLACES ให้ดึงจาก collection 'places'
    if (selectedType == 'PLACES') {
      return placeCol.snapshots();
    }

    // กรณีเป็น amenity type อื่นๆ ให้กรองจาก field 'type' ใน place_amenities
    final typeRef = FirebaseFirestore.instance.doc(
      'amenity_types/${selectedType.toUpperCase()}',
    );
    return col.where('type', isEqualTo: typeRef).snapshots();
  }

  @override
  void initState() {
    super.initState();
    _flutterMapController = MapController();
    context.read<MyMapController>().setMapController(_flutterMapController);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MyMapController>();
    final tileUrl = c.tileUrl;
    final mapType = c.mapType;
    return Scaffold(
      body: FlutterMap(
        mapController: _flutterMapController,
        options: MapOptions(
          initialCenter: LatLng(14.0711, 100.6041),
          initialZoom: 16,
          minZoom: 14,
          maxZoom: 18,
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
                  //print("Type Ref: $typeRef");
                  final String typeId =
                      (typeRef is DocumentReference) ? typeRef.id : 'UNKNOWN';
                  // print(" Type ID: $typeId");

                  final key = typeId.trim().toUpperCase();
                  final selectedType = c.selectedTypeKey;
                  final placeRef = FirebaseFirestore.instance
                      .collection(
                        selectedType == 'PLACES' ? 'places' : 'place_amenities',
                      )
                      .doc(doc.id);

                  // print("Place Ref: ${placeRef.path} $selectedType");

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
                      'color': const Color.fromRGBO(156, 39, 176, 1),
                      'icon': Icons.accessible_forward,
                    },
                  };
                  final selectedConfig = typeConfig[key] ??
                      {
                        'color': const Color.fromARGB(255, 0, 0, 0),
                        'icon': Icons.location_city,
                      };

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
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
                          // อ่าน rawImages ที่อาจจะเป็น String (url เดี่ยว), List หรือ Map
                          final rawImages = data['images'];

                          // Normalize เป็น List<String>
                          final images = <String>[];
                          if (rawImages == null) {
                            // keep empty
                          } else if (rawImages is String) {
                            if (rawImages.startsWith('http'))
                              images.add(rawImages);
                          } else if (rawImages is List) {
                            for (final e in rawImages) {
                              if (e == null) continue;
                              if (e is String && e.startsWith('http')) {
                                images.add(e);
                              } else if (e is Map &&
                                  (e['url'] != null || e['src'] != null)) {
                                final url = (e['url'] ?? e['src']).toString();
                                if (url.startsWith('http')) images.add(url);
                              }
                            }
                          } else if (rawImages is Map) {
                            final url = (rawImages['url'] ?? rawImages['src'])
                                ?.toString();
                            if (url != null && url.startsWith('http'))
                              images.add(url);
                          }

                          debugPrint('Normalized images: $images');

                          final toilets = (data['toilets'] is num)
                              ? (data['toilets'] as num).toInt()
                              : null;
                          final elevators = (data['elevators'] is num)
                              ? (data['elevators'] as num).toInt()
                              : null;
                          final parkings = (data['parkings'] is num)
                              ? (data['parkings'] as num).toInt()
                              : null;

                          final name = data['name']?.toString() ?? placeName;
                          final desc =
                              data['description']?.toString() ?? placeDesc;

                          final floorData = data['floor'];
                          final String? floor =
                              (floorData is String) ? floorData : null;

                          final rawAmenityRefs = data['place_amenities'];
                          final List<dynamic>? amenityRefs =
                              (rawAmenityRefs is List) ? rawAmenityRefs : null;

                          showPlaceSheet(
                            context,
                            title: name,
                            placeRef: placeRef,
                            description: desc,
                            images: images,
                            toilets: toilets,
                            elevators: elevators,
                            parkings: parkings,
                            floor: floor,
                            amenityRefs: amenityRefs,
                            onNavigate: () {
                              Navigator.pop(context);
                              navigateToPlaceWheelchair(
                                context,
                                placeRef: placeRef,
                                orsApiKey: orsApiKey,
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
                            color: selectedConfig['icon'] == Icons.location_city
                                ? Colors.white
                                : Colors.black,
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
                    backgroundColor: const Color.fromARGB(255, 0, 190, 57),
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
                      color: Color.fromARGB(255, 255, 255, 255),
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

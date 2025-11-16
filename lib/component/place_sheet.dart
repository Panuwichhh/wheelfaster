// lib/component/place_sheet.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheelfaster/component/auth/login_modal.dart';
import 'package:wheelfaster/component/ReviewsModal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wheelfaster/component/reviews_list.dart';

class PlaceSheet extends StatelessWidget {
  final String title;
  final DocumentReference<Map<String, dynamic>> placeRef;
  final String description;
  final List<dynamic> images;
  final int? toilets;
  final int? elevators;
  final int? parkings;
  final List<dynamic>? amenityRefs;
  final String? floor; // ⭐️ เพิ่ม field 'floor'

  final VoidCallback? onReview;
  final VoidCallback? onNavigate;

  const PlaceSheet({
    super.key,
    required this.title,
    required this.placeRef,
    required this.description,
    this.images = const [],
    this.toilets,
    this.elevators,
    this.parkings,
    this.amenityRefs,
    this.floor, // ⭐️ เพิ่ม 'floor' ใน constructor
    this.onReview,
    this.onNavigate,
  });

  // ⭐️ เพิ่ม helper functions สำหรับ Image.network ที่หายไป
  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    // final user = FirebaseAuth.instance.currentUser;

    return DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.18,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.28, 0.55, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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

              // Header
              ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 32,
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                // ⭐️ แก้ไข subtitle ให้แสดง 'floor' (ถ้ามี)
                subtitle: Text(
                  (floor != null && floor!.isNotEmpty)
                      ? 'ชั้น $floor'
                      : description, // ถ้าไม่มี floor ก็แสดง description แทน
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    // ... (ส่วนแสดง toilets, elevators, parkings ... เหมือนเดิม)
                    if (toilets != null ||
                        elevators != null ||
                        parkings != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (toilets != null)
                                Row(
                                  children: [
                                    const Icon(Icons.accessible, size: 34),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$toilets ห้องน้ำ',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              if (elevators != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.elevator_rounded,
                                      size: 34,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$elevators ตัว',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          if (parkings != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.local_parking_rounded,
                                  size: 34,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$parkings ที่จอด',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    Text(
                      description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),

                    // Action row (navigate + review)
                    if (onReview != null || onNavigate != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ⭐️ แทนที่ '###' ด้วย 'floor' (แบบ Null-safe)
                          Builder(
                            builder: (context) {
                              final localFloor = floor; // สร้าง local var
                              return (localFloor != null)
                                  ? Text(
                                      'ชั้น $localFloor',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : const SizedBox.shrink(); // ถ้าไม่มี floor ก็ไม่ต้องแสดง
                            },
                          ),

                          Row(
                            // ... (ปุ่ม Logout, นำทาง, รีวิว ... เหมือนเดิม)
                            children: [
                              if (onNavigate != null) ...[
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF01CE55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: onNavigate,
                                  icon: const Icon(Icons.navigation_rounded),
                                  label: const Text(
                                    "นำทาง",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              if (onReview != null) ...[
                                const SizedBox(width: 8),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () {
                                    showReviewModal(
                                      context,
                                      placeRef: placeRef,
                                    );
                                  },
                                  child: const Text(
                                    "รีวิว",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    if (images.isNotEmpty)
                      Builder(
                        builder: (ctx) {
                          // Normalize images -> List<String> urls
                          final imageUrls = images
                              .map<String?>((e) {
                                if (e == null) return null;
                                if (e is String) {
                                  return e.startsWith('http') ? e : null;
                                }
                                if (e is Map) {
                                  if (e['url'] != null)
                                    return e['url'].toString();
                                  if (e['src'] != null)
                                    return e['src'].toString();
                                }
                                return null;
                              })
                              .whereType<String>()
                              .toList();

                          if (imageUrls.isEmpty) return const SizedBox.shrink();

                          return Container(
                            height: 200,
                            // 1. ⭐️ (แนะนำ) ลบ margin ออกจาก Container...
                            // margin: const EdgeInsets.all(16),

                            // 2. ⭐️ (แนะนำ) ลบ decoration ออกจาก Container
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(12),
                            //   color: Colors.black12,
                            // ),

                            // 3. ⭐️ เปลี่ยน child เป็น ListView.builder
                            child: ListView.builder(
                              // 4. ⭐️ กำหนดให้เลื่อนแนวนอน
                              scrollDirection: Axis.horizontal,

                              // 5. ⭐️ ย้าย padding มาไว้ที่นี่ (เพื่อให้เลื่อนได้ถึงขอบ)
                              padding: const EdgeInsets.all(16.0),

                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                final url = imageUrls[index];

                                // 6. ⭐️ เพิ่ม Padding "ระหว่าง" รูปภาพ
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10.0,
                                  ), // <-- ระยะห่างระหว่างรูป
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,

                                      // 7. ⭐️ (สำคัญมาก) ต้องกำหนดความกว้าง!!
                                      width:
                                          300, // <-- ปรับความกว้างของรูปได้ตามต้องการ

                                      loadingBuilder: _loadingBuilder,
                                      errorBuilder: _errorBuilder,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                    // ⭐️ ส่วนแสดง `amenityRefs` (สิ่งอำนวยความสะดวก)
                    Builder(
                      builder: (context) {
                        final refs = amenityRefs;
                        if (refs == null || refs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'สิ่งอำนวยความสะดวก',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...refs.map((ref) {
                              if (ref is DocumentReference) {
                                return FutureBuilder<DocumentSnapshot>(
                                  future: ref.get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const ListTile(
                                        leading: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        title: Text(
                                          'กำลังโหลด...',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        dense: true,
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return const ListTile(
                                        leading: Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          'ไม่สามารถโหลดข้อมูลได้',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        dense: true,
                                      );
                                    }
                                    if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return const ListTile(
                                        leading: Icon(
                                          Icons.help_outline,
                                          color: Colors.orange,
                                        ),
                                        title: Text('ไม่พบข้อมูลอ้างอิง'),
                                        dense: true,
                                      );
                                    }

                                    // --- ⭐️ เริ่มดึงข้อมูล Amenity ---
                                    final data =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;
                                    final name = data['name'] ?? 'ไม่มีชื่อ';
                                    final floor = data['floor'] ?? '';

                                    // 1. ดึงข้อมูลรูปภาพ (‼️ เช็คชื่อ field 'images' หรือ 'url_image' ให้ถูก)
                                    final rawImages = data['images'];

                                    // 2. Normalize รูปภาพ
                                    final amenityImages = <String>[];
                                    if (rawImages == null) {
                                      // keep empty
                                    } else if (rawImages is String) {
                                      if (rawImages.startsWith('http'))
                                        amenityImages.add(rawImages);
                                    } else if (rawImages is List) {
                                      for (final e in rawImages) {
                                        if (e == null) continue;
                                        if (e is String &&
                                            e.startsWith('http')) {
                                          amenityImages.add(e);
                                        } else if (e is Map &&
                                            (e['url'] != null ||
                                                e['src'] != null)) {
                                          final url = (e['url'] ?? e['src'])
                                              .toString();
                                          if (url.startsWith('http'))
                                            amenityImages.add(url);
                                        }
                                      }
                                    } else if (rawImages is Map) {
                                      final url =
                                          (rawImages['url'] ?? rawImages['src'])
                                              ?.toString();
                                      if (url != null && url.startsWith('http'))
                                        amenityImages.add(url);
                                    }

                                    // 3. คืนค่าเป็น Column (ชื่อ + รูป List แนวนอน)
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                floor != null
                                                    ? '  ชั้น $floor'
                                                    : '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 4. ⭐️ แสดง Horizontal ListView (ตามที่ขอ)
                                        if (amenityImages.isNotEmpty)
                                          Container(
                                            height: 150,
                                            margin: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: amenityImages.length,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                  ),
                                              itemBuilder: (context, index) {
                                                final url =
                                                    amenityImages[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 8.0,
                                                      ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.0,
                                                        ),
                                                    child: Image.network(
                                                      url,
                                                      width: 250,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder:
                                                          _loadingBuilder,
                                                      errorBuilder:
                                                          _errorBuilder,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                        const Divider(
                                          indent: 16,
                                          endIndent: 16,
                                          height: 24,
                                        ), // เส้นคั่น
                                      ],
                                    );
                                    // --- ⭐️ สิ้นสุดส่วน Amenity ---
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            }).toList(),
                          ],
                        );
                      },
                    ),

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(description),
                    ],

                    const SizedBox(height: 8),
                    const Text(
                      'รีวิว',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ReviewsList(placeRef: placeRef),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// helper function
Future<void> showPlaceSheet(
  BuildContext context, {
  required String title,
  required DocumentReference<Map<String, dynamic>> placeRef,
  required String description,
  List<dynamic> images = const [],
  int? toilets,
  int? elevators,
  int? parkings,

  // ⭐️ 6. เพิ่ม `floor` และ `amenityRefs` ที่ขาดไป
  String? floor,
  List<dynamic>? amenityRefs,

  VoidCallback? onReview,
  VoidCallback? onNavigate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PlaceSheet(
      title: title,
      placeRef: placeRef,
      description: description,
      images: images,
      toilets: toilets,
      elevators: elevators,
      parkings: parkings,

      // ⭐️ 7. ส่งค่า `floor` และ `amenityRefs`
      floor: floor,
      amenityRefs: amenityRefs,

      onReview: onReview,
      onNavigate: onNavigate,
    ),
  );
}

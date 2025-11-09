// lib/component/place_sheet.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheelfaster/component/auth/login_modal.dart';
import 'package:wheelfaster/component/reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wheelfaster/component/reviews_list.dart';

class PlaceSheet extends StatelessWidget {
  final String title;
  final DocumentReference<Map<String, dynamic>> placeRef; // ✅ ระบุ generic
  final String description;
  final List<String> images;
  final int? toilets;
  final int? elevators;
  final int? parkings;
  final VoidCallback? onReview;
  final VoidCallback? onNavigate;

  const PlaceSheet({
    super.key,
    required this.title,
    required this.placeRef, // ✅ ใช้ตัวนี้ต่อให้ทั่วไฟล์
    required this.description,
    this.images = const [],
    this.toilets,
    this.elevators,
    this.parkings,
    this.onReview,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final user = FirebaseAuth.instance.currentUser;

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
                subtitle: Text(
                  title,
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
                      const SizedBox(height: 16),
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
                          const Text("###", style: TextStyle(fontSize: 24)),
                          Row(
                            children: [
                              if (user != null)
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("ออกจากระบบเรียบร้อย"),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Logout"),
                                ),
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
                                  onPressed: () async {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user == null) {
                                      showDialog(
                                        context: context,
                                        builder: (_) => LoginModal(
                                          onLoginSuccess: () {
                                            Navigator.pop(context);
                                            showReviewModal(context, (
                                              rating,
                                              comment,
                                            ) {
                                              // รับค่าจากรีวิว
                                            });
                                          },
                                        ),
                                      );
                                    } else {
                                      showReviewModal(context, (
                                        rating,
                                        comment,
                                      ) {
                                        // รับค่าจากรีวิว
                                      });
                                    }
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
                      Container(
                        height: 200,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black12,
                        ),
                        child: PageView(
                          children: images.map((url) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          }).toList(),
                        ),
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

                    // ReviewsList ควรตั้งค่า shrinkWrap/physics ภายใน เพื่อลด ListView ซ้อนกันพัง
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
  required DocumentReference<Map<String, dynamic>> placeRef, // ✅ ระบุ generic
  required String description,
  List<String> images = const [],
  int? toilets,
  int? elevators,
  int? parkings,
  VoidCallback? onReview,
  VoidCallback? onNavigate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PlaceSheet(
      title: title,
      placeRef: placeRef, // ✅ ชนิดตรง
      description: description,
      images: images,
      toilets: toilets,
      elevators: elevators,
      parkings: parkings,
      onReview: onReview,
      onNavigate: onNavigate,
    ),
  );
}

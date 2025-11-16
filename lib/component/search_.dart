import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheelfaster/action/navigate_wheelchair.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wheelfaster/controllers/map_controller.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:wheelfaster/extension.dart';

void showSearchSheet(BuildContext context) {
  final String orsApiKey = dotenv.env['ORS_API_KEY'] ?? '';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color.fromARGB(0, 13, 13, 13),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration:  BoxDecoration(
            color: context.onBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: context.onText,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'เลือกสถานที่ปลายทาง',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('places')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name']?.toString() ?? '';
                        final desc = data['description']?.toString() ?? '';
                        final placeRef = FirebaseFirestore.instance
                            .collection('places')
                            .doc(doc.id);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 211, 211, 211),
                            child: const Icon(
                              Icons.location_on,
                              color: Color.fromARGB(255, 26, 156, 0),
                            ),
                          ),
                          title: Text(name),
                          textColor: context.onText,
                          subtitle: Text(
                            desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            Navigator.pop(context);

                            try {
                              final placeDoc = await placeRef.get();
                              if (placeDoc.exists) {
                                final placeData = placeDoc.data() ?? {};
                                final location = placeData['location'];

                                double lat = 0, lng = 0;
                                if (location is GeoPoint) {
                                  lat = location.latitude;
                                  lng = location.longitude;
                                } else if (location is List &&
                                    location.length >= 2) {
                                  lat = (location[0] as num).toDouble();
                                  lng = (location[1] as num).toDouble();
                                }

                                // เลื่อนแผนที่ไปยังตำแหน่ง
                                if (context.mounted) {
                                  final mapController = context
                                      .read<MyMapController>();
                                  mapController.simpleMove(
                                    LatLng(lat, lng),
                                    20.0,
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('Error fetching location: $e');
                            }

                            // เริ่มการนำทาง
                            if (context.mounted) {
                              navigateToPlaceWheelchair(
                                context,
                                placeRef: placeRef,
                                orsApiKey: orsApiKey,
                                showStepsSheet: true,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

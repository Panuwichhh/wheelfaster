import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheelfaster/component/place_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wheelfaster/action/navigate_wheelchair.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void showSearchSheet(BuildContext context) {
  final String orsApiKey = dotenv.env['ORS_API_KEY'] ?? '';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
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

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'เลือกสถานที่ปลายทาง',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              // Results list
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
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.location_on),
                          ),
                          title: Text(name),
                          subtitle: Text(
                            desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            navigateToPlaceWheelchair(
                              context,
                              placeRef: placeRef,
                              orsApiKey: orsApiKey,
                              showStepsSheet: true,
                            );
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

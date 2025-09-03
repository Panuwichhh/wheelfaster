import 'package:flutter/material.dart';

Future<void> showPlaceSearchSheet(BuildContext context) {
  final TextEditingController searchCtrl = TextEditingController();
  final all = <String>[
    "คณะวิศวกรรมศาสตร์",
    "ตึกวิจัยวิศวกรรมศาสตร์",
    "SC",
    "หอสมุด",
    "โรงอาหารกลาง",
  ];
  var results = List<String>.from(all);

  void filter(String q) {
    results = all
        .where((e) => e.toLowerCase().contains(q.toLowerCase()))
        .toList();
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.3, 0.6, 0.9],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🔥 แถวหัว + ปุ่มปิด
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "ค้นหาสถานที่",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: (q) => setState(() => filter(q)),
                        decoration: InputDecoration(
                          hintText: "ค้นหาสถานที่...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.mic_none),
                            onPressed: () {
                              // TODO: speech_to_text
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Results
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: results.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(results[i]),
                          onTap: () => Navigator.pop(context, results[i]),
                        ),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

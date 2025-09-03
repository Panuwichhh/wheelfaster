import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:wheelfaster/component/search_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../component/bottom_nav.dart';
import 'mappage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedTab = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _buildHomePage(), // index 0
      const SizedBox(), // index 1 (ไม่ใช้หน้า แค่ดักกดเพื่อเปิด popup)
      MapPage(
        // index 2
        onBack: () => setState(() => _selectedTab = 0),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01CE55),
      body: _pages[_selectedTab],
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedTab,
        onTap: (index) async {
          if (index == 1) {
            // 1) ไปหน้าแผนที่ก่อน (index 2)
            setState(() => _selectedTab = 2);

            // 2) รอให้หน้า map build เสร็จ แล้วค่อยเปิด popup
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              await showPlaceSearchSheet(context);
            });
            return; // ไม่ต้องตั้ง _selectedTab = 1
          }
          setState(() => _selectedTab = index);
        },
      ),
    );
  }

  // ---------------- Popup Search ----------------
  // Future<void> _openSearchPopup(BuildContext context) {
  //   return showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) {
  //       return DraggableScrollableSheet(
  //         initialChildSize: 0.3,
  //         minChildSize: 0.2,
  //         maxChildSize: 0.9,
  //         snap: true,
  //         snapSizes: const [0.3, 0.6, 0.9],
  //         builder: (context, scrollController) {
  //           return Container(
  //             decoration: const BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //             ),
  //             child: Column(
  //               children: [
  //                 const SizedBox(height: 8),
  //                 Container(
  //                   width: 40,
  //                   height: 5,
  //                   decoration: BoxDecoration(
  //                     color: Colors.black26,
  //                     borderRadius: BorderRadius.circular(3),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),

  //                 // Search bar
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 12),
  //                   child: TextField(
  //                     controller: _searchCtrl,
  //                     onChanged: _filter,
  //                     decoration: InputDecoration(
  //                       hintText: "ค้นหาสถานที่...",
  //                       prefixIcon: const Icon(Icons.search),
  //                       suffixIcon: IconButton(
  //                         icon: const Icon(Icons.mic_none),
  //                         onPressed: () {},
  //                       ),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(16),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),

  //                 // Results
  //                 Expanded(
  //                   child: ListView.separated(
  //                     controller: scrollController,
  //                     itemCount: _results.length,
  //                     itemBuilder: (_, i) => ListTile(
  //                       title: Text(_results[i]),
  //                       onTap: () {
  //                         Navigator.pop(context, _results[i]); // ปิด popup
  //                         // TODO: โยนค่าไปโฟกัสแผนที่/ค้นหาเส้นทางต่อได้
  //                       },
  //                     ),
  //                     separatorBuilder: (_, __) =>
  //                         const Divider(height: 1, thickness: 1),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // void _filter(String q) {
  //   setState(() {
  //     _results = _allPlaces
  //         .where((p) => p.toLowerCase().contains(q.toLowerCase()))
  //         .toList();
  //   });
  // }

  // ---------------- หน้าแรก (Home Page) ----------------
  Widget _buildHomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Logo
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.accessible_forward_rounded,
                    size: 60,
                    color: Colors.black,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Wheel Faster",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final GlobalKey<SlideActionState> key = GlobalKey();
                        return SlideAction(
                          key: key,
                          text: 'Slide To SOS!!!',
                          innerColor: const Color(0xFFFF3B30),
                          outerColor: const Color(0xFF2C2C2E),
                          textStyle: const TextStyle(color: Colors.white),
                          onSubmit: () async {
                            final uri = Uri(
                              scheme: 'tel',
                              path: '1669',
                            ); // หมายเลขฉุกเฉิน
                            final ok = await canLaunchUrl(uri);
                            if (ok) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              // เผื่อกรณีเปิดโทรศัพท์ไม่ได้
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ไม่สามารถเปิดโทรศัพท์ได้'),
                                  ),
                                );
                              }
                            }

                            // รีเซ็ตสไลด์ให้พร้อมใช้รอบต่อไป
                            key.currentState?.reset();
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildGridButton(Icons.wc, "Toilet", () {}),
                          _buildGridButton(
                            Icons.accessible,
                            "Wheelchair Ramp",
                            () {},
                          ),
                          _buildGridButton(Icons.elevator, "Elevator", () {}),
                          _buildGridButton(
                            Icons.local_parking,
                            "Disabled Parking",
                            () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        side: const BorderSide(color: Color(0xFF01CE55), width: 1),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

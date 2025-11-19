import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheelfaster/controllers/map_controller.dart';
import 'package:wheelfaster/extension.dart';
import 'package:wheelfaster/notifier/notifier.dart';
import 'package:wheelfaster/pages/map.dart';
import 'package:wheelfaster/component/bottom_nav.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF01CE55),
    body: Stack(
      children: [
        // --- หน้าหลักของแท็บ ---
        IndexedStack(
          index: _selectedTab,
          children: [
            _buildHomePage(),
            const SizedBox(),
            const AllMap(),
          ],
        ),

        // --- ปุ่ม Toggle Dark/Light ---
        Positioned(
          top: 50,
          right: 16,
          child: GestureDetector(
            onTap: () {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
                final c = context.read<MyMapController>();
                c.setMapType(isDarkModeNotifier.value ? "dark" : "light");
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDark, _) {
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),

    bottomNavigationBar: AppBottomNavigationBar(
      selectedIndex: _selectedTab,
      onTap: (index) async {
        if (index == 1) {
          setState(() => _selectedTab = 2);
        } else {
          setState(() => _selectedTab = index);
        }
      },
    ),
  );
}
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
                decoration: BoxDecoration(
                  color: context.onBlock,
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
                          textStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                          innerColor: const Color(0xFFFF3B30),
                          outerColor: const Color.fromARGB(255, 255, 255, 255),
                          elevation: 2,
                          onSubmit: () async {
                            final uri = Uri(scheme: 'tel', path: '1669');
                            final ok = await canLaunchUrl(uri);
                            if (ok) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ไม่สามารถเปิดโทรศัพท์ได้'),
                                  ),
                                );
                              }
                            }
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
                          _buildGridButton(Icons.wc, "Toilet", () {
                            context.read<MyMapController>().setFilter('toilet');
                            setState(() => _selectedTab = 2);
                          }),
                          _buildGridButton(
                            Icons.accessible,
                            "Wheelchair Ramp",
                            () {
                              context.read<MyMapController>().setFilter('ramp');
                              setState(() => _selectedTab = 2);
                            },
                          ),
                          _buildGridButton(Icons.elevator, "Elevator", () {
                            context.read<MyMapController>().setFilter(
                              'elevator',
                            );
                            setState(() => _selectedTab = 2);
                          }),
                          _buildGridButton(
                            Icons.local_parking,
                            "Disabled Parking",
                            () {
                              context.read<MyMapController>().setFilter(
                                'PARKING',
                              );
                              setState(() => _selectedTab = 2);
                            },
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
  return Builder(
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.onBlock2, 
          foregroundColor: context.onText,
          side: BorderSide(color: context.onRoot, width: 1),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: scheme.onSurface), // ใช้ onSurface
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface, // ตัวอักษรเปลี่ยนตาม theme
              ),
            ),
          ],
        ),
      );
    },
  );
 }
}
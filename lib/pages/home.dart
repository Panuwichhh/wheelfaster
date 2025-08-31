import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'bottom_nav.dart';
import 'mappage.dart'; // 👈 import หน้าแมพเข้ามา

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
      const MapPage(), // index 1
      const Center(child: Text("Profile Page")), // index 2
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
    );
  }

  // ---------------- หน้าแรก (Home Page) ----------------
  Widget _buildHomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Logo
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: const [
                  Icon(Icons.wheelchair_pickup, size: 60, color: Colors.green),
                  SizedBox(height: 8),
                  Text(
                    "Wheel Faster",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // SOS Slider
            Builder(
              builder: (context) {
                final GlobalKey<SlideActionState> key = GlobalKey();
                return SlideAction(
                  key: key,
                  text: 'Slide To SOS!!!',
                  innerColor: Colors.red,
                  outerColor: const Color.fromARGB(255, 214, 214, 214),
                  onSubmit: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SOS Activated!')),
                    );
                    key.currentState!.reset();
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // Grid Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildGridButton(Icons.wc, "Toilet", () {
                    // Action Toilet
                  }),
                  _buildGridButton(Icons.accessible, "Wheelchair Ramp", () {
                    // Action Ramp
                  }),
                  _buildGridButton(Icons.elevator, "Elevator", () {
                    // Action Elevator
                  }),
                  _buildGridButton(Icons.local_parking, "Disabled Parking", () {
                    // Action Parking
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ปุ่มใน Grid ----------------
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
          Icon(icon, size: 40, color: const Color.fromARGB(255, 0, 0, 0)),
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

import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF01CE55),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),

            child: const Icon(
              Icons.search,
              size: 36, // 👈 ทำให้ปุ่มกลางใหญ่กว่า
            ),
          ),
          label: 'Search',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_sharp),
          label: 'Map',
        ),
      ],
    );
  }
}

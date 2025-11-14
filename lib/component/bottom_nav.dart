import 'package:flutter/material.dart';
import 'package:wheelfaster/component/search_.dart'; // Add this import

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
      onTap: (index) {
        if (index == 1) {
          onTap(2);
          showSearchSheet(context);
        } else {
          onTap(index);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF01CE55),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
      ],
    );
  }
}

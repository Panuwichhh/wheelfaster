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
      selectedItemColor: const Color(0xFF01CE55),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Color(0xFF01CE55)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, color: Color(0xFF01CE55)),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Color(0xFF01CE55)),
          label: 'Profile',
        ),
      ],
    );
  }
}

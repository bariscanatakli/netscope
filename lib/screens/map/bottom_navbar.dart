import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favorites",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Homepage",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: "Contribute",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Updates",
        ),
      ],
    );
  }
}

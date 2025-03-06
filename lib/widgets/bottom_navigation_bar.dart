import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      // type: BottomNavigationBarType.fixed,
      index: currentIndex,
      onTap: onTap,
      color: Colors.white,
      buttonBackgroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 200),
      items: const [
        CurvedNavigationBarItem(
          child: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.description_outlined),
          label: 'Quotations',
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.people_alt_outlined),
          label: 'Clients',
        ),
        CurvedNavigationBarItem(
          child: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }

}
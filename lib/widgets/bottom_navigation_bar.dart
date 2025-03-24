import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quotation/main.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GNav(
        selectedIndex: currentIndex,
        onTabChange: onTap,
        backgroundColor: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
        color: Colors.grey,
        activeColor: Colors.blue,
        tabBackgroundColor: Colors.blue.withOpacity(0.1),
        padding: const EdgeInsets.all(10),
        gap: 8,
        tabs: const [
          GButton(
            icon: Icons.home_outlined,
            text: "Home",
          ),
          GButton(
            icon: Icons.description_outlined,
            text: "Estimations",
          ),
          GButton(
            icon: Icons.people_alt_outlined,
            text: "Clients",
          ),
          GButton(
            icon: Icons.settings_outlined,
            text: "Settings",
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'package:ungal_kaavalan/screens/core_screens/home/home_screen.dart';
import 'package:ungal_kaavalan/screens/core_screens/info/info_screen.dart';
import 'package:ungal_kaavalan/screens/core_screens/settings/settings_screen.dart';
import 'profile/profile_screen.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  static final List<Widget> _screens = [
    HomeScreen(),
    ProfileScreen(),
    InfoScreen(),
    SettingsScreen(),
  ];
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavProvider);
    return Scaffold(
      body: _screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(bottomNavProvider.notifier).state = index,
        selectedItemColor: Colors.white, // Ensure selected icons are visible
        unselectedItemColor: Colors.white70, // Lighten unselected icons
        backgroundColor: Color(0xFF3674B5), // Match AppBar color
        type: BottomNavigationBarType.fixed, // Prevent shifting effect
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.info,
              size: 30,
            ),
            label: "Info",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: 30,
            ),
            label: "Settings",
          )
        ],
      ),
    );
  }
}

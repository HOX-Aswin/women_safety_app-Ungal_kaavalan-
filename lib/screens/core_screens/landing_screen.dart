import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'package:ungal_kaavalan/screens/core_screens/home_screen.dart';
import 'package:ungal_kaavalan/screens/core_screens/info_screen.dart';
import 'package:ungal_kaavalan/screens/core_screens/settings_screen.dart';
import 'profile_screen.dart';

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Info"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
        ],
      ),
    );
  }
}

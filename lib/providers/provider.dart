import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final genderProvider = StateProvider<String?>((ref) => null);

// Load stored UID from SharedPreferences
final uidProvider = StateNotifierProvider<UidNotifier, String?>((ref) {
  return UidNotifier();
});

class UidNotifier extends StateNotifier<String?> {
  UidNotifier() : super(null) {
    _loadUid();
  }

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('uid');
  }

  Future<void> setUid(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (uid != null) {
      await prefs.setString('uid', uid);
    } else {
      await prefs.remove('uid');
    }
    state = uid;
  }
}

// Load authentication state
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isAuthenticated') ?? false;
  }

  Future<void> setAuthState(bool isAuthenticated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', isAuthenticated);
    state = isAuthenticated;
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungal_kaavalan/models/user_model.dart';

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

final bottomNavProvider = StateProvider<int>((ref) => 0);

// Fetch user data
final userProvider = StreamProvider<UserModel?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null; // No user logged in

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!userDoc.exists) return null;

    return UserModel.fromFirestore(userDoc.data()!);
  });
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final uid = ref.watch(uidProvider);
  if (uid == null) return null;

  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if (userDoc.exists) {
    return userDoc.data() as Map<String, dynamic>;
  }
  return null;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final cabModeProvider = StateNotifierProvider<CabModeNotifier, Map<String, dynamic>?>(
  (ref) => CabModeNotifier(),
);

class CabModeNotifier extends StateNotifier<Map<String, dynamic>?> {
  CabModeNotifier() : super(null) {
    _loadRideFromPrefs();
  }

  /// Load ride data from SharedPreferences when app starts
  Future<void> _loadRideFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rideData = prefs.getString('rideDetails');
    if (rideData != null) {
      state = jsonDecode(rideData);
    }
  }

  /// Save ride details to SharedPreferences
  Future<void> _saveRideToPrefs(Map<String, dynamic> ride) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rideDetails', jsonEncode(ride));
  }

  /// Create or Edit Ride
  Future<void> saveRide(Map<String, dynamic> ride) async {
    state = ride;
    await _saveRideToPrefs(ride);
  }

  /// Start Ride
  Future<void> startRide() async {
    if (state != null) {
      state = {...state!, "status": "started"};
      await _saveRideToPrefs(state!);
    }
  }

  /// Stop Ride (Deletes ride details)
  Future<void> stopRide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rideDetails');
    state = null;
  }
}

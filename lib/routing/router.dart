import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'package:ungal_kaavalan/screens/core_screens/home/emergency_contact_screen.dart';
import 'package:ungal_kaavalan/screens/core_screens/landing_screen.dart';
import 'package:ungal_kaavalan/screens/auth_screens/login_screen.dart';
import 'package:ungal_kaavalan/screens/auth_screens/signup_screen.dart';

// Define Routes using GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authProvider);
  return GoRouter(
    initialLocation: isAuthenticated ? '/landing' : '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(path: '/landing', builder: (context, state) => LandingScreen()),
      GoRoute(path: '/emergencycontact', builder: (context, state) => EmergencyContactScreen()),
    ],
  );
});

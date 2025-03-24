import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'package:ungal_kaavalan/screens/home_screen.dart';
import 'package:ungal_kaavalan/screens/login_screen.dart';
import 'package:ungal_kaavalan/screens/signup_screen.dart';

// Define Routes using GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authProvider);
  return GoRouter(
    initialLocation: isAuthenticated ? '/home' : '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    ],
  );
});

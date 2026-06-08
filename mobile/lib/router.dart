import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/search_screen.dart';
import 'screens/player/player_screen.dart';
import 'screens/quran/quran_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/upload/upload_screen.dart';
import 'screens/profile/artist_verification_screen.dart';
import 'screens/profile/artist_stats_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = auth.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/role');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (ctx, _) => const LoginScreen()),
      GoRoute(path: '/role', builder: (ctx, _) => const RoleSelectionScreen()),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (ctx, _) => const HomeScreen()),
          GoRoute(path: '/search', builder: (ctx, _) => const SearchScreen()),
          GoRoute(path: '/quran', builder: (ctx, _) => const QuranScreen()),
          GoRoute(path: '/library', builder: (ctx, _) => const LibraryScreen()),
          GoRoute(path: '/profile', builder: (ctx, _) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/player', builder: (ctx, _) => const PlayerScreen()),
      GoRoute(path: '/upload', builder: (ctx, _) => const UploadScreen()),
      GoRoute(path: '/verification', builder: (ctx, _) => const ArtistVerificationScreen()),
      GoRoute(path: '/stats', builder: (ctx, _) => const ArtistStatsScreen()),
      GoRoute(
        path: '/artist/:id',
        builder: (ctx, state) => ArtistProfileScreen(artistId: state.pathParameters['id']!),
      ),
    ],
  );
});

// Placeholder until library screen is created
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(body: Center(child: Text('Library')));
  }
}

class ArtistProfileScreen extends StatelessWidget {
  final String artistId;
  const ArtistProfileScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artist')),
      body: Center(child: Text('Artist $artistId')),
    );
  }
}

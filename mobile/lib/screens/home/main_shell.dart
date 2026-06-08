import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/player_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mini_player.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/quran')) return 2;
    if (location.startsWith('/library')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final playerState = ref.watch(playerProvider);
    final hasPlayer = playerState.nasheed != null;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          if (hasPlayer) const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex(location),
          onTap: (i) {
            final routes = ['/home', '/search', '/quran', '/library', '/profile'];
            context.go(routes[i]);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Поиск'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Коран'),
            BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: 'Библиотека'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}

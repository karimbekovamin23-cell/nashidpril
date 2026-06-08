import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nasheed_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nasheed_tile.dart';
import '../../widgets/nasheed_cover.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final nasheedsAsync = ref.watch(nasheedsProvider('newest'));
    final popularAsync = ref.watch(nasheedsProvider('popular'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: Row(
              children: [
                const Icon(Icons.music_note_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text('NashidPril'),
                const Spacer(),
                if (user?.isVerifiedArtist == true)
                  TextButton.icon(
                    onPressed: () => context.push('/upload'),
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    label: const Text('Загрузить'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
              ],
            ),
          ),

          // Greeting
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (user != null)
                    Text(user.name, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Featured - Popular nasheeds horizontal scroll
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text('Популярное', style: Theme.of(context).textTheme.titleLarge),
                ),
                SizedBox(
                  height: 180,
                  child: popularAsync.when(
                    loading: () => _shimmerRow(),
                    error: (_, __) => const Center(child: Text('Ошибка загрузки')),
                    data: (nasheeds) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: nasheeds.take(10).length,
                      itemBuilder: (ctx, i) => _FeaturedCard(nasheed: nasheeds[i], queue: nasheeds),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // New nasheeds
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text('Новое', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          nasheedsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Center(child: Text('Ошибка загрузки')),
            ),
            data: (nasheeds) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => NasheedTile(nasheed: nasheeds[i], queue: nasheeds),
                childCount: nasheeds.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Ночь мубарака,';
    if (h < 12) return 'Доброе утро,';
    if (h < 17) return 'Добрый день,';
    if (h < 21) return 'Добрый вечер,';
    return 'Добрый вечер,';
  }

  Widget _shimmerRow() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: 130,
          height: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}

class _FeaturedCard extends ConsumerWidget {
  final dynamic nasheed;
  final List<dynamic> queue;

  const _FeaturedCard({required this.nasheed, required this.queue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(playerProvider.notifier).play(nasheed, queue: queue);
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NasheedCover(url: nasheed.coverUrl, size: 130, borderRadius: 12),
            const SizedBox(height: 8),
            Text(
              nasheed.title,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              nasheed.artist?.name ?? '',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

final _artistStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ApiService().getArtistStats();
});

class ArtistStatsScreen extends ConsumerWidget {
  const ArtistStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_artistStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Статистика')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Ошибка загрузки')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Прослушиваний', value: _fmt(stats['totalPlays'] ?? 0), icon: Icons.play_arrow_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Лайков', value: _fmt(stats['totalLikes'] ?? 0), icon: Icons.favorite_rounded, color: AppColors.error)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Подписчики', value: _fmt(stats['followersCount'] ?? 0), icon: Icons.people_rounded, color: AppColors.gold)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Нашидов', value: _fmt((stats['nasheedsStats'] as List?)?.length ?? 0), icon: Icons.library_music_rounded)),
                ],
              ),
              const SizedBox(height: 24),

              // Top nasheeds
              Text('Ваши нашиды', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              if ((stats['nasheedsStats'] as List?)?.isEmpty ?? true)
                const Center(
                  child: Text('Вы ещё не загрузили ни одного нашида', style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                ...(stats['nasheedsStats'] as List).map((n) => _NasheedStatTile(nasheed: n)),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(dynamic value) {
    final n = int.tryParse(value.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
}

class _NasheedStatTile extends StatelessWidget {
  final Map<String, dynamic> nasheed;

  const _NasheedStatTile({required this.nasheed});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nasheed['title'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmt(nasheed['playsCount'])} прослушиваний · ${_fmt(nasheed['likesCount'])} лайков',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20),
            Text(_fmt(nasheed['playsCount']), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  String _fmt(dynamic value) {
    final n = int.tryParse(value.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

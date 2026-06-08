import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quran_surah.dart';
import '../../providers/player_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../models/nasheed.dart';

final _surahsProvider = FutureProvider<List<QuranSurah>>((ref) async {
  return ApiService().getSurahs();
});

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(_surahsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: const Text('Священный Коран'),
          ),

          // Bismillah header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.gold.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 22,
                      fontFamily: 'Amiri',
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '114 сур Священного Корана',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          surahsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Center(child: Text('Ошибка загрузки Корана')),
            ),
            data: (surahs) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _SurahTile(surah: surahs[i]),
                childCount: surahs.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _SurahTile extends ConsumerWidget {
  final QuranSurah surah;

  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final isPlaying = playerState.nasheed?.id == 'quran_${surah.id}' && playerState.isPlaying;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPlaying ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Center(
          child: Text(
            '${surah.id}',
            style: TextStyle(
              color: isPlaying ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              surah.nameTransliteration,
              style: TextStyle(
                color: isPlaying ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            surah.nameArabic,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontFamily: 'Amiri',
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            surah.nameTranslation,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${surah.versesCount} аятов',
              style: const TextStyle(color: AppColors.textHint, fontSize: 11),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              surah.revelationType == 'Meccan' ? 'Мекканская' : 'Мединская',
              style: const TextStyle(color: AppColors.textHint, fontSize: 11),
            ),
          ),
        ],
      ),
      trailing: surah.audioUrl != null
          ? IconButton(
              onPressed: () => _playSurah(ref),
              icon: Icon(
                isPlaying ? Icons.stop_rounded : Icons.play_circle_outline_rounded,
                color: isPlaying ? AppColors.primary : AppColors.textSecondary,
                size: 28,
              ),
            )
          : null,
    );
  }

  void _playSurah(WidgetRef ref) {
    if (surah.audioUrl == null) return;
    final nasheed = Nasheed(
      id: 'quran_${surah.id}',
      artistId: 'quran',
      title: surah.nameTransliteration,
      description: surah.nameTranslation,
      audioUrl: surah.audioUrl!,
      duration: 0,
      playsCount: 0,
      likesCount: 0,
      isPublished: true,
      createdAt: DateTime.now(),
      artist: NasheedArtist(id: 'quran', name: 'Священный Коран'),
    );
    ref.read(playerProvider.notifier).play(nasheed);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/nasheed_cover.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    if (state.nasheed == null) return const SizedBox.shrink();

    final nasheed = state.nasheed!;
    final progress = state.duration != null && state.duration!.inMilliseconds > 0
        ? state.position.inMilliseconds / state.duration!.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  NasheedCover(url: nasheed.coverUrl, size: 44, borderRadius: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nasheed.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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
                  IconButton(
                    onPressed: () => ref.read(playerProvider.notifier).previous(),
                    icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 22),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    onPressed: () => ref.read(playerProvider.notifier).togglePlay(),
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : Icon(
                            state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    onPressed: () => ref.read(playerProvider.notifier).next(),
                    icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 22),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Progress bar
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

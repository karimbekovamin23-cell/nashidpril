import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/player_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nasheed_cover.dart';
import '../../services/api_service.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    if (state.nasheed == null) {
      return const Scaffold(body: Center(child: Text('Нет треков')));
    }

    final nasheed = state.nasheed!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                  ),
                  const Expanded(
                    child: Text(
                      'Сейчас играет',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showOptions(context, ref),
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),
            ),

            // Cover
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: NasheedCover(url: nasheed.coverUrl, size: double.infinity, borderRadius: 20),
                ),
              ),
            ),

            // Track info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nasheed.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nasheed.artist?.name ?? '',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  _LikeButton(nasheedId: nasheed.id, isLiked: nasheed.isLiked),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.divider,
                      thumbColor: AppColors.primary,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: state.position.inMilliseconds.toDouble(),
                      max: (state.duration?.inMilliseconds ?? 1).toDouble(),
                      onChanged: (v) =>
                          ref.read(playerProvider.notifier).seek(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(state.position), style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                        Text(
                          _fmt(state.duration ?? Duration.zero),
                          style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  IconButton(
                    onPressed: () => ref.read(playerProvider.notifier).toggleShuffle(),
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: state.shuffleEnabled ? AppColors.primary : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                  // Previous
                  IconButton(
                    onPressed: () => ref.read(playerProvider.notifier).previous(),
                    icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 36),
                  ),
                  // Play/Pause
                  GestureDetector(
                    onTap: () => ref.read(playerProvider.notifier).togglePlay(),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: state.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Icon(
                              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                    ),
                  ),
                  // Next
                  IconButton(
                    onPressed: () => ref.read(playerProvider.notifier).next(),
                    icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 36),
                  ),
                  // Loop
                  IconButton(
                    onPressed: () => ref.read(playerProvider.notifier).toggleLoop(),
                    icon: Icon(
                      state.loopMode == LoopMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      color: state.loopMode != LoopMode.off ? AppColors.primary : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    final nasheed = ref.read(playerProvider).nasheed;
    if (nasheed == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: AppColors.textHint, borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: AppColors.textPrimary),
              title: Text('К исполнителю: ${nasheed.artist?.name ?? ''}'),
              onTap: () {
                context.pop();
                context.push('/artist/${nasheed.artistId}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: AppColors.textPrimary),
              title: const Text('Поделиться'),
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends ConsumerStatefulWidget {
  final String nasheedId;
  final bool isLiked;

  const _LikeButton({required this.nasheedId, required this.isLiked});

  @override
  ConsumerState<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<_LikeButton> {
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
  }

  Future<void> _toggle() async {
    final prev = _liked;
    setState(() => _liked = !_liked);
    try {
      if (!prev) {
        await ApiService().likeNasheed(widget.nasheedId);
      } else {
        await ApiService().unlikeNasheed(widget.nasheedId);
      }
    } catch (_) {
      setState(() => _liked = prev);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: _toggle,
        icon: Icon(
          _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _liked ? AppColors.primary : AppColors.textSecondary,
          size: 28,
        ),
      );
}

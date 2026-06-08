import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nasheed.dart';
import '../providers/player_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'nasheed_cover.dart';

class NasheedTile extends ConsumerStatefulWidget {
  final Nasheed nasheed;
  final List<Nasheed>? queue;
  final bool showArtist;

  const NasheedTile({
    super.key,
    required this.nasheed,
    this.queue,
    this.showArtist = true,
  });

  @override
  ConsumerState<NasheedTile> createState() => _NasheedTileState();
}

class _NasheedTileState extends ConsumerState<NasheedTile> {
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _liked = widget.nasheed.isLiked;
  }

  Future<void> _toggleLike() async {
    final prev = _liked;
    setState(() => _liked = !_liked);
    try {
      if (!prev) {
        await ApiService().likeNasheed(widget.nasheed.id);
      } else {
        await ApiService().unlikeNasheed(widget.nasheed.id);
      }
    } catch (_) {
      setState(() => _liked = prev);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final isPlaying = playerState.nasheed?.id == widget.nasheed.id && playerState.isPlaying;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          NasheedCover(url: widget.nasheed.coverUrl, size: 52),
          if (isPlaying)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.equalizer_rounded, color: AppColors.primary, size: 22),
              ),
            ),
        ],
      ),
      title: Text(
        widget.nasheed.title,
        style: TextStyle(
          color: isPlaying ? AppColors.primary : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: widget.showArtist
          ? Text(
              widget.nasheed.artist?.name ?? '',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.nasheed.durationFormatted,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _toggleLike,
            child: Icon(
              _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _liked ? AppColors.primary : AppColors.textHint,
              size: 20,
            ),
          ),
        ],
      ),
      onTap: () {
        ref.read(playerProvider.notifier).play(widget.nasheed, queue: widget.queue);
      },
    );
  }
}

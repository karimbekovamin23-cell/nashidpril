import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NasheedCover extends StatelessWidget {
  final String? url;
  final double size;
  final double borderRadius;

  const NasheedCover({super.key, this.url, required this.size, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: size,
        height: size,
        color: AppColors.surfaceElevated,
        child: const Icon(Icons.music_note_rounded, color: AppColors.textHint),
      );
}

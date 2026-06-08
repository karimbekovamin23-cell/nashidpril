import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nasheed_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nasheed_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            actions: [
              IconButton(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Выйти',
              ),
            ],
            title: const Text('Профиль'),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surfaceElevated,
                    backgroundImage: user.avatarUrl != null
                        ? CachedNetworkImageProvider(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 32),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(user.email, style: Theme.of(context).textTheme.bodyMedium),

                  const SizedBox(height: 8),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isArtist
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: user.isArtist ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isArtist ? Icons.mic_rounded : Icons.headphones_rounded,
                          color: user.isArtist ? AppColors.primary : AppColors.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.isArtist ? 'Исполнитель' : 'Слушатель',
                          style: TextStyle(
                            color: user.isArtist ? AppColors.primary : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (user.isArtist) ...[
                          const SizedBox(width: 4),
                          Icon(
                            user.isVerifiedArtist ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                            color: user.isVerifiedArtist ? AppColors.primary : AppColors.pending,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artist actions
          if (user.isArtist)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (user.isVerifiedArtist) ...[
                      _ActionTile(
                        icon: Icons.upload_rounded,
                        label: 'Загрузить нашид',
                        onTap: () => context.push('/upload'),
                      ),
                      _ActionTile(
                        icon: Icons.bar_chart_rounded,
                        label: 'Статистика',
                        onTap: () => context.push('/stats'),
                      ),
                    ] else
                      _ActionTile(
                        icon: Icons.verified_user_rounded,
                        label: 'Статус верификации',
                        subtitle: _verificationLabel(user.artistProfile?.verificationStatus),
                        onTap: () => context.push('/verification'),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // Liked nasheeds
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text('Понравившиеся', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          _LikedNasheeds(),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  String _verificationLabel(String? status) {
    switch (status) {
      case 'APPROVED': return 'Верифицирован';
      case 'PENDING': return 'На проверке';
      case 'REJECTED': return 'Отклонено';
      default: return 'Подать заявку';
    }
  }
}

class _LikedNasheeds extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedAsync = ref.watch(likedNasheedsProvider);

    return likedAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (nasheeds) => nasheeds.isEmpty
          ? const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Вы ещё не добавили нашиды в избранное',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => NasheedTile(nasheed: nasheeds[i], queue: nasheeds),
                childCount: nasheeds.length,
              ),
            ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}

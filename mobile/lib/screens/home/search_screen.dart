import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/nasheed_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nasheed_tile.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(_searchQueryProvider);
    final resultsAsync = ref.watch(searchProvider(query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Поиск')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Нашиды, исполнители...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                        onPressed: () => ref.read(_searchQueryProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (v) => ref.read(_searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _EmptySearch()
                : resultsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (_, __) => const Center(child: Text('Ошибка')),
                    data: (nasheeds) => nasheeds.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, color: AppColors.textHint, size: 48),
                                SizedBox(height: 12),
                                Text('Ничего не найдено', style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: nasheeds.length,
                            itemBuilder: (ctx, i) => NasheedTile(nasheed: nasheeds[i], queue: nasheeds),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Найдите нашиды и исполнителей',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

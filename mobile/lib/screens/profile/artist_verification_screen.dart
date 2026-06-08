import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ArtistVerificationScreen extends ConsumerStatefulWidget {
  const ArtistVerificationScreen({super.key});

  @override
  ConsumerState<ArtistVerificationScreen> createState() =>
      _ArtistVerificationScreenState();
}

class _ArtistVerificationScreenState
    extends ConsumerState<ArtistVerificationScreen> {
  final _bioController = TextEditingController();
  String? _docPath;
  String? _docName;
  bool _loading = false;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _docPath = result.files.single.path;
        _docName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ApiService().submitVerification(
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        documentPath: _docPath,
      );
      await ref.read(authProvider.notifier).refresh();
      if (!mounted) return;
      context.go('/home');
    } catch (_) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при отправке заявки')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final status = user?.artistProfile?.verificationStatus;

    if (status == 'APPROVED') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.primary, size: 64),
              const SizedBox(height: 16),
              const Text('Аккаунт верифицирован!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      );
    }

    if (status == 'PENDING') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top_rounded, color: AppColors.pending, size: 64),
              const SizedBox(height: 16),
              const Text('Заявка на проверке',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                'Мы проверяем вашу заявку. Обычно это занимает 1-3 дня.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Верификация исполнителя'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Верификация нужна для публикации нашидов. После проверки вы сможете загружать контент.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('О себе', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Расскажите о себе как исполнителе нашидов...',
              ),
            ),

            const SizedBox(height: 24),
            Text('Документ (необязательно)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Можно приложить ссылку на соц. сети или любой подтверждающий документ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _docPath != null ? AppColors.primary : AppColors.divider,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _docPath != null ? Icons.attach_file_rounded : Icons.upload_file_rounded,
                      color: _docPath != null ? AppColors.primary : AppColors.textHint,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _docName ?? 'Прикрепить файл',
                        style: TextStyle(
                          color: _docPath != null ? AppColors.textPrimary : AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Отправить заявку'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

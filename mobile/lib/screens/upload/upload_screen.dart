import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _audioPath;
  String? _audioName;
  String? _coverPath;
  bool _loading = false;

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result?.files.single.path != null) {
      setState(() {
        _audioPath = result!.files.single.path;
        _audioName = result.files.single.name;
      });
    }
  }

  Future<void> _pickCover() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) setState(() => _coverPath = image.path);
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _audioPath == null) return;
    setState(() => _loading = true);
    try {
      await ApiService().uploadNasheed(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        audioPath: _audioPath!,
        coverPath: _coverPath,
        duration: 0,
      );
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нашид успешно загружен!'), backgroundColor: AppColors.primary),
      );
    } catch (_) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки. Попробуйте ещё раз.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = !_loading && _audioPath != null && _titleController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Загрузить нашид'),
        actions: [
          TextButton(
            onPressed: canUpload ? _upload : null,
            child: _loading
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Text('Опубликовать',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover picker
            Center(
              child: GestureDetector(
                onTap: _pickCover,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider, width: 2),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _coverPath != null
                      ? Image.file(File(_coverPath!), fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, color: AppColors.textHint, size: 36),
                            SizedBox(height: 8),
                            Text('Обложка', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text('Название *', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Название нашида'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            Text('Описание', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Краткое описание...'),
            ),
            const SizedBox(height: 20),

            Text('Аудио файл *', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickAudio,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _audioPath != null ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _audioPath != null ? Icons.audio_file_rounded : Icons.upload_rounded,
                      color: _audioPath != null ? AppColors.primary : AppColors.textHint,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _audioName ?? 'Выбрать аудио файл',
                      style: TextStyle(
                        color: _audioPath != null ? AppColors.textPrimary : AppColors.textHint,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_audioPath == null) ...[
                      const SizedBox(height: 4),
                      const Text('MP3, AAC, FLAC до 100MB',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canUpload ? _upload : null,
                child: const Text('Загрузить нашид'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

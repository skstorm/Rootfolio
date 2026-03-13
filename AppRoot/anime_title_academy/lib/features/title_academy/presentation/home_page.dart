import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../image_gen/presentation/style_preview_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _selectedStyle = 'anime';
  final ImagePicker _picker = ImagePicker();

  static const _styles = [
    {'name': 'anime', 'label': '애니메이션', 'emoji': '🎌'},
    {'name': 'pixel_art', 'label': '픽셀아트', 'emoji': '👾'},
    {'name': 'watercolor', 'label': '수채화', 'emoji': '🎨'},
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (picked == null) return;

      if (context.mounted) {
        context.push(RouteNames.result, extra: {
          'imagePath': picked.path,
          'style': _selectedStyle,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 오류: $e')),
        );
      }
    }
  }

  void _showPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anime Title Academy', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_search_rounded, size: 120, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text('사진을 선택하고 스타일을 고르세요',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _styles.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: StylePreviewCard(
                    styleName: s['name']!,
                    styleLabel: s['label']!,
                    emoji: s['emoji']!,
                    isSelected: _selectedStyle == s['name'],
                    onTap: () => setState(() => _selectedStyle = s['name']!),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library, color: Colors.black87),
                label: const Text('사진 선택하기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                onPressed: _showPickerBottomSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

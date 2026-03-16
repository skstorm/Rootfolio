import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/ui_constants.dart';
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
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1D2B),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              
              return Stack(
                children: [
                   // 1. 헤더 영역 (로고/타이틀)
                  Positioned(
                    top: h * 0.05,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Anime Title Academy',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -1.0,
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '나만의 애니메이션 타이틀 만들기',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2 & 3. 센터 집중형 스타일 선택 섹션 (버티컬 배치)
                  Positioned(
                    top: h * 0.22,
                    left: UiConstants.homeHorizontalPadding,
                    right: UiConstants.homeHorizontalPadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '원하는 스타일을 선택하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // [MOD] 수직 배치로 변경하여 센터 영역 밀도 최적화
                        ..._styles.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: UiConstants.homeStyleCardVerticalSpacing),
                          child: SizedBox(
                            width: double.infinity, // 카드가 가로로 꽉 차게 변경
                            child: StylePreviewCard(
                              styleName: s['name']!,
                              styleLabel: s['label']!,
                              emoji: s['emoji']!,
                              isSelected: _selectedStyle == s['name'],
                              onTap: () => setState(() => _selectedStyle = s['name']!),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),

                  // 4. 하단 액션 버튼
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + UiConstants.homeBottomActionPadding,
                    left: UiConstants.homeHorizontalPadding,
                    right: UiConstants.homeHorizontalPadding,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.black87),
                        label: const Text(
                          '사진 선택하여 시작하기',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 12,
                          shadowColor: AppColors.primary.withOpacity(0.6),
                        ),
                        onPressed: _showPickerBottomSheet,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

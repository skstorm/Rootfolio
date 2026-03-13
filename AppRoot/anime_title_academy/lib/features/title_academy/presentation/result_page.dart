import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scratch_ux/presentation/scratch_wrapper_view.dart';
import '../../scratch_ux/presentation/scratch_provider.dart';

// 프리셋별 Mock 자막 목록 (Gemini API 연동 전 테스트용)
const _mockTitles = {
  'anime': [
    '생존을 위한 극한의 사투가 시작되었다.',
    '이 순간이 나의 전부다... 뒤는 없다.',
    '운명이 나를 시험하는가. 받아주마.',
    '이제부터가 진짜다. 물러섬은 없어.',
    '내가 지켜야 할 것들을 위해, 싸운다.',
  ],
  'pixel_art': [
    'LEVEL UP! 새로운 스테이지가 열렸다.',
    '잔여 생명 1. 이 판을 클리어해라.',
    'GAME OVER는 없다. CONTINUE 선택.',
    '적이 너무 강하다... 아이템을 써야해.',
    '보스 등장... HP가 풀인지 확인해.',
  ],
  'watercolor': [
    '너란 녀석... 내가 이렇게까지 해야 직성이 풀리는 건가.',
    '이 감정이 뭔지는 모르겠지만, 너 때문이야.',
    '돌아보지 않겠다 했는데... 그게 안 되더라.',
    '처음 봤을 때부터 알았어야 했는데.',
    '오늘도 네 생각을 지웠다. 그리고 다시 떠올렸다.',
  ],
};

class ResultPage extends ConsumerStatefulWidget {
  final String? imagePath;
  final String style;

  const ResultPage({
    super.key,
    this.imagePath,
    this.style = 'anime',
  });

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  late final String _generatedTitle;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 딱 한 번 랜덤 자막 생성
    final titles = _mockTitles[widget.style] ?? _mockTitles['anime']!;
    _generatedTitle = titles[Random().nextInt(titles.length)];
  }

  @override
  Widget build(BuildContext context) {
    final isCleared = ref.watch(scratchProvider).isCleared;
    final imageFile = widget.imagePath != null ? File(widget.imagePath!) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('결과 확인')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: ScratchWrapperView(
                clearThreshold: 0.4,
                foreground: Container(
                  color: Colors.grey[850],
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageFile != null)
                        ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ]),
                          child: Image.file(imageFile, fit: BoxFit.cover),
                        ),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white70, size: 48),
                            SizedBox(height: 8),
                            Text(
                              '여기를 문질러\n결과를 확인하세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageFile != null)
                      Image.file(imageFile, fit: BoxFit.cover),
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: Text(
                        _generatedTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          shadows: [
                            Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                            Shadow(offset: Offset(-2, -2), blurRadius: 4, color: Colors.black),
                            Shadow(offset: Offset(2, -2), blurRadius: 4, color: Colors.black),
                            Shadow(offset: Offset(-2, 2), blurRadius: 4, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  ref.read(scratchProvider.notifier).reset();
                  Navigator.of(context).pop();
                },
                child: const Text('다시하기'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('저장 / 공유'),
                onPressed: isCleared
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('저장 기능은 Phase 4에서 구현됩니다.')),
                        );
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

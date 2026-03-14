import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scratch_ux/presentation/scratch_wrapper_view.dart';
import '../../scratch_ux/presentation/scratch_provider.dart';
import 'title_provider.dart';

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
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 AI 파이프라인 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imagePath != null) {
        ref.read(titleNotifierProvider.notifier).runFullPipeline(
          File(widget.imagePath!),
          widget.style,
          widget.style, // presetPrompt로 스타일 이름을 그대로 전달
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleState = ref.watch(titleNotifierProvider);
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
              child: titleState is TitleLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.yellow),
                          SizedBox(height: 20),
                          Text('AI가 사진을 분석하여\n자막을 생성하고 있습니다...',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )
                  : titleState is TitleError
                      ? Center(child: Text('오류 발생: ${(titleState as TitleError).message}'))
                      : titleState is TitleSuccess
                          ? ScratchWrapperView(
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
                                      (titleState as TitleSuccess).result.text,
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
                            )
                          : const Center(child: Text('준비 중...')),
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

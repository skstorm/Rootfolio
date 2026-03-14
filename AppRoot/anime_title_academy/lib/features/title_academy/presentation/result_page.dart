import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scratch_ux/presentation/scratch_wrapper_view.dart';
import '../../scratch_ux/presentation/scratch_provider.dart';
import '../../../core/theme/scratch_styles.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imagePath != null) {
        ref.read(titleNotifierProvider.notifier).runFullPipeline(
          File(widget.imagePath!),
          widget.style,
          widget.style,
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
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageFile != null)
                                  Image.file(imageFile, fit: BoxFit.cover),
                                
                                Positioned(
                                  bottom: 40,
                                  left: 20,
                                  right: 20,
                                  height: 85,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ScratchWrapperView(
                                      clearThreshold: 0.3,
                                      foreground: Container(), // Dummy
                                      background: Container(
                                        alignment: Alignment.center,
                                        color: Colors.black.withOpacity(0.6),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          (titleState as TitleSuccess).result.text,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow,
                                            shadows: [
                                              Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(child: const Text('준비 중...')),
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
              const SizedBox(width: 12),
              if (kDebugMode)
                TextButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.redAccent),
                  label: const Text('리셋 (Debug)', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    ref.read(scratchProvider.notifier).reset();
                  },
                ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

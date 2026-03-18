import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_names.dart';
import 'package:anime_title_academy/features/scratch_ux/presentation/scratch_wrapper_view.dart';
import 'package:anime_title_academy/features/scratch_ux/presentation/scratch_provider.dart';
import 'package:anime_title_academy/core/util/debug_service.dart';
import 'package:anime_title_academy/core/constants/ui_constants.dart';
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
        // 이전 상태 초기화 후 새로운 파이프라인 시작
        ref.read(titleNotifierProvider.notifier).reset();
        ref.read(titleNotifierProvider.notifier).runFullPipeline(
          File(widget.imagePath!),
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
    final titleResult = titleState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 확인'),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(debugEnabledProvider) 
                  ? Icons.bug_report 
                  : Icons.bug_report_outlined,
              color: ref.watch(debugEnabledProvider) ? Colors.redAccent : Colors.white70,
            ),
            onPressed: () {
              ref.read(debugEnabledProvider.notifier).toggle();
            },
            tooltip: '디버그 UI 토글',
          ),
          if (ref.watch(debugEnabledProvider))
            IconButton(
              icon: const Icon(Icons.science_outlined, color: Colors.orangeAccent),
              onPressed: () {
                context.push(RouteNames.promptSandbox, extra: {
                  'imagePath': widget.imagePath,
                });
              },
              tooltip: '프롬프트 샌드박스',
            ),
        ],
      ),
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
              child: titleState.isLoading
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
                  : titleState.hasError
                      ? Center(child: Text('오류 발생: ${titleState.error}'))
                      : titleResult != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageFile != null)
                                  Image.file(imageFile, fit: BoxFit.cover),
                                
                                Positioned(
                                  bottom: 40,
                                  left: 20,
                                  right: 20,
                                  height: UiConstants.scratchAreaHeight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    clipBehavior: ref.watch(debugServiceProvider).isDebugMode 
                                        ? Clip.none 
                                        : Clip.antiAlias,
                                    child: ScratchWrapperView(
                                      clearThreshold: UiConstants.scratchTotalClearThreshold,
                                      targetText: titleResult.text,
                                      targetTextStyle: const TextStyle(
                                        fontSize: UiConstants.scratchTitleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: UiConstants.scratchTitleColor,
                                      ),
                                      foreground: Container(), // Dummy
                                      background: Container(
                                        alignment: Alignment.center,
                                        color: Colors.black.withOpacity(0.6),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Center(
                                          child: Text(
                                            titleResult.text,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: UiConstants.scratchTitleFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: UiConstants.scratchTitleColor,
                                              shadows: [
                                                Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ),
                                  ),
                              ],
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

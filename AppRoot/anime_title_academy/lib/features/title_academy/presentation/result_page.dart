import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/result.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/shared/providers/debug_provider.dart';
import 'package:anime_title_academy/core/constants/scratch_constants.dart';
import 'package:anime_title_academy/features/scratch_ux/presentation/scratch_provider.dart';
import 'package:anime_title_academy/features/scratch_ux/presentation/scratch_wrapper_view.dart';
import '../domain/title_generation_model.dart';
import '../../watermark/domain/title_style.dart';
import 'title_provider.dart';
import 'widgets/result_action_dock.dart';
import 'widgets/result_model_selector_pill.dart';
import 'widgets/result_quota_summary.dart';

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
  TitleGenerationModel _selectedLlmModel = TitleGenerationModel.fast;
  bool _isQuotaActionInProgress = false;
  bool _isSaveInProgress = false;

  Future<void> _runInitialPipeline() async {
    await _runFullPipeline(useCache: true);
  }

  Future<void> _runFullPipeline({required bool useCache}) async {
    if (widget.imagePath == null) return;
    await _runWithQuotaGate(
      onAllowed: () async {
        final recentTitles =
            ref.read(titleNotifierProvider).asData?.value?.recentTitles ??
                const <String>[];
        ref.read(scratchProvider.notifier).reset();
        await ref.read(titleNotifierProvider.notifier).runFullPipeline(
              File(widget.imagePath!),
              widget.style,
              useCache: useCache,
              recentTitles: recentTitles,
              llmModel: _selectedLlmModel,
            );
      },
    );
  }

  Future<void> _regenerateTitleOnly() async {
    await _runWithQuotaGate(
      onAllowed: () async {
        ref.read(scratchProvider.notifier).reset();
        await ref.read(titleNotifierProvider.notifier).regenerateTitleOnly(
              llmModel: _selectedLlmModel,
            );
      },
    );
  }

  /// Quota 확인 → 광고 → 충전 → 실행 흐름을 UseCase에 위임합니다.
  /// UI(dialog, snackbar)는 이 메서드에서 콜백으로 제공합니다.
  Future<void> _runWithQuotaGate({
    required Future<void> Function() onAllowed,
  }) async {
    if (_isQuotaActionInProgress) return;

    setState(() => _isQuotaActionInProgress = true);

    try {
      final useCase = ref.read(quotaGatedPipelineProvider);
      await useCase.execute(
        model: _selectedLlmModel,
        onAllowed: onAllowed,
        onNeedAd: () => _showQuotaDialog(_selectedLlmModel),
        onMessage: _showSnackBar,
      );
      ref.invalidate(titleQuotaProvider);
    } finally {
      if (mounted) {
        setState(() => _isQuotaActionInProgress = false);
      }
    }
  }

  Future<bool> _showQuotaDialog(TitleGenerationModel model) async {
    // quota 상세 정보를 가져와 다이얼로그 표시
    final quotaSnapshot = await ref.read(titleUsageQuotaServiceProvider).getQuota();
    final quota = quotaSnapshot.forModel(model);

    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${quota.model.label} 이용권이 부족합니다'),
          content: Text(
            '무료 횟수를 모두 사용했습니다.\n'
            '광고를 보면 ${quota.model.label} ${quota.rewardRechargeCount}회를 충전할 수 있습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('광고 보고 충전'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSharePlaceholder() {
    _showSnackBar('공유 기능은 Phase 4에서 구현됩니다.');
  }

  void _resetScratchDebug() {
    ref.read(scratchProvider.notifier).reset();
  }

  Future<void> _saveResultImage() async {
    if (_isSaveInProgress || widget.imagePath == null) {
      return;
    }

    final titleResult = ref.read(titleNotifierProvider).asData?.value?.result;
    if (titleResult == null) {
      _showSnackBar('저장할 결과가 아직 준비되지 않았습니다.');
      return;
    }

    setState(() => _isSaveInProgress = true);
    try {
      final compositeUseCase = ref.read(compositeTitleUseCaseProvider);
      final shareService = ref.read(shareServiceProvider);
      final compositeResult = await compositeUseCase(
        image: File(widget.imagePath!),
        titleResult: titleResult,
        titleStyle: const TitleStyle(
          fontSize: 28,
          position: Offset.zero,
          strokeWidth: 3.0,
        ),
      );

      if (compositeResult is Failure<File>) {
        _showSnackBar(compositeResult.failure.message);
        return;
      }

      final composedFile = (compositeResult as Success<File>).data;
      final saveResult = await shareService.saveToGallery(composedFile);

      if (saveResult is Failure<File>) {
        _showSnackBar(saveResult.failure.message);
        return;
      }

      final savedFile = (saveResult as Success<File>).data;
      if (Platform.isAndroid || Platform.isIOS) {
        _showSnackBar('갤러리에 이미지를 저장했습니다.');
      } else {
        _showSnackBar('이미지를 저장했습니다.\n${savedFile.path}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaveInProgress = false);
      }
    }
  }

  Widget _buildQuotaSummary() {
    final quotaState = ref.watch(titleQuotaProvider);
    final runtimeConfig = ref.watch(appRuntimeConfigProvider);

    return quotaState.when(
      data: (quota) {
        final selectedQuota = quota.forModel(_selectedLlmModel);
        final summaryText = quota.isBypassed
            ? '개발 모드: 사용 제한 없음'
            : '${_selectedLlmModel.label} 무료 ${selectedQuota.dailyFreeRemaining}회'
                ' / 충전 ${selectedQuota.rewardedRemaining}회 남음';
        final rewardText = quota.isBypassed
            ? null
            : '광고 1회로 ${selectedQuota.rewardRechargeCount}회 충전';
        final modeText = runtimeConfig.rewardedAdMode == RewardedAdMode.disabled
            ? null
            : runtimeConfig.rewardedAdMode.debugLabel;

        return ResultQuotaSummary(
          summaryText: summaryText,
          rewardText: rewardText,
          modeText: runtimeConfig.isDebugBuild ? modeText : null,
        );
      },
      loading: () => const ResultQuotaSummary(
        summaryText: '이용권 정보를 확인하는 중...',
      ),
      error: (_, _) => const ResultQuotaSummary(
        summaryText: '이용권 정보를 불러오지 못했습니다.',
        isError: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imagePath != null) {
        ref.read(titleNotifierProvider.notifier).reset();
        _runInitialPipeline();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleState = ref.watch(titleNotifierProvider);
    final loadingMode = ref.watch(titleLoadingModeProvider);
    final isCleared = ref.watch(scratchProvider).isCleared;
    final isBusy = titleState.isLoading || _isQuotaActionInProgress || _isSaveInProgress;
    final imageFile = widget.imagePath != null ? File(widget.imagePath!) : null;
    final titleViewState = titleState.asData?.value;
    final titleResult = titleViewState?.result;
    final actionItems = [
      ResultActionDockItem(
        icon: Icons.download_rounded,
        label: '저장',
        onPressed: isCleared ? _saveResultImage : null,
      ),
      ResultActionDockItem(
        icon: Icons.ios_share_rounded,
        label: '공유',
        onPressed: isCleared ? _showSharePlaceholder : null,
      ),
      ResultActionDockItem(
        icon: Icons.replay_rounded,
        label: '다시하기',
        onPressed: widget.imagePath != null && !isBusy
            ? () => _runFullPipeline(useCache: false)
            : null,
      ),
      ResultActionDockItem(
        icon: Icons.auto_awesome_rounded,
        label: '자막 재생성',
        accentColor: Colors.amberAccent,
        onPressed: titleViewState != null && !isBusy
            ? _regenerateTitleOnly
            : null,
      ),
    ];
    final loadingMessage = loadingMode == TitleLoadingMode.regenerateOnly
        ? 'AI가 자막을 재생성 하고 있습니다...'
        : 'AI가 사진을 분석하여\n자막을 생성하고 있습니다...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 확인'),
        actions: [
          if (kDebugMode) ...[
            IconButton(
              icon: Icon(
                ref.watch(debugEnabledProvider)
                    ? Icons.bug_report
                    : Icons.bug_report_outlined,
                color: ref.watch(debugEnabledProvider)
                    ? Colors.redAccent
                    : Colors.white70,
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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(UiConstants.resultHorizontalPadding),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: titleState.isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.yellow),
                          const SizedBox(height: 20),
                          Text(
                            loadingMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
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
                                  height: ScratchConstants.areaHeight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    clipBehavior:
                                        ref.watch(debugServiceProvider).isDebugMode
                                            ? Clip.none
                                            : Clip.antiAlias,
                                    child: ScratchWrapperView(
                                      clearThreshold:
                                          ScratchConstants.totalClearThreshold,
                                      targetText: titleResult.text,
                                      targetTextStyle: const TextStyle(
                                        fontSize: ScratchConstants.titleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: ScratchConstants.titleColor,
                                      ),
                                      foreground: Container(),
                                      background: Container(
                                        alignment: Alignment.center,
                                        color: const Color(0x99000000),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Center(
                                          child: Text(
                                            titleResult.text,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize:
                                                  ScratchConstants.titleFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: ScratchConstants.titleColor,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(2, 2),
                                                  blurRadius: 4,
                                                  color: Colors.black,
                                                ),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.resultHorizontalPadding,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResultModelSelectorPill(
                      selectedModel: _selectedLlmModel,
                      enabled: !isBusy,
                      onSelected: (model) {
                        setState(() => _selectedLlmModel = model);
                        ref.invalidate(titleQuotaProvider);
                      },
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(width: 10),
                      Tooltip(
                        message: '스크래치 리셋',
                        preferBelow: false,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _resetScratchDebug,
                            customBorder: const CircleBorder(),
                            child: Ink(
                              width: UiConstants.resultModelPillHeight,
                              height: UiConstants.resultModelPillHeight,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.redAccent.withValues(alpha: 0.45),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                _buildQuotaSummary(),
                const SizedBox(height: UiConstants.resultBottomSectionSpacing),
                ResultActionDock(items: actionItems),
              ],
            ),
          ),
          const SizedBox(height: UiConstants.resultBottomSafePadding),
        ],
      ),
    );
  }
}

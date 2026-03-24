import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_names.dart';
import 'package:anime_title_academy/core/ads/ad_runtime_mode.dart';
import 'package:anime_title_academy/core/debug/debug_service.dart';
import 'package:anime_title_academy/shared/providers/debug_provider.dart';
import 'package:anime_title_academy/core/constants/ui_constants.dart';
import 'package:anime_title_academy/features/scratch_ux/presentation/scratch_provider.dart';
import 'package:anime_title_academy/features/scratch_ux/presentation/scratch_wrapper_view.dart';
import '../domain/title_model_usage_quota.dart';
import '../domain/title_generation_model.dart';
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
  TitleGenerationModel _selectedLlmModel = TitleGenerationModel.fast;
  bool _isQuotaActionInProgress = false;

  Future<void> _runInitialPipeline() async {
    await _runFullPipeline(useCache: true);
  }

  Future<void> _runFullPipeline({required bool useCache}) async {
    if (widget.imagePath == null) {
      return;
    }

    await _executeWithQuota(
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
    await _executeWithQuota(
      onAllowed: () async {
        ref.read(scratchProvider.notifier).reset();
        await ref.read(titleNotifierProvider.notifier).regenerateTitleOnly(
              llmModel: _selectedLlmModel,
            );
      },
    );
  }

  Future<void> _executeWithQuota({
    required Future<void> Function() onAllowed,
  }) async {
    if (_isQuotaActionInProgress) {
      return;
    }

    setState(() {
      _isQuotaActionInProgress = true;
    });

    try {
      final quotaService = ref.read(titleUsageQuotaServiceProvider);
      final consumeResult = await quotaService.consume(_selectedLlmModel);
      ref.invalidate(titleQuotaProvider);

      if (consumeResult.isAllowed) {
        await onAllowed();
        return;
      }

      final shouldWatchAd = await _showQuotaDialog(
        consumeResult.quota.forModel(_selectedLlmModel),
      );
      if (!shouldWatchAd || !mounted) {
        return;
      }

      final adResult = await ref.read(adServiceProvider).showRewardedAd(
            model: _selectedLlmModel,
          );
      if (!mounted) {
        return;
      }

      if (!adResult.isRewarded) {
        _showSnackBar(adResult.message ?? '광고 시청이 완료되지 않았습니다.');
        return;
      }

      await quotaService.reward(_selectedLlmModel);
      ref.invalidate(titleQuotaProvider);

      final retryConsume = await quotaService.consume(_selectedLlmModel);
      ref.invalidate(titleQuotaProvider);
      if (!retryConsume.isAllowed) {
        _showSnackBar('충전 후에도 사용권을 확보하지 못했습니다.');
        return;
      }

      await onAllowed();
      if (adResult.message != null && adResult.message!.isNotEmpty) {
        _showSnackBar(adResult.message!);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isQuotaActionInProgress = false;
        });
      }
    }
  }

  Future<bool> _showQuotaDialog(TitleModelUsageQuota quota) async {
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              summaryText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (rewardText != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  rewardText,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (runtimeConfig.isDebugBuild && modeText != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  modeText,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
      loading: () => const Text(
        '이용권 정보를 확인하는 중...',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      error: (_, _) => const Text(
        '이용권 정보를 불러오지 못했습니다.',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
        ),
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
    final isBusy = titleState.isLoading || _isQuotaActionInProgress;
    final imageFile = widget.imagePath != null ? File(widget.imagePath!) : null;
    final titleViewState = titleState.asData?.value;
    final titleResult = titleViewState?.result;
    final loadingMessage = loadingMode == TitleLoadingMode.regenerateOnly
        ? 'AI가 자막을 재생성 하고 있습니다...'
        : 'AI가 사진을 분석하여\n자막을 생성하고 있습니다...';

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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PopupMenuButton<TitleGenerationModel>(
                      enabled: !isBusy,
                      tooltip: 'LLM 선택',
                      initialValue: _selectedLlmModel,
                      onSelected: (model) {
                        setState(() {
                          _selectedLlmModel = model;
                        });
                        ref.invalidate(titleQuotaProvider);
                      },
                      itemBuilder: (context) => TitleGenerationModel.values
                          .map(
                            (model) => PopupMenuItem<TitleGenerationModel>(
                              value: model,
                              child: Text(model.displayLabel),
                            ),
                          )
                          .toList(),
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.arrow_drop_down),
                        label: Text(_selectedLlmModel.label),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildQuotaSummary(),
                  ),
                  OutlinedButton(
                    onPressed: widget.imagePath != null && !isBusy
                        ? () => _runFullPipeline(useCache: false)
                        : null,
                    child: const Text('다시하기'),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (kDebugMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.redAccent),
                        label: const Text(
                          '리셋 (Debug)',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onPressed: () {
                          ref.read(scratchProvider.notifier).reset();
                        },
                      ),
                    ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('자막만 다시 생성'),
                    onPressed: titleViewState != null && !isBusy
                        ? _regenerateTitleOnly
                        : null,
                  ),
                ],
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

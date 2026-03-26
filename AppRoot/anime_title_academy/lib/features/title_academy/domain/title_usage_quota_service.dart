import 'package:anime_title_academy/core/constants/quota_constants.dart';
import 'package:anime_title_academy/core/config/app_runtime_config.dart';
import 'package:anime_title_academy/features/title_academy/data/title_usage_local_datasource.dart';
import 'package:anime_title_academy/features/title_academy/domain/quota_consume_result.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_model_usage_quota.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_usage_quota_snapshot.dart';
import 'package:injectable/injectable.dart';

typedef NowProvider = DateTime Function();

@lazySingleton
class TitleUsageQuotaService {
  @factoryMethod
  static TitleUsageQuotaService create(
    TitleUsageLocalDatasource localDatasource,
    AppRuntimeConfig runtimeConfig,
  ) =>
      TitleUsageQuotaService(localDatasource, runtimeConfig);

  TitleUsageQuotaService(
    this._localDatasource,
    this._runtimeConfig, {
    NowProvider? nowProvider,
  }) : _nowProvider = nowProvider ?? DateTime.now;

  final TitleUsageLocalDatasource _localDatasource;
  final AppRuntimeConfig _runtimeConfig;
  final DateTime Function() _nowProvider;

  Future<TitleUsageQuotaSnapshot> getQuota() async {
    if (_runtimeConfig.bypassQuotaAndAds) {
      return _buildBypassSnapshot();
    }

    await _refreshIfNeeded();
    return _buildSnapshot();
  }

  Future<QuotaConsumeResult> consume(TitleGenerationModel model) async {
    if (_runtimeConfig.bypassQuotaAndAds) {
      return QuotaConsumeResult(
        status: QuotaConsumeStatus.bypassed,
        quota: _buildBypassSnapshot(),
      );
    }

    await _refreshIfNeeded();

    final policy = titleUsageQuotaPolicies[model]!;
    final freeUsed = _localDatasource.readFreeUsed(model);
    if (freeUsed < policy.dailyFreeCount) {
      await _localDatasource.writeFreeUsed(model, freeUsed + 1);
      return QuotaConsumeResult(
        status: QuotaConsumeStatus.consumedFree,
        quota: _buildSnapshot(),
      );
    }

    final rewardedRemaining = _localDatasource.readRewardedRemaining(model);
    if (rewardedRemaining > 0) {
      await _localDatasource.writeRewardedRemaining(
        model,
        rewardedRemaining - 1,
      );
      return QuotaConsumeResult(
        status: QuotaConsumeStatus.consumedRewarded,
        quota: _buildSnapshot(),
      );
    }

    return QuotaConsumeResult(
      status: QuotaConsumeStatus.exhausted,
      quota: _buildSnapshot(),
    );
  }

  Future<TitleUsageQuotaSnapshot> reward(TitleGenerationModel model) async {
    if (_runtimeConfig.bypassQuotaAndAds) {
      return _buildBypassSnapshot();
    }

    await _refreshIfNeeded();

    final policy = titleUsageQuotaPolicies[model]!;
    final rewardedRemaining = _localDatasource.readRewardedRemaining(model);
    await _localDatasource.writeRewardedRemaining(
      model,
      rewardedRemaining + policy.rewardRechargeCount,
    );
    return _buildSnapshot();
  }

  Future<void> _refreshIfNeeded() async {
    final todayKey = _buildDateKey(_nowProvider());
    final lastResetDateKey = _localDatasource.readLastResetDateKey();
    if (lastResetDateKey == todayKey) {
      return;
    }

    await _localDatasource.resetForNewDay(todayKey);
  }

  TitleUsageQuotaSnapshot _buildSnapshot() {
    final quotas = <TitleGenerationModel, TitleModelUsageQuota>{};
    for (final model in TitleGenerationModel.values) {
      final policy = titleUsageQuotaPolicies[model]!;
      final freeUsed = _localDatasource.readFreeUsed(model);
      final rewardedRemaining = _localDatasource.readRewardedRemaining(model);
      final dailyFreeRemaining = policy.dailyFreeCount - freeUsed;
      quotas[model] = TitleModelUsageQuota(
        model: model,
        dailyFreeCount: policy.dailyFreeCount,
        dailyFreeRemaining: dailyFreeRemaining < 0 ? 0 : dailyFreeRemaining,
        rewardedRemaining: rewardedRemaining,
        rewardRechargeCount: policy.rewardRechargeCount,
        isBypassed: false,
      );
    }

    return TitleUsageQuotaSnapshot(
      quotas: quotas,
      isBypassed: false,
      lastResetDateKey: _localDatasource.readLastResetDateKey() ??
          _buildDateKey(_nowProvider()),
    );
  }

  TitleUsageQuotaSnapshot _buildBypassSnapshot() {
    final quotas = <TitleGenerationModel, TitleModelUsageQuota>{};
    for (final model in TitleGenerationModel.values) {
      final policy = titleUsageQuotaPolicies[model]!;
      quotas[model] = TitleModelUsageQuota(
        model: model,
        dailyFreeCount: policy.dailyFreeCount,
        dailyFreeRemaining: policy.dailyFreeCount,
        rewardedRemaining: 0,
        rewardRechargeCount: policy.rewardRechargeCount,
        isBypassed: true,
      );
    }

    return TitleUsageQuotaSnapshot(
      quotas: quotas,
      isBypassed: true,
      lastResetDateKey: _buildDateKey(_nowProvider()),
    );
  }

  String _buildDateKey(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

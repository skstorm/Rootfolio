import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TitleUsageLocalDatasource {
  TitleUsageLocalDatasource(this._preferences);

  static const String _lastResetDateKey = 'title_usage_last_reset_date';

  final SharedPreferences _preferences;

  String? readLastResetDateKey() => _preferences.getString(_lastResetDateKey);

  int readFreeUsed(TitleGenerationModel model) =>
      _preferences.getInt(_freeUsedKey(model)) ?? 0;

  int readRewardedRemaining(TitleGenerationModel model) =>
      _preferences.getInt(_rewardedRemainingKey(model)) ?? 0;

  Future<void> resetForNewDay(String dateKey) async {
    final writes = <Future<bool>>[
      _preferences.setString(_lastResetDateKey, dateKey),
    ];

    for (final model in TitleGenerationModel.values) {
      writes.add(_preferences.setInt(_freeUsedKey(model), 0));
      writes.add(_preferences.setInt(_rewardedRemainingKey(model), 0));
    }

    await Future.wait(writes);
  }

  Future<void> writeFreeUsed(
    TitleGenerationModel model,
    int value,
  ) async {
    await _preferences.setInt(_freeUsedKey(model), value);
  }

  Future<void> writeRewardedRemaining(
    TitleGenerationModel model,
    int value,
  ) async {
    await _preferences.setInt(_rewardedRemainingKey(model), value);
  }

  String _freeUsedKey(TitleGenerationModel model) =>
      'title_usage_${model.name}_free_used';

  String _rewardedRemainingKey(TitleGenerationModel model) =>
      'title_usage_${model.name}_rewarded_remaining';
}

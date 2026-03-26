import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:anime_title_academy/features/title_academy/domain/title_generation_model.dart';
import 'package:anime_title_academy/features/title_academy/domain/quota_gated_pipeline_usecase.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_usage_quota_service.dart';
import 'package:anime_title_academy/features/title_academy/domain/quota_consume_result.dart';
import 'package:anime_title_academy/features/title_academy/domain/title_usage_quota_snapshot.dart';
import 'package:anime_title_academy/core/ads/ad_service.dart';
import 'package:anime_title_academy/core/ads/ad_reward_result.dart';

import 'quota_gated_pipeline_usecase_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TitleUsageQuotaService>(),
  MockSpec<AdService>(),
])
void main() {
  late QuotaGatedPipelineUseCase usecase;
  late MockTitleUsageQuotaService mockQuotaService;
  late MockAdService mockAdService;

  setUp(() {
    mockQuotaService = MockTitleUsageQuotaService();
    mockAdService = MockAdService();

    usecase = QuotaGatedPipelineUseCase(
      quotaService: mockQuotaService,
      adService: mockAdService,
    );
  });

  const model = TitleGenerationModel.fast;

  // 더미 스냅샷 (단순히 결과 객체 구성을 위해 사용)
  final dummySnapshot = TitleUsageQuotaSnapshot(
    quotas: {},
    isBypassed: false,
    lastResetDateKey: '2026-03-26',
  );

  test('할당량이 충분할 때, onAllowed를 바로 실행하고 true를 반환한다', () async {
    // Arrange
    when(mockQuotaService.consume(model)).thenAnswer(
      (_) async => QuotaConsumeResult(
        status: QuotaConsumeStatus.consumedFree, // 또는 consumedRewarded
        quota: dummySnapshot,
      ),
    );

    bool allowedCalled = false;

    // Act
    final result = await usecase.execute(
      model: model,
      onAllowed: () async {
        allowedCalled = true;
      },
      onNeedAd: () async => false, // 도달하면 안 됨
      onMessage: (_) {},
    );

    // Assert
    expect(result, isTrue);
    expect(allowedCalled, isTrue);
    verify(mockQuotaService.consume(model)).called(1);
    verifyNever(mockAdService.showRewardedAd(model: model));
  });

  test('할당량이 부족하고, 사용자가 광고 시청을 거부하면 false를 반환한다', () async {
    // Arrange
    when(mockQuotaService.consume(model)).thenAnswer(
      (_) async => QuotaConsumeResult(
        status: QuotaConsumeStatus.exhausted,
        quota: dummySnapshot,
      ),
    );

    bool allowedCalled = false;

    // Act
    final result = await usecase.execute(
      model: model,
      onAllowed: () async { allowedCalled = true; },
      onNeedAd: () async => false, // 사용자가 광고 거부
      onMessage: (_) {},
    );

    // Assert
    expect(result, isFalse);
    expect(allowedCalled, isFalse);
    verifyNever(mockAdService.showRewardedAd(model: model));
  });

  test('할당량이 부족하여 광고를 보려 했으나, 광고 시청이 완료되지 않으면 에러 메시지를 띄우고 false를 반환한다', () async {
    // Arrange
    when(mockQuotaService.consume(model)).thenAnswer(
      (_) async => QuotaConsumeResult(
        status: QuotaConsumeStatus.exhausted,
        quota: dummySnapshot,
      ),
    );
    when(mockAdService.showRewardedAd(model: model)).thenAnswer(
      (_) async => const AdRewardResult(status: AdRewardStatus.unavailable, message: '광고 로드 실패'),
    );

    String? emittedMessage;

    // Act
    final result = await usecase.execute(
      model: model,
      onAllowed: () async {},
      onNeedAd: () async => true, // 사용자가 광고 동의
      onMessage: (msg) {
        emittedMessage = msg;
      },
    );

    // Assert
    expect(result, isFalse);
    expect(emittedMessage, '광고 로드 실패');
    verify(mockAdService.showRewardedAd(model: model)).called(1);
    verifyNever(mockQuotaService.reward(model)); // 충전 호출 안 됨
  });

  test('광고 시청 성공 후 재시도 시 할당량 획득에 성공하면, 파이프라인(onAllowed)이 실행되고 true를 반환한다', () async {
    // Arrange
    int consumeCallCount = 0;
    when(mockQuotaService.consume(model)).thenAnswer((_) async {
      consumeCallCount++;
      // 첫 번째 호출: 고갈, 두 번째 호출: 성공
      if (consumeCallCount == 1) {
        return QuotaConsumeResult(status: QuotaConsumeStatus.exhausted, quota: dummySnapshot);
      } else {
        return QuotaConsumeResult(status: QuotaConsumeStatus.consumedRewarded, quota: dummySnapshot);
      }
    });

    when(mockAdService.showRewardedAd(model: model)).thenAnswer(
      (_) async => const AdRewardResult(status: AdRewardStatus.rewarded, message: '광고 시청 완료 텍스트'),
    );

    bool allowedCalled = false;
    String? emittedMessage;

    // Act
    final result = await usecase.execute(
      model: model,
      onAllowed: () async { allowedCalled = true; },
      onNeedAd: () async => true,
      onMessage: (msg) { emittedMessage = msg; },
    );

    // Assert
    expect(result, isTrue);
    expect(allowedCalled, isTrue);
    expect(emittedMessage, '광고 시청 완료 텍스트');
    verify(mockQuotaService.reward(model)).called(1);
    verify(mockQuotaService.consume(model)).called(2);
  });

  test('광고 시청은 성공했으나, 알 수 없는 오류로 할당량 충전/재시도 후에도 고갈 상태면 에러 메시지와 함께 false를 반환한다', () async {
    // Arrange
    // 항상 고갈 결과 반환
    when(mockQuotaService.consume(model)).thenAnswer(
      (_) async => QuotaConsumeResult(
        status: QuotaConsumeStatus.exhausted,
        quota: dummySnapshot,
      ),
    );

    when(mockAdService.showRewardedAd(model: model)).thenAnswer(
      (_) async => const AdRewardResult(status: AdRewardStatus.rewarded), // 보상은 받음
    );

    String? emittedMessage;

    // Act
    final result = await usecase.execute(
      model: model,
      onAllowed: () async {},
      onNeedAd: () async => true,
      onMessage: (msg) { emittedMessage = msg; },
    );

    // Assert
    expect(result, isFalse);
    expect(emittedMessage, '충전 후에도 사용권을 확보하지 못했습니다.');
    verify(mockQuotaService.reward(model)).called(1);
    verify(mockQuotaService.consume(model)).called(2);
  });
}

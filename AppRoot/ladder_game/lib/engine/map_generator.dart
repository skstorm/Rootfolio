import 'dart:math';
import '../models/ladder_models.dart';

class MapGenerator {
  final Random _random;

  MapGenerator({int? seed}) : _random = Random(seed);

  /// 사다리 지도를 생성합니다.
  /// [columnCount]: 수직선 개수
  /// [rowSlotCount]: 가로선을 놓을 수 있는 최대 높이 단계
  /// [density]: 가로선이 생성될 확률 (0.0 ~ 1.0)
  LadderMap generate({
    required int columnCount,
    required int rowSlotCount,
    required double density,
  }) {
    List<List<LadderPoint>> columns = List.generate(columnCount, (_) => []);

    for (int row = 0; row < rowSlotCount; row++) {
      // Y 좌표를 슬롯에 따라 균등 배분 (0.1 ~ 0.9 사이)
      double y = (row + 1) / (rowSlotCount + 1);
      
      // 해당 층(row)에서 이미 연결이 발생한 컬럼 추적 (중복/교차 방지)
      List<bool> hasConnection = List.filled(columnCount, false);

      for (int col = 0; col < columnCount - 1; col++) {
        if (hasConnection[col] || hasConnection[col + 1]) continue;

        if (_random.nextDouble() < density) {
          // col 과 col + 1 사이에 가로선 생성
          columns[col].add(LadderPoint(
            x: col.toDouble(),
            y: y,
            connectedColumnIndex: col + 1,
          ));
          columns[col + 1].add(LadderPoint(
            x: (col + 1).toDouble(),
            y: y,
            connectedColumnIndex: col,
          ));
          
          hasConnection[col] = true;
          hasConnection[col + 1] = true;
        }
      }
    }

    // 각 컬럼의 절점들을 Y축 기준(위에서 아래로) 정렬
    for (var column in columns) {
      column.sort((a, b) => a.y.compareTo(b.y));
    }

    return LadderMap(columnCount: columnCount, columns: columns);
  }
}

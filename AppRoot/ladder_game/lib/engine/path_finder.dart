import 'dart:ui';
import '../models/ladder_models.dart';

class PathFinder {
  /// 특정 시작점에서의 사다리 타기 경로를 계산합니다.
  static List<Offset> getPath(LadderMap map, int startColumnIndex) {
    List<Offset> path = [];
    int currentCol = startColumnIndex;
    double currentY = 0.0;

    // 1. 시작점 추가 (최상단)
    path.add(Offset(currentCol.toDouble(), 0.0));

    while (currentY < 1.0) {
      // 2. 현재 컬럼에서 현재 높이(currentY)보다 아래에 있는 가장 가까운 절점 찾기
      final columnPoints = map.columns[currentCol];
      LadderPoint? nextPoint;
      
      for (var p in columnPoints) {
        if (p.y > currentY) {
          nextPoint = p;
          break;
        }
      }

      if (nextPoint != null) {
        // 3. 수직 이동 (절점까지 내려감)
        path.add(Offset(currentCol.toDouble(), nextPoint.y));
        
        // 4. 수평 이동 (옆 컬럼으로 건너감)
        currentCol = nextPoint.connectedColumnIndex;
        currentY = nextPoint.y;
        path.add(Offset(currentCol.toDouble(), currentY));
      } else {
        // 5. 더 이상 절점이 없으면 최하단까지 직진
        currentY = 1.0;
        path.add(Offset(currentCol.toDouble(), 1.0));
      }
    }

    return path;
  }
}

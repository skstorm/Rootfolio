class LadderPoint {
  final double x; // 컬럼 인덱스 (0 ~ N-1)
  final double y; // 수직 위치 비율 (0.0 ~ 1.0)
  
  // 연결된 옆 컬럼의 인덱스 (x-1 또는 x+1)
  final int connectedColumnIndex;

  LadderPoint({
    required this.x,
    required this.y,
    required this.connectedColumnIndex,
  });
}

class LadderMap {
  final int columnCount;
  final List<List<LadderPoint>> columns; // 각 수직선별 포함된 절점 리스트

  LadderMap({
    required this.columnCount,
    required this.columns,
  });
}

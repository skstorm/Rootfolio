import 'package:flutter/material.dart';
import '../engine/map_generator.dart';
import '../engine/path_finder.dart';
import '../models/ladder_models.dart';

class GameProvider extends ChangeNotifier {
  LadderMap? _map;
  LadderMap? get map => _map;

  final MapGenerator _generator = MapGenerator();
  
  // 애니메이션 관련 상태
  List<Offset> _currentPath = [];
  List<Offset> get currentPath => _currentPath;

  double _animationProgress = 0.0;
  double get animationProgress => _animationProgress;

  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

  Offset? _currentPlayerPos;
  Offset? get currentPlayerPos => _currentPlayerPos;

  void generateNewMap({
    int columnCount = 5, 
    int rowCount = 15, 
    double density = 0.6,
  }) {
    _map = _generator.generate(
      columnCount: columnCount,
      rowSlotCount: rowCount,
      density: density,
    );
    _currentPath = [];
    _currentPlayerPos = null;
    _isAnimating = false;
    notifyListeners();
  }

  void startAnimation(int startCol) {
    if (_map == null) return;
    _currentPath = PathFinder.getPath(_map!, startCol);
    _isAnimating = true;
    _animationProgress = 0.0;
    _currentPlayerPos = _currentPath.first;
    notifyListeners();
  }

  void updateAnimation(double progress) {
    if (!_isAnimating || _currentPath.isEmpty) return;
    
    _animationProgress = progress;
    
    // 경로 상의 현재 위치 계산
    int totalSegments = _currentPath.length - 1;
    double segmentProgress = progress * totalSegments;
    int currentIndex = segmentProgress.floor();
    double localProgress = segmentProgress - currentIndex;

    if (currentIndex >= totalSegments) {
      _currentPlayerPos = _currentPath.last;
      _isAnimating = false;
    } else {
      Offset start = _currentPath[currentIndex];
      Offset end = _currentPath[currentIndex + 1];
      _currentPlayerPos = Offset.lerp(start, end, localProgress);
    }
    
    notifyListeners();
  }

  void clearMap() {
    _map = null;
    _currentPath = [];
    _currentPlayerPos = null;
    _isAnimating = false;
    notifyListeners();
  }
}

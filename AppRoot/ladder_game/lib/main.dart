import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import './providers/game_provider.dart';
import './renderer/ladder_painter.dart';
import './widgets/setup_widget.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const LadderGameApp(),
    ),
  );
}

class LadderGameApp extends StatelessWidget {
  const LadderGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electric Roots - Ghost Leg',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF10B981),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF34D399),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const GameView(),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addListener(() {
      context.read<GameProvider>().updateAnimation(_controller.value);
      _updateCamera();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _updateCamera() {
    final provider = context.read<GameProvider>();
    if (provider.isAnimating && provider.currentPlayerPos != null) {
      final pos = provider.currentPlayerPos!;
      final Size size = MediaQuery.of(context).size;
      final double colWidth = (size.width * 0.8) / (provider.map!.columnCount - 1 + 2);
      final double startX = colWidth;
      final double boardHeight = size.height * 0.7;

      // 캐릭터 위치를 타겟으로 카메라 줌인 효과
      double targetX = startX + (pos.dx * colWidth);
      double targetY = pos.dy * boardHeight;

      // 중앙 맞춤 및 줌 조정 (Matrix4)
      final zoom = 1.5;
      final matrix = Matrix4.identity()
        ..scale(zoom)
        ..translate(-targetX + (size.width / (2 * zoom)), -targetY + (size.height / (2 * zoom)));
      
      _transformationController.value = matrix;
    } else {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final map = provider.map;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. 배경 장식 (텍스트 로고)
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Center(
                  child: FittedBox(
                    child: Text(
                      'ELECTRIC\nROOTS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 200,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. 사다리 게임 캔버스
            if (map != null)
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(200),
                  minScale: 0.1,
                  maxScale: 3.0,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10),
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GestureDetector(
                        onTapUp: (details) {
                          if (provider.isAnimating) return;
                          
                          final double colWidth = (MediaQuery.of(context).size.width * 0.9) / (map.columnCount - 1 + 2);
                          final double startX = colWidth;
                          final int colIndex = ((details.localPosition.dx - startX + (colWidth / 2)) / colWidth).floor();
                          
                          if (colIndex >= 0 && colIndex < map.columnCount) {
                            provider.startAnimation(colIndex);
                            _controller.forward(from: 0.0);
                          }
                        },
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: LadderPainter(
                            map: map,
                            activePaths: [provider.currentPath],
                            themeColor: Theme.of(context).primaryColor,
                            currentPlayerPos: provider.currentPlayerPos,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. 상단 헤더
            if (!provider.isAnimating)
              Positioned(
                top: 30,
                child: Text(
                  'GHOST LEG',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

            // 4. 설정 UI
            if (map == null)
              const Center(
                child: SingleChildScrollView(
                  child: SetupWidget(),
                ),
              ),

            // 5. 초기화 버튼
            if (map != null && !provider.isAnimating)
              Positioned(
                bottom: 30,
                right: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    provider.clearMap();
                    _transformationController.value = Matrix4.identity();
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.refresh, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

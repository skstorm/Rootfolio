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
      // _updateCamera(); // 카메라 움직임 제거
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _updateCamera() {
    // 카메라 움직임 기능을 비활성화했습니다. (어지러움 방지)
    _transformationController.value = Matrix4.identity();
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
                      child: Stack(
                        children: [
                          // 2.1 사다리 본체 레이어
                          Positioned.fill(
                            child: CustomPaint(
                              painter: LadderPainter(
                                map: map,
                                activePaths: [provider.currentPath],
                                themeColor: Theme.of(context).primaryColor,
                                animationProgress: provider.animationProgress,
                              ),
                            ),
                          ),
                          // 2.2 상단 시작 버튼 레이어
                          if (!provider.isAnimating)
                            ...List.generate(map.columnCount, (index) {
                              final double colWidth = (MediaQuery.of(context).size.width * 0.9) / (map.columnCount - 1 + 2);
                              final double startX = colWidth;
                              return Positioned(
                                top: 0,
                                left: startX + (index * colWidth) - 20,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      provider.startAnimation(index);
                                      _controller.forward(from: 0.0);
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 60,
                                      color: Colors.transparent,
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.power,
                                            color: Theme.of(context).primaryColor,
                                            size: 24,
                                          ),
                                          Container(
                                            width: 4,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
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

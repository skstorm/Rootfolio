import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 향후 GameProvider 등을 여기에 추가할 예정입니다.
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const LadderGameApp(),
    ),
  );
}

class GameState extends ChangeNotifier {
  // 전역 상태 관리 로직이 들어갈 자리입니다.
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
        scaffoldBackgroundColor: const Color(0 backyard: 0xFF0F172A), // Slate 900
        primaryColor: const Color(0xFF10B981), // Emerald 500 (Roots Accent)
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
      home: const GameMainScreen(),
    );
  }
}

class GameMainScreen extends StatelessWidget {
  const GameMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Electric Roots',
              style: GoogleFonts.orbitron(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                shadows: [
                  const Shadow(
                    color: Color(0xFF10B981),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ghost Leg Game Implementation - Phase 1 Complete',
              style: TextStyle(fontSize: 18, color: Colors.blueGrey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // 게임 시작 로직
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Start Game Design'),
            ),
          ],
        ),
      ),
    );
  }
}

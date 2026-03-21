import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class RevealParticle extends StatefulWidget {
  final Widget child; // 메인 콘텐츠 
  final int triggerId; // 폭발 발동 이벤트 ID
  final Clip clipBehavior; // 클리핑 동작

  const RevealParticle({
    super.key,
    required this.child,
    required this.triggerId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  State<RevealParticle> createState() => _RevealParticleState();
}

class _RevealParticleState extends State<RevealParticle> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void didUpdateWidget(RevealParticle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerId != oldWidget.triggerId) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: widget.clipBehavior,
      alignment: Alignment.center,
      children: [
        widget.child,
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive, // 사방으로 퍼짐
          shouldLoop: false,
          colors: const [
            Colors.yellow, Colors.blue, Colors.pink, Colors.orange, Colors.purple
          ],
        ),
      ],
    );
  }
}

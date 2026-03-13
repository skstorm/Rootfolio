import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_names.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Anime Title Academy 에\n오신 것을 환영합니다!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('당신의 일상을 극적인 애니메이션의 한 장면처럼 만들어줍니다.'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.goNamed(RouteNames.home); 
                // TODO: 실제 동작에서는 Permission 페이지를 거치도록 수정
              },
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}

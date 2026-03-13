import 'package:flutter/material.dart';

class ShareBottomSheet extends StatelessWidget {
  final VoidCallback onSavePressed;
  final VoidCallback onSharePressed;

  const ShareBottomSheet({
    super.key,
    required this.onSavePressed,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('어떻게 할까요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('기기에 저장하기'),
            onPressed: () {
              Navigator.pop(context);
              onSavePressed();
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('다른 앱으로 공유'),
            onPressed: () {
              Navigator.pop(context);
              onSharePressed();
            },
          ),
        ],
      ),
    );
  }
}

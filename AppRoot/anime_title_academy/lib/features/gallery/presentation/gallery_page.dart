import 'package:flutter/material.dart';
import 'gallery_item_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('히스토리 갤러리')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 6, // 임시 데이터 개수
        itemBuilder: (context, index) {
          return GalleryItemCard(
            title: '생성된 자막 #$index',
            onTap: () {
              // 탭 시 상세(결과) 화면 이동 등 처리
            },
          );
        },
      ),
    );
  }
}

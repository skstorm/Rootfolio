import 'package:flutter/material.dart';

class GalleryItemCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const GalleryItemCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[800],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }
}

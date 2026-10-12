import 'package:flutter/material.dart';

/// 둥근 모서리 네트워크 이미지. 주소가 틀려도 빈 칸으로 둔다.
class AlbumThumb extends StatelessWidget {
  const AlbumThumb(this.url, {super.key, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      url,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (_, _, _) => SizedBox.square(dimension: size),
    ),
  );
}

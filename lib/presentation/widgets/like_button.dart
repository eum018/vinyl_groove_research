import 'package:flutter/material.dart';

import '../../core/scope.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';

/// 하트. 누르면 잠깐 커졌다가 관심상품을 넣고 뺀다.
class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.album, this.size = 18});

  final AlbumModel album;
  final double size;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final _pressed = ValueNotifier(false);

  Future<void> _tap() async {
    final likes = context.deps.likes;
    _pressed.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (mounted) _pressed.value = false;
    await likes.toggle(widget.album); // 그 사이 화면이 바뀌어도 누른 건 반영한다
  }

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final likes = context.deps.likes;
    return ValueListenableBuilder(
      valueListenable: _pressed,
      builder: (context, pressed, child) => AnimatedScale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        scale: pressed ? 1.4 : 1,
        child: child,
      ),
      child: ListenableBuilder(
        listenable: likes,
        builder: (context, _) => _Heart(
          on: likes.contains(widget.album),
          size: widget.size,
          onPressed: _tap,
        ),
      ),
    );
  }
}

class _Heart extends StatelessWidget {
  const _Heart({required this.on, required this.size, required this.onPressed});

  final bool on;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    key: const Key('like'),
    style: IconButton.styleFrom(
      backgroundColor: AppColor.dim,
      minimumSize: Size.zero,
    ),
    onPressed: onPressed,
    icon: Icon(
      on ? Icons.favorite : Icons.favorite_outline,
      size: size,
      color: on ? AppColor.red : AppColor.white,
    ),
  );
}

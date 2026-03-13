import 'package:flutter/material.dart';
import '../models/avatar.dart';
import '../painters/human_avatar_painter.dart';

/// Avatar humain personnalisé, rendu dans un cercle.
/// [size] = diamètre du cercle.
class AvatarWidget extends StatelessWidget {
  final Avatar avatar;
  final double size;

  const AvatarWidget({super.key, required this.avatar, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: HumanAvatarPainter(avatar),
        ),
      ),
    );
  }
}

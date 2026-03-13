import 'package:flutter/material.dart';
import '../models/avatar.dart';

/// Dessine un avatar humain stylisé dans un canvas virtuel 200×200.
/// Conçu pour être utilisé dans un ClipOval (cercle).
class HumanAvatarPainter extends CustomPainter {
  final Avatar avatar;

  const HumanAvatarPainter(this.avatar);

  // Canvas virtuel
  static const double _s = 200.0;

  // Géométrie du visage
  static const double _fcx = 100.0;
  static const double _fcy = 97.0;
  static const double _frx = 52.0;
  static const double _fry = 60.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _s, size.height / _s);

    _drawBackground(canvas);
    _drawClothing(canvas);
    _drawNeck(canvas);
    _drawEars(canvas);
    _drawHairBack(canvas);
    _drawFace(canvas);
    _drawEyes(canvas);
    _drawEyebrows(canvas);
    _drawNose(canvas);
    _drawMouth(canvas);
    _drawHairFront(canvas);

    canvas.restore();
  }

  @override
  bool shouldRepaint(HumanAvatarPainter old) => avatar != old.avatar;

  // ── Helpers ───────────────────────────────────────────────────────────────

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  // ── Background ────────────────────────────────────────────────────────────

  void _drawBackground(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _s, _s),
      _fill(const Color(0xFFDDE0F0)),
    );
  }

  // ── Vêtements ─────────────────────────────────────────────────────────────

  void _drawClothing(Canvas canvas) {
    final color = avatar.clothingColor;
    final dark = _darken(color, 0.18);
    final style = avatar.clothingStyleIndex;
    final path = Path();

    switch (style) {
      case 0: // T-shirt — col rond
        path
          ..moveTo(58, 178)
          ..quadraticBezierTo(78, 170, 100, 170)
          ..quadraticBezierTo(122, 170, 142, 178)
          ..lineTo(168, 225)
          ..lineTo(32, 225)
          ..close();
        canvas.drawPath(path, _fill(color));
        canvas.drawPath(
          Path()
            ..moveTo(80, 170)
            ..quadraticBezierTo(100, 181, 120, 170),
          _stroke(dark, 2.0),
        );

      case 1: // Sweat — col rond large
        path
          ..moveTo(50, 177)
          ..quadraticBezierTo(74, 168, 100, 168)
          ..quadraticBezierTo(126, 168, 150, 177)
          ..lineTo(178, 225)
          ..lineTo(22, 225)
          ..close();
        canvas.drawPath(path, _fill(color));
        canvas.drawPath(
          Path()
            ..moveTo(76, 168)
            ..quadraticBezierTo(100, 180, 124, 168),
          _stroke(dark, 2.5),
        );

      case 2: // Costume
        // Chemise blanche
        canvas.drawPath(
          Path()
            ..moveTo(88, 175)
            ..lineTo(100, 190)
            ..lineTo(112, 175)
            ..lineTo(122, 225)
            ..lineTo(78, 225)
            ..close(),
          _fill(const Color(0xFFF0EDE8)),
        );
        // Cravate
        canvas.drawPath(
          Path()
            ..moveTo(97, 177)
            ..lineTo(100, 184)
            ..lineTo(103, 177)
            ..lineTo(101.5, 200)
            ..lineTo(100, 206)
            ..lineTo(98.5, 200)
            ..close(),
          _fill(const Color(0xFF880000)),
        );
        // Veste
        path
          ..moveTo(50, 178)
          ..lineTo(88, 175)
          ..lineTo(100, 190)
          ..lineTo(112, 175)
          ..lineTo(150, 178)
          ..lineTo(175, 225)
          ..lineTo(25, 225)
          ..close();
        canvas.drawPath(path, _fill(color));
        // Revers
        canvas.drawPath(
          Path()
            ..moveTo(88, 175)
            ..lineTo(80, 164)
            ..lineTo(100, 190),
          _fill(_darken(color, 0.08)),
        );
        canvas.drawPath(
          Path()
            ..moveTo(112, 175)
            ..lineTo(120, 164)
            ..lineTo(100, 190),
          _fill(_darken(color, 0.08)),
        );

      case 3: // Robe
        path
          ..moveTo(44, 180)
          ..quadraticBezierTo(70, 168, 100, 168)
          ..quadraticBezierTo(130, 168, 156, 180)
          ..quadraticBezierTo(178, 205, 182, 225)
          ..lineTo(18, 225)
          ..quadraticBezierTo(22, 205, 44, 180)
          ..close();
        canvas.drawPath(path, _fill(color));
        canvas.drawPath(
          Path()
            ..moveTo(72, 168)
            ..quadraticBezierTo(86, 176, 100, 175)
            ..quadraticBezierTo(114, 176, 128, 168),
          _stroke(dark, 1.5),
        );

      case 4: // Débardeur
        path
          ..moveTo(72, 180)
          ..lineTo(76, 168)
          ..lineTo(90, 164)
          ..lineTo(110, 164)
          ..lineTo(124, 168)
          ..lineTo(128, 180)
          ..lineTo(158, 225)
          ..lineTo(42, 225)
          ..close();
        canvas.drawPath(path, _fill(color));
        canvas.drawPath(
          Path()
            ..moveTo(90, 164)
            ..quadraticBezierTo(100, 173, 110, 164),
          _stroke(dark, 1.5),
        );

      default:
        path.addRect(const Rect.fromLTRB(30, 175, 170, 225));
        canvas.drawPath(path, _fill(color));
    }
  }

  // ── Cou ───────────────────────────────────────────────────────────────────

  void _drawNeck(Canvas canvas) {
    final skin = avatar.skinColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(88, 153, 112, 183),
        const Radius.circular(4),
      ),
      _fill(skin),
    );
    final dark = _darken(skin, 0.10);
    canvas.drawLine(const Offset(88, 154), const Offset(88, 181), _stroke(dark, 1.2));
    canvas.drawLine(const Offset(112, 154), const Offset(112, 181), _stroke(dark, 1.2));
  }

  // ── Oreilles ──────────────────────────────────────────────────────────────

  void _drawEars(Canvas canvas) {
    final skin = avatar.skinColor;
    final dark = _darken(skin, 0.14);
    for (final x in [47.0, 153.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 100), width: 18, height: 24),
        _fill(skin),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 100), width: 18, height: 24),
        _stroke(dark, 1.0),
      );
      // Conque (détail interne)
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 100), width: 8, height: 12),
        _stroke(dark, 1.0),
      );
    }
  }

  // ── Visage ────────────────────────────────────────────────────────────────

  void _drawFace(Canvas canvas) {
    final skin = avatar.skinColor;
    final dark = _darken(skin, 0.10);
    final faceRect = Rect.fromCenter(
      center: const Offset(_fcx, _fcy),
      width: _frx * 2,
      height: _fry * 2,
    );
    canvas.drawOval(faceRect, _fill(skin));

    // Joues rosées
    final cheek = Color.lerp(skin, const Color(0xFFFF9E9E), 0.18)!;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(74, 112), width: 24, height: 15),
      _fill(cheek.withValues(alpha: 0.38)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(126, 112), width: 24, height: 15),
      _fill(cheek.withValues(alpha: 0.38)),
    );

    // Contour visage
    canvas.drawOval(faceRect, _stroke(dark, 1.2));
  }

  // ── Cheveux arrière ───────────────────────────────────────────────────────

  void _drawHairBack(Canvas canvas) {
    final style = avatar.hairStyleIndex;
    if (style == 6) return; // chauve
    final color = avatar.hairColor;

    switch (style) {
      case 2: // Long lisse
        canvas.drawPath(
          Path()
            ..moveTo(48, 108)
            ..lineTo(40, 195)
            ..lineTo(60, 195)
            ..lineTo(62, 112)
            ..close(),
          _fill(color),
        );
        canvas.drawPath(
          Path()
            ..moveTo(152, 108)
            ..lineTo(160, 195)
            ..lineTo(140, 195)
            ..lineTo(138, 112)
            ..close(),
          _fill(color),
        );

      case 3: // Long ondulé
        canvas.drawPath(
          Path()
            ..moveTo(48, 108)
            ..quadraticBezierTo(36, 132, 42, 155)
            ..quadraticBezierTo(36, 174, 42, 195)
            ..lineTo(62, 195)
            ..quadraticBezierTo(56, 174, 62, 155)
            ..quadraticBezierTo(68, 130, 62, 112)
            ..close(),
          _fill(color),
        );
        canvas.drawPath(
          Path()
            ..moveTo(152, 108)
            ..quadraticBezierTo(164, 132, 158, 155)
            ..quadraticBezierTo(164, 174, 158, 195)
            ..lineTo(138, 195)
            ..quadraticBezierTo(144, 174, 138, 155)
            ..quadraticBezierTo(132, 130, 138, 112)
            ..close(),
          _fill(color),
        );
    }
  }

  // ── Yeux ─────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas) {
    final eyeShape = avatar.eyeShapeIndex;
    final eyeColor = avatar.eyeColor;
    final double eyeRx = eyeShape == 1 ? 12.0 : 10.0;
    final double eyeRy = eyeShape == 1 ? 11.0 : (eyeShape == 2 ? 6.0 : 9.0);

    for (final cx in [78.0, 122.0]) {
      const cy = 88.0;

      // Blanc de l'œil
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: eyeRx * 2, height: eyeRy * 2),
        _fill(Colors.white),
      );

      // Iris
      final irisR = eyeRy * 0.74;
      canvas.drawCircle(Offset(cx, cy), irisR, _fill(eyeColor));

      // Pupille
      canvas.drawCircle(Offset(cx, cy), irisR * 0.52, _fill(const Color(0xFF0D0D0D)));

      // Reflet
      canvas.drawCircle(
        Offset(cx + 2.8, cy - 2.8),
        irisR * 0.24,
        _fill(Colors.white.withValues(alpha: 0.90)),
      );

      // Contour
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: eyeRx * 2, height: eyeRy * 2),
        _stroke(const Color(0xFF2A1A0A), 1.0),
      );

      // Paupière supérieure
      canvas.drawPath(
        Path()
          ..moveTo(cx - eyeRx, cy)
          ..quadraticBezierTo(cx, cy - eyeRy * 1.15, cx + eyeRx, cy),
        _stroke(const Color(0xFF1A0A00), 1.6),
      );
    }
  }

  // ── Sourcils ──────────────────────────────────────────────────────────────

  void _drawEyebrows(Canvas canvas) {
    if (avatar.hairStyleIndex == 6) return; // chauve
    final color = _darken(avatar.hairColor, 0.04);
    final paint = _stroke(color, 3.8);

    canvas.drawPath(
      Path()
        ..moveTo(64, 75)
        ..quadraticBezierTo(78, 70, 93, 73),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(107, 73)
        ..quadraticBezierTo(122, 70, 136, 75),
      paint,
    );
  }

  // ── Nez ───────────────────────────────────────────────────────────────────

  void _drawNose(Canvas canvas) {
    final skin = avatar.skinColor;
    final shadow = _darken(skin, 0.24);
    final noseSize = avatar.noseSizeIndex;

    final double spread = noseSize == 0 ? 7.0 : (noseSize == 1 ? 10.0 : 13.0);
    final double nostrilRx = noseSize == 0 ? 3.2 : (noseSize == 1 ? 4.2 : 5.5);
    final double nostrilRy = nostrilRx * 0.75;
    final double bridgeTop = noseSize == 0 ? 100.0 : (noseSize == 1 ? 97.0 : 95.0);

    // Pont du nez
    canvas.drawPath(
      Path()
        ..moveTo(97, bridgeTop)
        ..quadraticBezierTo(93, 108, 100 - spread / 2, 113)
        ..moveTo(103, bridgeTop)
        ..quadraticBezierTo(107, 108, 100 + spread / 2, 113),
      _stroke(shadow, 1.2),
    );

    // Narines
    canvas.drawOval(
      Rect.fromCenter(center: Offset(100 - spread / 2, 113), width: nostrilRx * 2, height: nostrilRy * 2),
      _fill(shadow),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(100 + spread / 2, 113), width: nostrilRx * 2, height: nostrilRy * 2),
      _fill(shadow),
    );
  }

  // ── Bouche ────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas) {
    final skin = avatar.skinColor;
    final lipColor = Color.lerp(skin, const Color(0xFFC0605A), 0.52)!;
    final darkLip = _darken(lipColor, 0.22);
    final mouthStyle = avatar.mouthStyleIndex;

    switch (mouthStyle) {
      case 1: // Neutre
        canvas.drawLine(
          const Offset(88, 130),
          const Offset(112, 130),
          _stroke(darkLip, 2.5),
        );

      case 2: // Grand sourire
        // Dents
        canvas.drawPath(
          Path()
            ..moveTo(87, 128)
            ..quadraticBezierTo(100, 143, 113, 128)
            ..quadraticBezierTo(100, 135, 87, 128)
            ..close(),
          _fill(Colors.white),
        );
        // Séparation dents
        canvas.drawLine(const Offset(93, 128), const Offset(107, 128), _stroke(const Color(0xFFDDDDDD), 0.8));
        // Arc extérieur
        canvas.drawPath(
          Path()
            ..moveTo(84, 126)
            ..quadraticBezierTo(100, 144, 116, 126),
          _stroke(darkLip, 2.5),
        );
        // Arc lèvre supérieure
        canvas.drawPath(
          Path()
            ..moveTo(84, 126)
            ..quadraticBezierTo(92, 122, 100, 123)
            ..quadraticBezierTo(108, 122, 116, 126),
          _stroke(darkLip, 1.5),
        );

      default: // Sourire (0)
        canvas.drawPath(
          Path()
            ..moveTo(88, 128)
            ..quadraticBezierTo(100, 137, 112, 128),
          _stroke(darkLip, 2.5),
        );
        // Lèvre supérieure
        canvas.drawPath(
          Path()
            ..moveTo(88, 128)
            ..quadraticBezierTo(94, 125, 100, 126)
            ..quadraticBezierTo(106, 125, 112, 128),
          _stroke(lipColor, 1.2),
        );
    }
  }

  // ── Cheveux (avant) ───────────────────────────────────────────────────────

  void _drawHairFront(Canvas canvas) {
    final style = avatar.hairStyleIndex;
    if (style == 6) return; // chauve
    final color = avatar.hairColor;
    final dark = _darken(color, 0.14);
    final shine = _lighten(color, 0.20);

    switch (style) {
      case 0: // Court
        canvas.drawPath(
          Path()
            ..moveTo(48, 96)
            ..quadraticBezierTo(50, 22, 100, 20)
            ..quadraticBezierTo(150, 22, 152, 96)
            ..quadraticBezierTo(142, 74, 100, 71)
            ..quadraticBezierTo(58, 74, 48, 96)
            ..close(),
          _fill(color),
        );
        _hairShine(canvas, shine);

      case 1: // Mi-long
        canvas.drawPath(
          Path()
            ..moveTo(46, 110)
            ..quadraticBezierTo(48, 22, 100, 20)
            ..quadraticBezierTo(152, 22, 154, 110)
            ..quadraticBezierTo(148, 78, 100, 75)
            ..quadraticBezierTo(52, 78, 46, 110)
            ..close(),
          _fill(color),
        );
        // Mèches latérales descendant jusqu'aux épaules
        canvas.drawPath(
          Path()
            ..moveTo(48, 110)
            ..quadraticBezierTo(44, 120, 46, 135)
            ..lineTo(58, 135)
            ..quadraticBezierTo(57, 120, 60, 110)
            ..close(),
          _fill(color),
        );
        canvas.drawPath(
          Path()
            ..moveTo(152, 110)
            ..quadraticBezierTo(156, 120, 154, 135)
            ..lineTo(142, 135)
            ..quadraticBezierTo(143, 120, 140, 110)
            ..close(),
          _fill(color),
        );
        _hairShine(canvas, shine);

      case 2: // Long lisse — bonnet
        canvas.drawPath(
          Path()
            ..moveTo(46, 110)
            ..quadraticBezierTo(48, 22, 100, 20)
            ..quadraticBezierTo(152, 22, 154, 110)
            ..quadraticBezierTo(148, 78, 100, 75)
            ..quadraticBezierTo(52, 78, 46, 110)
            ..close(),
          _fill(color),
        );
        _hairShine(canvas, shine);

      case 3: // Long ondulé — bonnet
        canvas.drawPath(
          Path()
            ..moveTo(46, 110)
            ..quadraticBezierTo(48, 22, 100, 20)
            ..quadraticBezierTo(152, 22, 154, 110)
            ..quadraticBezierTo(148, 78, 100, 75)
            ..quadraticBezierTo(52, 78, 46, 110)
            ..close(),
          _fill(color),
        );
        _hairShine(canvas, shine);

      case 4: // Chignon
        // Calotte fine
        canvas.drawPath(
          Path()
            ..moveTo(54, 92)
            ..quadraticBezierTo(54, 30, 100, 26)
            ..quadraticBezierTo(146, 30, 146, 92)
            ..quadraticBezierTo(138, 68, 100, 65)
            ..quadraticBezierTo(62, 68, 54, 92)
            ..close(),
          _fill(color),
        );
        // Chignon
        canvas.drawCircle(const Offset(100, 22), 20, _fill(color));
        canvas.drawCircle(const Offset(100, 22), 20, _stroke(dark, 1.5));
        canvas.drawCircle(
          const Offset(93, 15),
          5,
          _fill(shine.withValues(alpha: 0.5)),
        );
        _hairShine(canvas, shine);

      case 5: // Bouclé/Afro
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(100, 78), width: 138, height: 112),
          _fill(color),
        );
        // Texture (points plus foncés)
        for (final pos in [
          const Offset(66, 52), const Offset(86, 42), const Offset(108, 40),
          const Offset(130, 52), const Offset(142, 68), const Offset(134, 90),
          const Offset(62, 72), const Offset(68, 92),
        ]) {
          canvas.drawCircle(pos, 7, _fill(dark.withValues(alpha: 0.28)));
        }

      default:
        canvas.drawPath(
          Path()
            ..moveTo(48, 96)
            ..quadraticBezierTo(50, 22, 100, 20)
            ..quadraticBezierTo(150, 22, 152, 96)
            ..quadraticBezierTo(142, 74, 100, 71)
            ..quadraticBezierTo(58, 74, 48, 96)
            ..close(),
          _fill(color),
        );
        _hairShine(canvas, shine);
    }
  }

  void _hairShine(Canvas canvas, Color shine) {
    canvas.drawPath(
      Path()
        ..moveTo(80, 30)
        ..quadraticBezierTo(100, 24, 120, 30)
        ..quadraticBezierTo(112, 40, 100, 38)
        ..quadraticBezierTo(88, 40, 80, 30)
        ..close(),
      _fill(shine.withValues(alpha: 0.32)),
    );
  }
}

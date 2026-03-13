import 'package:flutter/material.dart';

class Avatar {
  final int skinIndex;
  final int hairStyleIndex;
  final int hairColorIndex;
  final int eyeColorIndex;
  final int eyeShapeIndex;      // 0=normal 1=grand 2=étroit
  final int noseSizeIndex;      // 0=petit 1=moyen 2=grand
  final int mouthStyleIndex;    // 0=sourire 1=neutre 2=grand sourire
  final int clothingStyleIndex; // 0=t-shirt 1=sweat 2=costume 3=robe 4=débardeur
  final int clothingColorIndex;

  const Avatar({
    this.skinIndex = 0,
    this.hairStyleIndex = 0,
    this.hairColorIndex = 0,
    this.eyeColorIndex = 4,
    this.eyeShapeIndex = 0,
    this.noseSizeIndex = 1,
    this.mouthStyleIndex = 0,
    this.clothingStyleIndex = 0,
    this.clothingColorIndex = 6,
  });

  // ── Palettes ──────────────────────────────────────────────────────────────

  static const List<Color> skinTones = [
    Color(0xFFFFE0BD),
    Color(0xFFF1C27D),
    Color(0xFFE8B88A),
    Color(0xFFC68642),
    Color(0xFF8D5524),
    Color(0xFF4A2912),
  ];

  static const List<Color> hairColors = [
    Color(0xFF1A1110), // noir
    Color(0xFF3B1F0E), // brun foncé
    Color(0xFF6B3A2A), // brun
    Color(0xFF8B5E3C), // châtain
    Color(0xFFB8860B), // blond foncé
    Color(0xFFD4AF37), // blond
    Color(0xFFA0522D), // roux
    Color(0xFFC8C8C8), // blanc/gris
  ];

  static const List<Color> eyeColors = [
    Color(0xFF3D1F00), // marron foncé
    Color(0xFF7B4F2E), // marron
    Color(0xFF9B7B3E), // noisette
    Color(0xFF4A7C59), // vert
    Color(0xFF3A6EA5), // bleu
    Color(0xFF7A8A8E), // gris
  ];

  static const List<Color> clothingColors = [
    Color(0xFFF0EDE8), // blanc cassé
    Color(0xFFB8B8C0), // gris clair
    Color(0xFF4A4A5A), // gris foncé
    Color(0xFF1E1E2A), // noir
    Color(0xFF1A2A4A), // marine
    Color(0xFFB03030), // rouge
    Color(0xFF2A5FA8), // bleu
    Color(0xFF2E6B3E), // vert
    Color(0xFF5C3A8A), // violet
    Color(0xFFC8A87A), // beige
  ];

  static const List<String> hairStyleNames = [
    'Court', 'Mi-long', 'Long lisse', 'Long ondulé', 'Chignon', 'Bouclé', 'Chauve',
  ];
  static const List<String> clothingStyleNames = [
    'T-shirt', 'Sweat', 'Costume', 'Robe', 'Débardeur',
  ];
  static const List<String> eyeShapeNames = ['Normal', 'Grand', 'Étroit'];
  static const List<String> noseSizeNames = ['Petit', 'Moyen', 'Grand'];
  static const List<String> mouthStyleNames = ['Sourire', 'Neutre', 'Grand sourire'];

  // ── Getters ───────────────────────────────────────────────────────────────

  Color get skinColor => skinTones[skinIndex];
  Color get hairColor => hairColors[hairColorIndex];
  Color get eyeColor => eyeColors[eyeColorIndex];
  Color get clothingColor => clothingColors[clothingColorIndex];

  // ── Sérialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toFirestore() => {
        'skinIndex': skinIndex,
        'hairStyleIndex': hairStyleIndex,
        'hairColorIndex': hairColorIndex,
        'eyeColorIndex': eyeColorIndex,
        'eyeShapeIndex': eyeShapeIndex,
        'noseSizeIndex': noseSizeIndex,
        'mouthStyleIndex': mouthStyleIndex,
        'clothingStyleIndex': clothingStyleIndex,
        'clothingColorIndex': clothingColorIndex,
      };

  factory Avatar.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const Avatar();
    return Avatar(
      skinIndex: (data['skinIndex'] as int? ?? 0).clamp(0, skinTones.length - 1),
      hairStyleIndex: (data['hairStyleIndex'] as int? ?? 0).clamp(0, hairStyleNames.length - 1),
      hairColorIndex: (data['hairColorIndex'] as int? ?? 0).clamp(0, hairColors.length - 1),
      eyeColorIndex: (data['eyeColorIndex'] as int? ?? 4).clamp(0, eyeColors.length - 1),
      eyeShapeIndex: (data['eyeShapeIndex'] as int? ?? 0).clamp(0, 2),
      noseSizeIndex: (data['noseSizeIndex'] as int? ?? 1).clamp(0, 2),
      mouthStyleIndex: (data['mouthStyleIndex'] as int? ?? 0).clamp(0, 2),
      clothingStyleIndex: (data['clothingStyleIndex'] as int? ?? 0).clamp(0, clothingStyleNames.length - 1),
      clothingColorIndex: (data['clothingColorIndex'] as int? ?? 6).clamp(0, clothingColors.length - 1),
    );
  }

  Avatar copyWith({
    int? skinIndex,
    int? hairStyleIndex,
    int? hairColorIndex,
    int? eyeColorIndex,
    int? eyeShapeIndex,
    int? noseSizeIndex,
    int? mouthStyleIndex,
    int? clothingStyleIndex,
    int? clothingColorIndex,
  }) =>
      Avatar(
        skinIndex: skinIndex ?? this.skinIndex,
        hairStyleIndex: hairStyleIndex ?? this.hairStyleIndex,
        hairColorIndex: hairColorIndex ?? this.hairColorIndex,
        eyeColorIndex: eyeColorIndex ?? this.eyeColorIndex,
        eyeShapeIndex: eyeShapeIndex ?? this.eyeShapeIndex,
        noseSizeIndex: noseSizeIndex ?? this.noseSizeIndex,
        mouthStyleIndex: mouthStyleIndex ?? this.mouthStyleIndex,
        clothingStyleIndex: clothingStyleIndex ?? this.clothingStyleIndex,
        clothingColorIndex: clothingColorIndex ?? this.clothingColorIndex,
      );

  @override
  bool operator ==(Object other) =>
      other is Avatar &&
      skinIndex == other.skinIndex &&
      hairStyleIndex == other.hairStyleIndex &&
      hairColorIndex == other.hairColorIndex &&
      eyeColorIndex == other.eyeColorIndex &&
      eyeShapeIndex == other.eyeShapeIndex &&
      noseSizeIndex == other.noseSizeIndex &&
      mouthStyleIndex == other.mouthStyleIndex &&
      clothingStyleIndex == other.clothingStyleIndex &&
      clothingColorIndex == other.clothingColorIndex;

  @override
  int get hashCode => Object.hash(
        skinIndex, hairStyleIndex, hairColorIndex, eyeColorIndex,
        eyeShapeIndex, noseSizeIndex, mouthStyleIndex,
        clothingStyleIndex, clothingColorIndex,
      );
}

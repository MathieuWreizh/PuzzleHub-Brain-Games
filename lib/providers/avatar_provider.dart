import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar.dart';
import '../services/avatar_service.dart';
import 'auth_provider.dart';

final avatarServiceProvider = Provider<AvatarService>(
  (ref) => AvatarService(),
);

/// Stream de l'avatar de l'utilisateur courant.
final myAvatarProvider = StreamProvider<Avatar>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value(const Avatar());
  return ref.watch(avatarServiceProvider).watchAvatar(uid);
});

/// Notifier permettant d'éditer l'avatar localement avant de sauvegarder.
class AvatarEditorNotifier extends Notifier<Avatar> {
  @override
  Avatar build() => ref.read(myAvatarProvider).maybeWhen(
        data: (a) => a,
        orElse: () => const Avatar(),
      );

  void init(Avatar avatar) => state = avatar;

  void setSkin(int i) => state = state.copyWith(skinIndex: i);
  void setHairStyle(int i) => state = state.copyWith(hairStyleIndex: i);
  void setHairColor(int i) => state = state.copyWith(hairColorIndex: i);
  void setEyeColor(int i) => state = state.copyWith(eyeColorIndex: i);
  void setEyeShape(int i) => state = state.copyWith(eyeShapeIndex: i);
  void setNoseSize(int i) => state = state.copyWith(noseSizeIndex: i);
  void setMouthStyle(int i) => state = state.copyWith(mouthStyleIndex: i);
  void setClothingStyle(int i) => state = state.copyWith(clothingStyleIndex: i);
  void setClothingColor(int i) => state = state.copyWith(clothingColorIndex: i);

  Future<void> save(String uid) async {
    await ref.read(avatarServiceProvider).saveAvatar(uid, state);
  }
}

final avatarEditorProvider =
    NotifierProvider<AvatarEditorNotifier, Avatar>(AvatarEditorNotifier.new);

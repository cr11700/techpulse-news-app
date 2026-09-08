import 'package:flutter/material.dart';
import 'package:tech_pulse/models/user/user_full.dart';
import 'package:tech_pulse/services/supabase_auth_service.dart';

mixin UserAvatarControllerMixin {
  Widget getAvatar({double? size}) {
    if (SupabaseAuthService.to.isLoginned == false) {
      return Icon(Icons.person, size: size);
    }
    if (userProfile == null) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(),
      );
    }
    return userProfile!.getAvatar(radius: size, hero: false);
  }

  UserFull? get userProfile => SupabaseAuthService.to.userProfile;
}

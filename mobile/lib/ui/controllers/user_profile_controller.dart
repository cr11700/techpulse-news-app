import 'package:get/get.dart';
import 'package:tech_pulse/ui/controllers/user_avatar_controller_mixin.dart';

class UserProfileController extends GetxController
    with UserAvatarControllerMixin {
  static UserProfileController get to => Get.find<UserProfileController>();

  void onAvatarPressed() async {
    //TODO: 实现更新头像功能
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/models/user/user_full.dart';
import 'package:tech_pulse/ui/controllers/user_profile_controller.dart';
import 'package:tech_pulse/ui/routes/routes.dart';
import 'package:tech_pulse/ui/widgets/user/curved_background_drawer.dart';

class UserProfilePage extends GetView<UserProfileController> {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      init: UserProfileController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {
                  goNamedRoute(Routes.userSettings);
                },
                icon: Icon(Icons.settings),
                tooltip: '设置',
                color: Colors.white,
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(horizontal: 8.0),
            backgroundColor: Colors.transparent,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              CurvedShape(),
              Column(
                children: [
                  SizedBox(height: 100),
                  Stack(
                    // Align the stack to center the content
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip
                        .none, // Allows widgets to overflow the Stack's bounds
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Obx(() => _buildProfileCard()),
                      ),
                      // 2. The CircleAvatar (the "floating" element)
                      GestureDetector(
                        onTap: controller.onAvatarPressed,
                        child: Obx(
                          () => Hero(
                            tag: ValueKey('MyAvatarHero'),
                            child: CircleAvatar(
                              radius: 50,
                              child: controller.getAvatar(size: 45),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    UserFull myProfile;
    if (controller.userProfile != null) {
      myProfile = controller.userProfile!;
    } else {
      myProfile = UserFull(
        nodeId: '',
        uid: '--',
        name: '加载中',
        avatar: null,
        bio: '',
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 250,
        width: 350,
        child: Card(
          elevation: 8.0, // Gives the card a "floating" shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                Text(
                  myProfile.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  myProfile.bio != '' ? myProfile.bio : '这个人很神秘，什么都没有写',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(child: _buildStatSpan('22', '关注', () {})),
                    Flexible(child: _buildStatSpan('33', '点赞', () {})),
                    Flexible(child: _buildStatSpan('44', '收藏', () {})),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatSpan(
    String content,
    String description,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Column(
            children: [
              Text(content, style: TextStyle(fontSize: 24)),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }
}

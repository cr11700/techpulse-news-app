import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/ui/controllers/user_login_register_controller.dart';
import 'package:tech_pulse/ui/dialogs/eula_confirm_dialog.dart';

class UserLoginPage extends GetView<UserLoginRegisterController> {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserLoginRegisterController>(
      init: UserLoginRegisterController(),
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop == false) {
              controller.goPreviousStep();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: Obx(() => Text(controller.title))),
            body: Center(child: SingleChildScrollView(child: UserLoginForm())),
          ),
        );
      },
    );
  }
}

class UserLoginForm extends GetView<UserLoginRegisterController> {
  const UserLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            const FlutterLogo(size: 80),
            _buildStep(),
            // 操作按钮
            Obx(
              () => IconButton.filled(
                padding: EdgeInsets.all(16),
                onPressed: () => controller.goNextStep(context),
                icon: _buildButtonIcon(),
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Obx(
                  () => Checkbox(
                    value: controller.isPrivacySelected.value,
                    onChanged: (value) {
                      controller.isPrivacySelected.value =
                          !controller.isPrivacySelected.value;
                    },
                  ),
                ),
                const Text("我已阅读并同意："),
                GestureDetector(
                  onTap: () {
                    EULAConfirmDialog.showLicencePage(context);
                  },
                  child: const Text(
                    "《用户协议》《隐私政策》",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonIcon() {
    Widget child;
    if (controller.isLoading.value) {
      child = CircularProgressIndicator(color: Colors.white);
    } else {
      child = Icon(controller.buttonIcon, size: 64);
    }
    return AnimatedSize(
      duration: Duration(milliseconds: 600),
      curve: Curves.fastLinearToSlowEaseIn,
      child: child,
    );
  }

  Widget _buildStep() {
    return Obx(
      () => AnimatedSize(
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        clipBehavior: Clip.none,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          transitionBuilder: (child, animation) {
            Tween<Offset> tween;
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: animation.value == 0
                  ? Curves.fastLinearToSlowEaseIn
                  : Curves.fastLinearToSlowEaseIn.flipped,
            );
            final loginStep = (child.key as ValueKey<LoginStep>).value;
            if (loginStep == controller.lhsStep) {
              // 当前状态下从左侧进入/退出的Widget，LTR
              tween = Tween<Offset>(begin: Offset(-0.8, 0), end: Offset(0, 0));
            } else {
              // 从右到左，RTL
              tween = Tween<Offset>(begin: Offset(0.8, 0), end: Offset(0, 0));
            }
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(curvedAnimation),
              child: SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              ),
            );
          },
          child: controller.currentStep.getWidget(),
        ),
      ),
    );
  }
}

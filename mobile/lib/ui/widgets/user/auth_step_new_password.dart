import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/ui/controllers/user_login_register_controller.dart';
import 'package:tech_pulse/ui/widgets/user/capsule_text_field.dart';

class PasswordStep extends LoginStepWidget {
  const PasswordStep({super.key});

  @override
  Widget build(BuildContext context) {
    UserLoginRegisterController controller = UserLoginRegisterController.to;
    return Column(
      spacing: 8,
      children: [
        Text(
          '输入新密码',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        FilledButton.tonalIcon(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            ),
          ),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text(controller.email, style: TextStyle(fontSize: 16))],
          ),
          icon: const Icon(Icons.account_circle, size: 32),
          onPressed: null,
          clipBehavior: Clip.antiAlias,
        ),
        Obx(
          () => CapsuleTextField(
            controller: controller.passwordController,
            keyboardType: TextInputType.visiblePassword,
            onFieldSubmitted: (String str) {
              controller.goNextStep(context);
            },
            prefixIcon: const Icon(Icons.lock_rounded),
            prompt: '设置新密码',
            obscureText: controller.isObscurePassword.value,
            obscureButtonCallback: () {
              controller.isObscurePassword.value =
                  !controller.isObscurePassword.value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入密码';
              if (value.length < 6) return '密码至少6位';
              return null;
            },
          ),
        ),
      ],
    );
  }
}

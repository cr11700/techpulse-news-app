import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tech_pulse/ui/controllers/user_login_register_controller.dart';
import 'package:tech_pulse/ui/widgets/user/capsule_text_field.dart';

class EmailStep extends LoginStepWidget {
  const EmailStep({super.key});

  @override
  Widget build(BuildContext context) {
    UserLoginRegisterController controller = UserLoginRegisterController.to;
    final loginStep = (key as ValueKey<LoginStep>).value;
    return Column(
      spacing: 16,
      children: [
        Text(
          loginStep == LoginStep.emailLogin ? '登录' : '注册',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text("使用您的邮箱账号"),
        CapsuleTextField(
          prefixIcon: Icon(Icons.email_rounded),
          prompt: '邮箱',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: (String str) {
            controller.goNextStep(context);
          },
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入邮箱';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return '请输入有效的邮箱';
            }
            return null;
          },
        ),
        GestureDetector(
          onTap: () {
            controller.isRegistering = !controller.isRegistering;
          },
          child: Obx(() => Text(controller.regPrompt)),
        ),
      ],
    );
  }
}

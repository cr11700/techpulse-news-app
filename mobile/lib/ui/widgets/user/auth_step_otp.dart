import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:pinput/pinput.dart';
import 'package:tech_pulse/ui/controllers/user_login_register_controller.dart';

class OTPStep extends LoginStepWidget {
  const OTPStep({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 36,
      height: 36,
      textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color.fromARGB(255, 209, 230, 255),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Color.fromRGBO(255, 121, 121, 1),
      ),
    );

    UserLoginRegisterController controller = UserLoginRegisterController.to;
    return Column(
      spacing: 16,
      children: [
        const Text(
          "输入验证码",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text("已发送验证码邮件到您的邮箱，请在此输入"),
        Obx(
          () => Pinput(
            length: 6,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            errorPinTheme: errorPinTheme,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            autofocus: true,
            forceErrorState: controller.isOtpError.value,
            errorText: '验证码错误',
            onCompleted: (pin) => controller.goNextStep(context, otp: pin),
          ),
        ),
      ],
    );
  }
}

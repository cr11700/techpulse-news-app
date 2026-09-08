import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/services/supabase_auth_service.dart';
import 'package:tech_pulse/ui/dialogs/confirm_dialog.dart';
import 'package:tech_pulse/ui/dialogs/eula_confirm_dialog.dart';
import 'package:tech_pulse/ui/routes/dialog.dart';
import 'package:tech_pulse/ui/routes/routes.dart';
import 'package:tech_pulse/ui/widgets/user/auth_step_email.dart';
import 'package:tech_pulse/ui/widgets/user/auth_step_otp.dart';
import 'package:tech_pulse/ui/widgets/user/auth_step_password.dart';

enum LoginStep {
  emailLogin,
  emailRegister,
  passwordLogin,
  passwordRegister,
  otpSignup,
  otpPasswordRecovery,
  typeNewPassword,
  undefined;

  Widget getWidget() {
    switch (this) {
      case emailLogin:
        return EmailStep(key: const ValueKey<LoginStep>(emailLogin));
      case emailRegister:
        return EmailStep(key: const ValueKey<LoginStep>(emailRegister));
      case passwordLogin:
        return PasswordStep(key: const ValueKey<LoginStep>(passwordLogin));
      case passwordRegister:
        return PasswordStep(key: const ValueKey<LoginStep>(passwordRegister));
      case otpSignup:
        return OTPStep(key: const ValueKey<LoginStep>(otpSignup));
      case otpPasswordRecovery:
        return OTPStep(key: const ValueKey<LoginStep>(otpPasswordRecovery));
      case typeNewPassword: // 输入新密码
        return PasswordStep(key: const ValueKey<LoginStep>(typeNewPassword));
      default:
        throw UnimplementedError();
    }
  }
}

abstract class LoginStepWidget extends StatelessWidget {
  const LoginStepWidget({super.key});
}

class UserLoginRegisterController extends GetxController {
  static UserLoginRegisterController get to => Get.find();

  // 外部依赖
  final _authService = SupabaseAuthService.to;

  // 状态变量
  final isLoading = false.obs; // 加载中
  final isOtpError = false.obs; // 验证码错误
  final isObscurePassword = true.obs; // 隐藏密码
  final isPrivacySelected = false.obs; // 接受用户协议
  final _isRegistering = false.obs; // 正在注册

  // 控制器
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // 基类方法覆盖

  @override
  void onInit() {
    super.onInit();
    _stack.add(LoginStep.emailLogin);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // 文本框控制器getter
  String get email => emailController.text;
  String get password => passwordController.text;

  // 注册/登录
  bool get isRegistering => _isRegistering.value;
  set isRegistering(bool value) {
    if (_isRegistering.value != value) {
      _isRegistering.value = value;
      if (value) {
        currentStep = LoginStep.emailRegister;
      } else {
        goPreviousStep(); // 返回登录UI
      }
    }
  }

  String get title => isRegistering ? '注册' : '登录';
  String get regPrompt => isRegistering ? '已有账号？点此 登录' : '没有账号？点此 注册新用户';

  // 状态栈
  final List<LoginStep> _stack = [];
  final _currentStep = LoginStep.emailLogin.obs;
  LoginStep _lhsStep = LoginStep.undefined;

  LoginStep get currentStep => _currentStep.value;
  IconData get buttonIcon =>
      currentStep == LoginStep.otpSignup ||
          currentStep == LoginStep.typeNewPassword ||
          currentStep == LoginStep.passwordLogin
      ? Icons.done
      : Icons.arrow_forward;
  // 获取当前状态下从左侧进入/退出的Step
  LoginStep get lhsStep {
    return _lhsStep;
  }

  set currentStep(LoginStep step) {
    if (step != _currentStep.value) {
      _stack.add(_currentStep.value);
      _lhsStep = _currentStep.value;
      _currentStep.value = step;
    }
  }

  // 跳转到上个状态
  void goPreviousStep() {
    if (_stack.length > 1) {
      _currentStep.value = _stack.removeLast();
      _lhsStep = _currentStep.value;
      isLoading.value = false;
    } else {
      goBack(false);
    }
  }

  // 清空密码文本框，仅当重新填写邮箱时使用。
  void _clearPasswordField() {
    passwordController.clear();
  }

  // 点击“下一步”或“提交”
  Future<void> goNextStep(BuildContext context, {String? otp}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    if (formKey.currentState!.validate()) {
      if (currentStep == LoginStep.emailLogin ||
          currentStep == LoginStep.emailRegister) {
        _clearPasswordField(); // 清空密码文本框
        // 先用户同意用户协议
        if (isPrivacySelected.value == false) {
          bool? result = await _showPrivacyModal(context);
          if (result == true) {
            isPrivacySelected.value = true;
          }
        }
        if (isPrivacySelected.value) {
          // 用户已输入邮箱，要求输入密码
          await Future.delayed(Duration(seconds: 1));
          if (isRegistering) {
            currentStep = LoginStep.passwordRegister;
          } else {
            currentStep = LoginStep.passwordLogin;
          }
        }
      } else if (currentStep == LoginStep.passwordLogin) {
        final authStatus = await _authService.login(email, password);

        if (authStatus == AuthStatus.ok) {
          showSnackBar(SnackBar(content: Text('登录成功')));
          _finalizeLogin();
        } else if (authStatus == AuthStatus.needConfirmEmail) {
          // 邮箱未验证
          await _authService.resendSignup(email);
          currentStep = LoginStep.otpSignup;
        } else {
          showSnackBar(SnackBar(content: Text('登录失败: $authStatus')));
        }
      } else if (currentStep == LoginStep.passwordRegister) {
        final authStatus = await _authService.signup(email, password);
        if (authStatus != AuthStatus.ok) {
          if (authStatus == AuthStatus.needConfirmEmail) {
            currentStep = LoginStep.otpSignup;
          } else {
            showSnackBar(SnackBar(content: Text('注册失败: $authStatus')));
          }
        }
      } else if (currentStep == LoginStep.otpSignup) {
        // 输入邮件确认验证码
        if (otp == null) {
          isOtpError.value = true;
        } else {
          final authStatus = await _authService.signupOtp(email, otp);
          if (authStatus != AuthStatus.ok) {
            if (authStatus == AuthStatus.invalidOTP) {
              isOtpError.value = true;
            } else {
              isOtpError.value = false;
              showSnackBar(SnackBar(content: Text('注册失败: $authStatus')));
            }
          } else {
            isOtpError.value = false;
            showSnackBar(SnackBar(content: Text('注册成功')));
            _finalizeLogin();
          }
        }
      } else if (currentStep == LoginStep.otpPasswordRecovery) {
        // 输入密码重置验证码
        final authStatus = await _authService.loginOtpRecovery(email, otp!);
        if (authStatus != AuthStatus.ok) {
          if (authStatus == AuthStatus.invalidOTP) {
            isOtpError.value = true;
          } else {
            isOtpError.value = false;
            showSnackBar(SnackBar(content: Text('验证失败: $authStatus')));
          }
        } else {
          isOtpError.value = false;
          currentStep = LoginStep.typeNewPassword;
        }
      } else if (currentStep == LoginStep.typeNewPassword) {
        // 设置新密码
        final authStatus = await _authService.setPassword(email, password);
        if (authStatus != AuthStatus.ok) {
          if (authStatus == AuthStatus.invalidOTP) {
            isOtpError.value = true;
          } else {
            isOtpError.value = false;
            showSnackBar(SnackBar(content: Text('验证失败: $authStatus')));
          }
        } else {
          isOtpError.value = false;
          showSnackBar(SnackBar(content: Text('密码修改成功')));
          _finalizeLogin();
        }
      }
    }
    isLoading.value = false;
  }

  // 注册/登录成功后的操作
  void _finalizeLogin() {
    goBack(true);
  }

  Future<void> resendSignup() async {
    isLoading.value = true;
    await _authService.resendSignup(email);
    showSnackBar(SnackBar(content: Text('账号验证邮件已发送到: $email')));
    isLoading.value = false;
  }

  Future<void> resendPasswordReset() async {
    isLoading.value = true;
    await _authService.sendPasswordReset(email);
    showSnackBar(SnackBar(content: Text('密码重置邮件已发送到: $email')));
    isLoading.value = false;
  }

  Future<void> goPasswordReset(BuildContext context) async {
    if (isLoading.value) return;
    bool? doResetPassword = await _showPasswordResetModal(context, email);
    if (doResetPassword == true) {
      await resendPasswordReset();
      currentStep = LoginStep.otpPasswordRecovery;
    }
  }

  // 切换显示/隐藏密码
  void togglePasswordVisibility() =>
      isObscurePassword.value = !isObscurePassword.value;

  Future<bool> _showPrivacyModal(BuildContext context) async {
    final result = await showMyDialog<bool>(
      context: context,
      child: EULAConfirmDialog(),
    );
    if (result != null && result == true) {
      return true;
    }
    return false;
  }

  Future<bool?> _showPasswordResetModal(BuildContext context, String email) {
    return showConfirmDialog(
      context: context,
      title: Text('忘记密码'),
      content: Text('发送密码重置链接到邮箱：$email 吗？'),
    );
  }
}

import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tech_pulse/models/user/user_full.dart';
import 'package:tech_pulse/repositories/user_repo.dart';
import 'package:tech_pulse/services/graphql_service.dart';

enum AuthStatus {
  ok,
  invalidEmail,
  invalidPassword,
  invalidOTP,
  needConfirmEmail,
  banned,
  samePassword,
  failed,
  rateLimit,
  unimplemented;

  @override
  String toString() {
    switch (this) {
      case ok:
        return "登录成功";
      case invalidEmail:
        return "邮箱未注册";
      case invalidPassword:
        return "用户名或密码错误";
      case invalidOTP:
        return "验证码错误";
      case needConfirmEmail:
        return "用户未激活";
      case banned:
        return "用户被封禁";
      case samePassword:
        return "新密码不能与旧密码相同";
      case failed:
        return "未知错误";
      case rateLimit:
        return "请求过于频繁，请1分钟后重试";
      case unimplemented:
        return "未实现此功能";
    }
  }
}

class SupabaseAuthService extends GetxService {
  static SupabaseAuthService get to => Get.find<SupabaseAuthService>();
  late SupabaseClient _supabase;

  final UserRepository _userRepo = UserRepository(GraphqlService.to);
  late StreamSubscription<AuthState> _authSubscription;

  final Rx<bool> _isLogined = false.obs;
  bool get isLoginned => _isLogined.value;

  final Rx<UserFull?> _userProfile = Rx<UserFull?>(null);
  UserFull? get userProfile => _userProfile.value;

  @override
  void onInit() {
    super.onInit();
    _supabase = Supabase.instance.client;
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      if (_supabase.auth.currentSession == null) {
        _isLogined.value = false;
      } else {
        _isLogined.value = true;
      }
      _fetchProfile();
    });
    _fetchProfile();
  }

  @override
  void onClose() {
    _authSubscription.cancel();
    super.onClose();
  }

  Future<void> _fetchProfile() async {
    if (isLoginned == false) {
      _userProfile.value = null;
    } else {
      final user = getUser();
      _userProfile.value = await _userRepo.getMyProfile(
        user!.id,
        forceRefresh: true,
      );
    }
  }

  // 检查邮箱是否被注册过
  Future<bool> checkEmailExists(String email) async {
    await Future.delayed(Duration(seconds: 1));
    return false;
  }

  // 忘记密码
  Future<AuthStatus> sendPasswordReset(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return AuthStatus.ok;
    } on AuthApiException catch (e) {
      if (e.code == 'over_email_send_rate_limit') {
        return AuthStatus.rateLimit;
      } else {
        rethrow;
      }
    }
  }

  // 重发确认邮件
  Future<AuthStatus> resendSignup(String email) async {
    try {
      await _supabase.auth.resend(email: email, type: OtpType.signup);
      return AuthStatus.ok;
    } on AuthApiException catch (e) {
      if (e.code == 'over_email_send_rate_limit') {
        return AuthStatus.rateLimit;
      } else {
        rethrow;
      }
    }
  }

  // 设置新密码
  Future<AuthStatus> setPassword(String email, String password) async {
    try {
      final UserResponse res = await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      if (res.user == null) {
        return AuthStatus.failed;
      }
      return AuthStatus.ok;
    } on AuthApiException catch (e) {
      if (e.code == 'same_password') {
        return AuthStatus.samePassword;
      }
      rethrow;
    }
  }

  // 注册
  Future<AuthStatus> signup(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user == null) {
        return AuthStatus.failed;
      }
      // 判断是否为已注册但未验证邮箱的情况
      if (res.session == null) {
        // 如果user存在但session为null，且user.identities为空，则说明邮箱已注册但未验证
        if (res.user?.identities == null || res.user!.identities!.isEmpty) {
          await resendSignup(email);
          return AuthStatus.needConfirmEmail;
        }
        return AuthStatus.needConfirmEmail;
      }
      return AuthStatus.ok;
    } on AuthApiException catch (e) {
      if (e.code == 'over_email_send_rate_limit') {
        return AuthStatus.rateLimit;
      }
      rethrow;
    }
  }

  // 登录
  Future<AuthStatus> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return AuthStatus.ok;
    } on AuthApiException catch (e) {
      if (e.code == 'invalid_credentials') {
        return AuthStatus.invalidPassword;
      } else if (e.code == 'user_banned') {
        return AuthStatus.banned;
      } else if (e.code == 'email_not_confirmed') {
        return AuthStatus.needConfirmEmail;
      } else {
        rethrow;
      }
    }
  }

  // 退出登录
  void logout() {
    _supabase.auth.signOut(scope: SignOutScope.local);
  }

  // 使用验证码重置密码
  Future<AuthStatus> loginOtpRecovery(String email, String otp) async {
    final AuthResponse res = await _supabase.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.recovery,
    );
    if (res.session == null) {
      return AuthStatus.needConfirmEmail;
    }
    if (res.user == null) {
      return AuthStatus.invalidEmail;
    }
    return AuthStatus.ok;
  }

  // 使用验证码注册
  Future<AuthStatus> signupOtp(String email, String otp) async {
    AuthResponse res;
    try {
      res = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
    } on AuthApiException {
      return AuthStatus.invalidOTP;
    }
    if (res.session == null) {
      return AuthStatus.needConfirmEmail;
    }
    if (res.user == null) {
      return AuthStatus.invalidEmail;
    }
    return AuthStatus.ok;
  }

  User? getUser() {
    return _supabase.auth.currentUser;
  }

  String? getJWT() {
    return _supabase.auth.currentSession?.accessToken;
  }
}

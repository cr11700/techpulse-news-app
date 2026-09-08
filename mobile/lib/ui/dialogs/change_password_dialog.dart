import 'package:flutter/material.dart';
import 'package:tech_pulse/services/supabase_auth_service.dart';
import 'package:tech_pulse/ui/routes/routes.dart';
import 'package:tech_pulse/ui/widgets/user/capsule_text_field.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController newPasswordController = TextEditingController();
  bool obscureText = true;
  final formKey = GlobalKey<FormState>();
  String? forceErrorText;
  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> onSubmitted(BuildContext context, String newPassword) async {
    if (forceErrorText == null) {
      if (formKey.currentState!.validate() == false) return;
    }
    setState(() {
      forceErrorText = null;
    });
    if (newPassword.length >= 6) {
      final result = await SupabaseAuthService.to.setPassword(
        SupabaseAuthService.to.getUser()!.email!,
        newPassword,
      );
      if (result == AuthStatus.ok) {
        showSnackBar(SnackBar(content: Text('密码修改成功')));
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          forceErrorText = '$result';
        });
      }
    } else {
      setState(() {
        forceErrorText = '密码至少6位';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.key),
      title: Text('修改密码'),
      content: Form(
        key: formKey,
        child: CapsuleTextField(
          prompt: '输入新密码',
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: Icon(Icons.lock),
          obscureButtonCallback: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
          onChanged: (value) {
            setState(() {
              forceErrorText = null;
            });
          },
          controller: newPasswordController,
          obscureText: obscureText,
          forceErrorText: forceErrorText,
          onFieldSubmitted: (value) => onSubmitted(context, value),
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入密码';
            if (value.length < 6) return '密码至少6位';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            onSubmitted(context, newPasswordController.text);
          },
          child: Text('确认'),
        ),
      ],
    );
  }
}

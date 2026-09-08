import 'package:flutter/material.dart';
import 'package:tech_pulse/ui/routes/routes.dart';

class EULAConfirmDialog extends StatelessWidget {
  const EULAConfirmDialog({super.key});

  // 跳转到用户协议页面
  static void showLicencePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'TechPulse',
      applicationIcon: FlutterLogo(size: 48),
      applicationVersion: '1.0.0',
      applicationLegalese: 'GPL 3.0',
      useRootNavigator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: FlutterLogo(),
      title: Text('提示'),
      content: GestureDetector(
        onTap: () {
          showLicencePage(context);
        },
        child: Text('登录即表明同意《最终用户许可协议》《隐私政策》（点击查看）'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            goBack(false);
          },
          child: Text('拒绝'),
        ),
        TextButton(
          autofocus: true,
          onPressed: () {
            goBack(true);
          },
          child: Text('接受'),
        ),
      ],
    );
  }
}

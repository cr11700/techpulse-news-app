import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/services/graphql_service.dart';
import 'package:tech_pulse/services/preference_storage_service.dart';
import 'package:tech_pulse/services/supabase_auth_service.dart';
import 'package:tech_pulse/ui/dialogs/change_password_dialog.dart';
import 'package:tech_pulse/ui/dialogs/confirm_dialog.dart';
import 'package:tech_pulse/ui/routes/dialog.dart';
import 'package:tech_pulse/ui/routes/routes.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final srv = PreferenceStorageService.to;
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          Obx(
            () => SwitchListTile(
              title: Text('订阅推送'),
              subtitle: Text('当订阅的出版社有新新闻时推送通知'),
              value: srv.getPreference(PrefKey.enablePushService),
              onChanged: (bool value) {
                srv.setPreference(PrefKey.enablePushService, value);
              },
            ),
          ),
          Obx(
            () => ListTile(
              title: Text('联网自动缓存'),
              subtitle: Slider(
                min: 0,
                max: 10,
                value: srv
                    .getPreference<int>(PrefKey.autoCacheCount)
                    .toDouble(),
                divisions: 10,
                label: "${srv.getPreference<int>(PrefKey.autoCacheCount)}",
                onChanged: (double value) {
                  srv.setPreference<int>(PrefKey.autoCacheCount, value.toInt());
                },
              ),
            ),
          ),
          Divider(),
          Obx(
            () => SwitchListTile(
              title: Text('深色模式'),
              value: srv.getPreference<bool>(PrefKey.darkMode),
              onChanged: (bool value) {
                srv.setPreference<bool>(PrefKey.darkMode, value);
              },
            ),
          ),
          Obx(
            () => SwitchListTile(
              title: Text('外链跳转'),
              subtitle: Text('在点击文章阅读页中的链接时使用浏览器打开'),
              value: srv.getPreference<bool>(PrefKey.enableExternalLink),
              onChanged: (bool value) {
                srv.setPreference<bool>(PrefKey.enableExternalLink, value);
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('恢复默认设置'),
            subtitle: Text('重置全部设置到默认值'),
            onTap: () async {
              if (await showConfirmDialog(
                context: context,
                title: Text('恢复默认设置'),
                content: Text('这将重置系统设置为默认值，但不会退出您的账号'),
              )) {
                srv.resetPreferences();
                showSnackBar(SnackBar(content: Text('默认设置已恢复')));
              }
            },
          ),
          ListTile(
            title: Text('清空缓存'),
            subtitle: Text('清空GraphQL缓存，当文章显示错误时使用'),
            onTap: () {
              GraphqlService.to.clearCache();
              showSnackBar(SnackBar(content: Text('已清空GraphQL缓存')));
            },
          ),
          AboutListTile(
            applicationIcon: FlutterLogo(size: 48),
            applicationName: 'TechPulse',
            applicationVersion: '1.0.0',
            child: Text('开放源代码许可'),
          ),
          Divider(),
          ListTile(
            title: Text('修改密码'),
            subtitle: Text('修改 TechPulse 账户登录密码'),
            onTap: () {
              showMyDialog(child: ChangePasswordDialog());
            },
          ),
          ListTile(
            title: Text('退出登录'),
            onTap: () async {
              if (await showConfirmDialog(
                context: context,
                title: Text('要退出登录吗'),
                content: Text('这不会影响已登录的其它设备'),
                icon: Icon(Icons.exit_to_app),
              )) {
                SupabaseAuthService.to.logout();
                goHome();
                showSnackBar(SnackBar(content: Text('已退出登录')));
              }
            },
          ),
        ],
      ),
    );
  }
}

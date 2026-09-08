import 'package:flutter/material.dart';
import 'package:tech_pulse/ui/pages/article_page.dart';
import 'package:tech_pulse/ui/pages/home_page.dart';
import 'package:tech_pulse/ui/pages/user/user_login_page.dart';
import 'package:tech_pulse/ui/pages/user/user_profile_page.dart';
import 'package:tech_pulse/ui/pages/user/user_settings_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static const home = '/';
  static const article = '/article';
  static const user = '/user';
  static const userLogin = '/user/login';
  static const userSettings = '/user/settings';
}

final Map<String, WidgetBuilder> routes = {
  Routes.home: (_) => const HomePage(),
  Routes.article: (_) => const ArticlePage(),
  Routes.user: (_) => const UserProfilePage(),
  Routes.userLogin: (_) => const UserLoginPage(),
  Routes.userSettings: (_) => const UserSettingsPage(),
};

Future<T?> goRoute<T extends Object?>(Route<T> route) {
  return navigatorKey.currentState!.push<T>(route);
}

Future<T?> goNamedRoute<T extends Object?>(
  String routeName, {
  Object? arguments,
}) {
  if (arguments != null) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  } else {
    return navigatorKey.currentState!.pushNamed<T>(routeName);
  }
}

Future<T?> goReplaceNamedRoute<T extends Object?, TO extends Object?>(
  String routeName, {
  TO? result,
  Object? arguments,
}) {
  if (arguments != null) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  } else {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName);
  }
}

void goBack([dynamic result]) {
  if (result != null) {
    return navigatorKey.currentState!.pop(result);
  } else {
    return navigatorKey.currentState!.pop();
  }
}

void goHome() {
  navigatorKey.currentState!.popUntil(ModalRoute.withName(Routes.home));
}

dynamic getArguments(BuildContext context) {
  return ModalRoute.of(context)?.settings.arguments;
}

BuildContext getContext() {
  return navigatorKey.currentContext!;
}

double getScreenWidth() {
  return MediaQuery.of(getContext()).size.width;
}

double getScreenHeight() {
  return MediaQuery.of(getContext()).size.height;
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
  SnackBar snackBar,
) {
  if (navigatorKey.currentContext != null &&
      navigatorKey.currentContext!.mounted) {
    return ScaffoldMessenger.of(
      navigatorKey.currentContext!,
    ).showSnackBar(snackBar);
  }
  else {
    throw StateError("[navigatorKey.currentContext] is not mounted");
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/services/article_http_service.dart';
import 'package:tech_pulse/services/preference_storage_service.dart';
import 'package:tech_pulse/services/supabase_auth_service.dart';
import 'package:tech_pulse/services/article_cache_service.dart';
import 'package:tech_pulse/services/graphql_service.dart';
import 'package:tech_pulse/ui/routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  kIsWeb ? usePathUrlStrategy() : true;
  await initHiveForFlutter();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_API_HOST']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  Get.put(GraphqlService());
  Get.put(ArticleCacheService());
  Get.put(SupabaseAuthService());
  Get.put(PreferenceStorageService());
  Get.put(ArticleHttpService());
  runApp(const MainApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    // Add other devices like stylus, trackpad if needed
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics(parent: RangeMaintainingScrollPhysics());
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MaterialApp(
        navigatorKey: navigatorKey,
        routes: routes,
        initialRoute: Routes.home,
        scrollBehavior: MyCustomScrollBehavior(),
        theme: ThemeData(
          brightness:
              PreferenceStorageService.to.getPreference<bool>(PrefKey.darkMode)
              ? Brightness.dark
              : Brightness.light,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
            },
          ),
          sliderTheme: SliderThemeData(
            showValueIndicator: ShowValueIndicator.always,
            valueIndicatorShape: DropSliderValueIndicatorShape(),
            // ignore: deprecated_member_use
            year2023: false,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_routes.dart';
import 'app/init_app.dart';

import 'core/style/theme/app_light_theme.dart';
import 'core/utils/app_constants.dart';

Future<void> main() async {
  await initApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppLightTheme.theme,
      themeMode: ThemeMode.light,
      getPages: AppPages.getPages,
    );
  }
}

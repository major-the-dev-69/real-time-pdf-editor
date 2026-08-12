import 'dart:async';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';

class SplashController extends GetxController {
  final opacity = 0.0.obs;
  final scale = 0.85.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 150), () {
      opacity.value = 1.0;
      scale.value = 1.0;
    });

    Timer(const Duration(seconds: 3), () {
      // final isLoggedIn = SharedPrefManager().isLoggedIn;
      // if (isLoggedIn) {
      //   if (SharedPrefManager().isCustomer) {
      //     Get.offAllNamed(AppRoutes.customerDashboard);
      //   } else {
      //     Get.offAllNamed(AppRoutes.dashboard);
      //   }
      // } else {
      //   Get.offAllNamed(AppRoutes.login);
      // }
      Get.offAllNamed(AppRoutes.login);
    });
  }
}

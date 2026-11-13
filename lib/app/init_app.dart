import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/network/api_services.dart';
import '../core/network/pusher_service.dart';
import '../db/shared_pref_manager.dart';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefManager().init();
  Get.put(ApiServices());
  await Get.putAsync(() => PusherService().init());
}

import 'package:get/get.dart';

import '../presentation/controller/site_form_controller.dart';
import '../presentation/controller/site_list_controller.dart';

class SiteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SiteListController>(() => SiteListController());
    Get.lazyPut<SiteFormController>(() => SiteFormController());
  }
}

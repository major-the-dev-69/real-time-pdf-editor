import 'package:get/get.dart';
import '../presentation/controller/search_page_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchPageController>(() => SearchPageController());
  }
}

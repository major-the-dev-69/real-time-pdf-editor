import 'package:get/get.dart';
import '../presentation/controller/user_controller.dart';
import '../presentation/controller/user_form_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<UserFormController>(() => UserFormController());
  }
}

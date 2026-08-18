import 'package:get/get.dart';
import '../presentation/controller/project_form_controller.dart';
import '../presentation/controller/project_list_controller.dart';

class ProjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectListController>(() => ProjectListController());
    Get.lazyPut<ProjectFormController>(() => ProjectFormController());
  }
}

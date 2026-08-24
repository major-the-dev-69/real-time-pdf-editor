import 'package:get/get.dart';

import '../presentation/controller/pdf_edit_controller.dart';

class PdfEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfEditController>(() => PdfEditController());
  }
}

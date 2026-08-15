import 'package:get/get.dart';
import '../presentation/controller/pdf_detail_controller.dart';

class PdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfDetailController>(() => PdfDetailController());
  }
}

import 'package:get/get.dart';

class NotificationController extends GetxController {
  final isLoading = false.obs;
  final notifications = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    // Currently empty state
    notifications.clear();
  }
}

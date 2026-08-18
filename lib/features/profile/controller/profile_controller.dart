import 'package:get/get.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../../app/app_routes.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../model/user_profile_model.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final isLoggingOut = false.obs;
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);

  final _apiService = Get.find<ApiServices>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    final response = await _apiService.callGetApi(
      ApiConstants.profile,
      isUserRequired: true,
    );
    isLoading.value = false;

    if (response.status && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['user'] != null) {
        userProfile.value = UserProfileModel.fromJson(data['user']);
      }
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }

  Future<void> logout() async {
    isLoggingOut.value = true;
    // Call logout API
    final response = await _apiService.callPostApi(
      ApiConstants.logout,
      isUserRequired: true,
    );
    isLoggingOut.value = false;
    await SharedPrefManager().userLogOut();
    Get.offAllNamed(AppRoutes.login);

    if (response.status) {
      CustomSnackBar.showSuccess(message: response.message);
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }
}

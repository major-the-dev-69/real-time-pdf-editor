import 'package:get/get.dart';
import 'package:sai_associates/core/helper/logger_helper.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../model/business_graph_model.dart';
import '../../model/dashboard_model.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;
  final isLoading = true.obs;
  final isGraphLoading = false.obs;
  final dashboardData = Rxn<DashboardModel>();
  final businessGraphList = <BusinessGraphModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchBusinessGraph();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final associateId = SharedPrefManager().userToken;
      final apiService = Get.find<ApiServices>();

      final response = await apiService.callPostApi(
        ApiConstants.dashboardUrl,
        req: {'AssosiateId': associateId},
      );

      if (response.status && response.data != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic>) {
          if (resData.containsKey('Response') && resData['Response'] is List) {
            final list = resData['Response'] as List;
            if (list.isNotEmpty && list[0] is Map) {
              dashboardData.value = DashboardModel.fromJson(
                Map<String, dynamic>.from(list[0] as Map),
              );
            }
          } else {
            dashboardData.value = DashboardModel.fromJson(resData);
          }
        }
      }
    } catch (e) {
      printMessage('⚠️ Exception in fetchDashboardData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBusinessGraph() async {
    isGraphLoading.value = true;
    try {
      final associateId = SharedPrefManager().userToken;
      final apiService = Get.find<ApiServices>();

      final req = {
        'MemberId': associateId,
        'AssosiateId': associateId,
        'Id': associateId,
      };

      printMessage('🚀 Fetching BusinessGraph with req: $req');

      final response = await apiService.callPostApi(
        ApiConstants.businessGraphUrl,
        req: req,
      );

      if (response.status && response.data != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic> &&
            resData.containsKey('Response') &&
            resData['Response'] is List) {
          final list = resData['Response'] as List;
          businessGraphList.value = list
              .map(
                (e) => BusinessGraphModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        } else {
          businessGraphList.clear();
        }
      } else {
        businessGraphList.clear();
      }
    } catch (e) {
      printMessage('⚠️ Exception in fetchBusinessGraph: $e');
      businessGraphList.clear();
    } finally {
      isGraphLoading.value = false;
    }
  }
}

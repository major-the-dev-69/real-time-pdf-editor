import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sai_associates/core/network/api_constants.dart';
import 'package:sai_associates/core/network/api_services.dart';
import 'package:sai_associates/widgets/custom_snack_bar.dart';

import '../../model/user_model.dart';

class UserController extends GetxController {
  final ApiServices _apiServices = Get.find<ApiServices>();

  final usersList = <UserModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final searchQuery = ''.obs;

  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalUsers = 0.obs;
  final hasMorePages = false.obs;
  final perPage = 10;

  final selectedRoleFilter = 'all'.obs;
  Timer? _debounceTimer;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchUsers(isRefresh: true);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        hasMorePages.value &&
        !isMoreLoading.value &&
        !isLoading.value) {
      loadMoreUsers();
    }
  }

  Future<void> fetchUsers({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      usersList.clear();
      isLoading.value = true;
    }

    final queryParams = <String, dynamic>{
      'page': currentPage.value,
      'per_page': perPage,
    };

    if (searchQuery.value.trim().isNotEmpty) {
      queryParams['search'] = searchQuery.value.trim();
    }

    final response = await _apiServices.callGetApi(
      ApiConstants.users,
      queryParameters: queryParams,
    );

    if (isRefresh) {
      isLoading.value = false;
    }

    if (response.status && response.data != null) {
      final dataMap = response.data;

      // Parse list data
      List rawList = [];
      if (dataMap is Map<String, dynamic> && dataMap['data'] is List) {
        rawList = dataMap['data'];
      } else if (dataMap is List) {
        rawList = dataMap;
      }

      final newUsers = rawList
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (isRefresh) {
        usersList.assignAll(newUsers);
      } else {
        usersList.addAll(newUsers);
      }

      // Parse pagination metadata
      if (dataMap is Map<String, dynamic> && dataMap['pagination'] != null) {
        final pagination = PaginationModel.fromJson(
          dataMap['pagination'] as Map<String, dynamic>,
        );
        currentPage.value = pagination.currentPage;
        lastPage.value = pagination.lastPage;
        totalUsers.value = pagination.total;
        hasMorePages.value = pagination.hasMorePages;
      } else {
        hasMorePages.value = false;
      }
    } else {
      if (isRefresh) {
        usersList.clear();
      }
      CustomSnackBar.showError(message: response.message);
    }
  }

  Future<void> loadMoreUsers() async {
    if (!hasMorePages.value || isMoreLoading.value) return;

    isMoreLoading.value = true;
    currentPage.value += 1;
    await fetchUsers(isRefresh: false);
    isMoreLoading.value = false;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchUsers(isRefresh: true);
    });
  }

  void filterByRole(String role) {
    selectedRoleFilter.value = role;
  }

  Future<void> deleteUser(int userId) async {
    if (userId == 0) return;

    isLoading.value = true;
    final response = await _apiServices.callDeleteApi(
      '${ApiConstants.users}/$userId',
    );
    isLoading.value = false;

    if (response.status) {
      usersList.removeWhere((user) => user.id == userId);
      totalUsers.value = (totalUsers.value - 1).clamp(0, 999999);
      CustomSnackBar.showSuccess(message: response.message);
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }

  void confirmDeleteUser(BuildContext context, UserModel user) {
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.trash_copy, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'Delete User',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete ${user.name}? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        if (user.id != null) {
                          deleteUser(user.id!);
                        }
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  List<UserModel> get filteredUsers {
    if (selectedRoleFilter.value == 'all') {
      return usersList;
    }
    return usersList
        .where(
          (u) => u.role.toLowerCase() == selectedRoleFilter.value.toLowerCase(),
        )
        .toList();
  }
}

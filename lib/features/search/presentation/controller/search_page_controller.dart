import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sai_associates/core/helper/logger_helper.dart';
import 'package:sai_associates/core/network/api_services.dart';

import '../../model/search_result_model.dart';

class SearchPageController extends GetxController {
  final _apiServices = Get.find<ApiServices>();

  final searchBarController = TextEditingController();
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final searchResult = Rxn<SearchResultModel>();

  Timer? _debounceTimer;

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchBarController.dispose();
    super.onClose();
  }

  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      isLoading.value = false;
      searchResult.value = null;
      return;
    }

    // Debounce API calls by 400ms
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      performSearch(query.trim());
    });
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      searchResult.value = null;
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiServices.callGetApi(
        'search',
        queryParameters: {'query': query},
        isUserRequired: true,
      );

      isLoading.value = false;

      if (response.status && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('projects') ||
              data.containsKey('sites') ||
              data.containsKey('pdfs')) {
            searchResult.value = SearchResultModel.fromJson(data);
          } else if (data['data'] is Map<String, dynamic>) {
            searchResult.value = SearchResultModel.fromJson(
              data['data'] as Map<String, dynamic>,
            );
          } else {
            searchResult.value = SearchResultModel(
              projects: [],
              sites: [],
              pdfs: [],
            );
          }
        } else {
          searchResult.value = SearchResultModel(
            projects: [],
            sites: [],
            pdfs: [],
          );
        }
      } else {
        searchResult.value = SearchResultModel(
          projects: [],
          sites: [],
          pdfs: [],
        );
      }
    } catch (e) {
      isLoading.value = false;
      printMessage("⚠️ Error performing search: $e");
      searchResult.value = SearchResultModel(projects: [], sites: [], pdfs: []);
    }
  }

  void clearSearch() {
    searchBarController.clear();
    searchQuery.value = '';
    searchResult.value = null;
    isLoading.value = false;
  }
}

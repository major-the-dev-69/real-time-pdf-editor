import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' hide FormData, Response;

import '../../db/shared_pref_manager.dart';
import '../../widgets/custom_snack_bar.dart';
import '../helper/logger_helper.dart';
import 'api_constants.dart';
import 'retry_interceptor.dart';

class ApiServices extends GetxService {
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {"Accept": "application/json, text/xml, */*"},
        validateStatus: (status) {
          return status != null && status > 0;
        },
      ),
    );
    _dio.interceptors.add(_buildLogger());
    _dio.interceptors.add(_buildRetry());
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  LogInterceptor _buildLogger() {
    return LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    );
  }

  RetryInterceptor _buildRetry() {
    return RetryInterceptor(
      dio: _dio,
      retries: 3,
      retryEvaluator: (error, attempt) {
        return error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout;
      },
    );
  }

  void logApiError(String message) {
    printMessage("⚠️ API Error: $message");
  }

  Future<Map<String, String>> _getHeaders(bool isUserRequired) async {
    final headers = <String, String>{"Accept": "application/json"};
    final token = SharedPrefManager().userToken;
    if (isUserRequired && token.isNotEmpty) {
      headers[ApiConstants.authorization] = "Bearer $token";
    }
    return headers;
  }

  /// 📡 Generic GET API Call
  Future<ResponseModel> callGetApi(
    String urlOrEndpoint, {
    Map<String, dynamic>? queryParameters,
    bool isUserRequired = true,
  }) async {
    try {
      final headers = await _getHeaders(isUserRequired);

      final options = Options(
        headers: headers,
        responseType: ResponseType.json,
      );

      printMessage("📡 GET [$urlOrEndpoint] Query: $queryParameters");

      final response = await _dio.get(
        urlOrEndpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return checkResponseModel(response);
    } catch (e, stk) {
      logApiError("Exception in GET $urlOrEndpoint → $e \n$stk");
      return ResponseModel(
        false,
        "Unable to connect to server. Please check your network connection.",
        null,
      );
    }
  }

  /// 📡 Generic POST API Call
  Future<ResponseModel> callPostApi(
    String urlOrEndpoint, {
    dynamic req,
    FormData? multipartRequest,
    bool isUserRequired = true,
  }) async {
    try {
      final headers = await _getHeaders(isUserRequired);

      dynamic requestData;
      String contentType;

      if (multipartRequest != null) {
        requestData = multipartRequest;
        contentType = "multipart/form-data";
      } else {
        requestData = req ?? <String, dynamic>{};
        contentType = "application/json";
      }

      final options = Options(
        headers: headers,
        contentType: contentType,
        responseType: ResponseType.json,
      );

      printMessage(
        "📡 POST [$urlOrEndpoint] ContentType: $contentType Request $req",
      );

      final response = await _dio.post(
        urlOrEndpoint,
        data: requestData,
        options: options,
      );

      return checkResponseModel(response);
    } catch (e, stk) {
      logApiError("Exception in POST $urlOrEndpoint → $e \n$stk");
      return ResponseModel(
        false,
        "Unable to connect to server. Please check your network connection.",
        null,
      );
    }
  }

  /// 📡 Generic PUT API Call
  Future<ResponseModel> callPutApi(
    String urlOrEndpoint, {
    dynamic req,
    bool isUserRequired = true,
  }) async {
    try {
      final headers = await _getHeaders(isUserRequired);

      final options = Options(
        headers: headers,
        contentType: "application/json",
        responseType: ResponseType.json,
      );

      printMessage("📡 PUT [$urlOrEndpoint] Request $req");

      final response = await _dio.put(
        urlOrEndpoint,
        data: req ?? <String, dynamic>{},
        options: options,
      );

      return checkResponseModel(response);
    } catch (e, stk) {
      logApiError("Exception in PUT $urlOrEndpoint → $e \n$stk");
      return ResponseModel(
        false,
        "Unable to connect to server. Please check your network connection.",
        null,
      );
    }
  }

  /// 📡 Generic DELETE API Call
  Future<ResponseModel> callDeleteApi(
    String urlOrEndpoint, {
    dynamic req,
    bool isUserRequired = true,
  }) async {
    try {
      final headers = await _getHeaders(isUserRequired);

      final options = Options(
        headers: headers,
        contentType: "application/json",
        responseType: ResponseType.json,
      );

      printMessage("📡 DELETE [$urlOrEndpoint] Request $req");

      final response = await _dio.delete(
        urlOrEndpoint,
        data: req,
        options: options,
      );

      return checkResponseModel(response);
    } catch (e, stk) {
      logApiError("Exception in DELETE $urlOrEndpoint → $e \n$stk");
      return ResponseModel(
        false,
        "Unable to connect to server. Please check your network connection.",
        null,
      );
    }
  }

  Future<ResponseModel> checkResponseModel(Response response) async {
    printMessage("Status Code: ${response.statusCode}");
    printMessage("Status Message: ${response.statusMessage}");
    printMessage("Raw Response Data: ${response.data}");

    dynamic responseData = response.data;
    if (responseData is String) {
      try {
        responseData = jsonDecode(responseData);
      } catch (e) {
        printMessage('⚠️ jsonDecode Exception: $e');
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData is Map<String, dynamic>) {
        final status = responseData['status'] == true;
        final message =
            responseData['message']?.toString() ??
            (status ? 'Success' : 'Error');
        final data = responseData['data'];

        return ResponseModel(status, message, data);
      } else {
        return ResponseModel(true, "Success", responseData);
      }
    }

    if (response.statusCode == 401) {
      const message = "Unauthorized access";
      CustomSnackBar.showError(message: message);
      return ResponseModel(false, message, null);
    }

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString() ?? "Error occurred";
      return ResponseModel(false, message, null);
    }

    return ResponseModel(
      false,
      "Invalid Credentials or Connection Error",
      null,
    );
  }
}

class ResponseModel {
  final bool _status;
  final String _message;
  final dynamic _data;

  ResponseModel(this._status, this._message, this._data);

  String get message => _message;

  bool get status => _status;

  dynamic get data => _data;
}

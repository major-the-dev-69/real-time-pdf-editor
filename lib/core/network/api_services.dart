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

  /// ✅ Robustly extract & parse JSON from XML WebService responses
  dynamic cleanXmlJsonResponse(dynamic responseData) {
    if (responseData == null) return null;
    String str = responseData.toString().trim();

    // Find the first occurrence of '{' or '[' and last occurrence of '}' or ']'
    final firstBrace = str.indexOf('{');
    final firstBracket = str.indexOf('[');

    int jsonStart = -1;
    if (firstBrace != -1 && firstBracket != -1) {
      jsonStart = firstBrace < firstBracket ? firstBrace : firstBracket;
    } else if (firstBrace != -1) {
      jsonStart = firstBrace;
    } else if (firstBracket != -1) {
      jsonStart = firstBracket;
    }

    final lastBrace = str.lastIndexOf('}');
    final lastBracket = str.lastIndexOf(']');

    int jsonEnd = -1;
    if (lastBrace != -1 && lastBracket != -1) {
      jsonEnd = lastBrace > lastBracket ? lastBrace : lastBracket;
    } else if (lastBrace != -1) {
      jsonEnd = lastBrace;
    } else if (lastBracket != -1) {
      jsonEnd = lastBracket;
    }

    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      str = str.substring(jsonStart, jsonEnd + 1).trim();
    }

    // Unescape XML entities if present
    str = str
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');

    // Decode JSON if string starts with '{' or '['
    if (str.startsWith('{') || str.startsWith('[')) {
      try {
        return jsonDecode(str);
      } catch (e) {
        printMessage('⚠️ jsonDecode Exception: $e');
      }
    }

    return responseData;
  }

  /// 📡 Generic POST API Call for all APIs (ASMX form-urlencoded compatible)
  Future<ResponseModel> callPostApi(
    String urlOrEndpoint, {
    Map<String, dynamic> req = const {},
    FormData? multipartRequest,
    bool isUserRequired = false,
    bool isBodyData = false,
  }) async {
    try {
      final headers = <String, String>{
        "Accept": "application/json, text/xml, */*",
      };
      final token = SharedPrefManager().userToken;
      if (isUserRequired && token.isNotEmpty) {
        headers[ApiConstants.authorization] = "Bearer $token";
      }

      dynamic requestData;
      String contentType;

      if (multipartRequest != null) {
        requestData = multipartRequest;
        contentType = "multipart/form-data";
      } else if (isBodyData) {
        requestData = req;
        contentType = "application/json";
      } else {
        requestData = req;
        contentType = Headers.formUrlEncodedContentType;
      }

      final options = Options(
        headers: headers,
        contentType: contentType,
        responseType: ResponseType.plain,
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

  Future<ResponseModel> checkResponseModel(Response response) async {
    printMessage("Status Code: ${response.statusCode}");
    printMessage("Status Message: ${response.statusMessage}");
    printMessage("Raw Response Data: ${response.data}");

    final cleanedData = cleanXmlJsonResponse(response.data);
    printMessage("Cleaned Response Data: ${jsonEncode(cleanedData)}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (cleanedData is Map<String, dynamic>) {
        // Check top-level Status
        final topStatus =
            cleanedData['Status'] ??
            cleanedData['status'] ??
            cleanedData[ApiKeys.success];
        final isTopStatusTrue =
            topStatus == true ||
            topStatus.toString().toLowerCase() == 'true' ||
            topStatus.toString() == '200' ||
            topStatus.toString() == '202';

        // Check ASMX "Response" format
        if (cleanedData.containsKey('Response') &&
            cleanedData['Response'] is List) {
          final list = cleanedData['Response'] as List;
          if (list.isNotEmpty && list[0] is Map) {
            final item = Map<String, dynamic>.from(list[0] as Map);
            final itemStatus = item['status'] ?? item['Status'];
            final isItemStatusTrue =
                itemStatus == true ||
                itemStatus.toString().toLowerCase() == 'true' ||
                itemStatus.toString() == '200' ||
                itemStatus.toString() == '202';

            final hasUidOrLogin =
                item.containsKey('uid') || item.containsKey('username');

            if (isItemStatusTrue || isTopStatusTrue || hasUidOrLogin) {
              final message =
                  cleanedData['Message'] ?? item['Msg'] ?? 'Success';
              return ResponseModel(true, message.toString(), cleanedData);
            }
          } else if (list.isEmpty) {
            return ResponseModel(false, "No records found", null);
          }
        }

        // Standard API format check
        if (isTopStatusTrue) {
          final message =
              cleanedData[ApiKeys.message] ??
              cleanedData['Message'] ??
              'Success';
          final data = cleanedData[ApiKeys.response] ?? cleanedData;
          return ResponseModel(true, message.toString(), data);
        }
      }
    }

    if (response.statusCode == 401) {
      const message = "Unauthorized access";
      CustomSnackBar.showError(message: message);
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

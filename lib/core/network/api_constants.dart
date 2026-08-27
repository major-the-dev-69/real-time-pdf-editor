class ApiConstants {
  ApiConstants._();

  static const baseUrl = "https://pbd.nivrajsoftware.in";
  static const apiBaseUrl = "$baseUrl/api/v1/";
  static const login = "auth/login";
  static const profile = "auth/profile";
  static const logout = "auth/logout";
  static const projects = "projects";
  static const sites = "sites";
  static const users = "users";

  static const sendOtp = "forgot-password/send-otp";
  static const verifyOtp = "forgot-password/verify-otp";
  static const resetPassword = "forgot-password/reset";

  static const xApiKey = "x-api-key";
  static const xApiValue = "OPT-pCMr6da5EC2mC6p1OA8aW3znkrF2T3cg";
  static const authorization = "Authorization";
}

class ApiKeys {
  ApiKeys._();

  static const String success = "status";
  static const String response = "data";
  static const String message = "Message";
}

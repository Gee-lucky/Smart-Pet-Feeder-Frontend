class AppUrl {
  static const String liveBaseURL = "https://your-production-url/api/v1";
  static const String localBaseURL = "http://localhost:8000/api/v1"; // Replace with your server’s IP
  static const String baseURL = localBaseURL;
  static const String login = "$baseURL/auth/login/";
  static const String register = "$baseURL/auth/register/";
  static const String logout = "$baseURL/auth/logout/";
  static const String resetPasswordEmail = "$baseURL/auth/reset-password-email/";
  static const String resetPassword = "$baseURL/auth/reset-password/";
  static const String feed = "$baseURL/auth/feed/";
  static const String profile = "$baseURL/auth/profile/";
  static const String refreshToken = "$baseURL/token/refresh/";
  static const String forgotPassword = "$baseURL/auth/forgot-password/";
}

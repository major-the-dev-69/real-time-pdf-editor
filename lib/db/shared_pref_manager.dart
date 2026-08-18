import 'package:encrypt_shared_preferences/provider.dart';
import '../core/enums/user_role.dart';

const blockSplashNavigation = "blockSplashNavigation";

class SharedPrefManager {
  static final SharedPrefManager _instance = SharedPrefManager._internal();

  factory SharedPrefManager() => _instance;

  SharedPrefManager._internal();

  static const String _keyUser = "app_users";
  static const String _keySettings = "app_settings";
  static const String _keyToken = "token";
  static const String _keyRole = "user_role";
  static const String _encryptionKey = "gotravelmart_key";

  late EncryptedSharedPreferences _prefs;

  Future<void> init() async {
    await EncryptedSharedPreferences.initialize(_encryptionKey);
    _prefs = EncryptedSharedPreferences.getInstance();
  }

  Future<void> userLogOut() async {
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyRole);
    await _prefs.remove(blockSplashNavigation);
    await _prefs.remove(_keySettings);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  Future<void> saveRole(String role) async {
    await _prefs.setString(_keyRole, role);
  }

  Future<void> saveSettings(String settings) async {
    await _prefs.setString(_keySettings, settings);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> removeBool(String key) async {
    await _prefs.remove(key);
  }

  bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  Future<void> removeString(String key) async {
    await _prefs.remove(key);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  String get userToken => _prefs.getString(_keyToken) ?? "";
  String get userRole => _prefs.getString(_keyRole) ?? "";

  UserRole get userRoleEnum {
    return UserRoleExtension.fromString(userRole);
  }

  bool get isCustomer => userRole == "3" || userToken.trim().toUpperCase().startsWith('AMC');
  bool get isLoggedIn => userToken.trim().isNotEmpty;
}

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _isProKey = 'is_pro_user';
  final SharedPreferences _prefs;

  SharedPrefsService._(this._prefs);

  static Future<SharedPrefsService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsService._(prefs);
  }

  bool get isPro => _prefs.getBool(_isProKey) ?? false;

  Future<void> setPro(bool val) async {
    await _prefs.setBool(_isProKey, val);
  }
}
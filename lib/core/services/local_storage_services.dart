import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static final _box = GetStorage();

  static T? getData<T>(String key) => _box.read<T>(key);

  static Future<void> saveData(String key, dynamic value) async =>
      await _box.write(key, value);

  static Future<void> removeData(String key) async =>
      await _box.remove(key);
}

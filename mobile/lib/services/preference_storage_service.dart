import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PrefKey { darkMode, enablePushService, autoCacheCount, enableExternalLink }

extension PrefKeyToKey on PrefKey {
  String get key => toString().split('.').last;
}

class PreferenceStorageService extends GetxService {
  static PreferenceStorageService get to =>
      Get.find<PreferenceStorageService>();

  late SharedPreferences _prefs;

  final Map<PrefKey, Rx<dynamic>> _preferences = {
    PrefKey.darkMode: false.obs,
    PrefKey.enablePushService: false.obs,
    PrefKey.autoCacheCount: 6.obs,
    PrefKey.enableExternalLink: false.obs,
  };

  void resetPreferences() {
    _preferences[PrefKey.darkMode]!.value = false;
    _preferences[PrefKey.enablePushService]!.value = false;
    _preferences[PrefKey.autoCacheCount]!.value = 6;
    _preferences[PrefKey.enableExternalLink]!.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    asyncInit();
  }

  Future<void> asyncInit() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromStorage();
    _bindAutoSave();
  }

  void _loadFromStorage() {
    _preferences.forEach((key, value) {
      if (value is Rx<bool>) {
        final result = _prefs.getBool(key.key);
        if (result != null) {
          value.value = result;
        }
      } else if (value is Rx<int>) {
        final result = _prefs.getInt(key.key);
        if (result != null) {
          value.value = result;
        }
      }
    });
  }

  void _bindAutoSave() {
    _preferences.forEach((key, value) {
      ever(value, (dynamic newValue) {
        if (newValue is bool) {
          _prefs.setBool(key.key, newValue);
        } else if (newValue is int) {
          _prefs.setInt(key.key, newValue);
        }
      });
    });
  }

  T getPreference<T>(PrefKey key) {
    return _preferences[key]?.value as T;
  }

  void setPreference<T>(PrefKey key, T value) {
    if (_preferences[key] != null) {
      _preferences[key]?.value = value;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TapToTurnPageProvider extends ChangeNotifier {
  static const String _key = 'tap_to_turn_page';

  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  TapToTurnPageProvider() {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    _isEnabled = prefs.getBool(_key) ?? false;

    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _isEnabled = value;

    notifyListeners();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(_key, value);
  }

  Future<void> toggle() async {
    await setEnabled(!_isEnabled);
  }
}
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrightnessProvider extends ChangeNotifier {
  // ============================================================
  // STORAGE KEY
  // ============================================================

  static const String _brightnessKey =
      'reader_brightness_mode';

  // ============================================================
  // BRIGHTNESS MODES
  // ============================================================

  static const String normal = 'Normal';
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';

  static const List<String> availableBrightnessModes = [
    normal,
    low,
    medium,
    high,
  ];

  // ============================================================
  // DEFAULT VALUE
  // ============================================================

  String _brightnessMode = normal;

  // ============================================================
  // GETTER
  // ============================================================

  String get brightnessMode => _brightnessMode;

  // ============================================================
  // DISPLAY NAME
  // ============================================================

  String get brightnessModeName {
    switch (_brightnessMode) {
      case low:
        return 'Low';

      case medium:
        return 'Medium';

      case high:
        return 'High';

      case normal:
      default:
        return 'Normal';
    }
  }

  // ============================================================
  // LOAD SAVED BRIGHTNESS
  // ============================================================

  Future<void> loadBrightnessPreference() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      final String? savedMode =
          prefs.getString(_brightnessKey);

      if (savedMode != null &&
          availableBrightnessModes.contains(
            savedMode,
          )) {
        _brightnessMode = savedMode;
      } else {
        _brightnessMode = normal;
      }
    } catch (e) {
      _brightnessMode = normal;

      debugPrint(
        'Brightness preference load error: $e',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // SELECT BRIGHTNESS MODE
  // ============================================================

  Future<void> selectBrightness(
    String mode,
  ) async {
    if (!availableBrightnessModes.contains(mode)) {
      return;
    }

    _brightnessMode = mode;

    // Immediately notify the UI.
    notifyListeners();

    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        _brightnessKey,
        mode,
      );
    } catch (e) {
      debugPrint(
        'Brightness preference save error: $e',
      );
    }
  }

  // ============================================================
  // CHECK MODE
  // ============================================================

  bool get isNormal =>
      _brightnessMode == normal;

  bool get isLow =>
      _brightnessMode == low;

  bool get isMedium =>
      _brightnessMode == medium;

  bool get isHigh =>
      _brightnessMode == high;
}
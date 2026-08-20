import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  static const String _fontKey = 'selected_font';

  // ============================================================
  // AVAILABLE FONTS
  // ============================================================

  static const String roboto = 'Roboto';
  static const String brittanySignature = 'BrittanySignature';
  static const String dancing = 'Dancing';

  // ============================================================
  // SELECTED FONT
  // ============================================================

  String _selectedFont = roboto;

  String get selectedFont => _selectedFont;

  // ============================================================
  // SELECTED FONT DISPLAY NAME
  // ============================================================

  String get selectedFontName {
    switch (_selectedFont) {
      case brittanySignature:
        return 'Brittany Signature';

      case dancing:
        return 'Dancing';

      case roboto:
      default:
        return 'Roboto';
    }
  }

  // ============================================================
  // FONT OPTIONS
  // ============================================================

  static const List<String> availableFonts = [
    roboto,
    brittanySignature,
    dancing,
  ];

  // ============================================================
  // LOAD SAVED FONT
  // ============================================================

  Future<void> loadFontPreference() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      final String? savedFont =
          prefs.getString(_fontKey);

      if (savedFont != null &&
          availableFonts.contains(savedFont)) {
        _selectedFont = savedFont;
      } else {
        _selectedFont = roboto;
      }
    } catch (e) {
      _selectedFont = roboto;

      debugPrint(
        'Font preference load error: $e',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // SELECT FONT
  // ============================================================

  Future<void> selectFont(String font) async {
    if (!availableFonts.contains(font)) {
      return;
    }

    _selectedFont = font;

    // Immediately update the entire app.
    notifyListeners();

    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        _fontKey,
        font,
      );
    } catch (e) {
      debugPrint(
        'Font preference save error: $e',
      );
    }
  }
}
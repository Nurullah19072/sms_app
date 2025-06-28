import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsManager {
  static bool isDarkTheme = false;
  static double fontSize = 16;
  static Color myMessageColor = Colors.blue[300]!;
  static Color otherMessageColor = Colors.green[300]!;
  static Color textColor = Colors.white;
  static String fontFamily = 'Roboto';

  static ValueNotifier<bool> settingsChanged = ValueNotifier<bool>(false); // ✅ YENİ

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    fontSize = prefs.getDouble('fontSize') ?? 16;
    myMessageColor = Color(prefs.getInt('myMessageColor') ?? Colors.blue[300]!.value);
    otherMessageColor = Color(prefs.getInt('otherMessageColor') ?? Colors.green[300]!.value);
    textColor = Color(prefs.getInt('textColor') ?? Colors.white.value);
    fontFamily = prefs.getString('selectedFont') ?? 'Roboto';
  }

  static Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkTheme);
    await prefs.setDouble('fontSize', fontSize);
    await prefs.setInt('myMessageColor', myMessageColor.value);
    await prefs.setInt('otherMessageColor', otherMessageColor.value);
    await prefs.setInt('textColor', textColor.value);
    await prefs.setString('selectedFont', fontFamily);

    settingsChanged.value = !settingsChanged.value; // ✅ Değişiklik olduğunda tetikle
  }
}

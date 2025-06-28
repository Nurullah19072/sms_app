import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'settings_manager.dart'; // SettingsManager dosyasını import etmeyi unutma!

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _opacity = 1.0;

  final List<String> fontOptions = [
    'Roboto',
    'Arial',
    'Courier New',
    'Times New Roman',
    'monospace',
  ];

  void pickColor(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = SettingsManager.isDarkTheme;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              background: Colors.grey[900]!,
              onBackground: Colors.white,
              surface: Colors.grey[800]!,
              onSurface: Colors.white,
            )
                : ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              background: Colors.white,
              onBackground: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            canvasColor: isDark ? Colors.grey[800]! : Colors.white, // Dropdown arka planı
            dropdownMenuTheme: DropdownMenuThemeData(
              menuStyle: MenuStyle(
                backgroundColor: MaterialStateProperty.all(
                  isDark ? Colors.grey[800]! : Colors.white,
                ),
              ),
              textStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontFamily: SettingsManager.fontFamily,
                fontSize: SettingsManager.fontSize,
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
              'Bir renk seçin',
              style: TextStyle(
                fontFamily: SettingsManager.fontFamily,
                fontSize: SettingsManager.fontSize,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: currentColor,
                onColorChanged: onColorChanged,
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.blue[200],
                  foregroundColor: isDark ? Colors.white : Colors.black,
                ),
                child: Text(
                  'Tamam',
                  style: TextStyle(
                    fontFamily: SettingsManager.fontFamily,
                    fontSize: SettingsManager.fontSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }






  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: Duration(milliseconds: 300),
      child: Scaffold(
        backgroundColor: SettingsManager.isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // ✅ Geri butonu rengi
          ),
          backgroundColor: SettingsManager.isDarkTheme ? Colors.grey[900] : null,
          title: Text(
            'Ayarlar',
            style: TextStyle(
              fontFamily: SettingsManager.fontFamily,
              color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Tema değişimi
            SwitchListTile(
              title: Text('Koyu Tema', style: TextStyle(
                fontFamily: SettingsManager.fontFamily,
                color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,)),
              value: SettingsManager.isDarkTheme,
              onChanged: (value) {
                setState(() => SettingsManager.isDarkTheme = value);
              },
            ),

            SizedBox(height: 20),

            // Yazı Boyutu
            Text('Yazı Boyutu', style: TextStyle(
              fontWeight: FontWeight.bold, fontFamily: SettingsManager.fontFamily,
              color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,)),
            Slider(
              value: SettingsManager.fontSize,
              min: 12,
              max: 30,
              divisions: 6,
              label: SettingsManager.fontSize.round().toString(),
              onChanged: (value) {
                setState(() => SettingsManager.fontSize = value);
              },
            ),

            SizedBox(height: 20),

            // Mesaj Renkleri
            ListTile(
              title: Text('Kendi Mesaj Rengi', style: TextStyle(
                  fontFamily: SettingsManager.fontFamily,
                color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,

              )),
              trailing: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SettingsManager.myMessageColor,
                  border: Border.all(
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
                    width: 2,
                  ),
                ),
              ),

              onTap: () => pickColor(
                SettingsManager.myMessageColor,
                    (color) => setState(() => SettingsManager.myMessageColor = color),
              ),
            ),
            ListTile(
              title: Text('Karşı Mesaj Rengi',
                  style: TextStyle(
                      fontFamily: SettingsManager.fontFamily,
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
                  )),
              trailing: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SettingsManager.otherMessageColor,
                  border: Border.all(
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
                    width: 2,
                  ),
                ),
              ),

              onTap: () => pickColor(
                SettingsManager.otherMessageColor,
                    (color) => setState(() => SettingsManager.otherMessageColor = color),
              ),
            ),
            ListTile(
              title: Text('Yazı Rengi',
                  style: TextStyle(
                    fontFamily: SettingsManager.fontFamily,
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
              )),
              trailing: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SettingsManager.textColor, // ✅ Buraya doğru değişken
                  border: Border.all(
                    color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
                    width: 2,
                  ),
                ),
              ),

              onTap: () => pickColor(
                SettingsManager.textColor,
                    (color) => setState(() => SettingsManager.textColor = color),
              ),
            ),

            SizedBox(height: 20),

            // Font Seçimi
            Text('Font Seçimi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: SettingsManager.fontFamily,
                  color: SettingsManager.isDarkTheme ? Colors.white : Colors.black,
                )),
            DropdownButton<String>(
              value: SettingsManager.fontFamily,
              dropdownColor: SettingsManager.isDarkTheme ? Colors.grey[900] : Colors.white, // 🌙 Menü arka plan rengi
              style: TextStyle(
                fontFamily: SettingsManager.fontFamily,
                color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // 🌙 Seçili yazı rengi
              ),
              onChanged: (newFont) {
                setState(() => SettingsManager.fontFamily = newFont!);
              },
              items: fontOptions.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(
                      fontFamily: font,
                      color: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // 🌙 Menü içindeki yazılar
                    ),
                  ),
                );
              }).toList(),
            ),


            SizedBox(height: 30),

            // Kaydet Butonu
            ElevatedButton(
              onPressed: () async {
                setState(() => _opacity = 0.0); // fade out
                await SettingsManager.saveSettings(); // ✅
                await SettingsManager.loadSettings(); // ✅
                await Future.delayed(Duration(milliseconds: 300)); // fade in
                setState(() => _opacity = 1.0);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ayarlar kaydedildi!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200], // 🌟 Tema bazlı arka plan rengi
                foregroundColor: SettingsManager.isDarkTheme ? Colors.white : Colors.black, // Yazı rengi
                textStyle: TextStyle(
                  fontFamily: SettingsManager.fontFamily,
                ),
              ),
              child: Text('Kaydet'),
            )
          ],
        ),
      ),
    );
  }
}

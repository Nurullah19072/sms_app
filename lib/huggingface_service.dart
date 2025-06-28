import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  static const String _apiUrl = "https://1e63663b-ab89-4828-83c5-c2ca8a1929b0-00-2fb4sttvwhi3t.picard.replit.dev/predict";

  // Sabit AES anahtarı (16 byte olmalı)
  static final _key = encrypt.Key.fromUtf8('ThisIsASecretKey'); // Aynı KEY
  static final _ivLength = 16;

  /// AES + CBC + PKCS7 + Base64 şifreleme
  static String encryptMessage(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(_ivLength);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // IV + encrypted data birleşip base64 olarak gönderilecek
    final combined = iv.bytes + encrypted.bytes;
    return base64.encode(combined);
  }

  /// Flask API'ye şifreli mesaj göndererek spam olup olmadığını belirler
  static Future<bool> isSpam(String message, {int retryCount = 3}) async {
    print("🧠 Flask API çağırılıyor: $message");

    String encryptedMessage = encryptMessage(message);
    print("🔐 AES ile şifrelenmiş mesaj: $encryptedMessage");

    for (int attempt = 0; attempt < retryCount; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({"sms": encryptedMessage}),
        );

        print("📬 Flask cevabı: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data is Map<String, dynamic> && data.containsKey("result")) {
            final resultText = data["result"].toString().toUpperCase();

            if (resultText.contains("LABEL_1")) {
              print("🚨 SPAM tespit edildi!");
              return true;
            } else if (resultText.contains("LABEL_0")) {
              print("✅ Normal mesaj.");
              return false;
            } else {
              print("❓ Tahmin sonucu anlaşılamadı: $resultText");
            }
          } else {
            print("❌ Beklenmeyen cevap formatı: $data");
          }
        } else {
          print("❌ API Hatası: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ Flask API çağrısı başarısız: $e");
      }
    }

    return false; // Hata olursa varsayılan olarak spam değil kabul et
  }
}

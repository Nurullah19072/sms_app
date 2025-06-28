# Türkçe SMS Spam Tespiti için BERT Tabanlı Mobil Uygulama

Bu proje, Flutter kullanılarak geliştirilmiş mobil bir uygulamadır. Gelen SMS mesajlarını gerçek zamanlı olarak “SPAM” veya “NORMAL” olarak sınıflandırmak için Hugging Face üzerinde barındırılan `BaranKanat/BerTurk-SpamSMS` BERT modelini API aracılığıyla çağırır.

## Özellikler

* **Gerçek Zamanlı SMS Analizi**: Uygulama açıkken ya da arka planda gelen SMS’leri otomatik olarak sınıflandırır.
* **Çift Platform Desteği**: Tek kod tabanıyla hem Android hem de iOS desteği.
* **Gizlilik ve Güvenlik**: AES şifreleme ile mesaj içeriği cihaz üzerinde şifrelenerek API’ye iletilir.
* **Özelleştirilebilir Arayüz**: Tema, yazı tipi boyutu ve renk seçenekleri.
* **Performans Optimizasyonu**: Daha önce sınıflandırılmış mesajlar lokal cache’de saklanarak gereksiz API çağrıları engellenir.

## Veri Seti

Bu veri seti, spam veya normal olarak etiketlenmiş Türkçe SMS mesajlarından oluşmaktadır. Türkiye’nin farklı bölgelerinde yaşayan çeşitli yaş gruplarındaki insanlardan toplanmıştır.

> Eğer bu veri setini kullanırsanız, lütfen aşağıdaki makaleyi referans gösterin:
> Karasoy, O., Ballı, S. (2021). Türkçe Dilinde Derin Metin Analizi ve Derin Öğrenme Yöntemleri ile Spam SMS Tespiti. *Arabian Journal for Science and Engineering*. [https://doi.org/10.1007/s13369-021-06187-1](https://doi.org/10.1007/s13369-021-06187-1)

## Katkıda Bulunanlar

* **Nurullah Yıldırım** — [LinkedIn](https://www.linkedin.com/in/nurullah1yıldırım/)
* **Baran Kanat** — [LinkedIn](https://www.linkedin.com/in/baran-kanat/)

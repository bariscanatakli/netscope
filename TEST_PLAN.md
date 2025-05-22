# NetScope Test Plan: Team Division

Bu doküman, projedeki test görevlerinin 4 kişiye eşit şekilde bölünmesini ve her birinin sorumluluklarının net olarak tanımlanmasını sağlar.

## Takım Üyesi 1: Kimlik Doğrulama & Kullanıcı Yönetimi
**Test Edilecek Dosyalar:**
- lib/screens/auth/login_screen.dart
- lib/screens/auth/signup_screen.dart
- lib/screens/auth/forgot_password_screen.dart
- lib/providers/auth_provider.dart
- lib/widgets/auth_state_wrapper.dart

**Test Kapsamı:**
- Kullanıcı kayıt akışı
- Giriş fonksiyonu
- Şifre kurtarma
- Kullanıcı profil verisi saklama/okuma
- Kimlik doğrulama durumu kalıcılığı
- Firebase kimlik doğrulama entegrasyonu

## Takım Üyesi 2: Hız Testi & Sonuçlar
**Test Edilecek Dosyalar:**
- lib/screens/apps/speedtest/speedtest_screen.dart
- lib/screens/apps/speedtest/speed_test_results_screen.dart
- lib/screens/apps/speedtest/services/speedtest_service.dart
- lib/screens/apps/pingtest/ (tüm dosyalar)

**Test Kapsamı:**
- Download/upload hız ölçümü
- Ping testi fonksiyonu
- Test sonuçlarının Firestore'a kaydı
- Geçmiş hız testi sonuçlarının gösterimi
- Ağ performans metriklerinin doğruluğu
- Hız testi iptali ve hata yönetimi

## Takım Üyesi 3: Traceroute & Harita Fonksiyonları
**Test Edilecek Dosyalar:**
- lib/screens/apps/traceroute/map/map_screen.dart
- lib/screens/apps/traceroute/map/map_tab.dart
- lib/screens/apps/traceroute/map/hops_tab.dart
- lib/screens/apps/traceroute/map/details_tab.dart
- lib/screens/apps/traceroute/map/hop_details_screen.dart

**Test Kapsamı:**
- Traceroute çalıştırma ve görselleştirme
- Google Maps entegrasyonu
- Hop navigasyonu ve gösterimi
- Coğrafi konum verisi haritalama
- Traceroute geçmişi saklama/okuma
- Ağ topolojisi görselleştirme

## Takım Üyesi 4: Ana Özellikler & Ağ Tarayıcı
**Test Edilecek Dosyalar:**
- lib/screens/home/home_page.dart
- lib/screens/home/favorites_page.dart
- lib/screens/home/profile_page.dart
- lib/screens/home/root_screen.dart
- lib/services/network_info_service.dart
- lib/screens/apps/networkscanner/ (tüm dosyalar)

**Test Kapsamı:**
- Ekranlar arası geçiş ve yönlendirme
- Tema değiştirme fonksiyonu
- Favoriler sistemi (ekle/çıkar)
- Kullanıcı profil verisi gösterimi
- Ağ bilgisi toplama
- Ağ tarayıcı aracı fonksiyonu
- Platformlar arası davranış testleri

## Her Alan İçin Test Tipleri
- Birim Testleri (unit)
- Widget Testleri
- Entegrasyon Testleri
- Uçtan Uca Testler

## Test Ortamı Kurulumu
- test/setup.dart dosyasında mock servisler tanımlanabilir.
- Testler için `flutter test` komutu kullanılabilir.

---

Her ekip üyesi, kendi alanındaki dosyalar için test yazmalı ve mevcut test klasör yapısını kullanmalıdır.

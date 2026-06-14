# FinScope AI — Mimari Doküman

Bu doküman uygulamanın katmanlı mimarisini, bağımlılık yönetimini, hata
stratejisini ve tasarım sistemini özetler. Bitirme sunumu için referans.

---

## 1. Katmanlı Mimari

Uygulama, sorumlulukları net ayrılmış katmanlardan oluşur. Veri akışı tek yönlü
ve öngörülebilirdir:

```
┌─────────────────────────────────────────────────────────────┐
│  UI KATMANI            lib/screens/  +  lib/widgets/          │
│  Ekranlar, yeniden kullanılabilir bileşenler (AppCard…)      │
│  Sadece sunumla ilgilenir; veri kaynağını bilmez.            │
└───────────────┬─────────────────────────────────────────────┘
                │  locator.market / locator.algoTrade …
                ▼
┌─────────────────────────────────────────────────────────────┐
│  DI / SERVICE LOCATOR  lib/core/di/locator.dart              │
│  Tüm bağımlılıkları tek yerden, tekil olarak sağlar.         │
└───────────────┬─────────────────────────────────────────────┘
                ▼
┌─────────────────────────────────────────────────────────────┐
│  REPOSITORY KATMANI    lib/data/repositories/                │
│  Market · Sentiment · AlgoTrade · Portfolio                  │
│  UI'ın konuştuğu soyutlama. Kaynak değişse UI etkilenmez.    │
└───────────────┬─────────────────────────────────────────────┘
                ▼
┌─────────────────────────────────────────────────────────────┐
│  SERVİS / VERİ KAYNAĞI lib/services/                         │
│  DataService(JSON) · AlgoTradeService(Supabase+Firebase) ·   │
│  SentimentService · AuthService · FavoritesService …         │
└───────────────┬─────────────────────────────────────────────┘
                ▼
        Firebase (Auth/Firestore) · Supabase · yerel JSON · SharedPreferences
```

**Kural:** Bir ekran asla doğrudan `FirebaseFirestore.instance` veya
`DataService()` çağırmaz. Her zaman `locator.<repo>` üzerinden gider.

---

## 2. Dizin Yapısı

```
lib/
├── main.dart                  # Uygulama girişi, MultiProvider, MaterialApp
├── theme_provider.dart        # Açık/koyu mod ChangeNotifier (runtime toggle)
├── core/
│   ├── theme/
│   │   ├── color_scheme.dart   # AppColors — tüm renk token'ları (tek kaynak)
│   │   ├── app_theme.dart      # AppTheme.light / AppTheme.dark (ThemeData)
│   │   └── text_styles.dart    # AppTextStyles — tipografi ölçeği
│   ├── di/
│   │   └── locator.dart        # ServiceLocator (DI)
│   ├── error/
│   │   └── result.dart         # Result<T>, Ok/Err, AppFailure hiyerarşisi
│   └── utils/
│       └── app_logger.dart     # Merkezi, seviyeli loglama
├── data/
│   └── repositories/           # Market · Sentiment · AlgoTrade · Portfolio
├── models/                     # Değer tipleri (fromJson/toJson/copyWith/==)
├── providers/
│   └── auth_provider.dart      # Merkezi auth state (ChangeNotifier)
├── services/                   # Veri kaynağı erişimi
├── screens/                    # Ekranlar (özellik bazlı klasörler)
└── widgets/                    # Yeniden kullanılabilir bileşenler
```

---

## 3. Bağımlılık Yönetimi (DI / Service Locator)

`lib/core/di/locator.dart` çok hafif bir **Service Locator** sunar. Önceden
ekranlar bağımlılıklarını doğrudan `new` ile yaratıyordu (`DataService()`),
bu da test ve bakımı zorlaştırıyordu. Artık:

```dart
final _dataService = locator.market;          // MarketRepository
final _servis     = locator.algoTrade;        // AlgoTradeRepository
```

Servisler ve repository'ler tek noktada, tekil (singleton) olarak tanımlıdır;
bağımlılık grafiği tek bakışta görülür ve testte sahte (fake) sürümler
enjekte edilebilir.

---

## 4. Repository Katmanı

Her repository, ilgili servise **delege** eder ve UI'a kararlı bir arayüz sunar:

| Repository            | Sarmaladığı kaynak                    |
|-----------------------|----------------------------------------|
| `MarketRepository`    | `DataService` (yerel JSON + cache)     |
| `SentimentRepository` | `SentimentService`                     |
| `AlgoTradeRepository` | `AlgoTradeService` (Supabase+Firebase) |
| `PortfolioRepository` | Firestore `user_match` koleksiyonu     |

**Kazanım:** Veri kaynağı değişse (JSON → REST API) yalnızca repository
güncellenir; ekranlar dokunulmaz. `PortfolioRepository`, önceden
`PortfolioScreen` içine gömülü olan Firestore çağrılarını da içine aldı
(iş mantığı UI'dan çıkarıldı).

---

## 5. Durum Yönetimi (State Management)

- **Auth & Tema:** `provider` paketi ile iki `ChangeNotifier`
  (`AuthProvider`, `ThemeProvider`) — `main.dart`'taki `MultiProvider`'da
  kayıtlı, tüm ağaca yayılır.
- **Ekran verisi:** `FutureBuilder` (tek seferlik yükleme) ve `StreamBuilder`
  (Firestore canlı veri, ör. portföy) ile reaktif.
- **Favoriler:** `FavoritesService` + `ValueNotifier` ile gözlemlenebilir,
  kullanıcıya özel (SharedPreferences) durum.

---

## 6. Hata Yönetimi & Loglama

- **Merkezi log:** `AppLogger` (`core/utils/app_logger.dart`) — servislere
  dağılmış `debugPrint` çağrılarının yerini aldı. Debug'da konsola yazar,
  release'de sessizdir; ileride tek noktadan Crashlytics'e bağlanabilir.
- **Hata sözleşmesi:** `Result<T>` (`Ok`/`Err`) + `sealed AppFailure`
  hiyerarşisi (`NetworkFailure`, `DataFailure`, `AuthFailure`,
  `UnknownFailure`). İstisna yerine hatayı *değer* olarak döndürerek
  çağıranı ele almaya zorlar. Birim testlerle kapsanmıştır; ekranlar
  kademeli olarak benimsenecektir.
- **Auth:** `AuthService`, login akışında kullanılan kendi
  `{success, message}` sözleşmesini korur (Result'a benzer; demo-kritik
  olduğu için dokunulmadı).

---

## 7. Tasarım Sistemi (Design System)

Tüm görsel kararlar tek kaynaktan yönetilir — ekranlarda sihirli renk/stil yok:

- **`AppColors`** — tüm renk token'ları (arka plan gradyanı, kart yüzeyleri,
  kâr/zarar, sektör renkleri, cam efekti overlay'leri). Önceden 5 ekrana
  kopyalanmış `_kBgTop/_kCard/...` sabitleri buraya bağlandı.
- **`AppTheme`** — `light` / `dark` `ThemeData` (token'lı). `main.dart`
  artık sadece `theme: AppTheme.light, darkTheme: AppTheme.dark`.
- **`AppTextStyles`** — tipografi ölçeği (başlık, kart, sayısal, etiket…).
- **`AppCard` / `glassCardDecoration`** — yeniden kullanılabilir kart;
  ekranlardaki kopyalanmış `_glass()/_cardDeco()` dekorları tek yere indi.

---

## 8. Modeller (Değer Tipleri)

`lib/models/` altındaki modeller manuel `fromJson` ile JSON'dan üretilir.
Çekirdek modeller (`StockModel`, `ValuationModel`, `SentimentModel`) ayrıca
`toJson`, `copyWith` ve değer eşitliği (`==`/`hashCode`) taşır — immutable,
karşılaştırılabilir ve güncellenebilir. (Codegen/Freezed kullanılmadı;
bağımlılık ve build karmaşası eklemeden elle yazıldı.)

---

## 9. Test

`test/` altında birim ve widget testleri (`flutter test` → tümü yeşil):

| Test                          | Neyi doğrular                              |
|-------------------------------|--------------------------------------------|
| `core/result_test.dart`       | Result/AppFailure davranışı                |
| `models/*_test.dart`          | fromJson, toJson round-trip, copyWith, ==  |
| `data/market_repository_test` | Repository'nin enjekte edilen kaynağa      |
|                               | delege etmesi (DI seam, sahte DataService) |
| `widget_test.dart`            | `AppCard` bileşeni render testi            |

> Not: Önceki varsayılan "Counter" smoke testi bu uygulamayla uyuşmuyordu
> (Provider/Firebase gerektirip başarısız oluyordu); kaldırıldı.

---

## 10. Çalıştırma

```bash
flutter pub get
flutter analyze      # statik analiz — 0 sorun
flutter test         # birim/widget testleri
flutter run          # uygulamayı çalıştır
```

# ADR 0001: Hasil Spike Teknis & Validasi Platform Mobile (Android & iOS)

* **Status**: Accepted
* **Tanggal**: 2026-10-24
* **Pengusul**: Mobile Architecture & Engineering Team
* **Tiket Referensi**: ROOTIN-M002 (GitHub Issue [#28](https://github.com/andresanjaya/rootin/issues/28))
* **Target Kelanjutan**: ROOTIN-M003 (Desain Arsitektur Sistem Terinci) & ROOTIN-M007 (Inisialisasi Scaffold Proyek)

---

## 1. Konteks & Latar Belakang

Rootin Mobile dirancang sebagai aplikasi *greenfield* untuk asisten pemeliharaan aset pribadi, peralatan rumah tangga, dan kendaraan yang berorientasi **offline-first** pada platform Android dan iOS. Karakteristik aplikasi ini menuntut keandalan operasional yang sangat tinggi:
1. **Offline Autonomy**: Seluruh siklus hidup aset, pembacaan riwayat, dan perhitungan kalkulasi jadwal perawatan harus berfungsi 100% tanpa jaringan internet.
2. **Presisi Notifikasi Lokal**: Pengingat wajib berbunyi tepat waktu di perangkat pengguna tanpa mengandalkan server push cloud (*zero server cost* untuk notifikasi rutin).
3. **Sinkronisasi Outbox Andal**: Perubahan data saat offline harus diantrekan secara persisten dan dikirimkan ke cloud saat koneksi pulih tanpa kehilangan data (*zero data loss*).
4. **Isolasi Privasi Aset**: Data dan foto aset disimpan secara terisolasi per pengguna menggunakan Row-Level Security (RLS) dan private storage bucket.

Sebelum memasuki fase penyusunan arsitektur terinci (ROOTIN-M003) dan scaffolding kode sumber (ROOTIN-M007), spike teknis pada tiket ROOTIN-M002 dilaksanakan untuk memverifikasi kompatibilitas pustaka inti, mengevaluasi perilaku sistem operasi pada Android vs iOS, mengidentifikasi batasan lingkungan pengembangan (host Windows 11), serta menetapkan konfigurasi build dan CI/CD yang diperlukan.

Spike ini juga menegaskan **invariant arsitektur Rootin**: tidak ada ketergantungan kode atau database ke Rootin Web (*zero dependency*), serta seluruh keputusan teknologi Flutter yang telah dipilih dipertahankan secara utuh tanpa pergantian diam-diam (*no silent tech replacement*).

---

## 2. Keputusan Arsitektur

Berdasarkan hasil investigasi dan pengujian spike teknis, arsitektur Rootin Mobile menetapkan tech stack dan konfigurasi platform berikut sebagai standar baku:

1. **Framework & Bahasa**:
   - **Flutter SDK 3.29.2** pada channel **stable**.
   - **Dart SDK 3.7.2** dengan mode sound null-safety penuh.
2. **State Management & Dependency Injection**:
   - `flutter_riverpod` (v2.6.x) dan `riverpod_annotation` (v2.3.x).
   - Penggunaan `Notifier` dan `AsyncNotifier` untuk mengelola state bisnis secara terisolasi dan reaktif.
3. **Navigasi & Deep Linking**:
   - `go_router` (v14.x) berbasis rute deklaratif.
   - Menangani *deep link* dari *payload* notifikasi lokal pada kondisi *cold start* (*terminated*) maupun *warm start* (*background*).
4. **Penyimpanan Lokal & Durable Outbox**:
   - `drift` (v2.24.x) dan `sqlite3_flutter_libs` (v0.5.x).
   - Penggunaan transaksi atomik SQLite (WAL mode) untuk memastikan pencatatan mutasi entitas lokal dan entri `sync_outbox` terjadi dalam satu unit kerja yang tak terpisahkan.
5. **Autentikasi & Layanan Cloud**:
   - `supabase_flutter` (v2.8.x) dengan alur PKCE (Proof Key for Code Exchange) dan Email OTP / Magic Link.
   - Sesi pengguna dikelola dengan token terenkripsi via `flutter_secure_storage` serta diisolasi ketat oleh UUID `user_id`.
6. **Pengingat & Alarm Lokal**:
   - `flutter_local_notifications` (v18.x) dikombinasikan dengan pustaka `timezone` (v0.9.x).
   - Konfigurasi izin runtime Android 13+ (`POST_NOTIFICATIONS`), izin alarm presisi (`SCHEDULE_EXACT_ALARM`), notification channels berprioritas tinggi, dan integrasi `UNUserNotificationCenter` pada iOS.
7. **Pengambilan Media & Penyimpanan Foto Privat**:
   - `image_picker` (v1.1.x) dengan kompresi lokal sisi klien (target resolusi maksimal 1080p, ukuran berkas < 1MB).
   - Unggah ke Supabase Storage bucket privat dengan struktur path `{user_id}/{item_id}/{uuid}.jpg` dan pembacaan melalui *short-lived signed URL* (durasi 60 menit).

---

## 3. Matriks Validasi Platform Lengkap (Android vs iOS)

Tabel berikut menyajikan hasil pengujian spike komprehensif yang membandingkan perilaku teknis antara platform Android (API level 34 / Android 14) dan iOS (iOS 17.x):

| Kategori Pengujian | Komponen / Fitur | Status Android (API 34) | Status iOS (iOS 17) | Temuan & Bukti Teknis | Keterbatasan Platform | Tindak Lanjut Arsitektur |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Toolchain & Runtime** | Flutter 3.29.2 & Dart 3.7.2 | **Berhasil** | **Berhasil** | Kompilasi clean build pada engine Flutter terbaru tanpa kendala ABI. Android NDK r26b dan Gradle 8.4 kompatibel penuh. | iOS build membutuhkan macOS runner dengan Xcode 16; tidak dapat dikompilasi langsung di Windows 11. | Host Windows 11 difokuskan untuk pengembangan Android; build dan pengujian iOS dialihkan ke GitHub Actions macOS runner. |
| **State Management** | Riverpod 2.6 (`flutter_riverpod`) | **Berhasil** | **Berhasil** | Provider lifecycle bekerja deterministik. Integrasi reactive stream dari Drift database mengalir ke UI tanpa *memory leak* atau *rebuild* berlebih. | Tidak ada keterbatasan spesifik platform. | Terapkan `riverpod_generator` untuk standardisasi boilerplate notifier dan compile-time safety. |
| **Navigasi & Routing** | `go_router` 14.x Deep Linking | **Berhasil** | **Berhasil** | Rute berbasis URI berjalan mulus. Pengujian payload notifikasi membuka halaman target (`/items/:id/reminders/:reminderId`) secara presisi. | Pada cold start, rute awal sempat berkedip jika listener router belum siap sebelum payload terbaca. | Tangani payload peluncuran di fungsi `main()` via `getNotificationAppLaunchDetails()` sebelum inisialisasi awal `GoRouter`. |
| **Database Lokal** | Drift SQLite (`sqlite3_flutter_libs`) | **Berhasil** | **Berhasil** | Kecepatan penulisan WAL mode < 5ms per transaksi. Integritas foreign key dan cascade delete berjalan sesuai aturan relasional. | Kunci enkripsi database SQLCipher memerlukan konfigurasi linking tambahan jika diaktifkan kelak. | Gunakan Drift standar dengan `sqlite3_flutter_libs` pada tahap MVP. Enkripsi level kolom via secure storage jika diperlukan. |
| **Durable Outbox** | Transaksi Atomik Outbox Queue | **Berhasil** | **Berhasil** | Mutasi entitas bisnis + insert tabel `sync_outbox` berhasil dieksekusi dalam satu blok transaksi atomik SQLite. Data antrean bertahan utuh saat aplikasi dimatikan paksa (*kill*). | Background sync saat app mati bergantung pada keterbatasan OS scheduler (WorkManager vs BGTaskScheduler). | Buat mekanisme sinkronisasi ganda: sinkronisasi otomatis saat app dibuka (*on app resume*) dan scheduler latar belakang saat perangkat idle. |
| **Autentikasi** | Supabase Auth (PKCE & Email OTP) | **Berhasil** | **Berhasil** | Alur PKCE berhasil tanpa membuka browser eksternal yang merusak alur aplikasi. Sesi bertahan di `flutter_secure_storage`. Isolasi multi-tenant terverifikasi melalui RLS database. | Saat offline total, token refresh tidak dapat menghubungi server, namun sesi lokal tetap dapat dibaca untuk mengidentifikasi `user_id`. | Gunakan sesi lokal ter-cache untuk operasi offline; trigger re-autentikasi hanya saat koneksi pulih dan token kedaluwarsa. |
| **Notifikasi: Izin Runtime** | Android 13+ & iOS Permission | **Berhasil** | **Berhasil** | Android meminta `POST_NOTIFICATIONS` secara dinamis saat runtime; iOS meminta izin `UNUserNotificationCenter` (`alert`, `sound`, `badge`). | Jika pengguna menolak izin (*denied*), sistem operasi memblokir prompt dialog berikutnya secara permanen. | Tampilkan banner peringatan non-intrusif di UI aplikasi dan sediakan tombol pintas untuk membuka App Settings (`openAppSettings()`). |
| **Notifikasi: Alarm Presisi** | Android Exact Alarm Permission | **Berhasil** | **N/A (Native)** | Android 12+ memerlukan deklarasi `SCHEDULE_EXACT_ALARM`. Notifikasi dijadwalkan tepat detik yang ditentukan via AlarmManager. | Pada Android 14 (API 34), izin exact alarm dapat dicabut pengguna dari pengaturan sistem atau dibatasi oleh Doze Mode. | Deklarasikan `SCHEDULE_EXACT_ALARM` dan implementasikan fallback graceful ke inexact window jika izin exact dicabut. |
| **Notifikasi: Channel & Sound** | Notification Channels | **Berhasil** | **Berhasil** | Android channel `rootin_reminders` dengan importance `HIGH` memunculkan *heads-up banner*. iOS menampilkan banner dan memutar suara default. | Kustomisasi suara notifikasi memerlukan aset audio yang diletakkan di direktori resource native (`res/raw` dan bundle iOS). | Sediakan channel default berprioritas tinggi pada tahap scaffold (M007) dengan suara sistem standar. |
| **Notifikasi: State Foreground** | Notifikasi saat App Aktif | **Berhasil** | **Berhasil** | Android menampilkan notifikasi di tray/heads-up. iOS menampilkan banner berkat konfigurasi `DarwinInitializationSettings(requestAlertPermission: true)`. Callback `onDidReceiveNotificationResponse` terpanggil. | Interaksi banner tidak otomatis memicu dialog jika context navigasi sedang menampilkan modal blocking. | Tangani payload melalui Riverpod event stream terpusat agar UI dapat merespons tanpa konflik dialog. |
| **Notifikasi: State Background** | Notifikasi saat App di Background | **Berhasil** | **Berhasil** | Notifikasi muncul di tray perangkat. Menekan notifikasi berhasil membangunkan aplikasi ke foreground dan mengalirkan payload ke navigasi. | Pada vendor Android tertentu (Xiaomi/MIUI, Samsung/OneUI), agresivitas penghemat baterai dapat menunda eksekusi jika tidak dikecualikan. | Dokumentasikan panduan pengecualian penghemat baterai (*battery optimization whitelist*) di menu Pengaturan Aplikasi. |
| **Notifikasi: State Terminated** | Cold Start dari Notifikasi | **Berhasil** | **Berhasil** | Aplikasi diluncurkan dari kondisi mati total (*cold start*). Payload JSON dibaca melalui `getNotificationAppLaunchDetails()` dan langsung mengarahkan rute ke rincian reminder terkait. | Proses inisialisasi async (Supabase, Drift, Riverpod) harus selesai sebelum transisi rute dilakukan untuk mencegah *null pointer*. | Pasang splash/bootstrap gatekeeper yang menunggu inisialisasi service inti sebelum mengeksekusi navigasi target payload. |
| **Notifikasi: Reboot Persistence** | Ketahanan Setelah Restart Perangkat | **Berhasil** | **Berhasil** | Android berhasil menjadwalkan ulang alarm setelah boot via receiver `RECEIVE_BOOT_COMPLETED`. Pada iOS, alarm yang dijadwalkan pada `UNUserNotificationCenter` bertahan otomatis di tingkat OS. | Android memerlukan pembacaan ulang database Drift untuk mendaftarkan ulang jadwal ke AlarmManager setelah *boot completed*. | Buat BootReceiver native yang memanggil worker ringan untuk membaca pengingat aktif dari database lokal Drift. |
| **Notifikasi: Timezone Shift** | Perubahan Zona Waktu / DST | **Berhasil** | **Berhasil** | Integrasi pustaka `timezone` (`tz.TZDateTime.from`) berhasil menjaga waktu absolut. Perubahan jam perangkat tidak merusak interval kalkulasi. | Database lokal harus menyimpan waktu dalam format ISO 8601 UTC untuk mencegah ambiguitas offset lokal. | Standarkan seluruh kolom tanggal di Drift database menggunakan tipe integer epoch milliseconds atau ISO 8601 UTC string. |
| **Notifikasi: Deduplikasi** | Pencegahan Notifikasi Dobel | **Berhasil** | **Berhasil** | Penetapan ID notifikasi deterministik (hashing 32-bit dari `reminder_id` + `scheduled_timestamp`) sukses mencegah duplikasi notifikasi pada slot yang sama. | Jangkauan ID notifikasi Android terbatas pada 32-bit signed integer (`-2^31` hingga `2^31 - 1`). | Terapkan algoritma hash deterministik (misalnya Murmur3 atau CRC32 modulo `0x7FFFFFFF`) untuk menghasilkan integer 32-bit positif. |
| **Media & Kamera** | `image_picker` (Kamera & Galeri) | **Berhasil** | **Berhasil** | Pemilihan foto dari kamera dan galeri berfungsi normal. Izin runtime `CAMERA` dan akses galeri tertangani dengan baik di Android dan iOS. | iOS Simulator tidak memiliki akses ke perangkat keras kamera (hanya galeri foto yang berfungsi di simulator). | Buat mock image provider atau gunakan fallback galeri otomatis saat aplikasi berjalan di lingkungan simulator/emulator. |
| **Kompresi Gambar** | Sisi Klien (Local Compression) | **Berhasil** | **Berhasil** | Foto beresolusi asli (12 MP, ~4-6 MB) berhasil dikompresi menjadi format JPEG 1080p dengan ukuran < 800 KB dalam durasi < 300 ms. | Operasi kompresi intensif CPU dapat memicu frame drop jika dijalankan di main isolate UI. | Jalankan proses decoding dan kompresi gambar di latar belakang menggunakan `compute()` isolate. |
| **Private Cloud Storage** | Supabase Storage & Signed URL | **Berhasil** | **Berhasil** | Berkas terunggah ke bucket privat `item-photos` pada path `{user_id}/{item_id}/{uuid}.jpg`. Berkas tidak dapat diakses publik (*403 Forbidden*), dan berhasil dibuka dengan *signed URL* 60 menit. | Ketergantungan signed URL memerlukan koneksi internet untuk memperbarui URL yang kedaluwarsa. | Simpan salinan berkas lokal secara permanen di direktori aplikasi perangkat (`path_provider`) sebagai *offline-first cache*. |

---

## 4. Analisis Kebutuhan Toolchain & Strategi CI/CD

### 4.1 Hambatan Lingkungan Pengembang Lokal (Windows 11)
Stasiun kerja pengembang saat ini berjalan di atas sistem operasi **Windows 11 Pro 64-bit**. Kondisi ini memberikan implikasi teknis langsung:
- **Pengembangan Android Penuh**: Windows 11 mendukung ekosistem Android Studio, Android SDK (target API 34+), Java Development Kit (JDK 17), dan Android Virtual Device (AVD) berbasis akselerasi hardware Hyper-V / WHPX.
- **Keterbatasan Kompilasi iOS**: Sistem operasi Windows tidak dapat mengkompilasi target iOS, tidak memiliki utilitas `xcodebuild`, dan tidak dapat menjalankan iOS Simulator maupun CocoaPods secara langsung (keterbatasan lisensi dan arsitektur Apple).

### 4.2 Strategi Runner CI/CD
Untuk mengatasi kendala host pengembang Windows dan menjamin kualitas kompilasi kedua platform, alur CI/CD dirancang menggunakan **GitHub Actions** dengan pembagian beban kerja sebagai berikut:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        GitHub Actions Pipeline                         │
├──────────────────────────────────┬─────────────────────────────────────┤
│   Runner: ubuntu-latest (Linux)  │   Runner: macos-14 (Apple Silicon)  │
├──────────────────────────────────┼─────────────────────────────────────┤
│ • Static Analysis (dart analyze) │ • Setup Xcode 16 & CocoaPods        │
│ • Formatting (dart format check) │ • Flutter build iOS (--no-codesign) │
│ • Pure Dart Unit Tests (Domain)  │ • iOS Integration & Widget Tests    │
│ • Flutter Widget Tests           │ • Archiving IPA (Staging / Release) │
│ • Android APK / AAB Build        │ • Fastlane upload to TestFlight     │
└──────────────────────────────────┴─────────────────────────────────────┘
```

1. **Linux Runner (`ubuntu-latest`)**:
   - Menjalankan analisis statis ketat (`very_good_analysis` / `flutter analyze`).
   - Menjalankan seluruh pengujian unit logika bisnis murni (*Pure Dart unit tests*) untuk kalkulator interval, recurrence engine, dan outbox processor.
   - Mengkompilasi APK dan Android App Bundle (`flutter build appbundle --release`).
2. **macOS Runner (`macos-14` / `macos-latest` M1/M2)**:
   - Dijalankan pada setiap *Pull Request* ke branch utama dan tag rilis.
   - Menjalankan instalasi pod (`pod install`) dan kompilasi headless iOS (`flutter build ios --no-codesign`).
   - Menjamin bahwa perubahan kode Dart tidak memicu regresi kompilasi pada Swift/Objective-C bindings.

### 4.3 Kebutuhan Perangkat Fisik vs Emulator/Simulator

| Aspek Pengujian | Emulator Android (API 34) | Simulator iOS (macOS Runner) | Perangkat Fisik (Hardware) | Rekomendasi Alokasi |
| :--- | :--- | :--- | :--- | :--- |
| **Logika Bisnis & SQLite** | 100% Valid | 100% Valid | 100% Valid | Cukup diuji pada unit test & emulator. |
| **Notifikasi Foreground/Background** | Valid | Valid | Valid | Emulator Android & Simulator iOS memadai untuk verifikasi UI flow. |
| **Notifikasi Terminated & Boot** | Valid (via `adb shell am broadcast`) | Terbatas | **Kritis & Wajib** | Wajib divalidasi pada minimal 1 perangkat fisik Android nyata untuk memverifikasi perilaku vendor OS (Samsung OneUI / Xiaomi HyperOS). |
| **Kamera Fisik Hardware** | Virtual Scene Emulasi | **Tidak Didukung** (Mock Galeri) | **Kritis & Wajib** | Pengujian fokus kamera, rasio aspek sensor, dan orientasi EXIF membutuhkan hardware nyata (Android & iPhone fisik). |
| **Performa Animasi & Scroll** | Terbatas (60 fps emulated) | Terbatas (60 fps emulated) | **Kritis (120 Hz ProMotion)** | Evaluasi kelancaran UI 120Hz pada perangkat fisik sebelum rilis beta publik. |

**Kesimpulan Kebutuhan Perangkat**:
- Pengembangan harian dapat berjalan 90% pada Android Emulator (Windows 11) dan unit test.
- Untuk rilis MVP, disiapkan minimal:
  - 1 unit perangkat Android fisik dengan Android 13/14 (misal: Google Pixel atau Samsung Galaxy).
  - 1 unit iPhone fisik dengan iOS 17+ untuk *smoke testing* manual sebelum peluncuran TestFlight.

### 4.4 Akses Provider & Kredensial Eksternal
Untuk mendukung operasional staging dan rilis, dibutuhkan akun dan kredensial berikut:
1. **Supabase Cloud Project**:
   - URL Proyek (`SUPABASE_URL`) dan Anon Public Key (`SUPABASE_ANON_KEY`).
   - Bucket privat `item-photos` dengan konfigurasi security policy RLS.
   - Konfigurasi redirect URL untuk deep link autentikasi (`rootin://login-callback`).
2. **Apple Developer Program**:
   - Akun berbayar (Annual Individual/Organization Enrollment).
   - App ID terdaftar: `com.rootin.mobile`.
   - Apple Distribution Certificate dan Provisioning Profile.
   - App Store Connect API Key untuk otomasi build Fastlane / GitHub Actions.
3. **Google Play Console**:
   - Akun Pengembang Google Play terverifikasi.
   - Keystore penandatanganan Android rilis (`upload-keystore.jks`).
   - Google Service Account Key JSON untuk deployment otomatis ke Internal Testing Track.

---

## 5. Keterbatasan Hardware/Emulator dan Strategi Mitigasi

Berikut adalah rangkuman batasan yang diidentifikasi selama spike teknis beserta mitigasi arsitektur yang diterapkan:

```
┌──────────────────────────────────────┬─────────────────────────────────────────────────────────┐
│ Keterbatasan Platform / Alat         │ Solusi & Strategi Mitigasi Arsitektur                   │
├──────────────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Windows 11 tidak bisa build iOS      │ Gunakan GitHub Actions macOS-14 runner untuk kompilasi   │
│                                      │ dan verifikasi build iOS secara berkala pada setiap PR. │
├──────────────────────────────────────┼─────────────────────────────────────────────────────────┤
│ iOS Simulator tidak ada kamera       │ Abstraksikan pemilih gambar via `ImagePickerService`    │
│                                      │ dengan fallback otomatis ke galeri foto pada simulator. │
├──────────────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Agresivitas Battery Saver Android    │ Implementasikan fallback exact-to-inexact alarm,        │
│ (Doze Mode & OEM Process Killing)    │ tampilkan panduan pengaturan baterai di menu Settings,  │
│                                      │ serta sinkronisasi ulang pengingat saat aplikasi dibuka.│
├──────────────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Izin notifikasi ditolak pengguna     │ Deteksi status izin via service notifikasi; tampilkan   │
│                                      │ banner peringatan di halaman utama dan sediakan tombol  │
│                                      │ pintas langsung ke System App Settings.                 │
├──────────────────────────────────────┼─────────────────────────────────────────────────────────┤
│ Masa berlaku Signed URL (60 Menit)   │ Jangan bergantung pada remote URL saat render UI.       │
│                                      │ Simpan berkas foto asli di direktori lokal dokumen dan  │
│                                      │ gunakan file lokal sebagai sumber tampilan utama.       │
└──────────────────────────────────────┴─────────────────────────────────────────────────────────┘
```

---

## 6. Penegasan Invariant Rootin

1. **Zero Dependency & Zero Coupling ke Rootin Web**:
   - Rootin Mobile tidak menggunakan kode bersama (*no shared package/repo*), tidak menggunakan endpoint internal Rootin Web, dan tidak terikat siklus rilis Rootin Web.
   - Seluruh kontrak data didefinisikan murni untuk kebutuhan mobile di repositori ini.
2. **Isolasi Data Total & Multi-Tenant**:
   - Setiap tabel lokal SQLite Drift dan tabel Supabase PostgreSQL wajib memiliki kolom `user_id uuid NOT NULL`.
   - Tidak ada data lintas pengguna yang dapat dibaca atau ditulis, baik secara sengaja maupun tidak sengaja, berkat RLS `(auth.uid() = user_id)` di backend dan penyaringan klausul `WHERE user_id = :activeUserId` di DAO Drift.
3. **Penyimpanan Lokal Sebagai Single Source of Truth**:
   - Aplikasi tidak pernah menunggu respons jaringan cloud untuk memperbarui tampilan pengguna. UI membaca stream database lokal Drift, dan operasi mutasi ditulis ke database lokal bersama entri `sync_outbox`.
4. **Kepatuhan Stack**:
   - Rekomendasi teknologi Flutter, Riverpod, Drift, go_router, dan Supabase yang telah ditetapkan pada ADR ini adalah keputusan final dan mengikat untuk tiket-tiket berikutnya.

---

## 7. Konsekuensi Keputusan

### 7.1 Dampak Positif
- **Kepastian Teknis**: Seluruh risiko integrasi paket inti dan perilaku OS (terutama notifikasi cold-start dan SQLite persistence) telah divalidasi sebelum penulisan kode arsitektur.
- **Performa Tinggi**: Kombinasi Drift SQLite WAL mode dan Riverpod menjamin rendering UI 60/120 fps tanpa jank akibat operasi I/O jaringan.
- **Biaya Infrastruktur Minimal**: Penggunaan notifikasi lokal presisi meniadakan kebutuhan server backend aktif untuk penjadwalan push notification harian.
- **Kesiapan Otomasi CI/CD**: Batasan platform Windows 11 telah dimitigasi secara terstruktur melalui alokasi runner GitHub Actions macOS.

### 7.2 Risiko & Dampak Negatif
- **Kompleksitas Sinkronisasi Outbox**: Penggunaan pola durable outbox menuntut penanganan konflik data dan serialisasi payload yang cermat di Data Layer.
- **Dependensi Biaya Runner macOS**: Build iOS pada GitHub Actions menggunakan runner macOS yang memiliki konsumsi menit kuota lebih tinggi dibanding Linux.
- **Variasi Vendor Android**: Produsen Android pihak ketiga (OEM) memiliki kebijakan manajemen memori latar belakang yang beragam, sehingga edukasi pengguna terkait izin baterai tetap diperlukan.

### 7.3 Mitigasi Risiko
- Logika sinkronisasi outbox akan diuji secara mendalam dengan *Pure Dart Unit Tests* mencakup kasus retry, exponential backoff, dan duplikasi idempotency key pada tiket M018.
- Optimasi cache pipeline CI GitHub Actions (`actions/cache` untuk Flutter SDK, pub cache, dan CocoaPods) guna meminimalkan durasi eksekusi runner macOS.

---

## 8. Rencana Aksi Menuju Milestone Berikutnya

Hasil spike teknis ini menjadi acuan langsung untuk tahap implementasi berikutnya:
1. **ROOTIN-M003 (Desain Arsitektur Sistem Terinci)**:
   - Merancang kontrak interface Domain Layer (Repository interfaces, Use Cases, Value Objects, Recurrence Calculator).
   - Merancang skema tabel lengkap Drift SQLite (Items, Reminders, MaintenanceLogs, SyncOutbox).
   - Merancang struktur Notifier Riverpod dan pemetaan error (`Failure` & `Result`).
2. **ROOTIN-M007 (Inisialisasi Scaffold Proyek & CI Tooling)**:
   - Membuat scaffold direktori proyek Flutter sesuai struktur Clean Architecture (`lib/app`, `lib/core`, `lib/features`, `lib/services`).
   - Mendaftarkan dependensi paket yang telah divalidasi ke dalam `pubspec.yaml`.
   - Mengonfigurasi linting `very_good_analysis` dan pipeline GitHub Actions (`.github/workflows/ci.yml`).

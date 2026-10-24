# Rootin Mobile â€” Project Overview & Architecture Guide

## 1. Identitas & Visi Proyek

### 1.1 Ringkasan Proyek
**Rootin Mobile** adalah aplikasi pendamping perawatan aset pribadi, barang rumah tangga, dan kendaraan yang dirancang khusus untuk platform mobile (**iOS** dan **Android**) dari nol (*greenfield*). Aplikasi ini memberikan sistem pengingat (reminder) yang adaptif, fleksibel, dan beroperasi dengan prinsip **offline-first**, memastikan pengguna dapat memantau dan mencatat pemeliharaan barang kapan pun dan di mana pun tanpa ketergantungan koneksi internet.

### 1.2 Batas Isolasi dari Rootin Web
Rootin Mobile **bukan** merupakan porting, wrapper WebView, PWA, ataupun bagian dari monorepo Rootin Web. Proyek ini memegang teguh prinsip isolasi total:
- **Terpisah Secara Kode**: Tidak ada impor pustaka, kode bersama (*shared code*), atau dependensi build ke Rootin Web.
- **Terpisah Secara Backend & Database**: Backend Supabase yang digunakan adalah proyek/instance terisolasi dengan skema database, migrasi, dan konfigurasi Row-Level Security (RLS) yang dirancang murni untuk ekosistem mobile offline-first.
- **Terpisah Secara Akun & Deployment**: Siklus rilis, manajemen sesi autentikasi, dan environment konfigurasi tidak memiliki dependensi pada status deployment maupun regresi dari Rootin Web.

---

## 2. Tech Stack Acuan

Tech stack dipilih secara selektif dengan memprioritaskan performa tinggi, stabilitas, ekosistem Dart/Flutter yang matang, serta keandalan pemrosesan data lokal:

| Komponen | Teknologi | Alasan Pemilihan |
| :--- | :--- | :--- |
| **Framework Mobile** | Flutter SDK (3.x+) / Dart (3.x+) | Kemampuan kompilasi native ke ARM/x86 untuk iOS & Android dengan konsistensi UI 60/120 fps. |
| **State Management & DI** | Riverpod (`flutter_riverpod`, `riverpod_annotation`) | Manajemen state deklaratif, kompilasi aman (*compile-time safe*), mudah diuji tanpa mocking rumit. |
| **Navigasi & Routing** | `go_router` | Routing deklaratif berbasis URI, mendukung deep-link, redirects guard (auth), dan nested navigation. |
| **Penyimpanan Lokal (Offline)** | `drift` (`sqlite3_flutter_libs`) | ORM SQLite reaktif dengan type-safety penuh di Dart, migrasi skema terstruktur, dan performa tinggi. |
| **Backend & Cloud Services** | Supabase (`supabase_flutter`) | Penyedia Auth, PostgreSQL dengan Row-Level Security (RLS) ketat, dan Private Storage Buckets. |
| **Notifikasi Perangkat** | `flutter_local_notifications` | Notifikasi lokal terjadwal di perangkat tanpa biaya server, sadar zona waktu via pustaka `timezone`. |
| **Penyimpanan Kunci Kredensial** | `flutter_secure_storage` | Penyimpanan aman token autentikasi (iOS Keychain & Android EncryptedSharedPreferences). |
| **Format & Serialisasi Data** | `freezed`, `json_serializable` | Pembuatan model immutable, pattern matching, dan serialisasi JSON yang bebas kesalahan ketik. |
| **Utilitas Waktu & Lokalisasi** | `intl`, `timezone` | Dukungan multi-bahasa (ID/EN) dan manipulasi tanggal yang akurat lintas zona waktu. |

---

## 3. Arsitektur Target

Aplikasi Rootin Mobile mengadopsi **Clean Architecture** berlapis dengan prinsip pemisahan tanggung jawab (*Separation of Concerns*):

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                     Presentation Layer                      â”‚
â”‚      (UI Widgets, Screens, Riverpod Notifiers/Providers)     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                               â”‚ relies on
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                        Domain Layer                         â”‚
â”‚   (Entities, Value Objects, Use Cases, Engine Kalkulasi)    â”‚
â”‚            *Pure Dart - No Flutter/DB Dependencies*         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–²â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                               â”‚ implements / used by
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                         Data Layer                          â”‚
â”‚  (Repositories, Drift Local DAOs, Supabase Remote DTOs,     â”‚
â”‚                   Durable Outbox Queue)                     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                               â”‚ relies on
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                         Core Layer                          â”‚
â”‚     (Constants, Network Info, Utilities, Error Handling)     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 3.1 Rincian Tanggung Jawab Lapisan

1. **Domain Layer (Pure Dart)**
   - Berisi entitas bisnis inti (`Item`, `Reminder`, `MaintenanceLog`, `VehicleProfile`).
   - Berisi kalkulator aturan bisnis (algoritma kabisat, clamping akhir bulan, threshold keausan pemakaian, perhitungan baseline servis odometer).
   - Bersih dari dependensi framework Flutter, Drift, maupun Supabase. Semua aturan dapat diuji dengan *pure Dart unit tests*.
2. **Data Layer**
   - Mengimplementasikan antarmuka repositori yang didefinisikan di lapisan domain.
   - Mengelola dua sumber data: *Local Data Source* (Drift SQLite) dan *Remote Data Source* (Supabase REST/GraphQL).
   - Mengoperasikan mesin antrean **Durable Outbox** untuk memastikan mutasi data yang terjadi secara offline tersimpan aman dan disinkronkan saat koneksi pulih.
3. **Presentation Layer**
   - Dibangun menggunakan widget Flutter yang mematuhi sistem desain token (warna, tipografi, elevasi).
   - Memanfaatkan Riverpod untuk mendengarkan perubahan data lokal secara reaktif (*reactive streams* dari Drift).
   - Menghindari logika bisnis langsung pada widget; delegasi interaksi dilakukan melalui AsyncNotifier/Notifier.
4. **Core Layer**
   - Komponen pendukung umum: penanganan error (`Failure`, `AppException`), result wrappers, konfigurasi environment, helper tanggal/waktu, dan tema.

### 3.2 Struktur Folder Target (`lib/`)

```
lib/
â”œâ”€â”€ app/
â”‚   â”œâ”€â”€ app.dart                   # Root MaterialApp widget & config
â”‚   â”œâ”€â”€ router.dart                # go_router configuration & guards
â”‚   â””â”€â”€ theme/                     # Design tokens, color schemes, typography
â”œâ”€â”€ core/
â”‚   â”œâ”€â”€ constants/                 # Storage keys, assets paths, global constants
â”‚   â”œâ”€â”€ errors/                    # Failure classes & exception mapping
â”‚   â”œâ”€â”€ network/                   # Connectivity checker & network info
â”‚   â”œâ”€â”€ utils/                     # Date helpers, formatters, clamp utilities
â”‚   â””â”€â”€ l10n/                      # ARB files & generated localization (ID/EN)
â”œâ”€â”€ features/
â”‚   â”œâ”€â”€ auth/                      # Login, register, session management
â”‚   â”‚   â”œâ”€â”€ data/
â”‚   â”‚   â”œâ”€â”€ domain/
â”‚   â”‚   â””â”€â”€ presentation/
â”‚   â”œâ”€â”€ items/                     # Profil barang, foto aset, metadata
â”‚   â”‚   â”œâ”€â”€ data/
â”‚   â”‚   â”œâ”€â”€ domain/
â”‚   â”‚   â””â”€â”€ presentation/
â”‚   â”œâ”€â”€ reminders/                 # 3 Engine Reminder (Time, Usage, Mileage)
â”‚   â”‚   â”œâ”€â”€ data/
â”‚   â”‚   â”œâ”€â”€ domain/                # Recurrence engines & algorithms
â”‚   â”‚   â””â”€â”€ presentation/
â”‚   â”œâ”€â”€ maintenance_logs/          # Riwayat perawatan immutable & audit trail
â”‚   â”‚   â”œâ”€â”€ data/
â”‚   â”‚   â”œâ”€â”€ domain/
â”‚   â”‚   â””â”€â”€ presentation/
â”‚   â”œâ”€â”€ calendar/                  # Kalender jatuh tempo & timeline
â”‚   â”‚   â”œâ”€â”€ data/
â”‚   â”‚   â”œâ”€â”€ domain/
â”‚   â”‚   â””â”€â”€ presentation/
â”‚   â”œâ”€â”€ sync/                      # Durable outbox queue & conflict handling
â”‚   â”‚   â”œâ”€â”€ data/
â”‚   â”‚   â”œâ”€â”€ domain/
â”‚   â”‚   â””â”€â”€ presentation/
â”‚   â””â”€â”€ settings/                  # Profil, bahasa, zona waktu, lisensi
â”‚       â”œâ”€â”€ data/
â”‚       â”œâ”€â”€ domain/
â”‚       â””â”€â”€ presentation/
â”œâ”€â”€ services/
â”‚   â”œâ”€â”€ local_storage/             # Drift database instance & DAOs
â”‚   â”œâ”€â”€ notification/              # flutter_local_notifications wrapper
â”‚   â””â”€â”€ supabase/                  # Supabase client initializer & interceptors
â””â”€â”€ main.dart                      # App entry point (bootstrap, zone, runner)
```

### 3.3 Dokumen Desain & Kontrak Teknis
Spesifikasi terinci mengenai arsitektur, antarmuka pengguna, sistem desain, basis data, dan kontrak antarmuka didokumentasikan pada:
- **[ADR 0002: Arsitektur Flutter Modular, Backend Mobile & Kontrak Offline-First](decisions/0002-architecture-offline-first.md)**
- **[Arsitektur Informasi & Alur Pengguna (Information Architecture & User Flows)](03-mobile-ux.md)**
- **[Sistem Desain & Token Desain Mobile (Mobile Design System & Tokens)](04-mobile-design-system.md)**
- **[Desain Basis Data: Drift SQLite & Supabase PostgreSQL](05-database-design.md)**
- **[Desain API: Kontrak REST, RPC Supabase & Koordinasi Notifikasi](06-api-design.md)**

---

## 4. Invariant Arsitektur & Prinsip Desain

Untuk menjamin kualitas dan ketahanan aplikasi kelas produksi, arsitektur Rootin Mobile mematuhi invariant berikut:

### 4.1 Offline-First dengan Durable Outbox
- **Lokal Sebagai Sumber Utama (*Single Source of Truth*)**: Semua operasi penulisan (Create, Update, Delete) selalu ditulis ke database Drift SQLite lokal terlebih dahulu. UI segera merefleksikan perubahan secara optimistik tanpa menunggu latensi jaringan.
- **Tabel Outbox Terisolasi**: Setiap mutasi lokal memicu pembuatan entri pada tabel `sync_outbox` lokal yang memuat `operation_type`, `entity_type`, `record_id`, `payload_json`, `idempotency_key` (UUIDv4), dan `created_at`.
- **Worker Sinkronisasi Asinkron**: Komponen sync worker berjalan di latar belakang untuk mengirimkan mutasi dari antrean outbox ke Supabase.
- **Ketahanan Jaringan**: Jika koneksi gagal, sync worker melakukan *exponential backoff* dengan *jitter* tanpa memblokir interaksi pengguna di aplikasi.

### 4.2 Isolasi Multi-Tenant Mutlak (`user_id`)
- Setiap tabel di Drift lokal dan Supabase PostgreSQL wajib memiliki kolom `user_id uuid NOT NULL`.
- Di level database Supabase, **Row-Level Security (RLS)** diaktifkan pada semua tabel tanpa kecuali:
  ```sql
  ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Users can only access own items"
    ON public.items
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
  ```
- Di level penyimpanan lokal, database Drift memfilter query berdasarkan `user_id` aktif untuk menjamin keamanan bila perangkat digunakan bergantian.

### 4.3 Zero Leakage & Zero Regression Terhadap Rootin Web
- Arsitektur mobile tidak memiliki jembatan API privat atau skema bersama dengan Rootin Web.
- Setiap model data di mobile dirancang spesifik untuk kebutuhan perangkat bergerak (mendukung input offline, sinkronisasi berbasis timestamp, dan penanganan lokal).

### 4.4 Indeks Keputusan Arsitektur (Architectural Decision Records / ADR)
Seluruh keputusan arsitektur strategis, hasil investigasi spike teknis, dan evaluasi kelayakan platform didokumentasikan secara formal dalam direktori [`docs/decisions/`](decisions/):

- **[ADR 0001: Hasil Spike Teknis & Validasi Platform Mobile (Android & iOS)](decisions/0001-spike-technical-validation.md)** — Status: **Accepted**. Validasi kompatibilitas Flutter 3.29.2 & Dart 3.7.2, SQLite Drift & Durable Outbox, ketahanan notifikasi lokal multi-state (foreground/background/terminated/reboot), Supabase Auth/Storage, serta strategi runner CI/CD lintas platform.
- **[ADR 0002: Arsitektur Flutter Modular, Backend Mobile & Kontrak Offline-First](decisions/0002-architecture-offline-first.md)** — Status: **Accepted**. Penetapan arsitektur Flutter modular berbasis lapisan ringkas (Presentation, Domain, Data, Core), pola Single Source of Truth (SSOT) lokal Drift SQLite, Durable Outbox Queue dengan exponential backoff & jitter, resolusi konflik Revision & Last-Write-Wins (LWW) dengan tombstone soft-delete, kontrak pemisahan Calendar Date vs Instant UTC, serta isolasi total dari Rootin Web.

---

## 5. Peta 27 Tiket Implementasi (M000 - M027)

Pengembangan Rootin Mobile dibagi ke dalam 28 tiket terstruktur (M000 sampai M027) yang mencakup fase arsitektur, MVP Beta, hingga persiapan rilis produksi:

> **Catatan Validasi Teknis (ROOTIN-M002)**: Hasil validasi spike teknis pada tiket **ROOTIN-M002** yang telah disetujui dalam [ADR 0001](decisions/0001-spike-technical-validation.md) berfungsi sebagai landasan kelayakan platform yang kokoh menuju perancangan arsitektur sistem terinci pada **ROOTIN-M003** (Desain Arsitektur) dan implementasi kerangka kode pada **ROOTIN-M007** (Scaffold).

| ID Tiket | Judul Tiket | Fase / Kategori | Dependensi | Ringkasan Lingkup Kerja |
| :--- | :--- | :--- | :--- | :--- |
| **M000** | Discovery & Architecture RFC | Architecture | - | Perumusan RFC arsitektur mobile, evaluasi stack, dan kesepakatan prinsip offline-first. |
| **M001** | Mobile PRD & Project Overview | Foundation | M000 | Penyusunan PRD komprehensif dan panduan arsitektur. |
| **M002** | Spike Teknis & Validasi Platform | Tooling & Validation | M001 | Validasi Flutter 3.29.2/Dart 3.7.2, SQLite Drift, notifikasi lokal multi-state, Supabase Auth/Storage, dan strategi CI/CD (ADR 0001). |
| **M003** | Desain Arsitektur & Kontrak Offline-First | Architecture | M002 | Perancangan arsitektur Flutter modular, SSOT lokal, Durable Outbox, skema Drift & Supabase, kontrak API/RPC, dan ADR 0002 (Tiket Ini). |
| **M004** | Drift SQLite Database Setup | Persistence | M002 | Setup Drift ORM, skema tabel lokal, DAO dasar, dan skrip migrasi lokal. |
| **M005** | Supabase Auth Integration | Authentication | M004 | Integrasi Auth (Email/Password), manajemen token aman, dan status sesi. |
| **M006** | User Profile & Dynamic Timezone | Core Feature | M005 | Manajemen profil, deteksi zona waktu perangkat, dan dwibahasa (ID/EN). |
| **M007** | Item Management Module | Core Feature | M004 | CRUD profil barang/aset, kategori, nomor seri/plat, dan metadata kustom. |
| **M008** | Private Storage & Photo Handling | Storage | M007 | Kompresi gambar lokal, unggah ke Supabase Private Storage, dan cache signed URL. |
| **M009** | Time-Based Reminder Engine | Core Reminder | M007 | Mesin pengingat waktu: interval, actual completion baseline, kabisat & clamping akhir bulan. |
| **M010** | Usage-Based Reminder Engine | Core Reminder | M007 | Mesin pengingat pemakaian: counter manual, ambang batas keausan, dan indikator progres. |
| **M011** | Mileage-Based Reminder Engine | Core Reminder | M007 | Mesin pengingat jarak: profil odometer kendaraan dan baseline servis mandiri. |
| **M012** | Local Notification Scheduling | Notification | M009, M010, M011 | Integrasi `flutter_local_notifications`, sinkronisasi alarm perangkat, dan timezone bridge. |
| **M013** | Snooze & Deferral Mechanism | Core Reminder | M012 | Logika penundaan notifikasi tanpa menggeser tanggal dasar recurrence berikutnya. |
| **M014** | Maintenance History & Audit Trail | Core Feature | M009, M010, M011 | Pencatatan riwayat perawatan permanen (immutable), catatan biaya, dan tanggal selesai. |
| **M015** | Due Date Calendar & Dashboard | Presentation | M009, M011, M014 | Kalender visual jatuh tempo, status overdue, filter aset, dan ringkasan dasbor. |
| **M016** | Archival & Unarchive Lifecycle | Lifecycle | M007, M009 | Mekanisme arsip barang/reminder tidak aktif dan pengaktifan kembali tanpa data hilang. |
| **M017** | Soft & Permanent Delete Lifecycle | Lifecycle | M007, M014 | Siklus penghapusan barang bertingkat (soft delete, cascade cleanup, dan konfirmasi hapus). |
| **M018** | Durable Outbox Sync Queue | Sync Engine | M004, M005 | Implementasi antrean mutasi lokal, background sync worker, dan retry exponential backoff. |
| **M019** | Conflict Resolution & Sync Edge | Sync Engine | M018 | Penanganan konflik data lokal vs cloud (*last-write-wins* berbasis vector timestamp). |
| **M020** | Remote Push Infrastructure | Post-MVP | M012 | Integrasi APNs & FCM untuk notifikasi cloud lintas perangkat (*Post-MVP*). |
| **M021** | Privacy-Preserving Telemetry | Telemetry | M002 | Setup pelaporan crash tanpa mengoleksi data pribadi aset pengguna. |
| **M022** | Subscription Infrastructure | Post-MVP | M005 | Integrasi SDK RevenueCat untuk verifikasi status langganan (*Post-MVP*). |
| **M023** | Paywall & Quota Gating (Free/Pro) | Post-MVP | M022 | Implementasi paywall UI dan pembatasan kuota hipotesis (*Post-MVP*). |
| **M024** | Data Export & Privacy GDPR | Post-MVP | M007, M014 | Ekspor seluruh data dalam format JSON/CSV dan hak penghapusan akun mandiri (*Post-MVP*). |
| **M025** | Accessibility (a11y) & UX Polish | Quality | M003, M015 | Peningkatan kontras, screen reader semantics, dan dynamic type scaling. |
| **M026** | E2E Testing & Performance Tuning | Quality | M018, M019 | Pengujian skenario offline-to-online, memori leak profiling, dan benchmark query Drift. |
| **M027** | Store Metadata & Release Prep | Release | M025, M026 | Penyiapan aset App Store / Play Store, privacy manifest, dan build rilis final. |

---

## 6. Standar Kualitas & Verifikasi

1. **Static Analysis**: Seluruh kode Dart wajib lulus analisis ketat tanpa peringatan (*zero warnings*).
2. **Uji Otomatis**: Logika bisnis domain (kalkulasi tanggal, clamping, threshold pemakaian, baseline servis) memiliki cakupan unit test 100%.
3. **Integritas Migrasi**: Setiap perubahan skema Drift harus disertai skrip migrasi yang teruji untuk mencegah *data loss* pada pembaruan aplikasi.

# ADR 0002: Arsitektur Flutter Modular, Backend Mobile & Kontrak Offline-First

* **Status**: Accepted
* **Tanggal**: 2026-10-24
* **Pengusul**: Mobile Architecture & Engineering Team
* **Tiket Referensi**: ROOTIN-M003 (GitHub Issue [#2](https://github.com/andresanjaya/rootin/issues/2))
* **Target Kelanjutan**: ROOTIN-M004 (Drift SQLite Persistence), ROOTIN-M005 (Supabase Auth Integration), ROOTIN-M007 (Item Management & Scaffold)

---

## 1. Konteks & Latar Belakang

Rootin Mobile dirancang sebagai aplikasi *greenfield* untuk pemantauan dan pengelolaan perawatan aset pribadi, perlengkapan rumah tangga, dan kendaraan bermotor. Pengguna aplikasi ini kerap berada pada kondisi tanpa konektivitas internet (*zero connectivity*), seperti di ruang bawah tanah (*basement*), bengkel terpencil, area parkir tertutup, atau saat mode pesawat aktif.

Untuk memberikan pengalaman pengguna yang responsif tanpa jeda latensi jaringan (*zero latency*), aplikasi wajib beroperasi dengan prinsip **offline-first**:
1. Seluruh pembacaan dan penulisan data dilakukan langsung terhadap basis data lokal di perangkat.
2. Sinkronisasi data ke cloud backend (Supabase) berjalan di latar belakang secara asinkron tanpa memblokir interaksi antarmuka pengguna.
3. Notifikasi pengingat dijadwalkan secara lokal di perangkat tanpa memerlukan server push aktif.
4. Aplikasi berdiri mandiri tanpa ketergantungan pada kode sumber, basis data, cookie sesi, atau WebView dari aplikasi Rootin Web.

ADR ini menetapkan arsitektur perangkat lunak Flutter modular, batas tanggung jawab klien/server, pola *Single Source of Truth* (SSOT) lokal, mekanisme antrean *durable outbox*, penanganan konflik data, serta pemisahan tegas antara tipe data kalender (*Calendar Date*) dan titik waktu absolut (*Instant UTC*).

---

## 2. Keputusan Arsitektur

### 2.1 Arsitektur Flutter Modular Berbasis Layer Ringkas

Aplikasi mengadopsi variasi *Clean Architecture* modular yang disederhanakan untuk menghindari abstraksi berlebihan (*no over-engineering*, tanpa *interface* ber-implementasi tunggal yang tidak diperlukan):

```
┌─────────────────────────────────────────────────────────────────┐
│                       Presentation Layer                        │
│   • Flutter Widgets & Screen Components                         │
│   • Riverpod Notifiers / AsyncNotifiers                         │
│   • go_router Declarative Routing & Redirect Guards             │
└────────────────────────────────┬────────────────────────────────┘
                                 │ listens to reactive streams
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                          Domain Layer                           │
│   • Pure Dart Models / Entities (Freezed / Plain Dart)          │
│   • Pure Calculation Functions (Leap Year, Clamping, Mileage)   │
│   • Tanpa dependensi Flutter SDK, Drift, atau Supabase          │
└────────────────────────────────▲────────────────────────────────┘
                                 │ implements / invokes
┌────────────────────────────────┴────────────────────────────────┐
│                           Data Layer                            │
│   • Local Data Source: Drift ORM (SQLite WAL Mode)              │
│   • Remote Data Source: Supabase PostgREST & RPC Client         │
│   • Durable Outbox Queue Engine & Sync Worker                   │
│   • Repository Implementations                                  │
└────────────────────────────────┬────────────────────────────────┘
                                 │ utilizes
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                           Core Layer                            │
│   • Constants, App Configuration, Network Connectivity Info     │
│   • Standard Error & Failure Handling, Logging                  │
│   • Calendar Date & Instant Timezone Utilities                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Tanggung Jawab Tiap Lapisan:
1. **Presentation Layer**:
   - Menampilkan antarmuka pengguna secara deklaratif sesuai *design tokens*.
   - Memanfaatkan Riverpod (`AsyncNotifier`) untuk mengamati *Stream* data reaktif dari Drift.
   - Mengirim aksi pengguna ke *Notifier* tanpa memuat kalkulasi bisnis atau manipulasi query SQL langsung.
2. **Domain Layer (Pure Dart)**:
   - Berisi entitas data inti (`Item`, `Reminder`, `MaintenanceLog`) dan fungsi kalkulasi murni (*pure functions*): algoritma kabisat, *month-end clamping*, perhitungan sisa jarak tempuh, dan ambang batas keausan.
   - **Prinsip Ringkas**: Tidak membuat lapisan Use Case satu per satu jika operasi hanya meneruskan panggilan ke Repositori. *Repository* dapat langsung diakses oleh Riverpod Notifier bila tidak ada orkestrasi lintas domain.
3. **Data Layer**:
   - Menjadi pengelola persistensi data ganda: SQLite Drift lokal sebagai SSOT dan Supabase Remote Data Source untuk sinkronisasi.
   - Menjalankan transaksi atomik lokal yang mencakup pembaruan entitas bisnis dan pencatatan entri antrean `sync_outbox`.
   - Mengelola pemulihan sinkronisasi (*retry* dengan *exponential backoff* dan *jitter*).
4. **Core Layer**:
   - Menyediakan komponen transversal: utilitas parsing tanggal, tipe `Result<T>` / `Failure`, pemeriksaan status konektivitas, dan konfigurasi lingkungan (*environment config*).

---

### 2.2 Pola Single Source of Truth (SSOT) Lokal

Aplikasi menetapkan basis data lokal **Drift SQLite** sebagai satu-satunya sumber kebenaran (*Single Source of Truth*) bagi lapisan presentasi:

```
[ User Interaction ]
         │
         ▼
[ Riverpod Notifier ] ───(invoke mutation)───► [ Local Repository ]
                                                        │
                                                        ▼
                                              ┌───────────────────┐
                                              │ SQLite WAL Mode   │
                                              │ Atomic Tx:        │
                                              │ 1. Upsert Entity  │
                                              │ 2. Insert Outbox  │
                                              └─────────┬─────────┘
                                                        │
                                                        ▼
[ UI Screen Widget ] ◄──(Reactive Drift Stream)─────────┘
```

1. **Alur Baca (Read Path)**:
   - UI selalu membaca data melalui *reactive query stream* yang disediakan oleh DAO Drift (`select(...).watch()`).
   - UI tidak pernah memanggil API jarak jauh secara sinkron untuk merender layar utama, daftar aset, atau dasbor pengingat.
2. **Alur Tulis (Write Path)**:
   - Setiap mutasi (Create, Update, Delete) ditulis langsung ke database Drift dalam satu transaksi atomik bersama dengan pembuatan rekaman antrean pada tabel `sync_outbox`.
   - Perubahan data langsung terpropagasi ke UI secara optimistik (< 15 ms) tanpa menunggu konfirmasi dari jaringan cloud.

---

### 2.3 Durable Outbox Queue & Siklus Sinkronisasi

Semua mutasi yang dilakukan pengguna saat offline atau online dijamin tidak hilang (*zero data loss*) melalui pola **Durable Outbox**:

```
┌─────────────────┐       ┌─────────────────┐       ┌───────────────────┐
│  Drift SQLite   │       │   Sync Worker   │       │ Supabase Backend  │
│  `sync_outbox`  │       │  (Background)   │       │   (PostgreSQL)    │
└────────┬────────┘       └────────┬────────┘       └─────────┬─────────┘
         │                         │                          │
         │ (1) Polling FIFO /      │                          │
         │     Stream trigger      │                          │
         │◄────────────────────────┤                          │
         │ (2) Batch Mutations     │                          │
         ├────────────────────────►│                          │
         │                         │ (3) RPC:                 │
         │                         │ sync_push_mutations()    │
         │                         ├─────────────────────────►│
         │                         │                          │ (4) Atomic Tx &
         │                         │                          │     RLS Validation
         │                         │ (5) Success ACK /        │
         │                         │     Conflict Payload     │
         │                         │◄─────────────────────────┤
         │ (6) Delete ACKed Outbox │                          │
         │     / Update Metadata   │                          │
         │◄────────────────────────┤                          │
```

#### Karakteristik Outbox:
- **Atomisitas Lokal**: Operasi mutasi entitas bisnis dan penyisipan entri outbox dilakukan dalam blok `transaction(() async { ... })` Drift SQLite.
- **Idempotensi**: Setiap entri outbox memiliki `operation_id` unik (UUIDv4) yang dibuat di klien. Backend mencatat `operation_id` untuk mencegah eksekusi ganda jika terjadi *retry* jaringan.
- **Urutan Eksekusi**: Mutasi diproses secara FIFO (*First-In, First-Out*) per pengguna.
- **Strategi Retry**: Jika koneksi gagal atau terjadi galat jaringan sementara (*transient error*), *sync worker* menerapkan *exponential backoff* dengan *full jitter*:
  $$t_{\text{wait}} = \min(t_{\text{max}}, t_{\text{base}} \times 2^{\text{retry\_count}}) \times \text{random}(0.8, 1.2)$$
  dengan $t_{\text{base}} = 1\text{ detik}$ dan $t_{\text{max}} = 60\text{ detik}$.

---

### 2.4 Resolusi Konflik: Revision Counter, Last-Write-Wins (LWW) & Tombstone

Karena klien dapat beroperasi secara *offline* dalam durasi panjang, konflik data dapat terjadi jika entitas diperbarui dari perangkat lain.

1. **Skema Penomoran Versi & LWW**:
   - Setiap rekaman memiliki kolom integer `version` (dimulai dari `1`) dan timestamp ISO 8601 UTC `updated_at`.
   - Ketika mutasi dikirim ke backend, Supabase RPC membandingkan `version` dan `updated_at`.
   - Jika versi klien lebih tinggi atau sama dengan timestamp lebih baru, perubahan diterima (*Last-Write-Wins*).
   - Jika terdapat konflik konkuren pada detik yang sama, pemenang ditentukan secara deterministik melalui *tie-breaker*: perbandingan leksikografis UUID `updated_by` / `client_id`.
2. **Soft Delete & Tombstone**:
   - Operasi penghapusan data **tidak langsung mengeksekusi `DELETE` SQL fisik**, melainkan menandai kolom `deleted_at = NOW()` dan menaikkan `version`.
   - Rekaman yang memiliki `deleted_at IS NOT NULL` diperlakukan sebagai **Tombstone**.
   - Tombstone disinkronkan ke seluruh klien agar perangkat lain mengetahui bahwa rekaman tersebut telah dihapus.
   - Kueri baca UI lokal Drift secara otomatis memfilter rekaman aktif menggunakan predikat `WHERE deleted_at IS NULL`.
   - Pembersihan fisik (*hard delete purging*) dapat dilakukan secara berkala melalui scheduled maintenance setelah periode retensi 30 hari.

---

### 2.5 Kontrak Tanggal: Calendar Date vs Instant UTC

Untuk mencegah kekacauan jadwal akibat perbedaan zona waktu (*timezone shift*) atau *Daylight Saving Time* (DST), sistem membedakan secara tegas dua representasi waktu:

```
┌────────────────────────────────────────┬────────────────────────────────────────┐
│      Calendar Date (Tanggal Murni)     │        Instant UTC (Waktu Absolut)     │
├────────────────────────────────────────┼────────────────────────────────────────┤
│ Format: `YYYY-MM-DD` (Contoh: "2026-11-05") │ Format: ISO 8601 UTC (Contoh:          │
│                                        │ "2026-11-05T08:30:00.000Z")            │
│ Sifat: Netral zona waktu (Zone-Agnostic)│ Sifat: Titik waktu tunggal garis dunia │
│ Penggunaan:                            │ Penggunaan:                            │
│ • `purchase_date` (Tanggal pembelian)  │ • `created_at`, `updated_at`           │
│ • `target_date` (Jatuh tempo kalender) │ • `completed_at` (Log riwayat selesai) │
│ • `completion_date` (Hari servis fisik)│ • `snooze_until` (Alarm tunda presisi) │
│                                        │ • `last_synced_at` (Kursor sinkronisasi)│
└────────────────────────────────────────┴────────────────────────────────────────┘
```

#### Aturan Eksekusi:
1. **Jatuh Tempo Pengingat Kalender**:
   - Tanggal jatuh tempo disimpan sebagai `target_date` bertipe `TEXT` (`YYYY-MM-DD`).
   - Jam pengingat disimpan sebagai `target_time` bertipe `TEXT` (`HH:mm:ss`).
   - Ketika notifikasi lokal dijadwalkan, perangkat menggabungkan `target_date` dan `target_time` menggunakan zona waktu lokal perangkat (`tz.local`), sehingga jam 09:00 pagi tetap berbunyi jam 09:00 pagi di mana pun pengguna berada.
2. **Audit Trail & Sinkronisasi**:
   - Semua stempel audit (`created_at`, `updated_at`, `completed_at`, `outbox.created_at`) wajib menggunakan format UTC `ISO 8601` dengan presisi milidetik dan akhiran `Z`.

---

### 2.6 Manajemen Identitas (Identity & Primary Keys)

1. **Kunci Utama Dibuat di Klien (Client-Generated UUIDv4)**:
   - Seluruh entitas (`items`, `reminders`, `reminder_logs`) menggunakan `id` berupa UUIDv4 acak yang dihasilkan langsung di perangkat Flutter sebelum disimpan ke Drift.
   - **Alasan**: Menghilangkan ketergantungan pada *auto-increment integer* atau respons server saat pembuatan data secara *offline*. Hubungan relasional (misal: *foreign key* `item_id` pada `reminders`) dapat langsung dibangun seketika tanpa koneksi internet.
2. **Kunci Idempotensi Mutasi**:
   - Setiap operasi di tabel `sync_outbox` memiliki `operation_id` (UUIDv4) mandiri yang terpisah dari `record_id` entitas.
   - Server Supabase menyimpan daftar `operation_id` yang telah diproses untuk memastikan mutasi yang dikirim ulang akibat *timeout* jaringan tidak diproses dua kali.

---

### 2.7 Isolasi Total dari Rootin Web

Rootin Mobile beroperasi secara independen tanpa keterkaitan teknis dengan Rootin Web:
1. **Nol Pembagian Basis Data (*Zero Shared Database*)**:
   - Backend Supabase untuk Mobile menggunakan instance/schema terpisah yang didesain khusus untuk struktur offline-first (kolom `version`, `deleted_at`, tabel `sync_outbox` / RPC sync).
2. **Nol Autentikasi Web / Cookie**:
   - Mobile menggunakan token JWT native (Access Token & Refresh Token) via alur PKCE Supabase yang disimpan terenkripsi di `flutter_secure_storage`. Tidak ada cookie sesi berbasis browser.
3. **Nol WebView / Kode Bersama**:
   - Seluruh antarmuka dikompilasi secara native dalam Flutter. Tidak ada pemanggilan URL internal web atau integrasi WebView ke layanan web eksternal.

---

## 3. Batas Tanggung Jawab Klien vs Server

| Tanggung Jawab | Klien (Flutter Mobile) | Server (Supabase PostgreSQL) |
| :--- | :--- | :--- |
| **Kalkulasi Bisnis & Recurrence** | **Utama**: Eksekusi algoritma kabisat, clamping akhir bulan, evaluasi ambang pemakaian, dan sisa jarak odometer. | **Nihil**: Server hanya menyimpan hasil kalkulasi sebagai *state* persisten; tidak ada *cron worker* server untuk menghitung ulang tanggal. |
| **Penjadwalan Notifikasi** | **Utama**: Menjadwalkan alarm lokal via `flutter_local_notifications` menggunakan zona waktu perangkat. | **Sekunder (Post-MVP)**: Mengirim sinyal push remote (FCM/APNs) untuk sinkronisasi antar perangkat. |
| **Otorisasi & Keamanan Data** | Menyaring kueri lokal berdasarkan `user_id` sesi aktif. | **Penegak Mutlak**: Menegakkan Row-Level Security (RLS) `auth.uid() = user_id` pada seluruh tabel dan *storage bucket*. |
| **Penyimpanan Berkas Foto** | Mengompresi gambar lokal (< 1MB, 1080p), menyimpan berkas asli di *local sandbox*, dan menampilkan file lokal secara instan. | Menyimpan berkas di Private Bucket (`item-photos`) dan menerbitkan *signed URL* sementara (durasi 60 menit). |
| **Resolusi Konflik** | Mengemas mutasi dengan `version` lokal dan mengonsumsi rekaman hasil resolusi dari RPC server. | Membandingkan versi melalui RPC atomik `sync_push_mutations` dan menetapkan status LWW. |

---

## 4. Konsekuensi Keputusan

### 4.1 Dampak Positif
- **Kemandirian Penuh**: Aplikasi dapat berjalan tanpa batas waktu saat offline; semua fitur pencatatan dan kalkulasi pengingat tetap bekerja 100%.
- **Interaksi Instan**: Tidak ada indikator pemuatan (*loading spinner*) yang memblokir layar saat membuat atau mengubah data aset.
- **Efisiensi Infrastruktur**: Pengingat rutin ditangani oleh chipset alarm lokal perangkat, menekan biaya server push ke titik nol (*zero routine notification cost*).
- **Keamanan Kuat**: Kebijakan RLS tingkat baris menjamin isolasi data pengguna secara matematis pada tingkat mesin PostgreSQL.

### 4.2 Trade-offs & Risiko
- **Kompleksitas Sinkronisasi**: Penggunaan *durable outbox* menuntut pengujian ketat terhadap skenario kegagalan jaringan, konkurensi antrean, dan deserialisasi payload JSON.
- **Penggunaan Ruang Penyimpanan Klien**: Basis data SQLite lokal dan cache gambar memerlukan ruang penyimpanan di perangkat pengguna (dimitigasi dengan kompresi gambar lokal dan retensi cache).

### 4.3 Strategi Mitigasi
- Seluruh logika kalkulasi domain, generator outbox, dan resolusi konflik diuji melalui *Pure Dart Unit Tests* dengan cakupan kasus tepi (*edge cases*) yang tinggi.
- Batas retensi antrean outbox yang telah terkirim dibersihkan seketika setelah menerima konfirmasi (ACK) dari RPC server.

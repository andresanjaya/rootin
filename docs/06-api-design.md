# Desain API: Kontrak REST, RPC Supabase & Koordinasi Notifikasi

* **Status**: Accepted
* **Tanggal**: 2026-10-24
* **Tiket Referensi**: ROOTIN-M003 (GitHub Issue [#2](https://github.com/andresanjaya/rootin/issues/2))
* **Target Implementasi**: ROOTIN-M005 (Supabase Client), ROOTIN-M012 (Notification Coordinator), ROOTIN-M018 (Durable Outbox Sync)

---

## 1. Prinsip & Konvensi API

Backend Rootin Mobile dibangun di atas infrastruktur **Supabase (PostgreSQL + PostgREST + GoTrue + Storage)** yang terisolasi total dari ekosistem Rootin Web. API ini dirancang untuk melayani arsitektur *offline-first*, di mana interaksi jaringan berfokus pada sinkronisasi batch atomik berkecepatan tinggi, pertukaran berkas media, dan manajemen sesi.

### 1.1 Protokol & Transport
- **Protokol**: HTTPS / TLS 1.3 murni.
- **Base URL Endpoint**:
  - Autentikasi: `https://<project-ref>.supabase.co/auth/v1`
  - PostgREST & RPC: `https://<project-ref>.supabase.co/rest/v1`
  - Storage: `https://<project-ref>.supabase.co/storage/v1`
- **Format Payload**: Serialisasi JSON (`application/json; charset=utf-8`).
- **Konvensi Penamaan**: `snake_case` pada atribut JSON di wire/database; dipetakan ke `camelCase` pada model Dart di klien.

### 1.2 Headers Wajib

Setiap permintaan HTTP dari aplikasi mobile wajib menyertakan header standar berikut:

| Nama Header | Nilai Contoh | Keterangan |
| :--- | :--- | :--- |
| `apikey` | `<SUPABASE_ANON_KEY>` | Anon public API key proyek Supabase Mobile. |
| `Authorization` | `Bearer <ACCESS_TOKEN_JWT>` | Token akses pengguna terautentikasi (didapat dari alur GoTrue). |
| `Content-Type` | `application/json` | Format pengiriman data permintaan. |
| `X-Client-Info` | `rootin-mobile-flutter/1.0.0` | Identifikasi platform dan versi aplikasi untuk telemetri teknis. |
| `X-Idempotency-Key` | `550e8400-e29b-41d4-a716-446655440000` | UUIDv4 acak untuk memastikan permintaan tidak diduplikasi saat *retry*. |

---

## 2. Kontrak Autentikasi (Supabase GoTrue)

Manajemen sesi menggunakan token JWT terenkripsi yang disimpan di `flutter_secure_storage` (iOS Keychain / Android EncryptedSharedPreferences).

### 2.1 Pendaftaran Pengguna Baru (Sign Up)
- **Endpoint**: `POST /auth/v1/signup`
- **Request Body**:
  ```json
  {
    "email": "budi.santoso@example.com",
    "password": "PasswordKuat123!",
    "data": {
      "full_name": "Budi Santoso",
      "preferred_locale": "id"
    }
  }
  ```
- **Response Success (200 OK)**:
  ```json
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "budi.santoso@example.com",
    "access_token": "eyJhbGciOiJIUzI1Ni...",
    "token_type": "bearer",
    "expires_in": 3600,
    "refresh_token": "d9812f8a-...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "user_metadata": {
        "full_name": "Budi Santoso",
        "preferred_locale": "id"
      }
    }
  }
  ```

### 2.2 Masuk Sesi (Sign In with Password)
- **Endpoint**: `POST /auth/v1/token?grant_type=password`
- **Request Body**:
  ```json
  {
    "email": "budi.santoso@example.com",
    "password": "PasswordKuat123!"
  }
  ```
- **Response Success (200 OK)**: Format payload identik dengan respon Sign Up (mengandung `access_token` dan `refresh_token`).

### 2.3 Perpanjangan Sesi Token (Refresh Token)
- **Endpoint**: `POST /auth/v1/token?grant_type=refresh_token`
- **Request Body**:
  ```json
  {
    "refresh_token": "d9812f8a-..."
  }
  ```
- **Response Success (200 OK)**: Menerbitkan pasangan `access_token` dan `refresh_token` baru.

### 2.4 Keluar Sesi (Sign Out)
- **Endpoint**: `POST /auth/v1/logout`
- **Header**: `Authorization: Bearer <ACCESS_TOKEN_JWT>`
- **Response Success (204 No Content)**.

---

## 3. Kontrak RPC Sinkronisasi Data

Sinkronisasi data offline-first tidak menggunakan kueri tabel individual per record, melainkan melalui dua RPC atomik: **Push Mutations** dan **Pull Changes**.

### 3.1 Push Mutations (`sync_push_mutations`)
Mengirimkan batch rekaman mutasi yang tertampung di antrean lokal `sync_outbox` menuju backend dalam satu transaksi database tunggal.

- **Endpoint**: `POST /rest/v1/rpc/sync_push_mutations`
- **Headers**:
  - `apikey: <SUPABASE_ANON_KEY>`
  - `Authorization: Bearer <ACCESS_TOKEN_JWT>`
  - `Content-Type: application/json`

#### Request Body
Payload berupa objek JSON yang memuat array `p_mutations`:

```json
{
  "p_mutations": [
    {
      "operation_id": "8a7c2b3e-1111-4444-9999-0123456789ab",
      "entity_type": "item",
      "record_id": "a3bb189e-8bf9-3888-9912-ace4e6543002",
      "operation_type": "insert",
      "version": 1,
      "client_timestamp": "2026-10-24T14:30:00.000Z",
      "payload": {
        "name": "Honda Vario 160",
        "category": "vehicle",
        "brand": "Honda",
        "model_number": "Vario 160 CBS",
        "serial_or_plate_number": "B 1234 XYZ",
        "purchase_date": "2024-05-10",
        "has_odometer": true,
        "current_odometer": 12500,
        "photo_remote_path": "550e8400.../a3bb189e.../vario.jpg",
        "notes": "Kendaraan komuter utama",
        "is_archived": false,
        "created_at": "2026-10-24T14:30:00.000Z",
        "updated_at": "2026-10-24T14:30:00.000Z",
        "deleted_at": null
      }
    },
    {
      "operation_id": "9b8d3c4f-2222-5555-aaaa-1234567890cd",
      "entity_type": "reminder",
      "record_id": "b4cc290f-9cf0-4999-0023-bdf5f7654113",
      "operation_type": "insert",
      "version": 1,
      "client_timestamp": "2026-10-24T14:31:00.000Z",
      "payload": {
        "item_id": "a3bb189e-8bf9-3888-9912-ace4e6543002",
        "name": "Ganti Oli Mesin",
        "engine_type": "mileage",
        "last_service_odometer": 12000,
        "interval_km": 4000,
        "is_active": true,
        "created_at": "2026-10-24T14:31:00.000Z",
        "updated_at": "2026-10-24T14:31:00.000Z",
        "deleted_at": null
      }
    }
  ]
}
```

#### Response Success (200 OK)
```json
{
  "server_timestamp": "2026-10-24T14:31:02.120Z",
  "mutations_result": [
    {
      "operation_id": "8a7c2b3e-1111-4444-9999-0123456789ab",
      "status": "accepted",
      "version": 1
    },
    {
      "operation_id": "9b8d3c4f-2222-5555-aaaa-1234567890cd",
      "status": "accepted",
      "version": 1
    }
  ]
}
```

#### Nilai Status Hasil Mutasi (`mutations_result[i].status`):
- `accepted`: Mutasi berhasil divalidasi dan disimpan. Klien dapat menghapus baris outbox terkait.
- `duplicate_ignored`: `operation_id` telah pernah diproses sebelumnya (idempoten). Klien aman menghapus baris outbox terkait.
- `conflict_rejected`: Versi server lebih baru daripada versi klien (LWW rule). Server mengembalikan `server_version`. Klien membatalkan mutasi lokal dan menunggu sinkronisasi pull.
- `validation_failed`: Skema payload tidak memenuhi aturan integritas data. Baris outbox ditandai `failed` di klien untuk investigasi.

---

### 3.2 Pull Changes (`sync_pull_changes`)
Mengambil delta data yang berubah (rekaman baru, terbarui, atau tombstone penghapusan) dari backend sejak stempel kursor terakhir.

- **Endpoint**: `POST /rest/v1/rpc/sync_pull_changes`
- **Request Body**:
  ```json
  {
    "p_since": "2026-10-24T00:00:00.000Z",
    "p_limit": 500
  }
  ```
  *(Jika `p_since` bernilai `null`, server melakukan full-sync seluruh data aktif pengguna).*

#### Response Success (200 OK)
```json
{
  "server_timestamp": "2026-10-24T14:35:10.500Z",
  "items": [
    {
      "id": "a3bb189e-8bf9-3888-9912-ace4e6543002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Honda Vario 160",
      "category": "vehicle",
      "brand": "Honda",
      "model_number": "Vario 160 CBS",
      "serial_or_plate_number": "B 1234 XYZ",
      "purchase_date": "2024-05-10",
      "has_odometer": true,
      "current_odometer": 12500,
      "photo_remote_path": "550e8400.../a3bb189e.../vario.jpg",
      "notes": "Kendaraan komuter utama",
      "is_archived": false,
      "created_at": "2026-10-24T14:30:00.000Z",
      "updated_at": "2026-10-24T14:30:00.000Z",
      "deleted_at": null,
      "version": 1
    }
  ],
  "reminders": [
    {
      "id": "b4cc290f-9cf0-4999-0023-bdf5f7654113",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "item_id": "a3bb189e-8bf9-3888-9912-ace4e6543002",
      "name": "Ganti Oli Mesin",
      "engine_type": "mileage",
      "last_service_odometer": 12000,
      "interval_km": 4000,
      "is_active": true,
      "created_at": "2026-10-24T14:31:00.000Z",
      "updated_at": "2026-10-24T14:31:00.000Z",
      "deleted_at": null,
      "version": 1
    }
  ],
  "reminder_logs": []
}
```

---

## 4. Kontrak Storage Privat Foto Barang

Foto profil barang dikelola menggunakan Supabase Storage API dengan bucket privat `item-photos`.

### 4.1 Mengunggah Foto Barang (Upload Object)
- **Endpoint**: `POST /storage/v1/object/item-photos/{user_id}/{item_id}/{file_uuid}.jpg`
- **Headers**:
  - `apikey: <SUPABASE_ANON_KEY>`
  - `Authorization: Bearer <ACCESS_TOKEN_JWT>`
  - `Content-Type: image/jpeg`
  - `x-upsert: true`
- **Request Body**: Binary stream file gambar (terkompresi < 1 MB).
- **Response Success (200 OK)**:
  ```json
  {
    "Key": "item-photos/550e8400.../a3bb189e.../vario.jpg",
    "Id": "9f8c1b3d-1111-4444-9999-abcdef123456"
  }
  ```

### 4.2 Pembuatan Short-Lived Signed URL
Digunakan saat klien memerlukan tautan unduh berbatas waktu (misal saat login di perangkat kedua).
- **Endpoint**: `POST /storage/v1/object/sign/item-photos/{user_id}/{item_id}/{file_uuid}.jpg`
- **Request Body**:
  ```json
  {
    "expiresIn": 3600
  }
  ```
- **Response Success (200 OK)**:
  ```json
  {
    "signedURL": "/storage/v1/object/sign/item-photos/.../vario.jpg?token=eyJhbGciOi..."
  }
  ```

### 4.3 Menghapus Foto Barang (Delete Object)
- **Endpoint**: `DELETE /storage/v1/object/item-photos/{user_id}/{item_id}/{file_uuid}.jpg`
- **Response Success (200 OK)**:
  ```json
  {
    "message": "Successfully deleted"
  }
  ```

---

## 5. Taksonomi Error & Penanganan Kegagalan

Sistem menerapkan format respon galat standar yang membedakan kegagalan fatal (*permanent error*) dengan kegagalan sementara (*transient error*) yang dapat dicoba kembali (*retryable*).

### 5.1 Format Objek Galat
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Batas frekuensi permintaan terlampaui. Silakan coba kembali dalam beberapa saat.",
    "details": {
      "retry_after_seconds": 30
    },
    "retryable": true
  }
}
```

### 5.2 Matriks Kode Galat

| HTTP Status | Error Code | Sifat (`retryable`) | Deskripsi & Tindakan Klien |
| :--- | :--- | :--- | :--- |
| **400** | `VALIDATION_FAILED` | `false` | Payload tidak valid secara skema; tandai mutasi di outbox sebagai gagal. |
| **401** | `AUTH_TOKEN_EXPIRED` | `false` | Token kedaluwarsa; picu refresh token GoTrue secara otomatis lalu coba lagi. |
| **401** | `AUTH_INVALID_CREDENTIALS` | `false` | Kredensial email/password salah; tampilkan dialog input ke pengguna. |
| **403** | `FORBIDDEN_RLS_VIOLATION` | `false` | Pelanggaran RLS (`auth.uid() != user_id`); tolak mutasi secara permanen. |
| **409** | `CONFLICT_STALE_VERSION` | `false` | Versi server lebih baru (LWW); batalkan mutasi lokal dan konsumsi versi server. |
| **422** | `ENTITY_UNPROCESSABLE` | `false` | Ketergantungan relasi hilang (misal `item_id` tidak ada); log audit. |
| **429** | `RATE_LIMIT_EXCEEDED` | `true` | Batas kecepatan terlampaui; tunda sinkronisasi menggunakan *jitter backoff*. |
| **500** | `INTERNAL_SERVER_ERROR` | `true` | Masalah internal server PostgreSQL; jadwalkan ulang antrean outbox. |
| **503 / 504**| `GATEWAY_TIMEOUT` | `true` | Koneksi server terputus di tengah jalan; ulangi mutasi dengan aman (idempoten). |
| **0 (Lokal)** | `NETWORK_UNAVAILABLE` | `true` | Perangkat dalam Airplane Mode / tanpa sinyal; tahan outbox hingga sinyal pulih. |

### 5.3 Algoritma Retry di Sync Worker
Untuk galat bertanda `retryable: true`, *sync worker* menerapkan rumus *exponential backoff* dengan *full jitter*:
```dart
int calculateBackoffDelayMs(int retryCount) {
  const baseDelayMs = 1000; // 1 detik
  const maxDelayMs = 60000; // 60 detik

  final exponentialDelay = baseDelayMs * math.pow(2, retryCount).toInt();
  final cappedDelay = math.min(exponentialDelay, maxDelayMs);

  // Full Jitter: rentang acak antara 50% hingga 100% dari cappedDelay
  final jitter = 0.5 + (math.Random().nextDouble() * 0.5);
  return (cappedDelay * jitter).toInt();
}
```

---

## 6. Kontrak Koordinasi Notifikasi (Lokal vs Remote)

Rootin Mobile menggunakan pendekatan *hybrid notification coordination* yang menempatkan notifikasi lokal perangkat sebagai eksekutor primer dan push remote sebagai pendukung sekunder.

### 6.1 Format Identifier Unik & Deterministik
Untuk mencegah duplikasi peringatan pada pengingat yang sama, sistem menggunakan dua format identifier:

1. **Occurrence ID (String Deterministik)**:
   - Merepresentasikan satu kejadian jatuh tempo spesifik.
   - Pola Mesin Waktu: `${reminder_id}#${target_date}`
     *Contoh*: `b4cc290f-9cf0-4999-0023-bdf5f7654113#2026-11-01`
   - Pola Mesin Jarak / Pemakaian: `${reminder_id}#${threshold_target}`
     *Contoh*: `b4cc290f-9cf0-4999-0023-bdf5f7654113#odo_16000`
2. **Notification ID (Integer 32-bit Positif)**:
   - Batasan platform Android dan iOS (`flutter_local_notifications`) mensyaratkan ID berupa *signed 32-bit integer* (`1` hingga `2.147.483.647`).
   - Dihasilkan melalui algoritma hashing deterministik FNV-1a dari `occurrence_id`:
     ```dart
     int generateNotificationId(String occurrenceId) {
       // FNV-1a 32-bit Hash
       var hash = 0x811c9dc5;
       for (var codeUnit in occurrenceId.codeUnits) {
         hash ^= codeUnit;
         hash = (hash * 0x01000193) & 0xFFFFFFFF;
       }
       // Pastikan nilai bernilai positif dalam rentang signed 32-bit (0x7FFFFFFF)
       return hash & 0x7FFFFFFF;
     }
     ```

### 6.2 Rolling Horizon Notifikasi Lokal
Sistem operasi membatasi jumlah alarm terjadwal yang dapat didaftarkan (misal: iOS membatasi maksimal 64 alarm aktif di `UNUserNotificationCenter`).

- **Jendela Horizon**: Aplikasi menjadwalkan notifikasi lokal hanya untuk kejadian yang berada dalam rentang **30 hari ke depan** (*30-day Rolling Horizon*).
- **Penyelarasan Horizon (*Horizon Recalibration*)**:
  Horizon diselaraskan ulang secara otomatis pada tiga pemicu (*triggers*):
  1. Pengguna membuka aplikasi (*on app resume / foreground*).
  2. Terjadi mutasi pengingat (penambahan, penyelesaian, penundaan/snooze, atau arsip).
  3. Perubahan tanggal sistem operasi (*midnight tick* atau perubahan zona waktu perangkat).

```
                      Rolling Horizon (30 Hari)
           ├──────────────────────────────────────────►
───[ Hari Ini ]──────────────[ Hari ke-15 ]─────────────[ Hari ke-30 ]───> Masa Depan
   Alarm Terdaftar            Alarm Terdaftar             Batas Alarm
   di OS                      di OS                       (Event berikutnya
                                                          dijadwalkan saat horizon bergeser)
```

### 6.3 Pembagian Peran: Notifikasi Lokal vs Remote Push (Post-MVP)

```
┌────────────────────────────────────────┬────────────────────────────────────────┐
│      Notifikasi Lokal (MVP Utama)      │        Remote Push Cloud (Post-MVP)    │
├────────────────────────────────────────┼────────────────────────────────────────┤
│ • Menangani 100% jadwal pengingat rutin│ • Hanya bertindak sebagai sinyal latar │
│   jatuh tempo di perangkat.            │   belakang (*silent push sync trigger*)│
│ • Bekerja penuh saat offline tanpa     │ • Menghubungkan sinkronisasi jika data │
│   koneksi internet (*zero network*).   │   diubah dari perangkat lain.          │
│ • Nol biaya infrastruktur server.      │ • Memerlukan akun developer & FCM/APNs.│
│ • Presisi detik mengikuti jam sistem.  │ • Memeriksa `occurrence_id`; tidak     │
│                                        │   memunculkan banner jika lokal aktif. │
└────────────────────────────────────────┴────────────────────────────────────────┘
```

#### Aturan Anti-Duplikasi:
Ketika remote push tiba di perangkat, background handler membaca `occurrence_id`. Jika rekaman lokal menunjukkan reminder dengan `occurrence_id` tersebut telah ditandai selesai (*completed*) atau telah dijadwalkan oleh alarm lokal, pesan push diabaikan tanpa menampilkan banner peringatan ganda kepada pengguna.

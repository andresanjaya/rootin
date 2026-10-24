# Rootin Mobile â€” Product Requirement Document (PRD)

## 1. Dokumen Kontrol & Ringkasan Eksekutif

| Atribut | Nilai |
| :--- | :--- |
| **Nama Produk** | Rootin Mobile |
| **Versi Dokumen** | 1.0.0 (MVP Beta Specification) |
| **Status** | Approved / Baseline RFC |
| **Platform Target** | iOS & Android (Flutter Greenfield) |
| **Backend Target** | Supabase (Terisolasi 100% dari Rootin Web) |

### 1.1 Visi Produk
Rootin Mobile adalah aplikasi asisten pemeliharaan aset pribadi, peralatan rumah tangga, dan kendaraan yang berorientasi pada keandalan operasional, privasi, dan kesiapan **offline-first**. Aplikasi ini membebaskan pengguna dari kecemasan melupakan jadwal servis berkala, penggantian suku cadang habis pakai, dan masa berlaku dokumen legalitas dengan menghadirkan mesin pengingat cerdas yang fleksibel terhadap pola pemakaian nyata.

### 1.2 Masalah Pengguna (*Problem Statement*)
1. **Model Pengingat Kalender Konvensional Kaku**: Aplikasi kalender dan to-do list umum hanya menyediakan pengingat berbasis tanggal statis. Jika pengguna terlambat melakukan servis ganti oli selama dua minggu, kalender tetap menghitung jadwal berikutnya dari tanggal asli, bukan dari tanggal servis aktual, menyebabkan jadwal berikutnya menjadi terlalu dini dan boros biaya.
2. **Ketiadaan Dukungan Multi-Metrik (Jarak & Pemakaian)**: Perawatan aset modern tidak hanya bergantung pada waktu. Komponen seperti filter air, mata pisau blender, dan pelumas rantai bergantung pada frekuensi penggunaan (counter pemakaian), sedangkan komponen kendaraan bermotor bergantung pada jarak tempuh odometer (kilometer/mil).
3. **Ketergantungan Jaringan Internet (Cloud-Only)**: Banyak aplikasi pencatat pemeliharaan mewajibkan koneksi internet aktif. Saat pengguna berada di garasi bawah tanah, bengkel luar kota, atau daerah minim sinyal, mereka tidak dapat membuka riwayat servis atau mencatat odometer terbaru.
4. **Kehilangan Catatan Riwayat Aset**: Bukti perawatan sering kali tercecer di kertas kuitansi manual atau buku servis fisik yang mudah hilang, menurunkan nilai jual kembali (*resale value*) aset dan menyulitkan diagnosa kerusakan berulang.

### 1.3 Nilai Pembeda (*Core Differentiator*)
- **True Offline-First**: Seluruh fitur inti (CRUD aset, perhitungan recurrence, log perawatan, alarm lokal) berjalan 100% di penyimpanan lokal Drift SQLite.
- **Tiga Mesin Pengingat Adaptif**: Waktu (dengan completion baseline & clamping kalender), Pemakaian (counter manual & keausan), dan Jarak Tempuh (odometer kendaraan mandiri).
- **Log Perawatan Permanen (Immutable Audit Trail)**: Catatan riwayat servis bersifat *append-only* untuk menjaga integritas data historis.
- **Privasi Tinggi & Nol Ketergantungan Web**: Data pengguna diproteksi Row-Level Security (RLS) pada instance database mandiri tanpa berbagi basis data dengan Rootin Web.

---

## 2. Persona Pengguna & Skenario Penggunaan

### 2.1 Persona 1: Budi Santoso â€” Pemilik Kendaraan Aktif
- **Profil**: Pria, 32 tahun, karyawan swasta komuter di kota metropolitan.
- **Aset yang Dikelola**: 1 unit mobil keluarga (MPV) dan 1 unit sepeda motor matic untuk harian.
- **Tujuan**:
  - Menjaga performa kendaraan tetap prima tanpa terlewat jadwal servis pabrikan.
  - Memantau beberapa jenis perawatan sekaligus pada satu kendaraan (oli mesin tiap 4.000 km, oli transmisi tiap 10.000 km, rotasi ban tiap 10.000 km, perpanjangan STNK tahunan).
  - Memiliki riwayat servis rapi untuk mempertahankan harga jual kendaraan.
- **Frustrasi**:
  - Sering lupa posisi odometer terakhir saat berada di bengkel.
  - Buku servis fisik hilang atau rusak terkena air/minyak.
  - Aplikasi pengingat biasa tidak bisa membedakan reminder berbasis kilometer vs berbasis tanggal.

### 2.2 Persona 2: Siti Rahma â€” Manajer Rumah Tangga & Aset Properti
- **Profil**: Wanita, 38 tahun, mengelola operasional rumah tinggal dan perlengkapan keluarga.
- **Aset yang Dikelola**: Dispenser air minum (filter sediment & karbon), 4 unit AC split, mesin pembersih vakum nirkabel, dan peralatan elektronik dapur.
- **Tujuan**:
  - Memastikan kualitas air minum dan sirkulasi udara keluarga terjaga dengan penggantian filter berkala.
  - Mengetahui kapan pembersihan filter vakum harus dicuci berdasarkan estimasi siklus pemakaian.
  - Mencatat kontak teknisi langganan dan biaya servis AC berkala.
- **Frustrasi**:
  - Lupa tanggal terakhir teknisi AC datang mencuci unit.
  - Sulit melacak filter dispenser mana yang baru diganti bulan lalu vs yang sudah 6 bulan belum diganti.
  - Aplikasi berbasis web lambat dibuka saat harus mengecek nomor model suku cadang di ruang utilitas.

### 2.3 Matriks Use Cases

| Kode UC | Judul Use Case | Aktor Utama | Deskripsi Singkat |
| :--- | :--- | :--- | :--- |
| **UC-01** | Daftarkan Kendaraan & Odometer | Budi Santoso | Membuat profil kendaraan, memasukkan angka odometer awal, dan menetapkan foto plat nomor. |
| **UC-02** | Buat Reminder Jarak Tempuh | Budi Santoso | Mengatur pengingat ganti oli mesin tiap 4.000 km yang terikat pada odometer kendaraan. |
| **UC-03** | Update Odometer & Cek Status | Budi Santoso | Memperbarui angka odometer saat isi bahan bakar dan melihat sisa kilometer sebelum servis. |
| **UC-04** | Buat Reminder Waktu Bulanan | Siti Rahma | Mengatur pengingat servis cuci AC setiap 3 bulan dengan baseline penyelesaian aktual. |
| **UC-05** | Buat Reminder Counter Pemakaian | Siti Rahma | Mengatur pengingat cuci filter vakum setiap 20 kali siklus penggunaan (counter +1). |
| **UC-06** | Selesaikan Reminder & Catat Biaya | Budi & Siti | Menandai reminder selesai, menginput tanggal actual, biaya, dan catatan mekanik ke riwayat. |
| **UC-07** | Tunda Pengingat (Snooze) | Budi Santoso | Menunda notifikasi servis selama 3 hari tanpa merusak interval recurrence jangka panjang. |
| **UC-08** | Buka Aplikasi Tanpa Sinyal | Siti Rahma | Membuka daftar filter saat berada di toko bangunan tanpa koneksi internet. |

---

## 3. User Stories & Acceptance Criteria

### US-01: Manajemen Profil Barang & Aset
> **Sebagai** pengguna,
> **Saya ingin** membuat, melihat, memperbarui, dan mengarsipkan profil aset pribadi atau kendaraan,
> **Agar** seluruh informasi fisik, kategori, dan identitas aset terdokumentasi terpusat.

**Acceptance Criteria (AC):**
1. Pengguna dapat membuat aset dengan atribut wajib: `name` (string, 1-100 karakter), `category` (Kendaraan, Elektronik Rumah Tangga, Furnitur, Fasilitas, Lainnya).
2. Atribut opsional mencakup: `brand`, `model_number`, `serial_or_plate_number`, `purchase_date`, dan `notes`.
3. Untuk kategori "Kendaraan", sistem menyediakan opsi khusus untuk mengaktifkan pelacakan odometer (`has_odometer: true`) dengan nilai `current_odometer` awal (bilangan bulat non-negatif).
4. Pembuatan aset baru langsung tersimpan di database lokal Drift dan memicu sinkronisasi outbox.
5. Daftar aset menampilkan ringkasan jumlah reminder aktif dan status pemeliharaan terkini.

---

### US-02: Manajemen Foto Aset Privat
> **Sebagai** pengguna,
> **Saya ingin** mengunggah dan melampirkan foto pada profil aset,
> **Agar** saya mudah mengidentifikasi barang secara visual dan memiliki dokumentasi fisik.

**Acceptance Criteria (AC):**
1. Pengguna dapat memilih gambar dari kamera atau galeri perangkat.
2. File gambar lokal dikompresi di sisi klien (maksimal 1080p, ukuran target < 1MB) sebelum disimpan.
3. Gambar disimpan di direktori dokumen lokal aplikasi untuk akses offline instan.
4. Ketika sinkronisasi cloud berjalan, file diunggah ke Supabase Storage bucket privat dengan struktur path `{user_id}/{item_id}/{uuid}.jpg`.
5. Akses gambar dari cloud wajib menggunakan short-lived signed URL (masa berlaku 60 menit) atau fallback file lokal; tidak ada gambar yang dapat diakses secara publik (*no public bucket*).

---

### US-03: Reminder Berbasis Waktu (Time-Based Engine)
> **Sebagai** pengguna,
> **Saya ingin** membuat pengingat perawatan berkala berdasarkan rentang waktu kalender,
> **Agar** perawatan rutin (misal: servis AC tiap 3 bulan) terjadwal otomatis.

**Acceptance Criteria (AC):**
1. Pengguna dapat memilih unit interval: Hari (`days`), Minggu (`weeks`), Bulan (`months`), atau Tahun (`years`) beserta nilai interval (bilangan bulat >= 1).
2. Sistem mendukung dua mode baseline recurrence:
   - **Actual Completion Baseline (Default)**: Jatuh tempo berikutnya dihitung dari tanggal pengguna menandai tugas selesai (`completion_date + interval`).
   - **Strict Schedule Baseline**: Jatuh tempo berikutnya dihitung dari tanggal jatuh tempo sebelumnya (`scheduled_date + interval`) terlepas dari kapan diselesaikan.
3. Notifikasi lokal dijadwalkan tepat pada waktu yang ditentukan pengguna (jam dan menit) di zona waktu perangkat lokal.
4. Tampilan kartu reminder menunjukkan tanggal jatuh tempo, sisa hari (atau hari lewat jatuh tempo / overdue), dan status warna visual.

---

### US-04: Aturan Recurrence Khusus (Tahun Kabisat & Clamping Akhir Bulan)
> **Sebagai** pengguna,
> **Saya ingin** pengingat tanggal akhir bulan atau tahun kabisat ditangani secara konsisten tanpa error,
> **Agar** jadwal tidak bergeser secara liar ke bulan berikutnya.

**Acceptance Criteria (AC):**
1. **Penanganan Tahun Kabisat (29 Februari)**:
   - Jika reminder tahunan dibuat pada tanggal 29 Februari (misal: 29 Feb 2024), pada tahun non-kabisat (2025, 2026, 2027) tanggal jatuh tempo otomatis di-clamp ke **28 Februari**.
   - Sistem menyimpan `target_day = 29` sebagai metadata anchor, sehingga ketika tiba tahun kabisat berikutnya (2028), tanggal jatuh tempo otomatis kembali ke **29 Februari**.
2. **Penanganan Akhir Bulan (Month-End Clamping)**:
   - Jika reminder bulanan dibuat pada tanggal 31 (misal: 31 Januari), pada bulan-bulan dengan hari lebih sedikit:
     - Februari: jatuh pada tanggal 28 (atau 29 pada tahun kabisat).
     - April, Juni, September, November: jatuh pada tanggal 30.
     - Maret, Mei, Juli, Agustus, Oktober, Desember: kembali jatuh pada tanggal 31 (karena `target_day = 31` tetap tersimpan).
3. Logika kalkulasi diimplementasikan pada lapisan Domain murni tanpa memicu exception kalender.

---

### US-05: Reminder Berbasis Pemakaian (Usage-Based Engine)
> **Sebagai** pengguna,
> **Saya ingin** mencatat siklus pemakaian barang melalui counter bertahap dan menetapkan ambang batas,
> **Agar** komponen yang aus karena pemakaian (misal: filter vakum) dapat diganti tepat waktu.

**Acceptance Criteria (AC):**
1. Pengguna dapat menentukan `threshold_limit` (misal: 20 siklus / 50 kali pakai) dan `unit_name` (misal: "kali seduh", "siklus", "jam operasional").
2. Antarmuka menyediakan tombol aksi cepat `+1` langsung dari daftar reminder untuk menambah counter pemakaian tanpa harus membuka form edit.
3. Persentase keausan dihitung otomatis: `(current_usage / threshold_limit) * 100%`.
4. Indikator status visual terbagi dalam 3 tingkatan:
   - **Normal**: Keausan < 80% (Aksen Netral/Hijau).
   - **Warning**: Keausan 80% s/d 99% (Aksen Oranye/Kuning).
   - **Due/Overdue**: Keausan >= 100% (Aksen Merah & peringatan jatuh tempo).
5. Ketika tindakan pemeliharaan diselesaikan, counter di-reset ke nilai 0 (atau offset yang ditentukan) dan riwayat dicatat di log perawatan.

---

### US-06: Reminder Berbasis Jarak Tempuh (Mileage-Based Engine)
> **Sebagai** pengguna pemilik kendaraan,
> **Saya ingin** menetapkan pengingat servis berdasarkan interval kilometer dan mencatat odometer kendaraan,
> **Agar** perawatan mesin dan pelumas terlacak akurat sesuai rekomendasi pabrikan.

**Acceptance Criteria (AC):**
1. Reminder jarak hanya dapat dibuat pada aset yang memiliki profil odometer (`has_odometer: true`).
2. Pengguna menentukan `interval_km` (misal: 4.000 km) dan sistem mencatat `last_service_odometer` (misal: 20.000 km).
3. Target servis berikutnya dihitung: `next_service_odometer = last_service_odometer + interval_km`.
4. Saat pengguna memperbarui `current_odometer` pada kendaraan (misal menjadi 23.500 km), seluruh reminder jarak pada kendaraan tersebut otomatis memperbarui sisa jarak: `remaining_km = next_service_odometer - current_odometer`.
5. Status reminder:
   - **Normal**: `remaining_km > 500 km`.
   - **Warning (Mendekati Servis)**: `0 km < remaining_km <= 500 km`.
   - **Due / Overdue**: `remaining_km <= 0 km`.
6. Ketika servis diselesaikan, pengguna memasukkan angka odometer saat servis dilakukan sebagai baseline baru (`last_service_odometer`), dan target berikutnya dihitung ulang secara mandiri.

---

### US-07: Notifikasi Perangkat Lokal & Penjadwalan Dinamis
> **Sebagai** pengguna,
> **Saya ingin** menerima notifikasi alarm di perangkat saya pada waktu yang ditentukan,
> **Agar** saya tidak perlu terus-menerus membuka aplikasi untuk memeriksa jadwal jatuh tempo.

**Acceptance Criteria (AC):**
1. Notifikasi dijadwalkan menggunakan pustaka native perangkat via `flutter_local_notifications`.
2. Penjadwalan mengandalkan zona waktu lokal perangkat (`tz.TZDateTime`) agar tetap akurat saat perangkat offline.
3. Teks notifikasi memuat nama aset, nama pengingat, dan status jatuh tempo.
4. Mengetuk notifikasi membuka aplikasi dan langsung mengarahkan pengguna (*deep-link*) ke halaman detail reminder terkait.
5. Notifikasi dibatalkan atau dijadwalkan ulang secara otomatis jika reminder diselesaikan, ditunda, atau dinonaktifkan.

---

### US-08: Penundaan Pengingat (Snooze Engine)
> **Sebagai** pengguna yang belum sempat melakukan servis pada hari H,
> **Saya ingin** menunda pengingat (snooze) selama beberapa hari,
> **Agar** notifikasi tidak mengganggu hari ini tanpa merusak siklus interval jangka panjang.

**Acceptance Criteria (AC):**
1. Pengguna dapat memilih durasi penundaan cepat: 1 Hari, 3 Hari, 1 Minggu, atau Pilih Tanggal Spesifik.
2. Saat di-snooze, atribut `snooze_until` diisi dengan waktu baru, dan notifikasi lokal dijadwalkan ulang ke tanggal tersebut.
3. **Invariant Inti**: Nilai `snooze_until` **TIDAK MENGUBAH** tanggal `next_due_date` dasar. Perhitungan siklus servis berikutnya tetap berpatokan pada penyelesaian aktual saat tugas akhirnya diselesaikan.
4. Reminder yang sedang dalam masa tunda diberi label status visual "Ditunda hingga [Tanggal]".

---

### US-09: Pencatatan Riwayat Perawatan Permanen (Immutable Audit Logs)
> **Sebagai** pengguna,
> **Saya ingin** setiap tindakan pemeliharaan yang diselesaikan tersimpan sebagai catatan riwayat permanen,
> **Agar** saya memiliki buku servis digital yang kredibel dan tidak dapat dimanipulasi tanpa sengaja.

**Acceptance Criteria (AC):**
1. Setiap kali tombol "Selesaikan" ditekan pada reminder, sistem wajib membuat entitas `maintenance_logs` baru.
2. Kolom log memuat: `id` (UUID), `item_id`, `reminder_id`, `completed_at` (timestamp aktual), `odometer_at_completion` (opsional untuk kendaraan), `cost` (desimal biaya dalam mata uang lokal), `performed_by` (mandiri/nama bengkel), dan `notes`.
3. Entitas riwayat bersifat **append-only (immutable)**: tidak ada antarmuka untuk mengedit tanggal penyelesaian atau data historis demi menjamin keaslian riwayat. Pengguna hanya dapat menambahkan catatan koreksi baru jika diperlukan.
4. Total akumulasi biaya servis per aset dapat dihitung dari agregasi data log ini.

---

### US-10: Kalender & Dasbor Jatuh Tempo
> **Sebagai** pengguna,
> **Saya ingin** melihat seluruh agenda jatuh tempo dalam tampilan kalender dan dasbor ringkas,
> **Agar** saya dapat mengantisipasi pengeluaran dan waktu luang untuk melakukan perawatan.

**Acceptance Criteria (AC):**
1. Dasbor utama membagi daftar menjadi 3 tab/seksi: "Perlu Tindakan / Overdue", "Segera Tiba (7 Hari Kedepan)", dan "Semua Aset".
2. Tampilan kalender bulanan menandai tanggal-tanggal yang memiliki jadwal jatuh tempo dengan titik status berwarna.
3. Memilih tanggal pada kalender menyaring dan menampilkan daftar pengingat yang jatuh tempo pada tanggal tersebut.
4. Tersedia filter cepat berdasarkan kategori aset (Kendaraan, Elektronik Rumah Tangga, dll.).

---

### US-11: Siklus Hidup: Arsip & Unarchive
> **Sebagai** pengguna,
> **Saya ingin** mengarsipkan aset yang sedang tidak aktif digunakan (misal: kendaraan disimpan sementara),
> **Agar** dasbor utama tetap rapi tanpa kehilangan riwayat data masa lalu.

**Acceptance Criteria (AC):**
1. Pengguna dapat mengubah status aset menjadi `is_archived: true`.
2. Seluruh reminder yang terikat pada aset yang diarsipkan otomatis dinonaktifkan dari penjadwalan notifikasi lokal.
3. Aset yang diarsipkan dipindahkan ke halaman/filter khusus "Arsip" dan tidak muncul di dasbor aktif maupun kalender.
4. Pengguna dapat mengaktifkan kembali (*unarchive*) aset kapan saja; notifikasi lokal akan dijadwalkan ulang sesuai status tanggal saat diaktifkan.

---

### US-12: Siklus Hidup: Soft Delete & Penghapusan Permanen
> **Sebagai** pengguna,
> **Saya ingin** menghapus aset atau reminder yang salah dibuat dengan konfirmasi aman,
> **Agar** tidak terjadi penghapusan data secara tidak sengaja.

**Acceptance Criteria (AC):**
1. Penghapusan aset memerlukan konfirmasi ganda melalui dialog konfirmasi eksplisit dengan menyebutkan nama aset.
2. Penghapusan aset menerapkan mekanisme *soft delete* lokal (`deleted_at IS NOT NULL`) sebelum pembersihan permanen.
3. Jika aset dihapus permanen, sistem secara *cascade* menghapus seluruh reminder terkait, log perawatan terkait, dan memicu penghapusan file gambar di penyimpanan cloud via outbox queue.

---

### US-13: Sinkronisasi Offline-First & Durable Outbox
> **Sebagai** pengguna,
> **Saya ingin** aplikasi bekerja lancar tanpa jaringan internet dan menyinkronkan data secara otomatis saat online,
> **Agar** saya tidak pernah terhambat oleh koneksi jaringan yang tidak stabil.

**Acceptance Criteria (AC):**
1. Seluruh operasi penulisan (Create, Update, Delete) langsung berhasil di database lokal Drift SQLite dalam waktu < 50ms.
2. Setiap operasi penulisan menambahkan satu baris entri pada tabel `sync_outbox` lokal dengan `idempotency_key` unik.
3. Ketika koneksi internet terdeteksi aktif, sync background worker mengirimkan mutasi sesuai urutan pembuatan (*FIFO*).
4. Jika terjadi kegagalan jaringan saat push ke Supabase, outbox tidak dibuang, melainkan dijadwalkan ulang dengan strategi *exponential backoff* (1s, 2s, 4s, 8s, maks 60s).
5. Pembaruan data dari cloud diunduh dan diintegrasikan ke Drift lokal dengan resolusi konflik *last-write-wins* berbasis `updated_at`.

---

### US-14: Pengaturan Preferensi, Bahasa & Zona Waktu
> **Sebagai** pengguna,
> **Saya ingin** mengatur preferensi bahasa (Indonesia/Inggris) dan memastikan waktu jatuh tempo akurat saat berpindah zona waktu,
> **Agar** pengalaman penggunaan terasa natural dan konsisten.

**Acceptance Criteria (AC):**
1. Aplikasi menyediakan pemilih bahasa (Bahasa Indonesia sebagai default dan English).
2. Sistem secara otomatis mendeteksi perubahan zona waktu perangkat (`dynamic device timezone`).
3. Seluruh timestamp internal disimpan dalam format UTC ISO 8601, sedangkan tampilan UI dan jam notifikasi dikonversi ke zona waktu lokal pengguna.

---

## 4. Logika Recurrence & Algoritma Kalkulasi

### 4.1 Model Berbasis Waktu (Time-Based Engine)

#### 4.1.1 Perbandingan Mode Baseline
Misalkan sebuah reminder servis berkala dibuat dengan interval **1 Bulan**. Tanggal jatuh tempo awal dijadwalkan pada **10 Januari**. Pengguna baru sempat melakukan dan menyelesaikan servis pada **15 Januari**.
- **Mode Actual Completion Baseline (Default)**:
  $$\text{Next Due Date} = \text{Completion Date} + \text{Interval} = 15\text{ Jan} + 1\text{ Bulan} = 15\text{ Februari}$$
  *Keuntungan*: Mencegah jadwal servis berikutnya terlalu cepat (hanya berselang 25 hari). Sangat cocok untuk oli mesin, filter AC, dan perawatan fisik.
- **Mode Strict Schedule Baseline**:
  $$\text{Next Due Date} = \text{Previous Due Date} + \text{Interval} = 10\text{ Jan} + 1\text{ Bulan} = 10\text{ Februari}$$
  *Keuntungan*: Menjaga keteraturan tanggal kalender tetap sama. Sangat cocok untuk pembayaran pajak kendaraan tahunan (STNK) atau sewa tempat.

#### 4.1.2 Algoritma Penanganan Tahun Kabisat (Leap Year)
Tahun kabisat terjadi setiap tahun yang habis dibagi 4, kecuali tahun abad yang tidak habis dibagi 400.
1. Jika target recurrence adalah tahunan dengan `target_month = 2` dan `target_day = 29`:
   - Pada tahun $Y$, jika $\text{isLeapYear}(Y) = \text{false}$, maka:
     $$\text{Effective Due Date} = Y\text{-02-28}$$
   - Pada tahun $Y$, jika $\text{isLeapYear}(Y) = \text{true}$, maka:
     $$\text{Effective Due Date} = Y\text{-02-29}$$
2. Metadata `anchor_day = 29` tetap disimpan secara persisten pada entitas reminder, sehingga transisi ke tahun kabisat berikutnya tidak kehilangan informasi hari ke-29.

#### 4.1.3 Algoritma Clamping Akhir Bulan (Month-End Clamping)
Banyak bulan memiliki jumlah hari berbeda (28, 29, 30, atau 31 hari).
1. Ketika interval bulanan ditambahkan ke tanggal dasar dengan `anchor_day = 31`:
   - Hitung bulan target: $M_{\text{target}} = (M_{\text{current}} + \text{interval}) \pmod{12}$.
   - Tentukan hari maksimum bulan target: $D_{\text{max}} = \text{daysInMonth}(Y_{\text{target}}, M_{\text{target}})$.
   - Tentukan hari jatuh tempo efektif:
     $$D_{\text{effective}} = \min(\text{anchor\_day}, D_{\text{max}})$$
2. Contoh Siklus Bulanan dari 31 Januari:
   - Januari: 31 Jan ($D_{\text{max}} = 31$)
   - Februari: 28 Feb (atau 29 Feb jika kabisat) ($D_{\text{max}} = 28/29$)
   - Maret: 31 Mar ($D_{\text{max}} = 31$)
   - April: 30 Apr ($D_{\text{max}} = 30$)
   - Mei: 31 Mei ($D_{\text{max}} = 31$)
   Informasi bahwa pengguna menginginkan akhir bulan (hari ke-31) tidak hilang terpotong menjadi hari ke-28 untuk selamanya.

---

### 4.2 Model Berbasis Pemakaian (Usage-Based Engine)

#### 4.2.1 Parameter Perhitungan
- $U_{\text{current}}$: Akumulasi nilai counter pemakaian saat ini (integer $\ge 0$).
- $T_{\text{threshold}}$: Ambang batas pemakaian maksimum yang disarankan (integer $> 0$).
- $P_{\text{wear}}$: Persentase keausan komponen.
  $$P_{\text{wear}} = \left( \frac{U_{\text{current}}}{T_{\text{threshold}}} \right) \times 100\%$$

#### 4.2.2 Pemetaan Tingkat Keausan
```
 0%                        80%             100%
 â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–º
 â”‚       NORMAL (Aman)      â”‚ WARNING (Siap)â”‚   OVERDUE / PERLU SERVIS â”‚
 â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```
1. **Normal ($P_{\text{wear}} < 80\%$)**:
   - Komponen dalam kondisi layak pakai.
   - Indikator progres berwarna hijau/netral.
2. **Peringatan / Warning ($80\% \le P_{\text{wear}} < 100\%$)**:
   - Komponen mendekati batas usia pakai.
   - Aplikasi menyarankan pengguna menyiapkan suku cadang baru.
   - Indikator progres berwarna kuning/oranye.
3. **Jatuh Tempo / Overdue ($P_{\text{wear}} \ge 100\%$)**:
   - Batas pemakaian telah terlampaui.
   - Reminder berstatus aktif "Perlu Tindakan".
   - Indikator progres berwarna merah solid dengan label "Melebihi Batas".

---

### 4.3 Model Berbasis Jarak Tempuh (Mileage-Based Engine)

#### 4.3.1 Struktur Relasi Data
Satu profil kendaraan dapat memiliki satu nilai odometer utama dan banyak reminder servis jarak mandiri:

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚               VehicleProfile (Kendaraan)                â”‚
â”‚             current_odometer = 42.300 km               â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                            â”‚ 1 : N
        â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
        â–¼                   â–¼                   â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Reminder Oli  â”‚   â”‚ Reminder Rem  â”‚   â”‚ Reminder Ban  â”‚
â”‚Interval: 4000 â”‚   â”‚Interval: 20000â”‚   â”‚Interval: 10000â”‚
â”‚Last: 40.000 kmâ”‚   â”‚Last: 30.000 kmâ”‚   â”‚Last: 35.000 kmâ”‚
â”‚Next: 44.000 kmâ”‚   â”‚Next: 50.000 kmâ”‚   â”‚Next: 45.000 kmâ”‚
â”‚Sisa: 1.700 km â”‚   â”‚Sisa: 7.700 km â”‚   â”‚Sisa: 2.700 km â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

#### 4.3.2 Rumus Perhitungan & Pembaruan Cascading
1. **Target Servis**:
   $$\text{Odo}_{\text{target}} = \text{Odo}_{\text{last\_service}} + \text{Interval}_{\text{km}}$$
2. **Sisa Jarak**:
   $$\text{Remaining}_{\text{km}} = \text{Odo}_{\text{target}} - \text{Odo}_{\text{current}}$$
3. **Kondisi Evaluasi Status**:
   - Jika $\text{Remaining}_{\text{km}} > 500\text{ km}$: Status **Normal**.
   - Jika $0\text{ km} < \text{Remaining}_{\text{km}} \le 500\text{ km}$: Status **Warning** (Mendekati Servis).
   - Jika $\text{Remaining}_{\text{km}} \le 0\text{ km}$: Status **Due/Overdue** (Waktunya Servis).
4. **Pembaruan Odometer**: Ketika pengguna mengubah `current_odometer` pada kendaraan dari 42.300 km menjadi 43.850 km, sistem secara otomatis mengevaluasi ulang sisa jarak pada ketiga reminder di atas tanpa memerlukan input manual pada masing-masing reminder.

---

## 5. Modul Pendukung & Siklus Hidup Aset

### 5.1 Siklus Tunda (Snooze Lifecycle)
Mekanisme penundaan dirancang untuk memberikan fleksibilitas kepada pengguna tanpa merusak integritas jadwal masa depan:

```
[ Reminder Jatuh Tempo (Hari H) ]
               â”‚
      [ Aksi: Snooze 3 Hari ]
               â”‚
               â–¼
[ Atribut snooze_until = Hari H + 3 ]
[ Local Notification Dijadwalkan Ulang ke Hari H + 3 ]
[ Status Tampilan: "Ditunda" ]
               â”‚
   [ Saat Servis Aktual Selesai ]
               â”‚
               â–¼
[ Riwayat Dicatat di maintenance_logs ]
[ snooze_until Dibersihkan (NULL) ]
[ next_due_date Baru Dihitung dari Tanggal Penyelesaian Aktual ]
```

### 5.2 Siklus Hidup Aset (Lifecycle State Machine)
Setiap aset berada dalam salah satu status siklus hidup berikut:
1. **Aktif (`is_archived: false`, `deleted_at: null`)**: Aset tampil di dasbor utama, reminder aktif terjadwal, penghitungan jarak berjalan normal.
2. **Diarsipkan (`is_archived: true`, `deleted_at: null`)**: Aset dipindahkan ke arsip, semua reminder dinonaktifkan sementara dari alarm lokal, data historis tetap tersimpan penuh. Dapat di-unarchive kapan saja.
3. **Terhapus Lunak (`deleted_at: timestamp`)**: Aset ditandai terhapus, disembunyikan dari seluruh UI, masuk dalam antrean sinkronisasi penghapusan permanen ke cloud.
4. **Terhapus Permanen**: Seluruh rekaman aset, reminder terkait, file foto di storage lokal dan cloud dihapus secara tuntas (*hard delete cascade*).

---

## 6. Batasan Scope: MVP Beta vs Post-MVP Lanjutan

Untuk menjaga fokus eksekusi, peluncuran MVP Beta dibatasi pada fungsionalitas inti yang solid, sementara fitur lanjutan dialokasikan pada fase berikutnya:

| Modul / Fitur | Status Rilis | Alokasi Tiket | Justifikasi & Catatan |
| :--- | :--- | :--- | :--- |
| **Klien Mobile iOS & Android** | **MVP Beta** | M002 - M027 | Dibangun dengan Flutter/Dart untuk rilis serentak di dua platform. |
| **Penyimpanan Lokal Drift SQLite** | **MVP Beta** | M004 | Fondasi offline-first wajib tersedia sejak awal. |
| **Autentikasi Supabase (Email/Pass)** | **MVP Beta** | M005 | Registrasi dan login aman pengguna dengan isolasi data RLS. |
| **3 Engine Reminder (Waktu, Pakai, Jarak)** | **MVP Beta** | M009, M010, M011 | Fitur pembeda utama produk yang harus diuji di pasar beta. |
| **Notifikasi Perangkat Lokal** | **MVP Beta** | M012 | Notifikasi handal tanpa memerlukan server push eksternal. |
| **Log Perawatan Permanen & Biaya** | **MVP Beta** | M014 | Pencatatan riwayat pemeliharaan dan pengeluaran dasar. |
| **Durable Outbox Sync Engine** | **MVP Beta** | M018, M019 | Sinkronisasi asinkron lokal-ke-cloud yang tahan gangguan sinyal. |
| **Bilingual (ID & EN) & Timezone** | **MVP Beta** | M006 | Dukungan pasar lokal Indonesia dan ekspansi global. |
| **Free Tier Fungsional Lengkap** | **MVP Beta** | M001 | Seluruh fitur beta dapat digunakan gratis oleh tester. |
| **Remote Push (FCM / APNs Cloud)** | **Post-MVP** | M020 | Memerlukan backend push trigger & sertifikat Apple Developer berbayar. |
| **Langganan Berbayar (RevenueCat Pro)** | **Post-MVP** | M022, M023 | Monetisasi diuji setelah metrik retensi versi gratis terbukti kuat. |
| **Ekspor Data Mandiri (JSON/CSV)** | **Post-MVP** | M024 | Fitur utilitas backup & kepatuhan privasi GDPR fase lanjutan. |
| **Pemindaian OCR Struk / Plat Nomor** | **Post-MVP** | Fase 2 | Memerlukan model ML on-device atau API vision pihak ketiga. |
| **Integrasi IoT / Scanner OBD2 Mobil** | **Post-MVP** | Fase 2 | Kompleksitas protokol hardware Bluetooth/Wi-Fi OBD2. |
| **Kolaborasi Keluarga / Multi-User Sharing** | **Post-MVP** | Fase 2 | Memerlukan model permission berbasis peran (*role-based sharing*). |

---

## 7. Skema Monetisasi & Kuota Hipotesis (Free vs Pro)

> **Pernyataan Penafian Hipotesis**:
> Seluruh angka kuota, batasan item, dan fitur tier di bawah ini berstatus **HIPOTESIS PENGUJIAN AWAL**. Angka ini tidak mengikat secara kaku dan akan divalidasi selama masa pengujian beta melalui observasi perilaku penggunaan nyata sebelum rilis komersial.

### 7.1 Matriks Perbandingan Tier Hipotesis

| Fitur / Parameter | Free Tier (Hipotesis) | Pro Tier (Hipotesis) |
| :--- | :--- | :--- |
| **Batas Aset Aktif** | Maksimal 5 Aset | Tanpa Batas (*Unlimited*) |
| **Batas Reminder Aktif per Aset** | Maksimal 3 Reminder / Aset | Tanpa Batas (*Unlimited*) |
| **Mesin Reminder** | Waktu, Pemakaian, Jarak | Waktu, Pemakaian, Jarak |
| **Penyimpanan Foto Aset** | Resolusi Standar (Maks 1 Foto/Aset) | Resolusi Tinggi (Maks 5 Foto/Aset) |
| **Sinkronisasi Cloud Multi-Device** | 1 Perangkat Aktif | Sinkronisasi Lintas Perangkat Real-time |
| **Riwayat Perawatan & Biaya** | Riwayat 1 Tahun Terakhir | Riwayat Selamanya + Analisis Pengeluaran |
| **Dukungan Prioritas** | Komunitas / Standar | Prioritas Khusus |

### 7.2 Kebijakan Downgrade Non-Destruktif
Prinsip dasar integritas data Rootin Mobile: **Pengurangan status langganan TIDAK PERNAH menghapus data pengguna**.
1. Jika pengguna beralih dari Pro Tier ke Free Tier (misal: membatalkan langganan):
   - Seluruh aset dan reminder yang telah dibuat sebelumnya (walaupun melebihi kuota 5 aset) **tetap tersimpan utuh** dan tidak dihapus.
   - Seluruh reminder yang sudah ada **tetap berjalan dan memicu notifikasi lokal** seperti biasa.
   - Pengguna tetap dapat membaca seluruh riwayat perawatan masa lalu (*full read-only access*).
2. Pembatasan yang berlaku:
   - Pengguna tidak dapat membuat aset baru atau menambah reminder baru hingga jumlah aset/reminder aktif dikurangi secara sukarela hingga berada di bawah batas Free Tier.

---

## 8. Non-Functional Requirements (NFR)

### 8.1 Keamanan & Isolasi Row-Level Security (RLS)
- **RLS PostgreSQL**: Seluruh tabel di Supabase wajib memiliki RLS aktif dengan policy `auth.uid() = user_id`. Pengguna tidak dapat melakukan *query injection* untuk melihat data pengguna lain.
- **Enkripsi Kunci & Token**: Token sesi JWT disimpan di Secure Storage (iOS Keychain / Android EncryptedSharedPreferences).
- **Private Storage**: Bucket gambar aset dilindungi aturan RLS berbasis prefix folder `auth.uid()`.

### 8.2 Ketahanan & Performa Offline
- **Latensi Penulisan Lokal**: Mutasi CRUD di Drift SQLite harus selesai dalam waktu kurang dari 50 milidetik.
- **Kemandirian Jaringan**: 100% alur kerja inti (membuat aset, mencatat odometer, mematikan reminder, melihat riwayat) dapat dioperasikan saat perangkat dalam Airplane Mode.
- **Kapasitas Penyimpanan**: Ukuran basis data lokal Drift dioptimalkan agar tidak melebihi 25MB untuk penggunaan 1.000 log perawatan.

### 8.3 Internasionalisasi & Lokalisasi (i18n / l10n)
- Aplikasi mendukung dua bahasa awal: **Bahasa Indonesia** (`id`) dan **Bahasa Inggris** (`en`).
- Format tanggal, pemisah desimal, dan mata uang mengikuti konfigurasi `locale` aktif pada perangkat pengguna (misal: format `dd/MM/yyyy` dan `Rp` untuk Indonesia).

### 8.4 Penanganan Zona Waktu Dinamis (Dynamic Timezone)
- Tanggal jatuh tempo reminder berbasis waktu disimpan dalam bentuk representasi kalender murni (`date`) atau UTC timestamp dengan offset.
- Pustaka `timezone` mendeteksi perubahan lokasi pengguna dan menjadwalkan ulang notifikasi lokal agar alarm berbunyi pada jam yang sama di lokasi baru (misal: jam 09.00 WIB tetap jam 09.00 WITA saat pengguna bepergian).

### 8.5 Privasi Data & Retensi
- Tidak mengumpulkan telemetri invasif yang merekam data sensitif seperti nomor rangka kendaraan, alamat rumah, atau nominal biaya pribadi.
- Pengguna memiliki hak mutlak untuk menghapus akun dan seluruh data terkait secara instan (*Right to be Forgotten*).

---

## 9. Matriks Kesiapan & Kriteria Keberhasilan (Acceptance Matrix)

| Kriteria | Tolok Ukur Keberhasilan | Metode Verifikasi |
| :--- | :--- | :--- |
| **Kelengkapan Dokumen** | Seluruh persona, use case, user story, 3 engine reminder, batas scope, dan NFR terdokumentasi tuntas. | Tinjauan sejawat (*Peer review*) & checklist AC. |
| **Isolasi Arsitektur** | Nol dependensi ke Rootin Web; skema dan backend berdiri sendiri. | Audit referensi kode & konfigurasi Supabase. |
| **Akurasi Recurrence** | Aturan kabisat dan clamping akhir bulan terdefinisi dengan algoritma yang teruji tanpa ambiguitas. | Spesifikasi rumus matematika & contoh uji kasus ekstrem. |
| **Ketegasan Scope** | Batas MVP Beta vs Post-MVP dinyatakan secara eksplisit pada setiap modul. | Tabel pemetaan tiket M000-M027. |
| **Status Hipotesis Monetisasi** | Batasan Free vs Pro dinyatakan sebagai hipotesis pengujian pasar yang non-destruktif. | Penegasan klausul downgrade dan penafian hipotesis. |

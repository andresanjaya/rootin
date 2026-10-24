# Sistem Desain Mobile Rootin (Rootin Mobile Design System & Tokens)
## Material 3 Kustom & Adaptasi Native iOS/Android

* **Status**: Approved / Design Baseline RFC
* **Tanggal**: 2026-10-24
* **Tiket Referensi**: ROOTIN-M005 (GitHub Issue [#4](https://github.com/andresanjaya/rootin/issues/4))
* **Target Implementasi**: ROOTIN-M006 (User Profile), ROOTIN-M007 (Item Management & App Scaffold), ROOTIN-M008 s/d M027
* **Framework Acuan**: Flutter 3.x+ (Dart 3.x+) | Material Design 3 (M3) Kustom & Cupertino Adaptive

---

## 1. Ringkasan Eksekutif & Prinsip Desain

Sistem Desain Mobile Rootin (**Rootin Mobile Design System**) adalah fondasi visual dan interaktif resmi untuk aplikasi mobile Rootin (iOS dan Android). Sistem ini dirancang secara murni dari nol (*greenfield*) untuk mendukung arsitektur **offline-first**, memastikan keterbacaan tinggi di berbagai kondisi pencahayaan fisik (misalnya bengkel atau ruang bawah tanah), menjamin aksesibilitas universal (WCAG 2.1 AA/AAA), serta mengutamakan kenyamanan penggunaan satu tangan (*one-handed ergonomics*).

### 1.1 Tiga Pilar Filosofi Desain Rootin

1. **Kejelasan Tanpa Kompromi (*Clarity & Purpose-Driven Visuals*)**:
   - Setiap elemen warna, ketebalan tipografi, dan elevasi memiliki makna semantik fungsional.
   - Status pemeliharaan aset (sehat, mendekati jatuh tempo, lewat jatuh tempo) dikomunikasikan secara instan melalui kombinasi warna kontras tinggi, ikonografi eksplisit, dan teks deskriptif, bukan hanya mengandalkan persepsi warna (*color-alone prevention*).
2. **Kesiapan Offline & Nol Latensi Antarmuka (*Zero-Latency Offline-First*)**:
   - Tidak bergantung pada aset daring, CDN pihak ketiga, stylesheet web, atau font eksternal yang diunduh saat runtime. Seluruh token, ikon, dan keluarga font mengandalkan paket lokal atau font sistem native (*platform system fonts*).
   - Seluruh interaksi mikro (penambahan counter `+1`, input odometer, toggle) memberikan umpan balik visual dan haptik seketika (< 16 ms) sebelum transaksi disk lokal terselesaikan.
3. **Harmonisasi Native Lintas Platform (*Adaptive Platform Parity*)**:
   - Mengadopsi prinsip Material 3 kustom sebagai basis estetika inti, dengan adaptasi cerdas terhadap konvensi interaksi iOS (Cupertino) seperti gestur geser tepi (*interactive swipe-back*), pemilih tanggal berbasis putaran roda (*scroll wheel picker*), dan bilah navigasi dengan efek buram tembus pandang (*vibrancy blur*).

---

## 2. Token Desain (Design Tokens)

Token desain adalah nilai atomik terkecil yang mendefinisikan identitas visual Rootin Mobile. Token ini diterjemahkan langsung ke dalam struktur `ThemeData`, `ColorScheme`, dan `ThemeExtension` di Flutter.

### 2.1 Palet Warna Merek (Brand Colors)

Palet merek Rootin merefleksikan keandalan, ketelitian teknis, dan ekosistem pemeliharaan yang berakar pada kesegaran alam:

| Token Merek | Nilai Hex | Peran & Deskripsi |
| :--- | :--- | :--- |
| `brand-primary` | `#1B5E20` | **Forest Green 900**: Warna identitas utama. Mengesankan stabilitas, daya tahan aset, dan kepercayaan. Digunakan pada komponen utama, AppBar, dan tombol primer. |
| `brand-secondary` | `#00897B` | **Teal / Mint Dark**: Warna aksen pendukung. Digunakan pada kontainer interaktif sekunder, filter chips, dan elemen seleksi aktif. |
| `brand-tertiary` | `#10B981` | **Emerald Green**: Warna penanda keberhasilan dan kondisi aset sehat (*Healthy/Success*). |
| `brand-accent` | `#FF9800` | **Vibrant Amber/Orange**: Warna penarik atensi. Digunakan untuk indikator perhatian, jatuh tempo mendekat (*Warning*), dan penanda peringatan. |
| `brand-error` | `#BA1A1A` | **Crimson Red**: Warna peringatan kritis, status lewat jatuh tempo (*Overdue*), dan aksi destruktif permanen. |

#### Palet Warna Netral (Neutral Grey Palette)

Palet netral digunakan untuk latar belakang, permukaan kartu, garis pemisah (*dividers*), dan hierarki teks:

```
[#FAFAFA] Grey 50  - Latar Belakang Layar (Light Mode)
[#F5F5F5] Grey 100 - Kontainer Permukaan Rendah
[#EEEEEE] Grey 200 - Garis Batas / Divider Tipis
[#E0E0E0] Grey 300 - Border Input Normal & Placeholder
[#BDBDBD] Grey 400 - Ikon Nonaktif & Teks Disabled
[#9E9E9E] Grey 500 - Border Komponen Netral
[#757575] Grey 600 - Teks Sekunder / Helper Text (Light)
[#616161] Grey 700 - Teks Sekunder Kontras Tinggi
[#424242] Grey 800 - Permukaan Kartu Elevated (Dark Mode)
[#212121] Grey 900 - Teks Utama / Judul (Light Mode)
[#121212] Grey 950 - Latar Belakang Layar (Dark Mode)
```

---

### 2.2 Skema Warna Material 3: Terang & Gelap (Light & Dark Color Schemes)

Skema warna di bawah dipetakan langsung ke atribut `ColorScheme` Flutter Material 3, lengkap dengan verifikasi rasio kontras terhadap latar belakangnya sesuai standar **WCAG 2.1 AA (minimal 4.5:1 untuk teks normal, 3.0:1 untuk teks besar/komponen)** dan **WCAG 2.1 AAA (minimal 7.0:1)**.

#### A. Skema Warna Terang (Light Mode ColorScheme)

| Token M3 Flutter | Nilai Hex | Dipasangkan Dengan | Rasio Kontras | Standar WCAG | Penggunaan Utama |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `primary` | `#1B5E20` | `onPrimary` (`#FFFFFF`) | 7.91:1 | **WCAG AAA** | Tombol primer, tab bar aktif, toggle switch on |
| `onPrimary` | `#FFFFFF` | `primary` (`#1B5E20`) | 7.91:1 | **WCAG AAA** | Teks dan ikon di atas permukaan primary |
| `primaryContainer` | `#A3F2A7` | `onPrimaryContainer` (`#002105`) | 12.35:1 | **WCAG AAA** | Badge aktif, pill indicator navigation bar |
| `onPrimaryContainer`| `#002105` | `primaryContainer` (`#A3F2A7`)| 12.35:1 | **WCAG AAA** | Teks/ikon pada kontainer primary |
| `secondary` | `#006A60` | `onSecondary` (`#FFFFFF`) | 5.24:1 | **WCAG AA** | Tombol filter, action chips aktif |
| `onSecondary` | `#FFFFFF` | `secondary` (`#006A60`) | 5.24:1 | **WCAG AA** | Teks/ikon di atas permukaan secondary |
| `secondaryContainer`| `#9CF2E4` | `onSecondaryContainer` (`#00201C`)| 13.10:1 | **WCAG AAA** | Highlight filter kategori, badge jenis pengingat |
| `onSecondaryContainer`| `#00201C`| `secondaryContainer` (`#9CF2E4`)| 13.10:1 | **WCAG AAA**| Teks pada kontainer secondary |
| `tertiary` | `#8C5000` | `onTertiary` (`#FFFFFF`) | 5.48:1 | **WCAG AA** | Peringatan status amber kontras tinggi |
| `onTertiary` | `#FFFFFF` | `tertiary` (`#8C5000`) | 5.48:1 | **WCAG AA** | Teks di atas warna aksen amber |
| `tertiaryContainer`| `#FFDCC1` | `onTertiaryContainer` (`#2E1500`)| 13.40:1 | **WCAG AAA** | Kontainer peringatan jadwal mendekat |
| `onTertiaryContainer`| `#2E1500`| `tertiaryContainer` (`#FFDCC1`)| 13.40:1 | **WCAG AAA**| Teks judul peringatan jadwal mendekat |
| `error` | `#BA1A1A` | `onError` (`#FFFFFF`) | 5.86:1 | **WCAG AA** | Indikator overdue, input error, dialog hapus |
| `onError` | `#FFFFFF` | `error` (`#BA1A1A`) | 5.86:1 | **WCAG AA** | Teks di atas warna error |
| `errorContainer` | `#FFDAD6` | `onErrorContainer` (`#410002`) | 12.94:1 | **WCAG AAA** | Latar belakang kartu overdue, banner kritis |
| `onErrorContainer` | `#410002` | `errorContainer` (`#FFDAD6`) | 12.94:1 | **WCAG AAA** | Teks peringatan overdue di dalam kartu |
| `surface` | `#FAFAFA` | `onSurface` (`#1A1C19`) | 16.48:1 | **WCAG AAA** | Latar belakang scaffold layar dan kartu datar |
| `onSurface` | `#1A1C19` | `surface` (`#FAFAFA`) | 16.48:1 | **WCAG AAA** | Teks utama judul dan konten body |
| `surfaceVariant` | `#E0E4DB` | `onSurfaceVariant` (`#43483F`) | 5.12:1 | **WCAG AA** | Kontainer input text field, outline cards |
| `onSurfaceVariant`| `#43483F` | `surfaceVariant` (`#E0E4DB`) | 5.12:1 | **WCAG AA** | Teks bantuan (helper), label sekunder, caption |
| `outline` | `#73796E` | `surface` (`#FAFAFA`) | 4.60:1 | **WCAG AA** | Border input field normal, pemisah kartu |
| `outlineVariant` | `#C3C8BC` | `surface` (`#FAFAFA`) | 1.82:1 | Elemen UI Dekoratif | Garis pemisah tipis (*dividers*), hairline inset |
| `inverseSurface` | `#2F312D` | `onInverseSurface` (`#F1F1EB`)| 11.20:1 | **WCAG AAA** | Latar belakang SnackBar melayang |
| `onInverseSurface`| `#F1F1EB` | `inverseSurface` (`#2F312D`) | 11.20:1 | **WCAG AAA** | Teks konten di dalam SnackBar |
| `inversePrimary` | `#88D68D` | `inverseSurface` (`#2F312D`) | 6.80:1 | **WCAG AA** | Tombol aksi (Undo) di dalam SnackBar |

#### B. Skema Warna Gelap (Dark Mode ColorScheme)

| Token M3 Flutter | Nilai Hex | Dipasangkan Dengan | Rasio Kontras | Standar WCAG | Penggunaan Utama |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `primary` | `#88D68D` | `onPrimary` (`#00390E`) | 10.45:1 | **WCAG AAA** | Tombol primer pada tema gelap |
| `onPrimary` | `#00390E` | `primary` (`#88D68D`) | 10.45:1 | **WCAG AAA** | Teks di atas tombol primary gelap |
| `primaryContainer` | `#005318` | `onPrimaryContainer` (`#A3F2A7`)| 6.20:1 | **WCAG AA** | Kontainer aktif dan badge pengingat gelap |
| `onPrimaryContainer`| `#A3F2A7`| `primaryContainer` (`#005318`)| 6.20:1 | **WCAG AA** | Teks pada kontainer primary gelap |
| `secondary` | `#80D5C8` | `onSecondary` (`#003731`) | 9.85:1 | **WCAG AAA** | Filter chip aktif pada tema gelap |
| `onSecondary` | `#003731` | `secondary` (`#80D5C8`) | 9.85:1 | **WCAG AAA** | Teks di atas warna secondary gelap |
| `secondaryContainer`| `#004F47` | `onSecondaryContainer` (`#9CF2E4`)| 6.45:1 | **WCAG AA** | Highlight pill navigation bar gelap |
| `onSecondaryContainer`| `#9CF2E4`| `secondaryContainer` (`#004F47`)| 6.45:1 | **WCAG AA**| Teks pada kontainer secondary gelap |
| `tertiary` | `#FFB77C` | `onTertiary` (`#4B2800`) | 8.70:1 | **WCAG AAA** | Warna status warning pada tema gelap |
| `onTertiary` | `#4B2800` | `tertiary` (`#FFB77C`) | 8.70:1 | **WCAG AAA** | Teks di atas warna aksen amber gelap |
| `tertiaryContainer`| `#6B3B00` | `onTertiaryContainer` (`#FFDCC1`)| 6.10:1 | **WCAG AA** | Kontainer peringatan jatuh tempo gelap |
| `onTertiaryContainer`| `#FFDCC1`| `tertiaryContainer` (`#6B3B00`)| 6.10:1 | **WCAG AA**| Teks pada kontainer peringatan gelap |
| `error` | `#FFB4AB` | `onError` (`#690005`) | 9.20:1 | **WCAG AAA** | Indikator overdue dan galat pada tema gelap |
| `onError` | `#690005` | `error` (`#FFB4AB`) | 9.20:1 | **WCAG AAA** | Teks di atas tombol galat gelap |
| `errorContainer` | `#93000A` | `onErrorContainer` (`#FFDAD6`)| 6.50:1 | **WCAG AA** | Latar belakang kartu overdue tema gelap |
| `onErrorContainer` | `#FFDAD6` | `errorContainer` (`#93000A`) | 6.50:1 | **WCAG AA** | Teks peringatan overdue tema gelap |
| `surface` | `#121411` | `onSurface` (`#E1E3DE`) | 14.80:1 | **WCAG AAA** | Latar belakang layar scaffold tema gelap |
| `onSurface` | `#E1E3DE` | `surface` (`#121411`) | 14.80:1 | **WCAG AAA** | Teks utama judul dan paragraf tema gelap |
| `surfaceVariant` | `#43483F` | `onSurfaceVariant` (`#C3C8BC`) | 5.30:1 | **WCAG AA** | Kontainer input field & card border gelap |
| `onSurfaceVariant`| `#C3C8BC` | `surfaceVariant` (`#43483F`) | 5.30:1 | **WCAG AA** | Teks keterangan bantuan (helper) tema gelap |
| `outline` | `#8D9387` | `surface` (`#121411`) | 5.80:1 | **WCAG AA** | Garis batas input field dan kartu tema gelap |
| `outlineVariant` | `#43483F` | `surface` (`#121411`) | 2.10:1 | Elemen UI Dekoratif | Garis pemisah halus tema gelap |
| `inverseSurface` | `#E1E3DE` | `onInverseSurface` (`#2F312D`)| 10.90:1 | **WCAG AAA** | Latar belakang SnackBar pada tema gelap |
| `onInverseSurface`| `#2F312D` | `inverseSurface` (`#E1E3DE`) | 10.90:1 | **WCAG AAA** | Teks SnackBar pada tema gelap |
| `inversePrimary` | `#1B5E20` | `inverseSurface` (`#E1E3DE`) | 7.20:1 | **WCAG AAA** | Tombol aksi SnackBar pada tema gelap |

---

### 2.3 Token Warna Semantik Status (Semantic Status Colors)

Untuk mencerminkan 4 status esensial siklus perawatan barang dan reminder (Healthy, Warning, Overdue, dan Neutral/Archived), Rootin mendefinisikan set warna semantik khusus yang diinjeksikan melalui `ThemeExtension<RootinStatusColors>`.

```
+---------------------------------------------------------------------------------------+
| Status Semantik | Kondisi Bisnis & Pemicu                        | Light (Hex)        | Dark (Hex)         |
+-----------------+------------------------------------------------+--------------------+--------------------+
| HEALTHY         | Aman: Pemakaian < 80%, Sisa Jarak > 500 km,    | Base: #1B5E20      | Base: #88D68D      |
|                 | Tanggal > 7 hari mendatang, Sync normal        | Box:  #E8F5E9      | Box:  #00390E      |
|                 |                                                | Text: #00390E      | Text: #C8E6C9      |
+-----------------+------------------------------------------------+--------------------+--------------------+
| WARNING         | Waspada: Pemakaian 80%-99%, Sisa 1-500 km,     | Base: #E65100      | Base: #FFB77C      |
|                 | Jatuh tempo dlm 7 hari, Outbox pending         | Box:  #FFF3E0      | Box:  #4E2600      |
|                 |                                                | Text: #4E2600      | Text: #FFE0B2      |
+-----------------+------------------------------------------------+--------------------+--------------------+
| OVERDUE         | Kritis: Pemakaian >= 100%, Sisa Jarak <= 0 km, | Base: #BA1A1A      | Base: #FFB4AB      |
|                 | Jatuh tempo terlewati, Hapus permanen          | Box:  #FFEBEE      | Box:  #690005      |
|                 |                                                | Text: #5B0004      | Text: #FFCDD2      |
+-----------------+------------------------------------------------+--------------------+--------------------+
| NEUTRAL /       | Ditunda (Snoozed), Barang Diarsipkan,          | Base: #546E7A      | Base: #B0BEC5      |
| SNOOZED         | Tidak ada reminder aktif, Riwayat selesai      | Box:  #ECEFF1      | Box:  #263238      |
|                 |                                                | Text: #263238      | Text: #ECEFF1      |
+---------------------------------------------------------------------------------------+
```

---

### 2.4 Skala Tipografi (Typography Scale) & Fallback Sistem

Tipografi Rootin Mobile mengikuti hierarki Material 3 dengan penyesuaian khusus kenyamanan baca teks teknis (seperti angka odometer, nomor plat, dan interval tanggal).

#### Prinsip Nol Ketergantungan Eksternal (*Zero-External-Font Policy*)
Untuk menjamin aplikasi **100% siap offline** tanpa lonjakan visual (*cumulative layout shift*) saat pertama kali dibuka tanpa internet:
- **Android**: Menggunakan font sistem bawaan **Roboto** (`sans-serif`).
- **iOS**: Menggunakan font sistem bawaan Apple **San Francisco (SF Pro Text / SF Pro Display)**.
- Konfigurasi `TextTheme` di Flutter diatur secara adaptif membaca platform tanpa mengimpor paket `google_fonts` yang memerlukan unduhan jaringan.

#### Tabel Skala Tipografi Lengkap:

| Skala Tipografi | Ukuran (sp) | Berat (Weight) | Jarak Garis (Line Height) | Spasi Karakter (Letter Spacing) | Konteks Penggunaan di Rootin |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `displayLarge` | 57 sp | Regular (400) | 64 sp (1.12x) | -0.25 sp | Layar promosi onboarding nilai tambah |
| `displayMedium`| 45 sp | Regular (400) | 52 sp (1.15x) | 0.00 sp | Angka metrik ringkasan odometer besar |
| `displaySmall` | 36 sp | Regular (400) | 44 sp (1.22x) | 0.00 sp | Angka countdown hari jatuh tempo |
| `headlineLarge`| 32 sp | SemiBold (600) | 40 sp (1.25x) | 0.00 sp | Judul layar utama (AppBar Large Title iOS) |
| `headlineMedium`| 28 sp | SemiBold (600) | 36 sp (1.28x) | 0.00 sp | Judul lembar bawah (*BottomSheet Header*) |
| `headlineSmall`| 24 sp | Medium (500) | 32 sp (1.33x) | 0.00 sp | Judul grup kategori & dialog modal |
| `titleLarge` | 22 sp | SemiBold (600) | 28 sp (1.27x) | 0.00 sp | Judul kartu reminder & kartu barang |
| `titleMedium` | 16 sp | Medium (500) | 24 sp (1.50x) | +0.15 sp | Sub-judul bagian & input field header |
| `titleSmall` | 14 sp | Bold (700) | 20 sp (1.43x) | +0.10 sp | Label filter tab & teks penegas kartu |
| `bodyLarge` | 16 sp | Regular (400) | 24 sp (1.50x) | +0.50 sp | Teks utama deskripsi, catatan log servis |
| `bodyMedium` | 14 sp | Regular (400) | 20 sp (1.43x) | +0.25 sp | Keterangan atribut sekunder (merk, seri) |
| `bodySmall` | 12 sp | Regular (400) | 16 sp (1.33x) | +0.40 sp | Timestamp audit (*last sync*, format tanggal) |
| `labelLarge` | 14 sp | SemiBold (600) | 20 sp (1.43x) | +0.10 sp | Teks tombol utama (*FilledButton, Outlined*) |
| `labelMedium` | 12 sp | SemiBold (600) | 16 sp (1.33x) | +0.50 sp | Label badge status (*Overdue, Warning, Done*) |
| `labelSmall` | 11 sp | Medium (500) | 16 sp (1.45x) | +0.50 sp | Keterangan unit odometer (km / mil), chip tag |

---

### 2.5 Spasi, Grid, Radius & Elevasi

#### A. Skala Spasi (Spacing Scale)
Sistem spasi berbasis kelipatan 4dp / 8dp yang memandu konsistensi ritme vertikal dan horizontal:

| Token Spasi | Nilai (dp) | Penggunaan Acuan |
| :--- | :--- | :--- |
| `space-xxs` | 2 dp | Hairline gap, micro badge padding |
| `space-xs` | 4 dp | Spasi antar ikon dan label kecil, padding chip internal |
| `space-sm` | 8 dp | Jarak vertikal antar baris teks terkait, gap tombol mini |
| `space-md` | 12 dp | Padding internal kartu ringkas, spasi horizontal form |
| `space-lg` | 16 dp | **Default Screen Padding**: Margin tepi layar kiri & kanan |
| `space-xl` | 20 dp | Jarak pemisah antar seksi konten di layar detail |
| `space-2xl` | 24 dp | Jarak antar kartu vertikal pada list, padding bottom sheet |
| `space-3xl` | 32 dp | Jarak pemisah antar grup formulir bertingkat |
| `space-4xl` | 40 dp | Margin atas layar pada state kosong (*empty state*) |
| `space-5xl` | 48 dp | Tinggi target interaktif minimum (*safe touch zone*) |
| `space-6xl` | 64 dp | Padding dasar di atas floating navigation bar |

#### B. Skala Kelengkungan Sudut (Corner Radius)

| Token Radius | Nilai (dp) | Bentuk & Komponen Terkait |
| :--- | :--- | :--- |
| `radius-xs` | 4 dp | Indikator progress bar linier, hairline tooltip |
| `radius-sm` | 8 dp | Action chips, filter tags, secondary mini buttons |
| `radius-md` | 12 dp | **Standard Input Field**, kartu pengingat (`ReminderCard`) |
| `radius-lg` | 16 dp | Kartu barang (`ItemCard`), thumbnail foto, Dialog Box |
| `radius-xl` | 24 dp | Sudut atas Modal Bottom Sheet, Floating Action Button (FAB) |
| `radius-full` | 999 dp | Pill status indicator, Circular Avatar, Tombol aksi `+1` |

#### C. Elevasi & Bayangan Material 3 (Elevation & Shadows)

Material 3 menggunakan perpaduan **Surface Tint Color** (pergeseran warna permukaan berdasarkan elevasi) dan bayangan lembut (*ambient & key shadows*):

| Level Elevasi | Ketinggian | Surface Tint (Light) | Surface Tint (Dark) | Komponen Acuan |
| :--- | :--- | :--- | :--- | :--- |
| **Level 0** | 0 dp | 0% Tint (`#FAFAFA`) | 0% Tint (`#121411`) | Scaffold Background, Kartu Berbingkai (*OutlinedCard*) |
| **Level 1** | 1 dp | 5% Primary Tint | 5% Primary Tint | Kartu Tugas Standar, Search Bar Mengambang |
| **Level 2** | 3 dp | 8% Primary Tint | 8% Primary Tint | Small FAB, Tombol Mengambang Terangkat |
| **Level 3** | 6 dp | 11% Primary Tint | 11% Primary Tint | Standard FAB, Modal Bottom Sheet, Menu Dropdown |
| **Level 4** | 8 dp | 12% Primary Tint | 12% Primary Tint | Bottom Navigation Bar M3, Contextual Action Bar |
| **Level 5** | 12 dp| 14% Primary Tint | 14% Primary Tint | Destructive Confirmation Dialog, Date Picker Modal |

---

### 2.6 Gerak & Animasi (Motion, Durations & Easing)

Rootin Mobile menggunakan animasi fungsional untuk mengarahkan atensi pengguna tanpa memperlambat alur kerja operasional.

#### A. Skala Durasi Animasi
- **Fast (`150 ms`)**: Interaksi mikro instan (efek tekan tombol, seleksi checkbox, lonjakan animasi counter `+1`, haptic sync).
- **Standard (`250 ms`)**: Transisi komponen lokal (pembukaan modal bottom sheet, ekspansi kartu filter, pergantian tab bar).
- **Emphasized (`350 ms`)**: Transisi layar penuh (*route transition*), transisi dialog konfirmasi bertingkat, perpindahan visual layout besar.

#### B. Kurva Easing (Motion Curves)
- **Standard Curve (`Curves.easeInOutCubic`)**: Untuk elemen yang sudah berada di layar dan berpindah posisi.
- **Decelerate / Entrance Curve (`Curves.easeOutCubic`)**: Untuk elemen yang masuk ke area pandang (misal Bottom Sheet naik dari bawah).
- **Accelerate / Exit Curve (`Curves.easeInCubic`)**: Untuk elemen yang keluar dari area pandang (misal penutupan sheet).
- **Emphasized Curve (`Curves.fastEaseInToSlowEaseOut`)**: Untuk animasi transisi halaman navigasi `go_router`.

#### C. Penanganan Pengurangan Gerakan (*Reduced Motion Handling*)
Mematuhi standar aksesibilitas bagi pengguna dengan gangguan vestibular (*vestibular disorders*):
```dart
// Aturan global adaptasi gerakan:
final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
final Duration effectiveDuration = disableAnimations ? Duration.zero : AppMotion.durationStandard;
```
Jika `disableAnimations` bernilai `true`, seluruh transisi animasi dihilangkan seketika (*instant jump cut*) atau digantikan dengan *fade* lembut tanpa translasi spasial.

---

## 3. Spesifikasi Komponen & Matriks Status (Component State Matrix)

Setiap komponen diuji terhadap 5 kondisi interaksi esensial: **Default/Normal**, **Pressed/Active**, **Focused/Hover**, **Disabled**, dan **Loading/In-Progress**.

### 3.1 Spesifikasi Tombol (Buttons)

Seluruh tombol interaktif wajib memenuhi target sentuh minimum **48 x 48 dp**.

```
+---------------------------------------------------------------------------------------------------------+
| Tipe Tombol        | Normal/Default          | Pressed/Active          | Disabled          | Loading    |
+--------------------+-------------------------+-------------------------+-------------------+------------+
| 1. FilledButton    | Bg: primary (#1B5E20)   | Bg: primaryContainer    | Bg: Grey 300      | Bg: primary|
|    (Tombol Primer) | Fg: onPrimary (#FFFFFF) | Fg: onPrimaryContainer  | Fg: Grey 500      | Spinner:   |
|                    | Elevasi: 0 dp           | Elevasi: 1 dp           | Klik: Diabaikan   | 20dp putih |
+--------------------+-------------------------+-------------------------+-------------------+------------+
| 2. OutlinedButton  | Bg: Transparan          | Bg: primaryContainer 10%| Border: Grey 300  | Spinner:   |
|    (Sekunder)      | Border: 1.5dp primary   | Border: primary         | Fg: Grey 400      | 20dp hijau |
|                    | Fg: primary             | Fg: primary             |                   |            |
+--------------------+-------------------------+-------------------------+-------------------+------------+
| 3. TextButton      | Bg: Transparan          | Bg: primaryContainer 15%| Fg: Grey 400      | Spinner    |
|    (Tersier/Batal) | Fg: primary             | Fg: primary             | Klik: Diabaikan   | 16dp hijau |
+--------------------+-------------------------+-------------------------+-------------------+------------+
| 4. DestructiveBtn  | Bg: error (#BA1A1A)     | Bg: #93000A             | Bg: Grey 300      | Spinner    |
|    (Hapus Permanen)| Fg: onError (#FFFFFF)   | Fg: onError (#FFFFFF)   | Fg: Grey 500      | 20dp putih |
+--------------------+-------------------------+-------------------------+-------------------+------------+
| 5. FAB (Primary)   | Bg: primaryContainer    | Bg: primary (terbalik)  | N/A (Selalu aktif)| Spinner    |
|    (Ukuran 56x56)  | Fg: onPrimaryContainer  | Elevasi: 8 dp           |                   | mini 24dp  |
+---------------------------------------------------------------------------------------------------------+
```

---

### 3.2 Spesifikasi Input Formulir (Form Inputs)

#### A. Input Teks Standar (`TextField / TextFormField`)
- **Tinggi Kontainer**: 56 dp (memenuhi batas target sentuh minimum).
- **Radius Sudut**: `radius-md` (12 dp).
- **Garis Batas (Border)**:
  - *Default*: 1 dp warna `outline` (`#73796E`).
  - *Focused*: 2 dp warna `primary` (`#1B5E20`).
  - *Error*: 2 dp warna `error` (`#BA1A1A`) dengan pesan error di bawah input (tipografi `bodySmall`).
  - *Disabled*: 1 dp warna `outlineVariant` (`#C3C8BC`), teks `onSurfaceVariant` dengan opasitas 38%.
- **Ikon Pelengkap**: Prefix icon untuk kategori/jenis input, suffix icon untuk membersihkan input (*clear text*) atau toggle visibilitas sandi.

#### B. Pengontrol Angka Pemakaian (`NumberCounterTile`)
Komponen aksi cepat penambahan pemakaian aset (misal: filter air, blender) yang dirancang untuk dieksekusi dengan satu ketukan jempol:
- **Target Sentuh Tombol `+1`**: Berbentuk lingkaran berdiameter **48 x 48 dp**.
- **Respon Haptik**: Menjalankan `HapticFeedback.lightImpact()` segera saat tombol tersentuh.
- **Animasi Visual**: Nilai angka counter membesar dengan faktor skala 1.15x selama 150 ms sebelum kembali ke ukuran normal (*scale pop animation*).
- **Status Ambang Batas**: Ketika `usage_counter >= usage_threshold`, kontainer counter berubah warna seketika dari `Healthy` (hijau) menjadi `Overdue` (merah).

#### C. Input Odometer & Pemilih Satuan (`OdometerInputField`)
- **Tipe Keyboard**: `TextInputType.numberWithOptions(signed: false, decimal: false)` (hanya memunculkan numpad numerik tanpa karakter khusus).
- **Pemformatan Otomatis Ribuan**: Memasukkan separator pemisah ribuan lokal secara dinamis saat mengetik (misal: `42300` langsung terformat menjadi `42.300`).
- **Selector Satuan Terintegrasi**: Segmented button di sebelah kanan input dengan pilihan `KM` (Kilometer) dan `MIL` (Mil). Nilai default: `KM`.
- **Indikator Delta Otomatis**: Menampilkan teks perhitungan selisih penambahan jarak secara *real-time* di bawah input: `-> Penambahan: +1.550 km`.
- **Validasi Nilai Mundur**: Jika angka yang dimasukkan lebih kecil dari nilai odometer sebelumnya, border berubah warna menjadi `Warning` (Amber `#FF9800`) dan memunculkan konfirmasi eksplisit penggantian spedometer.

#### D. Pemilih Tanggal & Waktu Adaptif (Adaptive Date/Time Pickers)
- **Platform Android (Material 3)**:
  - Menggunakan `showDatePicker` dan `showTimePicker` bertema Material 3 dengan warna header `primary` (`#1B5E20`) dan kalender modular.
- **Platform iOS (Cupertino)**:
  - Menggunakan modal bottom sheet yang memuat `CupertinoDatePicker` dengan mode pemilih putar roda (*scroll wheel*).
- **Format Tanggal Baku**: Output tanggal selalu diselaraskan ke format standar domain `YYYY-MM-DD` dan jam `HH:mm`.

---

### 3.3 Kartu & Baris Daftar (Cards & List Rows)

#### A. Kartu Pengingat (`ReminderCard`)
Komponen paling penting dalam Rootin Mobile. Mendukung 3 varian mesin pengingat:

```
+-----------------------------------------------------------------------+
| [Ikon Mesin] Ganti Oli Mesin Sintetik                [Badge: Overdue] |
| Toyota Avanza (B 1234 CD)                            Terlambat 3 hari |
+-----------------------------------------------------------------------+
| Target: 40.000 km | Saat Ini: 41.550 km                               |
| [====================================!           ] 103% (Lewat Batas) |
+-----------------------------------------------------------------------+
| [ Aksi Geser: Kanan -> Tunda (Snooze) | Kiri -> Tandai Selesai ]      |
| [ Tombol: Update Odo ]                             [ Tombol: Selesai ]|
+-----------------------------------------------------------------------+
```

1. **Badge 3 Tipe Mesin Pengingat**:
   - *Mesin Waktu (Time-Based)*: Ikon Jam Kalender (`Icons.schedule_rounded`), label `Waktu`.
   - *Mesin Pemakaian (Usage-Based)*: Ikon Counter Perulangan (`Icons.repeat_rounded`), label `Pemakaian`.
   - *Mesin Jarak Tempuh (Mileage-Based)*: Ikon Spedometer Odometer (`Icons.speed_rounded`), label `Jarak Tempuh`.
2. **Indikator Progres Visual (Visual Progress Bar)**:
   - Ketebalan bar 8 dp dengan ujung membulat (`radius-xs`).
   - Warna bar reaktif:
     - `0% s/d 79%`: Hijau Semantik (`#1B5E20`).
     - `80% s/d 99%`: Oranye Semantik (`#E65100`).
     - `>= 100%`: Merah Semantik (`#BA1A1A`).
3. **Gestur Kartu**:
   - *Ketuk Normal*: Masuk ke rute rincian `/reminders/:id`.
   - *Geser ke Kanan (Swipe Right)*: Membuka opsi Snooze (+1 Hari, +3 Hari, +1 Minggu).
   - *Geser ke Kiri (Swipe Left)*: Membuka lembar penyelesaian siklus (*Complete Sheet*).
   - *Tekan Lama (Long-Press)*: Memunculkan menu kontekstual cepat (Edit, Arsipkan, Hapus).

#### B. Kartu Profil Barang (`ItemCard`)
- **Thumbnail Foto Privat**:
  - Dimensi kotak rasio 1:1 (72 x 72 dp), radius `radius-md` (12 dp).
  - *Placeholder Default*: Jika pengguna belum mengunggah foto fisik, sistem merender kontainer berlatar `surfaceVariant` dengan ikon kategori aset SVG/IconData berukuran 36 dp (Kendaraan: `Icons.directions_car`, Elektronik: `Icons.tv`, Fasilitas: `Icons.home_repair_service`).
- **Blok Ringkasan Odometer**:
  - Khusus barang dengan `has_odometer: true`, kartu menampilkan meteran angka dengan font semi-bold dan badge satuan unit `KM`.
- **Indikator Reminder Aktif**:
  - Badge angka berbentuk pill di sudut kanan bawah kartu: misal `3 Pengingat Aktif`.

---

### 3.4 Cangkang Aplikasi & Navigasi (App Shell & Navigation)

#### A. Bilah Navigasi Bawah 5-Tab (Bottom Navigation Bar)
Mempertahankan riwayat stack independen untuk 5 tab utama:
1. **Hari Ini (`/today`)**: Ikon `Icons.today_rounded` (aktif: filled, nonaktif: outlined).
2. **Pengingat (`/reminders`)**: Ikon `Icons.notifications_active_rounded`.
3. **Barang (`/items`)**: Ikon `Icons.inventory_2_rounded`.
4. **Kalender (`/calendar`)**: Ikon `Icons.calendar_month_rounded`.
5. **Pengaturan (`/settings`)**: Ikon `Icons.tune_rounded`.

- **Spesifikasi Android (Material 3 `NavigationBar`)**:
  - Tinggi bilah: 80 dp.
  - Seleksi aktif ditandai kapsul (*pill indicator*) berwarna `primaryContainer` (`#A3F2A7`) di belakang ikon.
  - Elevasi Level 2 tanpa bayangan tajam.
- **Spesifikasi iOS (`CupertinoTabBar`)**:
  - Tinggi bilah: 50 dp + padding safe area bawah (*Home Indicator*).
  - Latar belakang tembus pandang kaca buram (*frosted glass blur effect*) menggunakan `BackdropFilter` sigma 20.0.
  - Ikon menggunakan padanan Apple SF Symbols dengan warna seleksi aktif `brand-primary`.

#### B. Bilah Aplikasi Atas (Top AppBar) & Indikator Sinkronisasi
- **Judul**: Sejajar kiri pada Android M3, dan mendukung transisi *Collapsing Large Title* pada iOS.
- **Badge Status Sinkronisasi Outbox (`SyncStatusBadge`)**:
  Terletak di sisi kanan AppBar sebelum avatar profil:
  - *Sinkron Penuh (Online)*: Ikon awan centang hijau lembut (`Icons.cloud_done_rounded`), tooltip *"Semua data tersinkronisasi"*.
  - *Pending Outbox (Offline / Syncing)*: Badge pill amber dengan teks counter misal `3 Pending` disertai ikon putar halus (`Icons.sync_rounded`). Mengetuk badge ini membuka dialog rincian antrean mutasi lokal.
  - *Koneksi Galat / Tertunda*: Ikon awan peringatan oranye (`Icons.cloud_off_rounded`).

---

### 3.5 Umpan Balik & Lapisan Melayang (Feedback & Overlays)

#### A. SnackBar Kontekstual dengan Tombol Batalkan (Undo)
- **Penempatan**: Mengambang (*floating*) berjarak 16 dp dari tepi bawah dan samping layar, berada tepat di atas Bottom Navigation Bar.
- **Latar Belakang**: `inverseSurface` (`#2F312D` pada tema terang) dengan teks `onInverseSurface` (`#F1F1EB`).
- **Durasi Tampil**: 5 detik penuh sebelum menutup otomatis.
- **Tombol Aksi**: Teks label `BATALKAN` (Undo) berwarna `inversePrimary` (`#88D68D`). Saat diketuk, mutasi lokal segera dibatalkan melalui transaksi rollback database Drift.

#### B. Lembar Bawah Modal (Modal BottomSheet)
- **Sudut Lengkung Atas**: 28 dp pada Material 3.
- **Bilah Pegangan (Drag Handle)**: Kapsul horizontal berukuran lebar 32 dp, tinggi 4 dp, warna `outlineVariant` di tengah atas lembar.
- **Perilaku Keyboard**: Menggunakan `isScrollControlled: true` dengan pembatasan tinggi maksimal 90% layar dan inset otomatis `EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)`.

#### C. Dialog Konfirmasi Tindakan Berisiko (Destructive Dialogs)
- **Tingkat 1-2 (Rendah - Sedang)**: Dialog modal 2 tombol (`Batal` warna netral, `Hapus` warna error).
- **Tingkat 3-4 (Tinggi - Kritis)**: Mengharuskan pengguna mengetik nama spesifik aset (misal: `"Toyota Avanza"`) atau teks konfirmasi `"HAPUS AKUN"` secara presisi pada input field sebelum tombol merah destruktif diaktifkan.

---

## 4. Aksesibilitas (A11y) & Adaptasi Platform Native

Rootin Mobile memperlakukan aksesibilitas sebagai fitur inti, bukan polesan akhir.

### 4.1 Target Sentuh Minimum (Touch Targets)
- Seluruh elemen yang dapat diketuk, digeser, atau di-toggle memiliki area batas interaktif minimal **48 x 48 dp** di Android dan **44 x 44 pt** di iOS.
- Pada elemen visual yang berukuran lebih kecil dari 48 dp (misalnya ikon titik status 12 dp atau chip tombol mikro), batas interaksi diperluas menggunakan `HitTestBehavior.opaque` dan wrapper padding tak terlihat.

### 4.2 Kompatibilitas Pembaca Layar (VoiceOver & TalkBack)
- Seluruh komponen interaktif dibungkus dengan widget `Semantics`:
  - Kartu reminder mengumumkan: *"Pengingat ganti oli motor, status terlambat 3 hari, jarak saat ini 41.550 km dari target 40.000 km, ketuk dua kali untuk rincian, geser untuk aksi tunda atau selesai"*.
  - Tombol aksi `+1` mengumumkan: *"Tambah 1 pemakaian untuk filter air dispenser, nilai saat ini 18 dari target 20"*.
  - Foto privat mengumumkan: *"Foto bukti kuitansi servis, disimpan secara lokal di perangkat"*.
- Elemen dekoratif murni (garis pemisah, ilustrasi latar) dinonaktifkan dari pohon aksesibilitas menggunakan `excludeFromSemantics: true`.

### 4.3 Skalasi Tipografi Dinamis (Dynamic Type Scaling)
- Mendukung fitur pembesaran font OS hingga skala **2.0x (200%)**.
- Layout tidak boleh menggunakan `height` tetap (*hardcoded height*) pada baris kartu yang memuat teks. Menggunakan `IntrinsicHeight` atau layout fleksibel yang dapat bertambah tinggi secara vertikal (*auto-expand*) tanpa memicu kesalahan luapan pixel (*render overflow errors*).
- Menjamin teks judul tidak terpotong (*no abrupt truncation*) pada skala 1.5x.

### 4.4 Penanganan Area Aman (Safe Area) & Penghindaran Keyboard
- Seluruh layar dibungkus secara selektif dengan `SafeArea` untuk mengkompensasi:
  - Takik layar (*Notch*) dan *Dynamic Island* pada iPhone modern.
  - Lubang kamera depan (*punch-hole*) pada perangkat Android.
  - Bilah gestur navigasi bawah (*Home Indicator Bar*) pada iOS dan Android geser.
- Layar input formulir wajib membungkus konten dalam `SingleChildScrollView` dengan parameter `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` untuk menutup keyboard secara alami saat pengguna menggulir layar.

---

## 5. Blueprint Arsitektur Teknis Flutter (Dart)

Bagian ini menyajikan kode cetak biru (*blueprint*) siap pakai yang menjadi acuan implementasi pada tiket **ROOTIN-M007** (Scaffold & Item Management).

### 5.1 Implementasi Token & ThemeExtension (`app_theme.dart`)

```dart
// lib/app/theme/rootin_status_colors.dart
import 'package:flutter/material.dart';

@immutable
class RootinStatusColors extends ThemeExtension<RootinStatusColors> {
  const RootinStatusColors({
    required this.healthy,
    required this.onHealthy,
    required this.healthyContainer,
    required this.onHealthyContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.overdue,
    required this.onOverdue,
    required this.overdueContainer,
    required this.onOverdueContainer,
    required this.neutral,
    required this.onNeutral,
    required this.neutralContainer,
    required this.onNeutralContainer,
  });

  final Color healthy;
  final Color onHealthy;
  final Color healthyContainer;
  final Color onHealthyContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color overdue;
  final Color onOverdue;
  final Color overdueContainer;
  final Color onOverdueContainer;

  final Color neutral;
  final Color onNeutral;
  final Color neutralContainer;
  final Color onNeutralContainer;

  static const light = RootinStatusColors(
    healthy: Color(0xFF1B5E20),
    onHealthy: Color(0xFFFFFFFF),
    healthyContainer: Color(0xFFE8F5E9),
    onHealthyContainer: Color(0xFF00390E),
    warning: Color(0xFFE65100),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFF3E0),
    onWarningContainer: Color(0xFF4E2600),
    overdue: Color(0xFFBA1A1A),
    onOverdue: Color(0xFFFFFFFF),
    overdueContainer: Color(0xFFFFEBEE),
    onOverdueContainer: Color(0xFF5B0004),
    neutral: Color(0xFF546E7A),
    onNeutral: Color(0xFFFFFFFF),
    neutralContainer: Color(0xFFECEFF1),
    onNeutralContainer: Color(0xFF263238),
  );

  static const dark = RootinStatusColors(
    healthy: Color(0xFF88D68D),
    onHealthy: Color(0xFF00390E),
    healthyContainer: Color(0xFF005318),
    onHealthyContainer: Color(0xFFC8E6C9),
    warning: Color(0xFFFFB77C),
    onWarning: Color(0xFF4B2800),
    warningContainer: Color(0xFF6B3B00),
    onWarningContainer: Color(0xFFFFDCC1),
    overdue: Color(0xFFFFB4AB),
    onOverdue: Color(0xFF690005),
    overdueContainer: Color(0xFF93000A),
    onOverdueContainer: Color(0xFFFFDAD6),
    neutral: Color(0xFFB0BEC5),
    onNeutral: Color(0xFF263238),
    neutralContainer: Color(0xFF37474F),
    onNeutralContainer: Color(0xFFECEFF1),
  );

  @override
  RootinStatusColors copyWith({
    Color? healthy,
    Color? onHealthy,
    Color? healthyContainer,
    Color? onHealthyContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? overdue,
    Color? onOverdue,
    Color? overdueContainer,
    Color? onOverdueContainer,
    Color? neutral,
    Color? onNeutral,
    Color? neutralContainer,
    Color? onNeutralContainer,
  }) {
    return RootinStatusColors(
      healthy: healthy ?? this.healthy,
      onHealthy: onHealthy ?? this.onHealthy,
      healthyContainer: healthyContainer ?? this.healthyContainer,
      onHealthyContainer: onHealthyContainer ?? this.onHealthyContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      overdue: overdue ?? this.overdue,
      onOverdue: onOverdue ?? this.onOverdue,
      overdueContainer: overdueContainer ?? this.overdueContainer,
      onOverdueContainer: onOverdueContainer ?? this.onOverdueContainer,
      neutral: neutral ?? this.neutral,
      onNeutral: onNeutral ?? this.onNeutral,
      neutralContainer: neutralContainer ?? this.neutralContainer,
      onNeutralContainer: onNeutralContainer ?? this.onNeutralContainer,
    );
  }

  @override
  RootinStatusColors lerp(ThemeExtension<RootinStatusColors>? other, double t) {
    if (other is! RootinStatusColors) return this;
    return RootinStatusColors(
      healthy: Color.lerp(healthy, other.healthy, t)!,
      onHealthy: Color.lerp(onHealthy, other.onHealthy, t)!,
      healthyContainer: Color.lerp(healthyContainer, other.healthyContainer, t)!,
      onHealthyContainer: Color.lerp(onHealthyContainer, other.onHealthyContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      overdue: Color.lerp(overdue, other.overdue, t)!,
      onOverdue: Color.lerp(onOverdue, other.onOverdue, t)!,
      overdueContainer: Color.lerp(overdueContainer, other.overdueContainer, t)!,
      onOverdueContainer: Color.lerp(onOverdueContainer, other.onOverdueContainer, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      onNeutral: Color.lerp(onNeutral, other.onNeutral, t)!,
      neutralContainer: Color.lerp(neutralContainer, other.neutralContainer, t)!,
      onNeutralContainer: Color.lerp(onNeutralContainer, other.onNeutralContainer, t)!,
    );
  }
}

extension RootinThemeContext on BuildContext {
  RootinStatusColors get statusColors =>
      Theme.of(this).extension<RootinStatusColors>() ?? RootinStatusColors.light;
}
```

---

### 5.2 Konfigurasi Master ThemeData (`app_theme_data.dart`)

```dart
// lib/app/theme/app_theme_data.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rootin_status_colors.dart';

class AppTheme {
  AppTheme._();

  static const Color primarySeed = Color(0xFF1B5E20);

  // Skema Terang
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.light,
    primary: const Color(0xFF1B5E20),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFA3F2A7),
    onPrimaryContainer: const Color(0xFF002105),
    secondary: const Color(0xFF006A60),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFF9CF2E4),
    onSecondaryContainer: const Color(0xFF00201C),
    tertiary: const Color(0xFF8C5000),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFFFDCC1),
    onTertiaryContainer: const Color(0xFF2E1500),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFFAFAFA),
    onSurface: const Color(0xFF1A1C19),
    surfaceVariant: const Color(0xFFE0E4DB),
    onSurfaceVariant: const Color(0xFF43483F),
    outline: const Color(0xFF73796E),
    outlineVariant: const Color(0xFFC3C8BC),
  );

  // Skema Gelap
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: Brightness.dark,
    primary: const Color(0xFF88D68D),
    onPrimary: const Color(0xFF00390E),
    primaryContainer: const Color(0xFF005318),
    onPrimaryContainer: const Color(0xFFA3F2A7),
    secondary: const Color(0xFF80D5C8),
    onSecondary: const Color(0xFF003731),
    secondaryContainer: const Color(0xFF004F47),
    onSecondaryContainer: const Color(0xFF9CF2E4),
    tertiary: const Color(0xFFFFB77C),
    onTertiary: const Color(0xFF4B2800),
    tertiaryContainer: const Color(0xFF6B3B00),
    onTertiaryContainer: const Color(0xFFFFDCC1),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF121411),
    onSurface: const Color(0xFFE1E3DE),
    surfaceVariant: const Color(0xFF43483F),
    onSurfaceVariant: const Color(0xFFC3C8BC),
    outline: const Color(0xFF8D9387),
    outlineVariant: const Color(0xFF43483F),
  );

  static ThemeData light() => _buildTheme(lightColorScheme, RootinStatusColors.light);
  static ThemeData dark() => _buildTheme(darkColorScheme, RootinStatusColors.dark);

  static ThemeData _buildTheme(ColorScheme colorScheme, RootinStatusColors statusColors) {
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [statusColors],

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.8),
        ),
        color: isDark ? const Color(0xFF1E221D) : Colors.white,
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E221D) : const Color(0xFFF5F7F3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        helperStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        errorStyle: TextStyle(color: colorScheme.error, fontSize: 12),
      ),

      // FilledButton Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // OutlinedButton Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // NavigationBar Theme
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 2,
        backgroundColor: isDark ? const Color(0xFF161A15) : Colors.white,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDark ? const Color(0xFFE1E3DE) : const Color(0xFF2F312D),
        contentTextStyle: TextStyle(
          color: isDark ? const Color(0xFF2F312D) : const Color(0xFFF1F1EB),
          fontSize: 14,
        ),
        actionTextColor: isDark ? const Color(0xFF1B5E20) : const Color(0xFF88D68D),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // BottomSheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF1E221D) : Colors.white,
        modalBackgroundColor: isDark ? const Color(0xFF1E221D) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.outlineVariant,
      ),
    );
  }
}
```

---

### 5.3 Blueprint Komponen Reusable Modular (`lib/core/widgets/`)

#### A. Tombol Adaptif dengan State Loading (`RootinButton.dart`)

```dart
// lib/core/widgets/rootin_button.dart
import 'package:flutter/material.dart';

enum RootinButtonVariant { filled, outlined, text, destructive }

class RootinButton extends StatelessWidget {
  const RootinButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = RootinButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final RootinButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    Widget childContent;
    if (isLoading) {
      final spinnerColor = variant == RootinButtonVariant.filled || variant == RootinButtonVariant.destructive
          ? Colors.white
          : theme.colorScheme.primary;
      childContent = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(spinnerColor)),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    } else {
      childContent = Text(label);
    }

    Widget button;
    switch (variant) {
      case RootinButtonVariant.filled:
        button = FilledButton(
          onPressed: isEnabled ? onPressed : null,
          child: childContent,
        );
        break;
      case RootinButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          child: childContent,
        );
        break;
      case RootinButtonVariant.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          child: childContent,
        );
        break;
      case RootinButtonVariant.destructive:
        button = FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: isEnabled ? onPressed : null,
          child: childContent,
        );
        break;
    }

    return isFullWidth
        ? SizedBox(width: double.infinity, height: 48, child: button)
        : ConstrainedBox(constraints: const BoxConstraints(minHeight: 48, minWidth: 48), child: button);
  }
}
```

#### B. Pengontrol Pemakaian Mikro `+1` (`RootinCounterTile.dart`)

```dart
// lib/core/widgets/rootin_counter_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RootinCounterTile extends StatefulWidget {
  const RootinCounterTile({
    super.key,
    required this.title,
    required this.currentCount,
    required this.threshold,
    required this.unit,
    required this.onIncrement,
  });

  final String title;
  final int currentCount;
  final int threshold;
  final String unit;
  final VoidCallback onIncrement;

  @override
  State<RootinCounterTile> createState() => _RootinCounterTileState();
}

class _RootinCounterTileState extends State<RootinCounterTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
    widget.onIncrement();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLimitReached = widget.currentCount >= widget.threshold;
    final progress = (widget.currentCount / widget.threshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLimitReached ? theme.colorScheme.errorContainer.withOpacity(0.3) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLimitReached ? theme.colorScheme.error : theme.colorScheme.outlineVariant,
          width: isLimitReached ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(
                    isLimitReached ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.currentCount} / ${widget.threshold} ${widget.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isLimitReached ? FontWeight.bold : FontWeight.normal,
                    color: isLimitReached ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Semantics(
            button: true,
            label: 'Tambah 1 pemakaian untuk ${widget.title}',
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: isLimitReached ? theme.colorScheme.error : theme.colorScheme.primaryContainer,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _handleTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      '+1',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLimitReached
                            ? theme.colorScheme.onError
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### C. Input Odometer dengan Format Ribuan & Unit Selector (`RootinOdometerInput.dart`)

```dart
// lib/core/widgets/rootin_odometer_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RootinOdometerInput extends StatefulWidget {
  const RootinOdometerInput({
    super.key,
    required this.initialOdometer,
    required this.onChanged,
    this.unit = 'KM',
    this.onUnitChanged,
  });

  final int initialOdometer;
  final ValueChanged<int> onChanged;
  final String unit;
  final ValueChanged<String>? onUnitChanged;

  @override
  State<RootinOdometerInput> createState() => _RootinOdometerInputState();
}

class _RootinOdometerInputState extends State<RootinOdometerInput> {
  late TextEditingController _controller;
  String _selectedUnit = 'KM';

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.unit;
    _controller = TextEditingController(text: _formatNumber(widget.initialOdometer));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Angka Odometer Terkini', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorInputFormatter(),
                ],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.speed_rounded),
                  hintText: 'Misal: 42.300',
                  suffixText: _selectedUnit,
                ),
                onChanged: (val) {
                  final rawNumber = int.tryParse(val.replaceAll('.', '')) ?? 0;
                  widget.onChanged(rawNumber);
                },
              ),
            ),
            const SizedBox(width: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'KM', label: Text('KM')),
                ButtonSegment(value: 'MIL', label: Text('MIL')),
              ],
              selected: {_selectedUnit},
              onSelectionChanged: (set) {
                setState(() => _selectedUnit = set.first);
                widget.onUnitChanged?.call(_selectedUnit);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll('.', '');
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

#### D. Badge Status Sinkronisasi Outbox AppBar (`RootinSyncBadge.dart`)

```dart
// lib/core/widgets/rootin_sync_badge.dart
import 'package:flutter/material.dart';

enum SyncState { synced, syncing, offlinePending, error }

class RootinSyncBadge extends StatelessWidget {
  const RootinSyncBadge({
    super.key,
    required this.state,
    this.pendingCount = 0,
    this.onTap,
  });

  final SyncState state;
  final int pendingCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color badgeBg;
    Color badgeFg;
    Widget iconWidget;
    String label;

    switch (state) {
      case SyncState.synced:
        badgeBg = theme.colorScheme.primaryContainer.withOpacity(0.5);
        badgeFg = theme.colorScheme.primary;
        iconWidget = Icon(Icons.cloud_done_rounded, size: 16, color: badgeFg);
        label = 'Tersinkron';
        break;
      case SyncState.syncing:
        badgeBg = theme.colorScheme.secondaryContainer;
        badgeFg = theme.colorScheme.secondary;
        iconWidget = SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(badgeFg)),
        );
        label = 'Menyinkronkan...';
        break;
      case SyncState.offlinePending:
        badgeBg = const Color(0xFFFFF3E0);
        badgeFg = const Color(0xFFE65100);
        iconWidget = Icon(Icons.cloud_queue_rounded, size: 16, color: badgeFg);
        label = '$pendingCount Pending';
        break;
      case SyncState.error:
        badgeBg = theme.colorScheme.errorContainer;
        badgeFg = theme.colorScheme.error;
        iconWidget = Icon(Icons.cloud_off_rounded, size: 16, color: badgeFg);
        label = 'Galat Sync';
        break;
    }

    return Semantics(
      button: onTap != null,
      label: 'Status sinkronisasi: $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: badgeFg.withOpacity(0.4), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: badgeFg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### E. Kartu Pengingat Modular (`RootinReminderCard.dart`)

```dart
// lib/core/widgets/rootin_reminder_card.dart
import 'package:flutter/material.dart';
import '../theme/rootin_status_colors.dart';

enum ReminderType { time, usage, mileage }
enum ReminderStatus { healthy, warning, overdue, snoozed }

class RootinReminderCard extends StatelessWidget {
  const RootinReminderCard({
    super.key,
    required this.title,
    required this.assetName,
    required this.type,
    required this.status,
    required this.statusText,
    required this.progress,
    required this.targetDetail,
    required this.onTap,
    required this.onComplete,
    required this.onSnooze,
    this.onUpdateOdometer,
  });

  final String title;
  final String assetName;
  final ReminderType type;
  final ReminderStatus status;
  final String statusText;
  final double progress; // 0.0 to 1.0+
  final String targetDetail;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onSnooze;
  final VoidCallback? onUpdateOdometer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = context.statusColors;

    Color badgeBg;
    Color badgeFg;
    Color barColor;

    switch (status) {
      case ReminderStatus.healthy:
        badgeBg = statusColors.healthyContainer;
        badgeFg = statusColors.onHealthyContainer;
        barColor = statusColors.healthy;
        break;
      case ReminderStatus.warning:
        badgeBg = statusColors.warningContainer;
        badgeFg = statusColors.onWarningContainer;
        barColor = statusColors.warning;
        break;
      case ReminderStatus.overdue:
        badgeBg = statusColors.overdueContainer;
        badgeFg = statusColors.onOverdueContainer;
        barColor = statusColors.overdue;
        break;
      case ReminderStatus.snoozed:
        badgeBg = statusColors.neutralContainer;
        badgeFg = statusColors.onNeutralContainer;
        barColor = statusColors.neutral;
        break;
    }

    IconData typeIcon;
    String typeLabel;
    switch (type) {
      case ReminderType.time:
        typeIcon = Icons.schedule_rounded;
        typeLabel = 'Waktu';
        break;
      case ReminderType.usage:
        typeIcon = Icons.repeat_rounded;
        typeLabel = 'Pemakaian';
        break;
      case ReminderType.mileage:
        typeIcon = Icons.speed_rounded;
        typeLabel = 'Jarak';
        break;
    }

    return Dismissible(
      key: ValueKey(title + assetName),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onSnooze();
        } else {
          onComplete();
        }
        return false; // Jangan hapus kartu otomatis tanpa alur sheet/snackbar
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: statusColors.warningContainer,
        child: Row(
          children: [
            Icon(Icons.snooze_rounded, color: statusColors.onWarningContainer),
            const SizedBox(width: 8),
            Text('Tunda', style: TextStyle(fontWeight: FontWeight.bold, color: statusColors.onWarningContainer)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: statusColors.healthyContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold, color: statusColors.onHealthyContainer)),
            const SizedBox(width: 8),
            Icon(Icons.check_circle_rounded, color: statusColors.onHealthyContainer),
          ],
        ),
      ),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Baris: Tipe & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(typeIcon, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Judul & Nama Barang
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  assetName,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                // Indikator Progres Linier
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
                const SizedBox(height: 8),
                Text(
                  targetDetail,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                // Baris Tombol Aksi Cepat
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (type == ReminderType.mileage && onUpdateOdometer != null) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(40, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: onUpdateOdometer,
                        icon: const Icon(Icons.edit_road_rounded, size: 16),
                        label: const Text('Update Odo'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(40, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: onComplete,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Selesai'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### F. Kartu Profil Barang (`RootinItemCard.dart`)

```dart
// lib/core/widgets/rootin_item_card.dart
import 'package:flutter/material.dart';

class RootinItemCard extends StatelessWidget {
  const RootinItemCard({
    super.key,
    required this.name,
    required this.category,
    required this.activeReminderCount,
    this.photoUrl,
    this.currentOdometer,
    this.plateOrSerialNumber,
    required this.onTap,
  });

  final String name;
  final String category;
  final int activeReminderCount;
  final String? photoUrl;
  final int? currentOdometer;
  final String? plateOrSerialNumber;
  final VoidCallback onTap;

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'kendaraan':
        return Icons.directions_car_rounded;
      case 'elektronik':
        return Icons.devices_other_rounded;
      case 'furnitur':
        return Icons.chair_rounded;
      case 'fasilitas':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail Foto Privat dengan Fallback Ikon Kategori
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 72,
                  height: 72,
                  color: theme.colorScheme.surfaceVariant,
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            _getCategoryIcon(),
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          _getCategoryIcon(),
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Detail Barang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (plateOrSerialNumber != null) ...[
                      Text(
                        plateOrSerialNumber!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$activeReminderCount Pengingat',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        if (currentOdometer != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '$currentOdometer km',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### G. Wrapper Modal BottomSheet Adaptif (`RootinAdaptiveSheet.dart`)

```dart
// lib/core/widgets/rootin_adaptive_sheet.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RootinAdaptiveSheet {
  RootinAdaptiveSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    final theme = Theme.of(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          message: child,
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}
```

---

## 6. Validasi & Checklist Kepatuhan Sistem Desain

Sebelum mempublikasikan komponen antarmuka ke tahap produksi, seluruh kode wajib memenuhi matriks verifikasi berikut:

| Aspek Verifikasi | Kriteria Kelulusan | Verifikasi Otomatis / Manual |
| :--- | :--- | :--- |
| **Kontras Teks (WCAG AA/AAA)** | Rasio kontras teks terhadap latar belakang minimal 4.5:1 untuk teks normal dan 3.0:1 untuk judul besar. | Verifikasi matematis skema M3 (Lulus 100%). |
| **Target Sentuh Minimum** | Seluruh tombol, chip, input, dan aksi mikro minimal 48 x 48 dp (Android) dan 44 x 44 pt (iOS). | Uji lint `kMinInteractiveDimension`. |
| **Kemandirian Jaringan (Offline)** | Nol impor font eksternal runtime (`google_fonts`), nol ikon jaringan, nol CDN stylesheet. | Audit `pubspec.yaml` & bundle analyzer. |
| **Dukungan Pembesaran Teks** | Layout tidak pecah (*zero overflow errors*) pada pembesaran font sistem 2.0x. | Uji simulator text scaler 2.0x. |
| **Pengurangan Gerakan (A11y)** | Animasi disederhanakan saat `MediaQuery.disableAnimationsOf(context)` bernilai `true`. | Uji preferensi reduced-motion OS. |
| **Kompatibilitas Tema Gelap** | Seluruh kontainer dan kartu memiliki kontras seimbang tanpa saturasi warna berlebihan di mode gelap. | Evaluasi visual Dark ThemeData. |

---

## 7. Hubungan dengan Dokumen Terkait

1. **[docs/01-project-overview.md](01-project-overview.md)**: Ringkasan proyek, arsitektur target, dan peta 27 tiket implementasi.
2. **[docs/02-mobile-prd.md](02-mobile-prd.md)**: Product Requirement Document, persona pengguna, dan matriks use-cases.
3. **[docs/03-mobile-ux.md](03-mobile-ux.md)**: Arsitektur informasi, 7 alur pengguna terperinci, dan panduan transisi antarmuka.
4. **[docs/decisions/0002-architecture-offline-first.md](decisions/0002-architecture-offline-first.md)**: ADR Arsitektur Flutter modular, SSOT lokal Drift SQLite, dan Durable Outbox.

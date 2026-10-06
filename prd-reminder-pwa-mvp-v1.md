# PRD — Reminder PWA (MVP v1)

## 1. Ringkasan

**Nama kerja:** Reminder PWA  
**Platform:** web mobile-first yang dapat dipasang sebagai PWA  
**Pengguna awal:** Andre, untuk pemakaian pribadi

Aplikasi membantu pengguna mengingat aktivitas perawatan dan penggantian yang berulang, tetapi memiliki interval berbeda. Pengguna mencatat kapan aktivitas terakhir dilakukan dan aturan pengulangannya. Aplikasi menghitung jadwal berikutnya, menampilkan aktivitas yang mendekati jatuh tempo, dan mengirim notifikasi setelah pengguna mengaktifkannya.

Contoh: mengganti sikat gigi, mengganti alat cukur, mengganti oli motor, mencuci jeans, dan mencuci jaket.

## 2. Masalah dan tujuan

Pengguna mengandalkan ingatan atau catatan tersebar untuk mengingat aktivitas rutin. Setiap aktivitas memiliki interval berbeda dan sebagian dihitung sejak terakhir dilakukan. Akibatnya, pengguna tidak yakin kapan perlu bertindak dan dapat terlambat merawat atau mengganti sesuatu.

> Saya kesulitan mengingat kapan harus mengulang aktivitas perawatan karena setiap barang dan aktivitas memiliki periode berbeda, sering kali dihitung sejak terakhir kali dilakukan.

**Tujuan pengguna:** saat membuka aplikasi, pengguna dapat mengetahui apa yang perlu dilakukan, kapan waktunya, dan mencatat penyelesaian agar jadwal berikutnya dihitung kembali.

## 3. Tujuan dan bukan tujuan

### Tujuan MVP

- Membuat, melihat, mengubah, menunda, menyelesaikan, dan mengarsipkan reminder.
- Menghitung tanggal jatuh tempo dari tanggal terakhir dan aturan pengulangan.
- Mendukung pengulangan berdasarkan waktu, jumlah pemakaian, atau jarak tempuh manual.
- Menampilkan aktivitas mendatang dan terlambat.
- Mengirim web push setelah pengguna mengaktifkannya.
- Menyimpan riwayat penyelesaian dan perubahan jadwal.
- Memberikan UI mobile-first yang bersih, jelas, dan terasa seperti produk konsumen matang.

### Bukan tujuan MVP

- Profil publik, berbagi, feed sosial, rekomendasi, atau kolaborasi.
- Integrasi kendaraan, wearable, kalender, atau layanan eksternal.
- Pelacakan otomatis pemakaian atau odometer.
- Menentukan interval perawatan yang dianggap benar untuk semua barang.
- WhatsApp/SMS/email, analitik perilaku, atau iklan.

## 4. Prinsip produk

1. **Cepat dicatat:** membuat reminder tidak terasa seperti mengisi formulir administrasi.
2. **Jadwal transparan:** jelaskan dasar hitungan tanggal berikutnya.
3. **Pengguna memegang kendali:** pengguna menentukan interval dan waktu pengingat.
4. **Tidak menghakimi:** aktivitas terlambat ditampilkan dengan bahasa netral dan tindakan jelas.
5. **Riwayat membantu ingatan:** selesaikan aktivitas dengan satu tindakan dan simpan tanggalnya.
6. **Notifikasi dapat dipercaya:** jangan menyatakan push aktif sebelum izin dan subscription berhasil.

## 5. Bahasa dan stack yang disarankan

### Bahasa: TypeScript

Gunakan TypeScript karena UI dan server dapat memakai satu bahasa, tipe membantu menjaga konsistensi model reminder dan recurrence, dan ekosistemnya sesuai untuk PWA.

### Stack

- **Next.js + TypeScript** — aplikasi full-stack dan routing.
- **PostgreSQL melalui Supabase** — reminder, riwayat, dan push subscription.
- **Supabase Auth** — login sederhana untuk melindungi data dan menghubungkan perangkat; tidak ada fitur sosial.
- **Web Push API + Service Worker** — menerima notifikasi push.
- **Vercel** — hosting dan scheduled job untuk memeriksa reminder jatuh tempo. Server mengirim push dan menangani subscription tidak berlaku.
- **CSS Modules atau Tailwind CSS dengan token desain eksplisit** — pilih satu; hindari UI kit besar kecuali diperlukan.
- **Zod** — validasi input di server dan browser.
- **Vitest** — uji perhitungan jadwal dan edge case tanggal.

Jangan membangun push dengan timer browser yang hanya berjalan saat halaman terbuka. Push memerlukan izin, service worker, subscription, dan proses server yang mengirim saat jadwal jatuh tempo.

### Batasan iPhone

Pada iPhone, pengguna perlu menambahkan web app ke Home Screen dan memberikan izin notifikasi. Apple mendukung Web Push untuk web app Home Screen pada iOS/iPadOS 16.4 atau lebih baru. Dukungan berbeda menurut perangkat/browser, jadi dashboard tetap menjadi fallback dan status push harus jelas. citeturn0search1turn0search2

## 6. Model jadwal

Setiap reminder memiliki satu aturan pengulangan aktif. Pengguna dapat mengubah jenis aturan; perubahan tidak menghapus riwayat.

### A. Berbasis waktu

- Pengguna mengisi tanggal terakhir dilakukan.
- Interval: setiap N hari, minggu, bulan, atau tahun.
- Hitung dari tanggal penyelesaian terakhir, bukan dari saat pengguna membuka aplikasi.
- Jika due date terlewat, status menjadi **Terlambat**; jangan membuat rentetan push untuk tanggal lampau.

### B. Berbasis pemakaian

- Pengguna menentukan target jumlah pemakaian.
- Pengguna menambahkan pemakaian manual dengan aksi cepat `+1 pemakaian`.
- Tampilkan progres seperti `4 dari 6 pemakaian`.
- Saat target tercapai, status menjadi **Jatuh tempo**. Jangan memperkirakan tanggal tanpa data.
- Push dikirim setelah target tercapai.

### C. Berbasis jarak

- Pengguna memasukkan jarak terakhir (km) dan interval (km).
- Pengguna memperbarui odometer secara manual.
- Tampilkan jarak tersisa; saat ambang tercapai, status menjadi **Jatuh tempo**.
- Tidak membuat tenggat kalender kecuali pengguna menambahkan tanggal cadangan.

### Selesai dan tunda

- `Selesai` mencatat waktu aktual, menambah event riwayat, mereset progres pemakaian bila relevan, dan menghitung siklus selanjutnya.
- Pengguna boleh memasukkan tanggal selesai yang berbeda jika mencatat belakangan.
- `Tunda` menambahkan tanggal pengingat sementara tanpa mengubah interval dasar atau tanggal terakhir.

## 7. Data utama

### Reminder

- `id`, `user_id`, `title` (wajib), `category` (opsional), `notes` (opsional)
- `schedule_type`: `time`, `usage`, atau `distance`
- `interval_value`, `interval_unit` untuk waktu
- `usage_target`, `usage_count` untuk pemakaian
- `last_odometer_km`, `distance_interval_km`, `current_odometer_km` untuk jarak
- `last_completed_at`, `next_due_at`, `snoozed_until`
- `notification_enabled`, `archived_at`, `created_at`, `updated_at`

### Riwayat aktivitas

- `id`, `user_id`, `reminder_id`
- `event_type`: `completed`, `snoozed`, `usage_incremented`, `odometer_updated`, atau `schedule_changed`
- `occurred_at`, `value_before`, `value_after`, `note` (opsional)

### Push subscription

- `id`, `user_id`, `endpoint`, `p256dh`, `auth`, `created_at`, `last_success_at`, `disabled_at`
- Subscription privat dan hanya dapat diakses pemiliknya melalui kebijakan akses database.

## 8. Navigasi

Navigasi utama mobile berupa tiga tab:

1. **Hari ini** — ringkasan yang perlu diperhatikan dan aktivitas mendatang.
2. **Semua** — daftar reminder aktif dan filter status/kategori.
3. **Riwayat** — aktivitas selesai dan perubahan jadwal.

Pengaturan notifikasi dan akun ada di menu pengaturan yang mudah ditemukan, bukan tab utama.

## 9. Layar dan interaksi

### Onboarding

- Pengantar singkat tentang pengingat yang dihitung dari aktivitas terakhir.
- Login sebelum menyimpan data lintas sesi/perangkat.
- Jangan langsung meminta izin push pada pembukaan pertama.
- Setelah reminder pertama dibuat, tawarkan aktivasi notifikasi. Beri instruksi Add to Home Screen untuk iPhone bila diperlukan.

### Hari ini

- Tanggal atau salam singkat; hindari dashboard penuh statistik.
- Bagian `Perlu dilakukan` dan `Segera`.
- Urutkan terlambat lebih dulu, lalu jatuh tempo terdekat.
- Item menampilkan nama, status/tanggal atau progres, dan satu aksi utama.
- Tombol tambah reminder mudah dijangkau ibu jari.
- Empty state mengarahkan ke `Buat reminder pertama`.

### Buat/edit reminder

- Form adaptif; hanya tampilkan field sesuai jenis jadwal.
- Field: nama, kategori opsional, aturan, informasi terakhir, interval/target, waktu notifikasi.
- Preview otomatis, misalnya `Jatuh tempo berikutnya 12 November 2026` atau `Ingatkan setelah 6 pemakaian`.
- Validasi inline dan pertahankan nilai bila jenis jadwal diganti.
- CTA utama `Simpan reminder`.

### Detail reminder

- Tampilkan nama, status, dasar hitungan, dan tanggal/progres berikutnya.
- Aksi utama `Tandai selesai` atau `Perbarui pemakaian/odometer`.
- Aksi sekunder `Tunda`, `Edit`, dan `Arsipkan`.
- Riwayat ringkas berdasarkan tanggal.

### Semua reminder

- Daftar satu kolom yang mudah dipindai; bukan grid kartu dekoratif.
- Filter sederhana: Semua, Segera, Terlambat, Tanpa jadwal waktu.
- Kategori membantu pemindaian, tetapi tidak wajib.
- Arsipkan item tidak aktif tanpa menghapus riwayat.

### Riwayat

- Daftar kronologis dengan nama aktivitas dan jenis tindakan.
- Empty state menjelaskan bahwa penyelesaian akan tercatat di sini.
- Grafik dan statistik tidak termasuk MVP.

### Pengaturan notifikasi

- Status: belum disiapkan, izin belum diberikan, aktif, atau bermasalah.
- Kontrol untuk mengaktifkan, memeriksa ulang, atau mematikan push.
- Atur waktu notifikasi default dan pengingat sebelum jatuh tempo (opsional).
- Jika push tidak didukung/diizinkan, jelaskan dan tetap tampilkan due state di aplikasi.

## 10. Arahan UI

Clean, modern, ringan, dan terasa seperti utilitas personal berkualitas. Utamakan tipografi, ruang, hierarki, dan status yang mudah dibaca. Gunakan pola mobile yang matang: navigasi bawah ringkas, list mudah dipindai, form bertahap, bottom sheet untuk pilihan kontekstual, dan umpan balik langsung.

### Hindari

- Gradient dekoratif, terutama ungu/biru generik.
- Border warna-warni atau glowing di setiap card.
- Banyak panel dashboard yang semuanya tampak sama.
- Bayangan berat, blur, efek kaca, ilustrasi generik, emoji sebagai ikon utama.
- Copywriting generik seperti “Your productivity, elevated”.
- Terlalu banyak grafik, angka, badge, dan warna status bersaing.

### Gunakan

- Latar putih/netral hangat, teks kontras tinggi, satu warna aksen yang hemat.
- Garis pemisah tipis dan permukaan datar; gunakan card hanya untuk kelompok konten yang perlu dipisahkan.
- Warna status semantik yang lembut dan tetap terbaca.
- Satu pustaka ikon konsisten; beri label untuk ikon aksi yang kurang jelas.
- Target sentuh minimal 44×44 CSS px sebagai target desain.
- Status teks selain warna; animasi singkat hanya untuk konfirmasi aksi.

### Responsif

- 320–430 px: satu kolom, tab bar bawah, CTA terjangkau, tanpa tabel atau scroll horizontal.
- Tablet: konten melebar terbatas, daftar tetap fokus.
- Desktop: lebar konten terkontrol; navigasi boleh berpindah ke sidebar/top bar tanpa mengubah model mental.
- Hormati safe area iOS, keyboard virtual, zoom teks, reduced motion, dan orientasi layar.

## 11. Aturan notifikasi

- Server memeriksa reminder waktu jatuh tempo melalui job terjadwal.
- Cegah duplikasi dengan idempotency key `reminder_id + due_at + notification_type`.
- Simpan zona waktu pengguna; default dari perangkat dan dapat diubah.
- Isi push ringkas; secara default jangan tampilkan catatan pribadi.
- Jika subscription invalid, nonaktifkan dan minta pengguna menyambungkan kembali.
- Jangan kirim rentetan reminder berulang untuk satu item overdue.
- Jadwal pemakaian/jarak memicu push setelah pengguna memperbarui progres hingga ambang.

## 12. Aksesibilitas dan kualitas

- Jadikan WCAG 2.2 AA sebagai target kontras dan interaksi.
- Semua alur dapat digunakan dengan keyboard pada desktop dan fokus terlihat.
- Form memiliki label persisten, instruksi, dan pesan error yang dapat dibaca screen reader.
- Status tidak bergantung pada warna; teks tetap berfungsi pada zoom browser.
- Hormati reduced motion dan sediakan area sentuh memadai.
- Tangani loading, error jaringan, empty, izin ditolak, push tidak didukung, dan subscription kedaluwarsa.

## 13. Kriteria penerimaan

1. Pengguna dapat login dan datanya terisolasi dari pengguna lain.
2. Pengguna membuat reminder untuk ketiga jenis aturan dan melihat preview sebelum menyimpan.
3. Due date berbasis waktu benar untuk hari, minggu, bulan, tahun, akhir bulan, dan tahun kabisat.
4. Penambahan pemakaian/odometer memperbarui progres dan status.
5. Menandai selesai menyimpan riwayat dan memulai siklus baru dari tanggal aktual.
6. Menunda tidak mengubah interval dasar; edit aturan tidak menghapus riwayat.
7. Hari ini menampilkan terlambat dan segera jatuh tempo dengan urutan konsisten.
8. Push dapat diaktifkan setelah tindakan eksplisit, status terlihat, subscription bisa dimatikan.
9. Satu occurrence tidak mengirim push lebih dari sekali.
10. Alur inti bekerja pada lebar 320 px tanpa scroll horizontal.
11. UI menyediakan loading/error/empty/izin ditolak/tidak didukung.
12. Data tersedia setelah aplikasi ditutup dan dibuka kembali.

## 14. Ukuran keberhasilan awal

Untuk aplikasi pribadi, evaluasi melalui penggunaan nyata, bukan metrik pertumbuhan:

- Reminder pertama dapat dibuat tanpa bantuan.
- Pengguna memahami alasan dan tanggal/progres jatuh tempo.
- Penyelesaian dapat dicatat dalam beberapa detik.
- Tidak ada kesalahan recurrence pada skenario uji yang disepakati.
- Push uji tiba di perangkat yang didukung setelah izin diberikan.
- Pengguna kembali mencatat aktivitas setelah reminder pertama.

Tetapkan angka target setelah prototipe dan pemakaian awal; jangan mengarang baseline.

## 15. Risiko

- Push web berbeda dukungannya antarperangkat; dashboard tetap harus berguna.
- Pemakaian/jarak memerlukan input manual; sediakan aksi cepat.
- Tanggal 31 pada bulan yang lebih pendek ambigu; tetapkan aturan akhir bulan dan uji.
- Notifikasi berlebihan dapat membuat pengguna mematikannya; batasi dan cegah duplikasi.
- Data pribadi perlu row-level security; jangan letakkan secret server di client.

## 16. Urutan implementasi Codex

1. Inspeksi repository dan laporkan struktur serta stack sebelum mengubah file.
2. Jika repository kosong, siapkan Next.js + TypeScript + PWA dasar. Jika sudah ada aplikasi, pertahankan stack/pola yang ada kecuali ada alasan teknis kuat.
3. Buat token visual dan shell responsif: Hari ini, Semua, Riwayat, navigasi, dan empty states.
4. Implementasikan model data/validasi dan fungsi murni kalkulasi jadwal; uji edge case tanggal.
5. Bangun alur create/edit/detail serta aksi selesai/tunda/arsip.
6. Tambahkan autentikasi personal dan persistensi data dengan akses per-user.
7. Tambahkan manifest/service worker dan UI status instalasi/notifikasi.
8. Implementasikan push subscription dan job terjadwal; uji pada perangkat yang didukung.
9. Periksa lebar 320 px, keyboard, loading/error/empty, dan aksesibilitas dasar.
10. Jalankan typecheck, lint, tes kalkulasi, dan production build; laporkan hasil serta keterbatasan.

### Instruksi untuk Codex

Sebelum coding, jelaskan temuan struktur repository, keputusan stack, dan risiko push. Implementasikan bertahap tanpa mengganti atau menghapus fitur yang sudah bekerja. Jangan menambahkan scope di luar MVP ini. Gunakan default yang tercantum dan catat asumsi; jangan menghentikan pekerjaan untuk pertanyaan kecil.

## 17. Referensi teknis

- Apple Developer, Web Push: https://developer.apple.com/documentation/usernotifications/sending-web-push-notifications-in-web-apps-and-browsers
- WebKit, Web Push di iOS/iPadOS: https://webkit.org/blog/13878/web-push-for-web-apps-on-ios-and-ipados/
- MDN, Push API: https://developer.mozilla.org/en-US/docs/Web/API/Push_API

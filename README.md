# Rootin

Rootin adalah aplikasi pengingat rutin berdasarkan [PRD](./prd-reminder-pwa-mvp-v1.md). Aplikasi memakai Supabase Auth dan database untuk reminder pribadi. PWA dan Web Push tersedia setelah konfigurasi server dan migrasi push diterapkan.

## Menyiapkan Supabase

1. Salin `.env.example` ke `.env.local`, lalu isi URL proyek dan publishable key. `.env.local` diabaikan oleh Git.
2. Sebagai pemilik proyek, jalankan [migrasi awal](./supabase/migrations/20261006000000_rootin_initial.sql) di Supabase SQL Editor. Migrasi membuat `reminders`, `activity_history`, dan `push_subscriptions`, serta mengaktifkan RLS dan membatasi akses ke pemilik data.
3. Di Supabase Authentication → URL Configuration, tambahkan `http://localhost:3000/auth/callback` ke Redirect URLs. Jika memakai port 3001, tambahkan juga `http://localhost:3001/auth/callback`. Atur Site URL sesuai alamat aplikasi yang digunakan. Konfigurasi URL produksi saat deployment.
4. Jalankan `npm run check:supabase`. Pemeriksaan ini berhasil jika proyek dapat dijangkau dan akses anonim ke `reminders` ditolak. Sebelum migrasi diterapkan, perintah ini keluar dengan kode 2 karena tabel belum tersedia.

## Mengaktifkan Web Push

1. Jalankan [migrasi push](./supabase/migrations/20261006010000_push_delivery.sql) **setelah** migrasi awal di Supabase SQL Editor. Migrasi menambah zona waktu subscription, klaim pengiriman yang unik, dan aksi progres/selesai.
2. Pasangan VAPID Rootin sudah dibuat untuk proyek ini. Public key ada di `.env.production`; private key dan `CRON_SECRET` ada di `.env.local` yang diabaikan Git. **Jangan menjalankan `npm run setup:push-keys` lagi** kecuali sengaja merotasi semua subscription. Untuk instalasi baru tanpa key, jalankan perintah itu sekali.
3. Atur variabel **Production** berikut di Vercel Project Settings → Environment Variables: `SUPABASE_SECRET_KEY` (secret key proyek Supabase), `PUSH_VAPID_PRIVATE_KEY` dan `CRON_SECRET` (salin dari `.env.local`). `NEXT_PUBLIC_PUSH_VAPID_PUBLIC_KEY` sudah ada di `.env.production`; jika diatur juga di Vercel, nilainya harus sama. Semua secret hanya untuk server; jangan ditambahkan ke `NEXT_PUBLIC_` atau Git. Public key memang aman di browser. Untuk lokal, tambahkan `SUPABASE_SECRET_KEY` ke `.env.local` agar pengiriman uji bisa berjalan.
4. Deploy ulang setelah migrasi dan variabel tersedia. `vercel.json` menjadwalkan pemeriksaan setiap hari pada **00:00 UTC** (sekitar 08:00 WITA; pada Vercel Hobby dapat berjalan kapan saja dalam jam tersebut). `CRON_SECRET` melindungi endpoint job.
5. Di iPhone dengan iOS 16.4+, buka Rootin lewat **Tambah ke Layar Utama**, masuk, buat reminder, lalu buka **Pengaturan → Aktifkan notifikasi**. Gunakan tombol **Kirim notifikasi uji** untuk memeriksa perangkat. Izin diminta hanya setelah tombol ditekan. Dashboard tetap menampilkan jatuh tempo jika push tidak tersedia.

Notifikasi waktu dikirim hanya pada tanggal jatuh tempo menurut zona waktu perangkat yang tersimpan. Pengiriman harian yang gagal tidak diulang untuk tanggal lampau. Progres pemakaian dan jarak memicu pengiriman saat ambang tercapai. Setiap kombinasi reminder, occurrence, jenis, dan perangkat diklaim sebelum pengiriman agar job atau aksi berulang tidak mengirim dua kali; jika layanan push gagal setelah klaim, occurrence itu tidak dicoba ulang. Subscription yang ditolak permanen oleh push service dinonaktifkan.

Publishable key dapat digunakan di browser; RLS menentukan baris yang boleh dibaca atau ditulis. Jangan menaruh secret/service role key di variabel `NEXT_PUBLIC_`.

Untuk Vercel, `.env.production` berisi URL dan publishable key publik agar build dari GitHub tetap terkonfigurasi. Nilai yang diatur pada Vercel Environment Variables akan mengambil prioritas; setelah mengubahnya, lakukan redeploy. `.env.local` tetap hanya untuk mesin pengembang.

## Menjalankan aplikasi

```bash
npm install
npm run dev
```

Buka `http://localhost:3000`. Jika port 3000 dipakai, jalankan `npm run dev -- -p 3001`. Daftar atau masuk dengan email dan kata sandi, lalu buat reminder dari tombol **Tambah reminder**. Konfirmasi email mungkin diperlukan sesuai pengaturan Supabase Auth.

Halaman Hari ini, Semua, Riwayat, dan detail memakai query yang dibatasi ke pengguna masuk. Form baru mendukung aturan waktu, pemakaian, dan jarak. Perhitungan tanggal bulanan/tahunan menjepit tanggal akhir bulan ke hari terakhir bulan tujuan; siklus berikutnya kelak dihitung dari tanggal selesai aktual. Untuk sekarang zona waktu tampilan status memakai `Asia/Makassar`, sesuai pengguna awal PRD.

## Pemeriksaan

```bash
npm run typecheck
npm test
npm run build
npm run check:supabase
```

Detail reminder mendukung penambahan progres pemakaian/jarak dan menandai selesai. Edit aturan, tunda, dan arsip tetap tahap berikutnya.

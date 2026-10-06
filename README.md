# Rootin

Rootin adalah aplikasi pengingat rutin berdasarkan [PRD](./prd-reminder-pwa-mvp-v1.md). Tahap ini memakai Supabase Auth dan database untuk membuat serta membaca reminder pribadi. Push notification belum diimplementasikan.

## Menyiapkan Supabase

1. Salin `.env.example` ke `.env.local`, lalu isi URL proyek dan publishable key. `.env.local` diabaikan oleh Git.
2. Sebagai pemilik proyek, jalankan [migrasi awal](./supabase/migrations/20261006000000_rootin_initial.sql) di Supabase SQL Editor. Migrasi membuat `reminders`, `activity_history`, dan `push_subscriptions`, serta mengaktifkan RLS dan membatasi akses ke pemilik data.
3. Di Supabase Authentication → URL Configuration, tambahkan `http://localhost:3000/auth/callback` ke Redirect URLs. Jika memakai port 3001, tambahkan juga `http://localhost:3001/auth/callback`. Atur Site URL sesuai alamat aplikasi yang digunakan. Konfigurasi URL produksi saat deployment.
4. Jalankan `npm run check:supabase`. Pemeriksaan ini berhasil jika proyek dapat dijangkau dan akses anonim ke `reminders` ditolak. Sebelum migrasi diterapkan, perintah ini keluar dengan kode 2 karena tabel belum tersedia.

Publishable key dapat digunakan di browser; RLS menentukan baris yang boleh dibaca atau ditulis. Jangan menaruh secret/service role key di variabel `NEXT_PUBLIC_`.

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

Pengubahan, penyelesaian, penundaan, dan pengarsipan reminder, serta pengiriman push, adalah tahap berikutnya. Tabel riwayat dan subscription sudah disiapkan dengan RLS, tetapi belum dipakai oleh aksi tersebut.

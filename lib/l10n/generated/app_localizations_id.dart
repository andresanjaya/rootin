// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get home => 'Beranda';

  @override
  String get logout => 'Keluar';

  @override
  String get settings => 'Pengaturan';

  @override
  String get offlineDescription => 'Pengingat perawatan offline-first';

  @override
  String signedInAs(String email) {
    return 'Masuk sebagai: $email';
  }

  @override
  String get loginDescription =>
      'Masuk ke akun Anda untuk mengelola pengingat pemeliharaan';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'nama@domain.com';

  @override
  String get emailRequired => 'Email wajib diisi';

  @override
  String get emailInvalid => 'Format email tidak valid';

  @override
  String get password => 'Kata Sandi';

  @override
  String get passwordRequired => 'Kata sandi wajib diisi';

  @override
  String get passwordShort => 'Kata sandi minimal 6 karakter';

  @override
  String get showPassword => 'Tampilkan kata sandi';

  @override
  String get hidePassword => 'Sembunyikan kata sandi';

  @override
  String get forgotPasswordQuestion => 'Lupa Kata Sandi?';

  @override
  String get login => 'Masuk';

  @override
  String get noAccount => 'Belum memiliki akun?';

  @override
  String get register => 'Daftar';

  @override
  String get loginFailed => 'Gagal masuk. Silakan coba lagi.';

  @override
  String get registerFailed => 'Gagal mendaftar. Silakan coba lagi.';

  @override
  String get registerSuccess =>
      'Pendaftaran berhasil! Silakan periksa email Anda atau masuk.';

  @override
  String get registerAccount => 'Daftar Akun';

  @override
  String get createAccount => 'Buat Akun Rootin';

  @override
  String get registerDescription =>
      'Kelola jadwal perawatan barang dan kendaraan Anda secara teratur';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get confirmRequired => 'Konfirmasi kata sandi wajib diisi';

  @override
  String get passwordMismatch => 'Kata sandi tidak cocok';

  @override
  String get hasAccount => 'Sudah memiliki akun?';

  @override
  String get forgotPassword => 'Lupa Kata Sandi';

  @override
  String get resetLinkFailed =>
      'Gagal mengirim tautan reset. Silakan coba lagi.';

  @override
  String get linkSent => 'Tautan Terkirim';

  @override
  String linkSentDescription(String email) {
    return 'Kami telah mengirimkan petunjuk pemulihan kata sandi ke $email. Silakan periksa kotak masuk atau spam email Anda.';
  }

  @override
  String get backToLogin => 'Kembali ke Masuk';

  @override
  String get resetPassword => 'Atur Ulang Kata Sandi';

  @override
  String get resetDescription =>
      'Masukkan email yang terdaftar untuk menerima tautan pembaruan kata sandi';

  @override
  String get sendResetLink => 'Kirim Tautan Reset';

  @override
  String get cancel => 'Batal';

  @override
  String get passwordUpdated => 'Kata sandi berhasil diperbarui!';

  @override
  String get passwordUpdateFailed =>
      'Gagal memperbarui kata sandi. Silakan coba lagi.';

  @override
  String get newPassword => 'Kata Sandi Baru';

  @override
  String get updatePassword => 'Perbarui Kata Sandi';

  @override
  String get newPasswordDescription =>
      'Masukkan kata sandi baru untuk akun Anda (minimal 6 karakter)';

  @override
  String get newPasswordRequired => 'Kata sandi baru wajib diisi';

  @override
  String get confirmNewPassword => 'Konfirmasi Kata Sandi Baru';

  @override
  String get savePassword => 'Simpan Kata Sandi';

  @override
  String get language => 'Bahasa';

  @override
  String get systemLanguage => 'Bahasa perangkat';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get english => 'English';

  @override
  String get distanceUnit => 'Satuan jarak';

  @override
  String get kilometers => 'Kilometer (km)';

  @override
  String get miles => 'Mil (mi)';

  @override
  String get deviceTimezone => 'Ikuti zona waktu perangkat';

  @override
  String get timezone => 'Zona waktu IANA';

  @override
  String get timezoneHint => 'Contoh: Asia/Jakarta';

  @override
  String get invalidTimezone => 'Zona waktu IANA tidak dikenal';

  @override
  String get reminderTime => 'Waktu pengingat';

  @override
  String get localOnly =>
      'Preferensi ini tersimpan di perangkat ini. Penjadwalan notifikasi belum tersedia.';

  @override
  String get save => 'Simpan';

  @override
  String get settingsSaved => 'Pengaturan disimpan';

  @override
  String get settingsFailed => 'Gagal menyimpan pengaturan';

  @override
  String reminderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pengingat',
      one: '1 pengingat',
      zero: 'Tidak ada pengingat',
    );
    return '$_temp0';
  }
}

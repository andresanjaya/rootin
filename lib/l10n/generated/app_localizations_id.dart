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

  @override
  String get today => 'Hari ini';

  @override
  String get reminders => 'Pengingat';

  @override
  String get items => 'Barang';

  @override
  String get calendar => 'Kalender';

  @override
  String get history => 'Riwayat';

  @override
  String get refreshLocalData => 'Muat ulang data lokal';

  @override
  String get noItems => 'Belum ada barang';

  @override
  String get noHistory => 'Belum ada pengingat yang selesai';

  @override
  String get completed => 'Selesai';

  @override
  String get noReminders => 'Tidak ada pengingat yang cocok';

  @override
  String get noScheduledReminders => 'Tidak ada pengingat terjadwal';

  @override
  String get loadFailed => 'Gagal memuat data lokal';

  @override
  String get timezoneUnavailable =>
      'Atur zona waktu yang valid untuk melihat pengingat';

  @override
  String get searchReminders => 'Cari pengingat atau barang';

  @override
  String get type => 'Jenis';

  @override
  String get status => 'Status';

  @override
  String get allTypes => 'Semua jenis';

  @override
  String get allCategories => 'Semua kategori';

  @override
  String get timeType => 'Waktu';

  @override
  String get usageType => 'Pemakaian';

  @override
  String get mileageType => 'Jarak tempuh';

  @override
  String get allStatuses => 'Semua status';

  @override
  String get overdue => 'Terlambat';

  @override
  String get dueToday => 'Jatuh tempo hari ini';

  @override
  String get soon => 'Segera';

  @override
  String get later => 'Nanti';

  @override
  String get noDate => 'Tanpa tanggal kalender';

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get activeReminders => 'Aktif';

  @override
  String get archivedReminders => 'Nonaktif / diarsipkan';

  @override
  String get normal => 'Normal';

  @override
  String get warning => 'Peringatan';

  @override
  String get due => 'Jatuh tempo';

  @override
  String remainingUsage(int count) {
    return 'Sisa $count';
  }

  @override
  String remainingDistance(int distance, String unit) {
    return 'Sisa $distance $unit';
  }

  @override
  String pendingSync(int count) {
    return '$count perubahan lokal menunggu sinkronisasi';
  }

  @override
  String failedSync(int count) {
    return '$count perubahan lokal gagal disinkronkan';
  }

  @override
  String conflictedSync(int count) {
    return '$count perubahan lokal mengalami konflik';
  }

  @override
  String get syncStatusUnavailable =>
      'Status antrean sinkronisasi lokal tidak tersedia';

  @override
  String get connectivityUnknown => 'Koneksi tidak diketahui';

  @override
  String get syncNow => 'Sinkronkan sekarang';

  @override
  String get syncFailed =>
      'Sinkronisasi tidak tersedia. Perubahan lokal tetap tersimpan.';

  @override
  String get useServerVersion => 'Pakai versi server';

  @override
  String get conflictWarning =>
      'Buang perubahan lokal ini dan muat data server? Tindakan ini tidak dapat dibatalkan.';

  @override
  String resolveConflict(String entity) {
    return 'Atasi konflik untuk $entity';
  }

  @override
  String get addReminder => 'Tambah Pengingat';

  @override
  String get editReminder => 'Edit Pengingat';

  @override
  String get reminderName => 'Nama Pengingat';

  @override
  String get reminderNameHint => 'Contoh: Ganti Oli Mesin';

  @override
  String get reminderNameRequired => 'Nama pengingat wajib diisi';

  @override
  String get reminderNameTooLong => 'Nama pengingat maksimal 150 karakter';

  @override
  String get selectItem => 'Pilih Barang';

  @override
  String get selectItemRequired => 'Barang wajib dipilih';

  @override
  String get engineType => 'Jenis Pengingat';

  @override
  String get intervalValue => 'Interval';

  @override
  String get intervalUnit => 'Satuan Interval';

  @override
  String get daysUnit => 'Hari';

  @override
  String get weeksUnit => 'Minggu';

  @override
  String get monthsUnit => 'Bulan';

  @override
  String get yearsUnit => 'Tahun';

  @override
  String get baselineMode => 'Mode Perhitungan Siklus';

  @override
  String get actualCompletion => 'Selesai Aktual (Default)';

  @override
  String get strictSchedule => 'Jadwal Ketat';

  @override
  String get targetDate => 'Tanggal Jatuh Tempo';

  @override
  String get targetTime => 'Jam Pengingat';

  @override
  String get targetDateRequired => 'Tanggal jatuh tempo wajib diisi';

  @override
  String get targetDateInvalid => 'Format tanggal tidak valid';

  @override
  String get usageThreshold => 'Ambang Batas Pemakaian';

  @override
  String get usageThresholdHint => 'Contoh: 100';

  @override
  String get usageThresholdRequired => 'Ambang batas pemakaian wajib diisi';

  @override
  String get usageThresholdPositive => 'Ambang batas harus lebih dari 0';

  @override
  String get currentUsage => 'Counter Pemakaian Awal';

  @override
  String get usageUnit => 'Satuan Pemakaian';

  @override
  String get usageUnitHint => 'Contoh: kali, siklus, jam';

  @override
  String get intervalKm => 'Interval Jarak (km)';

  @override
  String get intervalKmHint => 'Contoh: 5000';

  @override
  String get intervalKmRequired => 'Interval jarak wajib diisi';

  @override
  String get intervalKmPositive => 'Interval jarak harus lebih dari 0';

  @override
  String get lastServiceOdometer => 'Odometer Terakhir (km)';

  @override
  String get lastServiceOdometerRequired => 'Odometer terakhir wajib diisi';

  @override
  String get vehicleRequiredForMileage =>
      'Hanya barang dengan odometer (kendaraan) yang dapat menggunakan pengingat jarak';

  @override
  String get schedulePreview => 'Pratinjau Jadwal Berikutnya';

  @override
  String get wearPreview => 'Pratinjau Keausan & Sisa';

  @override
  String targetOdometerPreview(int odo) {
    return 'Target Odometer: $odo km';
  }

  @override
  String get savingReminder => 'Menyimpan pengingat...';

  @override
  String get reminderSaved => 'Pengingat berhasil disimpan';

  @override
  String get reminderSaveFailed => 'Gagal menyimpan pengingat';

  @override
  String get engineTypeImmutable =>
      'Jenis pengingat tidak dapat diubah setelah dibuat';

  @override
  String get reminderDetail => 'Detail Pengingat';

  @override
  String get completeCycle => 'Selesaikan Siklus';

  @override
  String get completionDate => 'Tanggal Selesai';

  @override
  String get performedBy => 'Dikerjakan Oleh';

  @override
  String get performedByHint => 'Contoh: Bengkel Resmi, Mandiri';

  @override
  String get cost => 'Biaya';

  @override
  String get costHint => 'Contoh: 150000';

  @override
  String get notes => 'Catatan';

  @override
  String get notesHint => 'Catatan tambahan perawatan...';

  @override
  String get odometerAtCompletion => 'Odometer Saat Selesai (km)';

  @override
  String odometerAtCompletionHint(int odo) {
    return 'Contoh: $odo';
  }

  @override
  String get confirmComplete => 'Konfirmasi Selesai';

  @override
  String get completingCycle => 'Menyelesaikan siklus...';

  @override
  String get cycleCompleted => 'Siklus perawatan berhasil diselesaikan';

  @override
  String get cycleCompleteFailed => 'Gagal menyelesaikan siklus';

  @override
  String get plusOneUsage => '+1 Pemakaian';

  @override
  String get usageIncremented => 'Pemakaian bertambah (+1)';

  @override
  String get usageIncrementFailed => 'Gagal menambah pemakaian';

  @override
  String get updateOdometer => 'Perbarui Odometer';

  @override
  String get currentOdometer => 'Odometer Saat Ini';

  @override
  String get newOdometer => 'Odometer Baru (km)';

  @override
  String get newOdometerHint => 'Harus lebih besar dari odometer saat ini';

  @override
  String get newOdometerRequired => 'Odometer baru wajib diisi';

  @override
  String get newOdometerInvalid =>
      'Odometer baru harus lebih besar atau sama dengan odometer saat ini';

  @override
  String get odometerUpdated => 'Odometer berhasil diperbarui';

  @override
  String get odometerUpdateFailed => 'Gagal memperbarui odometer';

  @override
  String get serviceHistory => 'Riwayat Servis / Siklus';

  @override
  String get noLogsYet => 'Belum ada riwayat penyelesaian untuk pengingat ini';

  @override
  String get progressSection => 'Progres & Target';

  @override
  String get calculationBasis => 'Basis Perhitungan';

  @override
  String completedOn(String date) {
    return 'Selesai pada $date';
  }

  @override
  String performedByLabel(String name) {
    return 'Oleh: $name';
  }

  @override
  String costLabel(String cost) {
    return 'Biaya: $cost';
  }

  @override
  String odometerLabel(int odo) {
    return 'Odometer: $odo km';
  }
}

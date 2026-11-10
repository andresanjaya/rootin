import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @offlineDescription.
  ///
  /// In id, this message translates to:
  /// **'Pengingat perawatan offline-first'**
  String get offlineDescription;

  /// No description provided for @signedInAs.
  ///
  /// In id, this message translates to:
  /// **'Masuk sebagai: {email}'**
  String signedInAs(String email);

  /// No description provided for @loginDescription.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke akun Anda untuk mengelola pengingat pemeliharaan'**
  String get loginDescription;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In id, this message translates to:
  /// **'nama@domain.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi wajib diisi'**
  String get passwordRequired;

  /// No description provided for @passwordShort.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 6 karakter'**
  String get passwordShort;

  /// No description provided for @showPassword.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kata sandi'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan kata sandi'**
  String get hidePassword;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi?'**
  String get forgotPasswordQuestion;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum memiliki akun?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get register;

  /// No description provided for @loginFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal masuk. Silakan coba lagi.'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mendaftar. Silakan coba lagi.'**
  String get registerFailed;

  /// No description provided for @registerSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pendaftaran berhasil! Silakan periksa email Anda atau masuk.'**
  String get registerSuccess;

  /// No description provided for @registerAccount.
  ///
  /// In id, this message translates to:
  /// **'Daftar Akun'**
  String get registerAccount;

  /// No description provided for @createAccount.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Rootin'**
  String get createAccount;

  /// No description provided for @registerDescription.
  ///
  /// In id, this message translates to:
  /// **'Kelola jadwal perawatan barang dan kendaraan Anda secara teratur'**
  String get registerDescription;

  /// No description provided for @confirmPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi'**
  String get confirmPassword;

  /// No description provided for @confirmRequired.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi kata sandi wajib diisi'**
  String get confirmRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak cocok'**
  String get passwordMismatch;

  /// No description provided for @hasAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah memiliki akun?'**
  String get hasAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi'**
  String get forgotPassword;

  /// No description provided for @resetLinkFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim tautan reset. Silakan coba lagi.'**
  String get resetLinkFailed;

  /// No description provided for @linkSent.
  ///
  /// In id, this message translates to:
  /// **'Tautan Terkirim'**
  String get linkSent;

  /// No description provided for @linkSentDescription.
  ///
  /// In id, this message translates to:
  /// **'Kami telah mengirimkan petunjuk pemulihan kata sandi ke {email}. Silakan periksa kotak masuk atau spam email Anda.'**
  String linkSentDescription(String email);

  /// No description provided for @backToLogin.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Masuk'**
  String get backToLogin;

  /// No description provided for @resetPassword.
  ///
  /// In id, this message translates to:
  /// **'Atur Ulang Kata Sandi'**
  String get resetPassword;

  /// No description provided for @resetDescription.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email yang terdaftar untuk menerima tautan pembaruan kata sandi'**
  String get resetDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In id, this message translates to:
  /// **'Kirim Tautan Reset'**
  String get sendResetLink;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @passwordUpdated.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi berhasil diperbarui!'**
  String get passwordUpdated;

  /// No description provided for @passwordUpdateFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memperbarui kata sandi. Silakan coba lagi.'**
  String get passwordUpdateFailed;

  /// No description provided for @newPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi Baru'**
  String get newPassword;

  /// No description provided for @updatePassword.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Kata Sandi'**
  String get updatePassword;

  /// No description provided for @newPasswordDescription.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kata sandi baru untuk akun Anda (minimal 6 karakter)'**
  String get newPasswordDescription;

  /// No description provided for @newPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru wajib diisi'**
  String get newPasswordRequired;

  /// No description provided for @confirmNewPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi Baru'**
  String get confirmNewPassword;

  /// No description provided for @savePassword.
  ///
  /// In id, this message translates to:
  /// **'Simpan Kata Sandi'**
  String get savePassword;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa perangkat'**
  String get systemLanguage;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @distanceUnit.
  ///
  /// In id, this message translates to:
  /// **'Satuan jarak'**
  String get distanceUnit;

  /// No description provided for @kilometers.
  ///
  /// In id, this message translates to:
  /// **'Kilometer (km)'**
  String get kilometers;

  /// No description provided for @miles.
  ///
  /// In id, this message translates to:
  /// **'Mil (mi)'**
  String get miles;

  /// No description provided for @deviceTimezone.
  ///
  /// In id, this message translates to:
  /// **'Ikuti zona waktu perangkat'**
  String get deviceTimezone;

  /// No description provided for @timezone.
  ///
  /// In id, this message translates to:
  /// **'Zona waktu IANA'**
  String get timezone;

  /// No description provided for @timezoneHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Asia/Jakarta'**
  String get timezoneHint;

  /// No description provided for @invalidTimezone.
  ///
  /// In id, this message translates to:
  /// **'Zona waktu IANA tidak dikenal'**
  String get invalidTimezone;

  /// No description provided for @reminderTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu pengingat'**
  String get reminderTime;

  /// No description provided for @localOnly.
  ///
  /// In id, this message translates to:
  /// **'Preferensi ini tersimpan di perangkat ini. Penjadwalan notifikasi belum tersedia.'**
  String get localOnly;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @settingsSaved.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan disimpan'**
  String get settingsSaved;

  /// No description provided for @settingsFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan pengaturan'**
  String get settingsFailed;

  /// No description provided for @reminderCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Tidak ada pengingat} one{1 pengingat} other{{count} pengingat}}'**
  String reminderCount(int count);

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get today;

  /// No description provided for @reminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get reminders;

  /// No description provided for @items.
  ///
  /// In id, this message translates to:
  /// **'Barang'**
  String get items;

  /// No description provided for @calendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender'**
  String get calendar;

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get history;

  /// No description provided for @refreshLocalData.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang data lokal'**
  String get refreshLocalData;

  /// No description provided for @noItems.
  ///
  /// In id, this message translates to:
  /// **'Belum ada barang'**
  String get noItems;

  /// No description provided for @noHistory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengingat yang selesai'**
  String get noHistory;

  /// No description provided for @completed.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get completed;

  /// No description provided for @noReminders.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengingat yang cocok'**
  String get noReminders;

  /// No description provided for @noScheduledReminders.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengingat terjadwal'**
  String get noScheduledReminders;

  /// No description provided for @loadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data lokal'**
  String get loadFailed;

  /// No description provided for @timezoneUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Atur zona waktu yang valid untuk melihat pengingat'**
  String get timezoneUnavailable;

  /// No description provided for @searchReminders.
  ///
  /// In id, this message translates to:
  /// **'Cari pengingat atau barang'**
  String get searchReminders;

  /// No description provided for @type.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get type;

  /// No description provided for @status.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @allTypes.
  ///
  /// In id, this message translates to:
  /// **'Semua jenis'**
  String get allTypes;

  /// No description provided for @allCategories.
  ///
  /// In id, this message translates to:
  /// **'Semua kategori'**
  String get allCategories;

  /// No description provided for @timeType.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get timeType;

  /// No description provided for @usageType.
  ///
  /// In id, this message translates to:
  /// **'Pemakaian'**
  String get usageType;

  /// No description provided for @mileageType.
  ///
  /// In id, this message translates to:
  /// **'Jarak tempuh'**
  String get mileageType;

  /// No description provided for @allStatuses.
  ///
  /// In id, this message translates to:
  /// **'Semua status'**
  String get allStatuses;

  /// No description provided for @overdue.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get overdue;

  /// No description provided for @dueToday.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo hari ini'**
  String get dueToday;

  /// No description provided for @soon.
  ///
  /// In id, this message translates to:
  /// **'Segera'**
  String get soon;

  /// No description provided for @later.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get later;

  /// No description provided for @noDate.
  ///
  /// In id, this message translates to:
  /// **'Tanpa tanggal kalender'**
  String get noDate;

  /// No description provided for @unknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak diketahui'**
  String get unknown;

  /// No description provided for @activeReminders.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get activeReminders;

  /// No description provided for @archivedReminders.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif / diarsipkan'**
  String get archivedReminders;

  /// No description provided for @normal.
  ///
  /// In id, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @warning.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get warning;

  /// No description provided for @due.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo'**
  String get due;

  /// No description provided for @remainingUsage.
  ///
  /// In id, this message translates to:
  /// **'Sisa {count}'**
  String remainingUsage(int count);

  /// No description provided for @remainingDistance.
  ///
  /// In id, this message translates to:
  /// **'Sisa {distance} {unit}'**
  String remainingDistance(int distance, String unit);

  /// No description provided for @pendingSync.
  ///
  /// In id, this message translates to:
  /// **'{count} perubahan lokal menunggu sinkronisasi'**
  String pendingSync(int count);

  /// No description provided for @failedSync.
  ///
  /// In id, this message translates to:
  /// **'{count} perubahan lokal gagal disinkronkan'**
  String failedSync(int count);

  /// No description provided for @conflictedSync.
  ///
  /// In id, this message translates to:
  /// **'{count} perubahan lokal mengalami konflik'**
  String conflictedSync(int count);

  /// No description provided for @syncStatusUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Status antrean sinkronisasi lokal tidak tersedia'**
  String get syncStatusUnavailable;

  /// No description provided for @connectivityUnknown.
  ///
  /// In id, this message translates to:
  /// **'Koneksi tidak diketahui'**
  String get connectivityUnknown;

  /// No description provided for @syncNow.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan sekarang'**
  String get syncNow;

  /// No description provided for @syncFailed.
  ///
  /// In id, this message translates to:
  /// **'Sinkronisasi tidak tersedia. Perubahan lokal tetap tersimpan.'**
  String get syncFailed;

  /// No description provided for @useServerVersion.
  ///
  /// In id, this message translates to:
  /// **'Pakai versi server'**
  String get useServerVersion;

  /// No description provided for @conflictWarning.
  ///
  /// In id, this message translates to:
  /// **'Buang perubahan lokal ini dan muat data server? Tindakan ini tidak dapat dibatalkan.'**
  String get conflictWarning;

  /// No description provided for @resolveConflict.
  ///
  /// In id, this message translates to:
  /// **'Atasi konflik untuk {entity}'**
  String resolveConflict(String entity);

  /// No description provided for @addReminder.
  ///
  /// In id, this message translates to:
  /// **'Tambah Pengingat'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In id, this message translates to:
  /// **'Edit Pengingat'**
  String get editReminder;

  /// No description provided for @reminderName.
  ///
  /// In id, this message translates to:
  /// **'Nama Pengingat'**
  String get reminderName;

  /// No description provided for @reminderNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Ganti Oli Mesin'**
  String get reminderNameHint;

  /// No description provided for @reminderNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama pengingat wajib diisi'**
  String get reminderNameRequired;

  /// No description provided for @reminderNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama pengingat maksimal 150 karakter'**
  String get reminderNameTooLong;

  /// No description provided for @selectItem.
  ///
  /// In id, this message translates to:
  /// **'Pilih Barang'**
  String get selectItem;

  /// No description provided for @selectItemRequired.
  ///
  /// In id, this message translates to:
  /// **'Barang wajib dipilih'**
  String get selectItemRequired;

  /// No description provided for @engineType.
  ///
  /// In id, this message translates to:
  /// **'Jenis Pengingat'**
  String get engineType;

  /// No description provided for @intervalValue.
  ///
  /// In id, this message translates to:
  /// **'Interval'**
  String get intervalValue;

  /// No description provided for @intervalUnit.
  ///
  /// In id, this message translates to:
  /// **'Satuan Interval'**
  String get intervalUnit;

  /// No description provided for @daysUnit.
  ///
  /// In id, this message translates to:
  /// **'Hari'**
  String get daysUnit;

  /// No description provided for @weeksUnit.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get weeksUnit;

  /// No description provided for @monthsUnit.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get monthsUnit;

  /// No description provided for @yearsUnit.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get yearsUnit;

  /// No description provided for @baselineMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Perhitungan Siklus'**
  String get baselineMode;

  /// No description provided for @actualCompletion.
  ///
  /// In id, this message translates to:
  /// **'Selesai Aktual (Default)'**
  String get actualCompletion;

  /// No description provided for @strictSchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Ketat'**
  String get strictSchedule;

  /// No description provided for @targetDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Jatuh Tempo'**
  String get targetDate;

  /// No description provided for @targetTime.
  ///
  /// In id, this message translates to:
  /// **'Jam Pengingat'**
  String get targetTime;

  /// No description provided for @targetDateRequired.
  ///
  /// In id, this message translates to:
  /// **'Tanggal jatuh tempo wajib diisi'**
  String get targetDateRequired;

  /// No description provided for @targetDateInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format tanggal tidak valid'**
  String get targetDateInvalid;

  /// No description provided for @usageThreshold.
  ///
  /// In id, this message translates to:
  /// **'Ambang Batas Pemakaian'**
  String get usageThreshold;

  /// No description provided for @usageThresholdHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 100'**
  String get usageThresholdHint;

  /// No description provided for @usageThresholdRequired.
  ///
  /// In id, this message translates to:
  /// **'Ambang batas pemakaian wajib diisi'**
  String get usageThresholdRequired;

  /// No description provided for @usageThresholdPositive.
  ///
  /// In id, this message translates to:
  /// **'Ambang batas harus lebih dari 0'**
  String get usageThresholdPositive;

  /// No description provided for @currentUsage.
  ///
  /// In id, this message translates to:
  /// **'Counter Pemakaian Awal'**
  String get currentUsage;

  /// No description provided for @usageUnit.
  ///
  /// In id, this message translates to:
  /// **'Satuan Pemakaian'**
  String get usageUnit;

  /// No description provided for @usageUnitHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: kali, siklus, jam'**
  String get usageUnitHint;

  /// No description provided for @intervalKm.
  ///
  /// In id, this message translates to:
  /// **'Interval Jarak (km)'**
  String get intervalKm;

  /// No description provided for @intervalKmHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 5000'**
  String get intervalKmHint;

  /// No description provided for @intervalKmRequired.
  ///
  /// In id, this message translates to:
  /// **'Interval jarak wajib diisi'**
  String get intervalKmRequired;

  /// No description provided for @intervalKmPositive.
  ///
  /// In id, this message translates to:
  /// **'Interval jarak harus lebih dari 0'**
  String get intervalKmPositive;

  /// No description provided for @lastServiceOdometer.
  ///
  /// In id, this message translates to:
  /// **'Odometer Terakhir (km)'**
  String get lastServiceOdometer;

  /// No description provided for @lastServiceOdometerRequired.
  ///
  /// In id, this message translates to:
  /// **'Odometer terakhir wajib diisi'**
  String get lastServiceOdometerRequired;

  /// No description provided for @vehicleRequiredForMileage.
  ///
  /// In id, this message translates to:
  /// **'Hanya barang dengan odometer (kendaraan) yang dapat menggunakan pengingat jarak'**
  String get vehicleRequiredForMileage;

  /// No description provided for @schedulePreview.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau Jadwal Berikutnya'**
  String get schedulePreview;

  /// No description provided for @wearPreview.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau Keausan & Sisa'**
  String get wearPreview;

  /// No description provided for @targetOdometerPreview.
  ///
  /// In id, this message translates to:
  /// **'Target Odometer: {odo} km'**
  String targetOdometerPreview(int odo);

  /// No description provided for @savingReminder.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan pengingat...'**
  String get savingReminder;

  /// No description provided for @reminderSaved.
  ///
  /// In id, this message translates to:
  /// **'Pengingat berhasil disimpan'**
  String get reminderSaved;

  /// No description provided for @reminderSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan pengingat'**
  String get reminderSaveFailed;

  /// No description provided for @engineTypeImmutable.
  ///
  /// In id, this message translates to:
  /// **'Jenis pengingat tidak dapat diubah setelah dibuat'**
  String get engineTypeImmutable;

  /// No description provided for @reminderDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Pengingat'**
  String get reminderDetail;

  /// No description provided for @completeCycle.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan Siklus'**
  String get completeCycle;

  /// No description provided for @completionDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Selesai'**
  String get completionDate;

  /// No description provided for @performedBy.
  ///
  /// In id, this message translates to:
  /// **'Dikerjakan Oleh'**
  String get performedBy;

  /// No description provided for @performedByHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Bengkel Resmi, Mandiri'**
  String get performedByHint;

  /// No description provided for @cost.
  ///
  /// In id, this message translates to:
  /// **'Biaya'**
  String get cost;

  /// No description provided for @costHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 150000'**
  String get costHint;

  /// No description provided for @notes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In id, this message translates to:
  /// **'Catatan tambahan perawatan...'**
  String get notesHint;

  /// No description provided for @odometerAtCompletion.
  ///
  /// In id, this message translates to:
  /// **'Odometer Saat Selesai (km)'**
  String get odometerAtCompletion;

  /// No description provided for @odometerAtCompletionHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: {odo}'**
  String odometerAtCompletionHint(int odo);

  /// No description provided for @confirmComplete.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Selesai'**
  String get confirmComplete;

  /// No description provided for @completingCycle.
  ///
  /// In id, this message translates to:
  /// **'Menyelesaikan siklus...'**
  String get completingCycle;

  /// No description provided for @cycleCompleted.
  ///
  /// In id, this message translates to:
  /// **'Siklus perawatan berhasil diselesaikan'**
  String get cycleCompleted;

  /// No description provided for @cycleCompleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyelesaikan siklus'**
  String get cycleCompleteFailed;

  /// No description provided for @plusOneUsage.
  ///
  /// In id, this message translates to:
  /// **'+1 Pemakaian'**
  String get plusOneUsage;

  /// No description provided for @usageIncremented.
  ///
  /// In id, this message translates to:
  /// **'Pemakaian bertambah (+1)'**
  String get usageIncremented;

  /// No description provided for @usageIncrementFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menambah pemakaian'**
  String get usageIncrementFailed;

  /// No description provided for @updateOdometer.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Odometer'**
  String get updateOdometer;

  /// No description provided for @currentOdometer.
  ///
  /// In id, this message translates to:
  /// **'Odometer Saat Ini'**
  String get currentOdometer;

  /// No description provided for @newOdometer.
  ///
  /// In id, this message translates to:
  /// **'Odometer Baru (km)'**
  String get newOdometer;

  /// No description provided for @newOdometerHint.
  ///
  /// In id, this message translates to:
  /// **'Harus lebih besar dari odometer saat ini'**
  String get newOdometerHint;

  /// No description provided for @newOdometerRequired.
  ///
  /// In id, this message translates to:
  /// **'Odometer baru wajib diisi'**
  String get newOdometerRequired;

  /// No description provided for @newOdometerInvalid.
  ///
  /// In id, this message translates to:
  /// **'Odometer baru harus lebih besar atau sama dengan odometer saat ini'**
  String get newOdometerInvalid;

  /// No description provided for @odometerUpdated.
  ///
  /// In id, this message translates to:
  /// **'Odometer berhasil diperbarui'**
  String get odometerUpdated;

  /// No description provided for @odometerUpdateFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memperbarui odometer'**
  String get odometerUpdateFailed;

  /// No description provided for @serviceHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Servis / Siklus'**
  String get serviceHistory;

  /// No description provided for @noLogsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat penyelesaian untuk pengingat ini'**
  String get noLogsYet;

  /// No description provided for @progressSection.
  ///
  /// In id, this message translates to:
  /// **'Progres & Target'**
  String get progressSection;

  /// No description provided for @calculationBasis.
  ///
  /// In id, this message translates to:
  /// **'Basis Perhitungan'**
  String get calculationBasis;

  /// No description provided for @completedOn.
  ///
  /// In id, this message translates to:
  /// **'Selesai pada {date}'**
  String completedOn(String date);

  /// No description provided for @performedByLabel.
  ///
  /// In id, this message translates to:
  /// **'Oleh: {name}'**
  String performedByLabel(String name);

  /// No description provided for @costLabel.
  ///
  /// In id, this message translates to:
  /// **'Biaya: {cost}'**
  String costLabel(String cost);

  /// No description provided for @odometerLabel.
  ///
  /// In id, this message translates to:
  /// **'Odometer: {odo} km'**
  String odometerLabel(int odo);

  /// No description provided for @addItem.
  ///
  /// In id, this message translates to:
  /// **'Tambah Barang'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In id, this message translates to:
  /// **'Edit Barang'**
  String get editItem;

  /// No description provided for @itemDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Barang'**
  String get itemDetail;

  /// No description provided for @itemName.
  ///
  /// In id, this message translates to:
  /// **'Nama Barang'**
  String get itemName;

  /// No description provided for @itemNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Honda Vario, Mesin Cuci Samsung'**
  String get itemNameHint;

  /// No description provided for @itemNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama barang wajib diisi'**
  String get itemNameRequired;

  /// No description provided for @category.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @categoryVehicle.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan'**
  String get categoryVehicle;

  /// No description provided for @categoryAppliance.
  ///
  /// In id, this message translates to:
  /// **'Elektronik / Mesin'**
  String get categoryAppliance;

  /// No description provided for @categoryFurniture.
  ///
  /// In id, this message translates to:
  /// **'Perabot'**
  String get categoryFurniture;

  /// No description provided for @categoryFacility.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas'**
  String get categoryFacility;

  /// No description provided for @categoryOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get categoryOther;

  /// No description provided for @brand.
  ///
  /// In id, this message translates to:
  /// **'Merek'**
  String get brand;

  /// No description provided for @brandHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Honda, Samsung'**
  String get brandHint;

  /// No description provided for @modelNumber.
  ///
  /// In id, this message translates to:
  /// **'Model / Tipe'**
  String get modelNumber;

  /// No description provided for @modelNumberHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Vario 160, WW80T'**
  String get modelNumberHint;

  /// No description provided for @serialOrPlate.
  ///
  /// In id, this message translates to:
  /// **'Nomor Plat / Seri'**
  String get serialOrPlate;

  /// No description provided for @serialOrPlateHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: B 1234 XYZ, SN-987654'**
  String get serialOrPlateHint;

  /// No description provided for @purchaseDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Pembelian'**
  String get purchaseDate;

  /// No description provided for @purchaseDateHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal pembelian'**
  String get purchaseDateHint;

  /// No description provided for @hasOdometer.
  ///
  /// In id, this message translates to:
  /// **'Memiliki Odometer'**
  String get hasOdometer;

  /// No description provided for @hasOdometerDesc.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan jika barang memiliki pencatat jarak tempuh (kilometer/mil)'**
  String get hasOdometerDesc;

  /// No description provided for @initialOdometer.
  ///
  /// In id, this message translates to:
  /// **'Odometer Awal (km)'**
  String get initialOdometer;

  /// No description provided for @initialOdometerHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 15000'**
  String get initialOdometerHint;

  /// No description provided for @itemSaved.
  ///
  /// In id, this message translates to:
  /// **'Barang berhasil disimpan'**
  String get itemSaved;

  /// No description provided for @itemSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan barang'**
  String get itemSaveFailed;

  /// No description provided for @archiveItem.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan Barang'**
  String get archiveItem;

  /// No description provided for @unarchiveItem.
  ///
  /// In id, this message translates to:
  /// **'Buka Arsip Barang'**
  String get unarchiveItem;

  /// No description provided for @confirmArchiveItem.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan barang ini? Pengingat terkait akan dinonaktifkan sementara dari jadwal utama.'**
  String get confirmArchiveItem;

  /// No description provided for @confirmUnarchiveItem.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan kembali barang ini?'**
  String get confirmUnarchiveItem;

  /// No description provided for @itemArchived.
  ///
  /// In id, this message translates to:
  /// **'Barang berhasil diarsipkan'**
  String get itemArchived;

  /// No description provided for @itemUnarchived.
  ///
  /// In id, this message translates to:
  /// **'Barang berhasil diaktifkan kembali'**
  String get itemUnarchived;

  /// No description provided for @deleteItem.
  ///
  /// In id, this message translates to:
  /// **'Hapus Barang'**
  String get deleteItem;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In id, this message translates to:
  /// **'Hapus barang ini secara permanen? Pengingat terkait juga akan dihapus. Riwayat servis tetap tersimpan.'**
  String get confirmDeleteItem;

  /// No description provided for @itemDeleted.
  ///
  /// In id, this message translates to:
  /// **'Barang berhasil dihapus'**
  String get itemDeleted;

  /// No description provided for @itemDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus barang'**
  String get itemDeleteFailed;

  /// No description provided for @associatedReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Terkait ({count})'**
  String associatedReminders(int count);

  /// No description provided for @noAssociatedReminders.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengingat untuk barang ini'**
  String get noAssociatedReminders;

  /// No description provided for @searchItems.
  ///
  /// In id, this message translates to:
  /// **'Cari barang...'**
  String get searchItems;

  /// No description provided for @activeItems.
  ///
  /// In id, this message translates to:
  /// **'Barang Aktif'**
  String get activeItems;

  /// No description provided for @archivedItems.
  ///
  /// In id, this message translates to:
  /// **'Barang Diarsipkan'**
  String get archivedItems;

  /// No description provided for @odometerCorrectionConfirm.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Koreksi Odometer'**
  String get odometerCorrectionConfirm;

  /// No description provided for @odometerCorrectionDesc.
  ///
  /// In id, this message translates to:
  /// **'Angka odometer ({newOdo} km) lebih rendah dari catatan sebelumnya ({currentOdo} km). Lanjutkan sebagai koreksi kesalahan?'**
  String odometerCorrectionDesc(int newOdo, int currentOdo);

  /// No description provided for @confirmCorrection.
  ///
  /// In id, this message translates to:
  /// **'Ya, Koreksi'**
  String get confirmCorrection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

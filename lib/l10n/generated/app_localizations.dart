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
  /// **'Sisa {distance} km'**
  String remainingDistance(int distance);

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

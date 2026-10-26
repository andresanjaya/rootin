// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get logout => 'Sign out';

  @override
  String get settings => 'Settings';

  @override
  String get offlineDescription => 'Offline-first maintenance reminders';

  @override
  String signedInAs(String email) {
    return 'Signed in as: $email';
  }

  @override
  String get loginDescription => 'Sign in to manage your maintenance reminders';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordShort => 'Password must be at least 6 characters';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPasswordQuestion => 'Forgot password?';

  @override
  String get login => 'Sign in';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Sign up';

  @override
  String get loginFailed => 'Could not sign in. Please try again.';

  @override
  String get registerFailed => 'Could not sign up. Please try again.';

  @override
  String get registerSuccess =>
      'Registration successful! Check your email or sign in.';

  @override
  String get registerAccount => 'Create account';

  @override
  String get createAccount => 'Create a Rootin account';

  @override
  String get registerDescription =>
      'Keep track of maintenance for your belongings and vehicles';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmRequired => 'Please confirm your password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get resetLinkFailed => 'Could not send reset link. Please try again.';

  @override
  String get linkSent => 'Link sent';

  @override
  String linkSentDescription(String email) {
    return 'We sent password recovery instructions to $email. Check your inbox or spam folder.';
  }

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetDescription =>
      'Enter your registered email to receive a password reset link';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get cancel => 'Cancel';

  @override
  String get passwordUpdated => 'Password updated!';

  @override
  String get passwordUpdateFailed =>
      'Could not update your password. Please try again.';

  @override
  String get newPassword => 'New password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get newPasswordDescription =>
      'Enter a new password (at least 6 characters)';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get savePassword => 'Save password';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'Device language';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get english => 'English';

  @override
  String get distanceUnit => 'Distance unit';

  @override
  String get kilometers => 'Kilometers (km)';

  @override
  String get miles => 'Miles (mi)';

  @override
  String get deviceTimezone => 'Use device time zone';

  @override
  String get timezone => 'IANA time zone';

  @override
  String get timezoneHint => 'Example: America/New_York';

  @override
  String get invalidTimezone => 'Unknown IANA time zone';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get localOnly =>
      'These preferences are stored on this device. Notification scheduling is not available yet.';

  @override
  String get save => 'Save';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsFailed => 'Could not save settings';

  @override
  String reminderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders',
      one: '1 reminder',
      zero: 'No reminders',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get reminders => 'Reminders';

  @override
  String get items => 'Items';

  @override
  String get calendar => 'Calendar';

  @override
  String get history => 'History';

  @override
  String get noItems => 'No items yet';

  @override
  String get noHistory => 'No completed reminders yet';

  @override
  String get completed => 'Completed';

  @override
  String get noReminders => 'No matching reminders';

  @override
  String get noScheduledReminders => 'No scheduled reminders';

  @override
  String get loadFailed => 'Could not load local data';

  @override
  String get timezoneUnavailable => 'Set a valid time zone to view reminders';

  @override
  String get searchReminders => 'Search reminders or items';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get allTypes => 'All types';

  @override
  String get timeType => 'Time';

  @override
  String get usageType => 'Usage';

  @override
  String get mileageType => 'Mileage';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get overdue => 'Overdue';

  @override
  String get dueToday => 'Due today';

  @override
  String get soon => 'Due soon';

  @override
  String get later => 'Later';

  @override
  String get noDate => 'No calendar date';

  @override
  String get unknown => 'Unknown';

  @override
  String pendingSync(int count) {
    return '$count pending changes';
  }
}

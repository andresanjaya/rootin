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
  String get refreshLocalData => 'Refresh local data';

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
  String get allCategories => 'All categories';

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
  String get activeReminders => 'Active';

  @override
  String get archivedReminders => 'Inactive / archived';

  @override
  String get normal => 'Normal';

  @override
  String get warning => 'Warning';

  @override
  String get due => 'Due';

  @override
  String remainingUsage(int count) {
    return '$count remaining';
  }

  @override
  String remainingDistance(int distance, String unit) {
    return '$distance $unit remaining';
  }

  @override
  String pendingSync(int count) {
    return '$count pending local changes';
  }

  @override
  String failedSync(int count) {
    return '$count local changes failed to sync';
  }

  @override
  String conflictedSync(int count) {
    return '$count local changes have conflicts';
  }

  @override
  String get syncStatusUnavailable => 'Local sync queue status unavailable';

  @override
  String get connectivityUnknown => 'Connectivity unknown';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncFailed => 'Sync unavailable. Local changes remain saved.';

  @override
  String get useServerVersion => 'Use server version';

  @override
  String get conflictWarning =>
      'Discard this local change and load server data? This cannot be undone.';

  @override
  String resolveConflict(String entity) {
    return 'Resolve conflict for $entity';
  }

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get reminderName => 'Reminder Name';

  @override
  String get reminderNameHint => 'e.g. Engine Oil Change';

  @override
  String get reminderNameRequired => 'Reminder name is required';

  @override
  String get reminderNameTooLong =>
      'Reminder name cannot exceed 150 characters';

  @override
  String get selectItem => 'Select Item';

  @override
  String get selectItemRequired => 'Item is required';

  @override
  String get engineType => 'Reminder Type';

  @override
  String get intervalValue => 'Interval';

  @override
  String get intervalUnit => 'Interval Unit';

  @override
  String get daysUnit => 'Days';

  @override
  String get weeksUnit => 'Weeks';

  @override
  String get monthsUnit => 'Months';

  @override
  String get yearsUnit => 'Years';

  @override
  String get baselineMode => 'Recurrence Baseline';

  @override
  String get actualCompletion => 'Actual Completion (Default)';

  @override
  String get strictSchedule => 'Strict Schedule';

  @override
  String get targetDate => 'Due Date';

  @override
  String get targetTime => 'Reminder Time';

  @override
  String get targetDateRequired => 'Due date is required';

  @override
  String get targetDateInvalid => 'Invalid date format';

  @override
  String get usageThreshold => 'Usage Threshold';

  @override
  String get usageThresholdHint => 'e.g. 100';

  @override
  String get usageThresholdRequired => 'Usage threshold is required';

  @override
  String get usageThresholdPositive => 'Threshold must be greater than 0';

  @override
  String get currentUsage => 'Initial Usage Counter';

  @override
  String get usageUnit => 'Usage Unit';

  @override
  String get usageUnitHint => 'e.g. times, cycles, hours';

  @override
  String get intervalKm => 'Distance Interval (km)';

  @override
  String get intervalKmHint => 'e.g. 5000';

  @override
  String get intervalKmRequired => 'Distance interval is required';

  @override
  String get intervalKmPositive => 'Distance interval must be greater than 0';

  @override
  String get lastServiceOdometer => 'Last Service Odometer (km)';

  @override
  String get lastServiceOdometerRequired => 'Last service odometer is required';

  @override
  String get vehicleRequiredForMileage =>
      'Only items with an odometer (vehicles) can use mileage reminders';

  @override
  String get schedulePreview => 'Upcoming Schedule Preview';

  @override
  String get wearPreview => 'Wear & Remaining Preview';

  @override
  String targetOdometerPreview(int odo) {
    return 'Target Odometer: $odo km';
  }

  @override
  String get savingReminder => 'Saving reminder...';

  @override
  String get reminderSaved => 'Reminder saved successfully';

  @override
  String get reminderSaveFailed => 'Could not save reminder';

  @override
  String get engineTypeImmutable =>
      'Reminder type cannot be changed after creation';

  @override
  String get reminderDetail => 'Reminder Details';

  @override
  String get completeCycle => 'Complete Cycle';

  @override
  String get completionDate => 'Completion Date';

  @override
  String get performedBy => 'Performed By';

  @override
  String get performedByHint => 'e.g. Official Workshop, Self';

  @override
  String get cost => 'Cost';

  @override
  String get costHint => 'e.g. 150000';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Maintenance notes...';

  @override
  String get odometerAtCompletion => 'Odometer at Completion (km)';

  @override
  String odometerAtCompletionHint(int odo) {
    return 'e.g. $odo';
  }

  @override
  String get confirmComplete => 'Confirm Completion';

  @override
  String get completingCycle => 'Completing cycle...';

  @override
  String get cycleCompleted => 'Maintenance cycle completed successfully';

  @override
  String get cycleCompleteFailed => 'Failed to complete cycle';

  @override
  String get plusOneUsage => '+1 Usage';

  @override
  String get usageIncremented => 'Usage incremented (+1)';

  @override
  String get usageIncrementFailed => 'Failed to increment usage';

  @override
  String get updateOdometer => 'Update Odometer';

  @override
  String get currentOdometer => 'Current Odometer';

  @override
  String get newOdometer => 'New Odometer (km)';

  @override
  String get newOdometerHint => 'Must be greater than current odometer';

  @override
  String get newOdometerRequired => 'New odometer is required';

  @override
  String get newOdometerInvalid =>
      'New odometer must be greater than or equal to current odometer';

  @override
  String get odometerUpdated => 'Odometer updated successfully';

  @override
  String get odometerUpdateFailed => 'Failed to update odometer';

  @override
  String get serviceHistory => 'Service & Cycle History';

  @override
  String get noLogsYet => 'No completion history for this reminder yet';

  @override
  String get progressSection => 'Progress & Target';

  @override
  String get calculationBasis => 'Calculation Basis';

  @override
  String completedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String performedByLabel(String name) {
    return 'By: $name';
  }

  @override
  String costLabel(String cost) {
    return 'Cost: $cost';
  }

  @override
  String odometerLabel(int odo) {
    return 'Odometer: $odo km';
  }
}

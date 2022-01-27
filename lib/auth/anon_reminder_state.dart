part of 'anon_reminder_cubit.dart';

@immutable
abstract class AnonReminderState {}

class AnonReminderInProgress extends AnonReminderState {}

class AnonReminderInitialized extends AnonReminderState {
  final bool showWarning;

  AnonReminderInitialized(this.showWarning);
}

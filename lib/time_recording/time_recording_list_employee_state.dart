part of 'time_recording_list_employee_cubit.dart';

@immutable
abstract class TimeRecordingListEmployeeState {}

class TimeRecordingListEmployeeInProgress
    extends TimeRecordingListEmployeeState {}

class TimeRecordingListEmployeeInitialized
    extends TimeRecordingListEmployeeState {
  final List<MonthlySummary> monthlySummaries;

  TimeRecordingListEmployeeInitialized(this.monthlySummaries);
}

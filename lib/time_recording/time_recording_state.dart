part of 'time_recording_cubit.dart';

@immutable
abstract class TimeRecordingState {}

class TimeRecordingInProgress extends TimeRecordingState {}

class TimeRecordingDone extends TimeRecordingState {}

class TimeRecordingInitialized extends TimeRecordingState {
  final GlobalKey<FormBuilderState> formKey;
  final DateTime fromDate;
  final TimeOfDay from;
  final TimeOfDay? to;
  final DynamicMap formValues;
  final String workingTime;
  final String? errorMessage;

  TimeRecordingInitialized(
      {required this.formKey,
      required this.fromDate,
      required this.from,
      required this.to,
      required this.formValues,
      required this.workingTime,
      required this.errorMessage});
}

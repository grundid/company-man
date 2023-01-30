part of 'time_recording_cubit.dart';

@immutable
abstract class TimeRecordingState {}

class TimeRecordingInProgress extends TimeRecordingState {}

class TimeRecordingDone extends TimeRecordingState {}

class TimeRecordingInitialized extends TimeRecordingState {
  final GlobalKey<FormBuilderState> formKey;
  final DynamicMap formValues;
  final String? errorMessage;

  TimeRecordingInitialized(
      {required this.formKey,
      required this.formValues,
      required this.errorMessage});
}

part of 'time_recording_list_cubit.dart';

@immutable
abstract class TimeRecordingListState {}

class TimeRecordingListInProgress extends TimeRecordingListState {}

class TimeRecordingListInitialized extends TimeRecordingListState {
  final List<GroupedTimeRecording> groups;

  TimeRecordingListInitialized(this.groups);
}

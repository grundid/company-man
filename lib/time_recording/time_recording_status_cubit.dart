import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class TimeRecordingStatusInitizalied extends Initialized {
  final String workingTime;
  final String pauseTime;
  final DateTime startingDateTime;
  final bool canFinish;

  TimeRecordingStatusInitizalied(
      this.workingTime, this.pauseTime, this.startingDateTime, this.canFinish);
}

class TimeRecordingStatusCubit extends Cubit<AppState> {
  TimeRecordingStatusCubit() : super(InProgress());

  update(WorkTimeState workTimeState) {
    if (workTimeState.to != null) {
      Duration duration = workTimeState.workDuration!;
      Duration pauseDuration = workTimeState.pauses.fold(
          Duration(minutes: 0), (previous, pause) => previous + pause.duration);

      TimeOfDay workingTime = fromDuration(duration - pauseDuration);
      TimeOfDay pauseTime = fromDuration(pauseDuration);

      emit(TimeRecordingStatusInitizalied(workingTime.getFormatted(),
          pauseTime.getFormatted(), workTimeState.from, true));
    } else {
      emit(TimeRecordingStatusInitizalied("-", "-", workTimeState.from, false));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/reusable/state.dart';
import 'package:smallbusiness/time_recording/utils.dart';

class TimeRecordingStatusInitizalied extends Initialized {
  final String workingLabel;
  final String? warning;

  TimeRecordingStatusInitizalied(this.workingLabel, this.warning);
}

class TimeRecordingStatusCubit extends Cubit<AppState> {
  TimeRecordingStatusCubit() : super(InProgress());

  update(WorkTimeState workTimeState) {
    if (workTimeState.to != null) {
      TimeOfDay workingTime = fromDuration(workTimeState.workDuration!);
      emit(TimeRecordingStatusInitizalied(
          "Arbeitszeit: ${workingTime.getFormatted()}", null));
    }
  }
}

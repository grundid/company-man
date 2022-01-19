import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/time_recording/models.dart';

part 'time_recording_list_state.dart';

class TimeRecordingListCubit extends Cubit<TimeRecordingListState> {
  final SbmContext sbmContext;
  TimeRecordingListCubit(this.sbmContext)
      : super(TimeRecordingListInProgress()) {
    _init();
  }

  _init() async {
    final querySnapshot = await sbmContext.queryBuilder
        .timeRecordingForEmployeeRef(
            companyRef: sbmContext.companyRef!,
            employeeRef: sbmContext.employeeRef!)
        .get();

    List<TimeRecording> timeRecordings = querySnapshot.docs
        .map((e) => TimeRecording.fromJson(e.data()))
        .toList();
    timeRecordings.sort((t1, t2) => t2.from.compareTo(t1.from));
    emit(TimeRecordingListInitialized(timeRecordings));
  }
}
